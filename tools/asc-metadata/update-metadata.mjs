#!/usr/bin/env node
/**
 * Upload App Store metadata from:
 *   listings.mjs    → name, subtitle, description, keywords, promotionalText
 *   whats-new.json  → whatsNew
 *
 * Usage:
 *   node update-metadata.mjs --dry-run
 *   node update-metadata.mjs
 *   node update-metadata.mjs --version 1.0.3
 *   node update-metadata.mjs --only whatsNew,promotionalText
 *   node update-metadata.mjs --only name,subtitle
 */

import path from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  EDITABLE_STATES,
  ascFetch,
  loadListings,
  readWhatsNew,
  requireAscEnv,
  resolveAppId,
  resolveAppInfo,
  resolveIosVersion,
} from './lib/asc.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const ALL_FIELDS = [
  'name',
  'subtitle',
  'description',
  'keywords',
  'promotionalText',
  'whatsNew',
];

const APP_INFO_FIELDS = new Set(['name', 'subtitle']);
const VERSION_FIELDS = new Set([
  'description',
  'keywords',
  'promotionalText',
  'whatsNew',
]);

function parseArgs(argv) {
  const args = {
    dryRun: false,
    version: null,
    listingsFile: path.join(__dirname, 'listings.mjs'),
    whatsNewFile: path.join(__dirname, 'whats-new.json'),
    only: new Set(ALL_FIELDS),
    help: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--dry-run') args.dryRun = true;
    else if (a === '--version') args.version = argv[++i];
    else if (a === '--listings') args.listingsFile = path.resolve(argv[++i]);
    else if (a === '--whats-new') args.whatsNewFile = path.resolve(argv[++i]);
    else if (a === '--only') {
      args.only = new Set(
        argv[++i]
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean),
      );
    } else if (a === '--help' || a === '-h') args.help = true;
  }
  return args;
}

function pickAttributes(source, keys) {
  const out = {};
  for (const key of keys) {
    const value = source[key];
    if (value != null && String(value).trim() !== '') {
      out[key] = String(value).trim();
    }
  }
  return out;
}

/** Drop attributes that already match ASC so we avoid no-op / locked PATCH. */
function diffAttributes(desired, currentAttrs = {}) {
  const out = {};
  for (const [key, value] of Object.entries(desired)) {
    const current = currentAttrs[key];
    if (current == null || String(current).trim() !== value) {
      out[key] = value;
    }
  }
  return out;
}

function isInvalidStateError(err) {
  const msg = String(err?.message ?? err);
  return (
    msg.includes('INVALID_STATE') ||
    msg.includes('can not be modified in the current state')
  );
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log(`Usage: node update-metadata.mjs [options]

Options:
  --dry-run                 Preview only
  --version 1.0.3           Target marketing version
  --only a,b,c              Subset of: ${ALL_FIELDS.join(',')}
  --listings FILE           Default: ./listings.mjs (.mjs with \`...\` multiline, or .json)
  --whats-new FILE          Default: ./whats-new.json
`);
    process.exit(0);
  }

  for (const field of args.only) {
    if (!ALL_FIELDS.includes(field)) {
      throw new Error(`Unknown field in --only: ${field}`);
    }
  }

  const { token, appId: appIdEnv, bundleId } = requireAscEnv(__dirname);
  const listings = await loadListings(args.listingsFile);
  const whatsNewByLocale = readWhatsNew(args.whatsNewFile);

  const locales = new Set([...listings.keys(), ...whatsNewByLocale.keys()]);
  const appId = await resolveAppId(token, { appId: appIdEnv, bundleId });

  const wantAppInfo = [...args.only].some((f) => APP_INFO_FIELDS.has(f));
  const wantVersion = [...args.only].some((f) => VERSION_FIELDS.has(f));

  let appInfoLocByLocale = new Map();
  if (wantAppInfo) {
    const appInfo = await resolveAppInfo(token, appId);
    const locs = await ascFetch(
      token,
      `/appInfos/${appInfo.id}/appInfoLocalizations`,
    );
    appInfoLocByLocale = new Map(
      (locs.data ?? []).map((loc) => [loc.attributes?.locale, loc]),
    );
    console.log(
      `App Info: ${appInfo.id} (${appInfo.attributes?.appStoreState ?? '?'})`,
    );
  }

  let version = null;
  let versionLocByLocale = new Map();
  if (wantVersion) {
    version = await resolveIosVersion(token, appId, args.version);
    const state = version.attributes?.appStoreState;
    console.log(
      `Version: ${version.attributes?.versionString} (${state}) id=${version.id}`,
    );
    if (!EDITABLE_STATES.has(state)) {
      console.warn(
        `Warning: version state is ${state}. Some fields may reject updates.`,
      );
    }
    const locs = await ascFetch(
      token,
      `/appStoreVersions/${version.id}/appStoreVersionLocalizations`,
    );
    versionLocByLocale = new Map(
      (locs.data ?? []).map((loc) => [loc.attributes?.locale, loc]),
    );
  }

  let updated = 0;
  let skipped = 0;

  for (const locale of [...locales].sort()) {
    const listing = listings.get(locale) ?? {};
    const merged = {
      ...listing,
      whatsNew: whatsNewByLocale.get(locale) ?? null,
    };

    console.log(`\n=== ${locale} ===`);

    if (wantAppInfo) {
      const loc = appInfoLocByLocale.get(locale);
      if (!loc) {
        console.warn(`⚠ No appInfoLocalization for ${locale}`);
        skipped++;
      } else {
        const desired = pickAttributes(merged, [
          ...args.only,
        ].filter((f) => APP_INFO_FIELDS.has(f)));
        const attributes = diffAttributes(desired, loc.attributes);
        if (Object.keys(attributes).length === 0) {
          console.log('(app info) unchanged');
        } else {
          console.log('(app info)', Object.keys(attributes).join(', '));
          if (args.dryRun) {
            for (const [k, v] of Object.entries(attributes)) {
              const preview = v.length > 80 ? `${v.slice(0, 80)}…` : v;
              console.log(`  ${k}: ${preview}`);
            }
          } else {
            try {
              await ascFetch(token, `/appInfoLocalizations/${loc.id}`, {
                method: 'PATCH',
                body: {
                  data: {
                    type: 'appInfoLocalizations',
                    id: loc.id,
                    attributes,
                  },
                },
              });
              console.log('✓ app info updated');
              updated++;
            } catch (err) {
              if (isInvalidStateError(err)) {
                console.warn(
                  `⚠ skipped name/subtitle (${locale}): locked in current App Info state`,
                );
                skipped++;
              } else {
                throw err;
              }
            }
          }
        }
      }
    }

    if (wantVersion) {
      const loc = versionLocByLocale.get(locale);
      if (!loc) {
        console.warn(`⚠ No appStoreVersionLocalization for ${locale}`);
        skipped++;
      } else {
        const attributes = pickAttributes(merged, [
          ...args.only,
        ].filter((f) => VERSION_FIELDS.has(f)));
        if (Object.keys(attributes).length === 0) {
          console.log('(version) nothing to update');
        } else {
          console.log('(version)', Object.keys(attributes).join(', '));
          if (args.dryRun) {
            for (const [k, v] of Object.entries(attributes)) {
              const preview = v.length > 80 ? `${v.slice(0, 80)}…` : v;
              console.log(`  ${k}: ${preview}`);
            }
          } else {
            await ascFetch(token, `/appStoreVersionLocalizations/${loc.id}`, {
              method: 'PATCH',
              body: {
                data: {
                  type: 'appStoreVersionLocalizations',
                  id: loc.id,
                  attributes,
                },
              },
            });
            console.log('✓ version localization updated');
            updated++;
          }
        }
      }
    }
  }

  console.log(
    `\nDone. updated=${updated} skipped=${skipped} dryRun=${args.dryRun}`,
  );
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
