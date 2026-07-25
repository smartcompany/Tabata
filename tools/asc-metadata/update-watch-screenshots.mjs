#!/usr/bin/env node
/**
 * Upload per-locale Apple Watch screenshots (APP_WATCH_ULTRA, 422×514).
 *
 * Expects:
 *   screenshots/watch/ko/*.png
 *   screenshots/watch/en-US/*.png
 *   screenshots/watch/ja/*.png
 *   screenshots/watch/zh-Hans/*.png
 *
 * Usage:
 *   node update-watch-screenshots.mjs
 *   node update-watch-screenshots.mjs --dir ./screenshots/watch
 *   node update-watch-screenshots.mjs --dry-run
 */

import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  EDITABLE_STATES,
  ascFetch,
  requireAscEnv,
  resolveAppId,
  resolveIosVersion,
} from './lib/asc.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DISPLAY_TYPE = 'APP_WATCH_ULTRA';

function parseArgs(argv) {
  const args = {
    dryRun: false,
    dir: path.join(__dirname, 'screenshots', 'watch'),
    version: null,
    help: false,
  };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--dry-run') args.dryRun = true;
    else if (a === '--dir') args.dir = path.resolve(argv[++i]);
    else if (a === '--version') args.version = argv[++i];
    else if (a === '--help' || a === '-h') args.help = true;
  }
  return args;
}

function listPngs(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((f) => /\.png$/i.test(f))
    .sort()
    .map((f) => path.join(dir, f));
}

function discoverLocaleDirs(root) {
  const map = new Map();
  if (!fs.existsSync(root)) {
    throw new Error(`Screenshot dir not found: ${root}`);
  }

  // Prefer locale subfolders (ko, en-US, …)
  for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const dir = path.join(root, entry.name);
    const files = listPngs(dir);
    if (files.length) map.set(entry.name, files);
  }

  // Fallback: flat folder → apply same files to every ASC locale later
  if (map.size === 0) {
    const flat = listPngs(root);
    if (flat.length) map.set('*', flat);
  }
  if (map.size === 0) {
    throw new Error(`No .png files under ${root}`);
  }
  return map;
}

async function listLocalizations(token, versionId) {
  const json = await ascFetch(
    token,
    `/appStoreVersions/${versionId}/appStoreVersionLocalizations`,
  );
  return json.data ?? [];
}

async function getOrCreateWatchSet(token, localizationId, { dryRun }) {
  const existing = await ascFetch(
    token,
    `/appStoreVersionLocalizations/${localizationId}/appScreenshotSets`,
  );
  const sets = existing.data ?? [];
  const found = sets.find(
    (s) => s.attributes?.screenshotDisplayType === DISPLAY_TYPE,
  );
  if (found) return found;

  if (dryRun) {
    console.log(`  (dry-run) would create ${DISPLAY_TYPE} set`);
    return { id: 'dry-run', attributes: { screenshotDisplayType: DISPLAY_TYPE } };
  }

  const created = await ascFetch(token, '/appScreenshotSets', {
    method: 'POST',
    body: {
      data: {
        type: 'appScreenshotSets',
        attributes: { screenshotDisplayType: DISPLAY_TYPE },
        relationships: {
          appStoreVersionLocalization: {
            data: {
              type: 'appStoreVersionLocalizations',
              id: localizationId,
            },
          },
        },
      },
    },
  });
  return created.data;
}

async function listScreenshots(token, setId) {
  if (setId === 'dry-run') return [];
  const json = await ascFetch(token, `/appScreenshotSets/${setId}/appScreenshots`);
  return json.data ?? [];
}

async function deleteScreenshot(token, id) {
  await ascFetch(token, `/appScreenshots/${id}`, { method: 'DELETE' });
}

async function uploadBinary(uploadOperations, fileBuffer) {
  const sorted = [...uploadOperations].sort(
    (a, b) => (a.offset ?? 0) - (b.offset ?? 0),
  );
  for (const op of sorted) {
    const offset = op.offset ?? 0;
    const length = op.length ?? fileBuffer.length;
    const chunk = fileBuffer.subarray(offset, offset + length);
    const headers = {};
    for (const h of op.requestHeaders ?? []) {
      headers[h.name] = h.value;
    }
    const res = await fetch(op.url, {
      method: op.method || 'PUT',
      headers,
      body: chunk,
    });
    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Upload failed ${res.status}: ${text}`);
    }
  }
}

async function createAndUploadScreenshot(token, setId, filePath, { dryRun }) {
  const fileName = path.basename(filePath);
  const fileBuffer = fs.readFileSync(filePath);
  const fileSize = fileBuffer.length;
  const checksum = crypto.createHash('md5').update(fileBuffer).digest('hex');

  if (dryRun) {
    console.log(`  (dry-run) upload ${fileName} (${fileSize} bytes)`);
    return;
  }

  const created = await ascFetch(token, '/appScreenshots', {
    method: 'POST',
    body: {
      data: {
        type: 'appScreenshots',
        attributes: { fileSize, fileName },
        relationships: {
          appScreenshotSet: {
            data: { type: 'appScreenshotSets', id: setId },
          },
        },
      },
    },
  });

  const screenshot = created.data;
  const ops = screenshot.attributes?.uploadOperations;
  if (!ops?.length) {
    throw new Error(`No uploadOperations for ${fileName}`);
  }

  await uploadBinary(ops, fileBuffer);

  await ascFetch(token, `/appScreenshots/${screenshot.id}`, {
    method: 'PATCH',
    body: {
      data: {
        type: 'appScreenshots',
        id: screenshot.id,
        attributes: {
          uploaded: true,
          sourceFileChecksum: checksum,
        },
      },
    },
  });

  console.log(`  ✓ ${fileName}`);
}

function filesForLocale(localeDirs, locale) {
  if (localeDirs.has(locale)) return localeDirs.get(locale);
  if (localeDirs.has('*')) return localeDirs.get('*');
  // Common aliases
  if (locale === 'en-US' && localeDirs.has('en')) return localeDirs.get('en');
  if (locale === 'zh-Hans' && localeDirs.has('zh')) return localeDirs.get('zh');
  return null;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log(
      `Usage: node update-watch-screenshots.mjs [--dir DIR] [--version X] [--dry-run]`,
    );
    process.exit(0);
  }

  const localeDirs = discoverLocaleDirs(args.dir);
  console.log('Locale folders:');
  for (const [loc, files] of localeDirs) {
    console.log(`  ${loc}: ${files.map((f) => path.basename(f)).join(', ')}`);
  }

  const { token, appId: envAppId, bundleId } = requireAscEnv(__dirname);
  const appId = await resolveAppId(token, { appId: envAppId, bundleId });
  const version = await resolveIosVersion(token, appId, args.version);
  const state = version.attributes?.appStoreState;
  console.log(
    `\nVersion: ${version.attributes?.versionString} (${state}) id=${version.id}`,
  );
  if (!EDITABLE_STATES.has(state)) {
    console.warn(
      `Warning: version state ${state} may not allow screenshot edits.`,
    );
  }

  const localizations = await listLocalizations(token, version.id);
  console.log(
    `Locales: ${localizations.map((l) => l.attributes?.locale).join(', ')}\n`,
  );

  for (const loc of localizations) {
    const locale = loc.attributes?.locale ?? loc.id;
    const files = filesForLocale(localeDirs, locale);
    if (!files?.length) {
      console.log(`=== ${locale} === SKIP (no screenshots)`);
      continue;
    }

    console.log(`=== ${locale} ===`);
    const set = await getOrCreateWatchSet(token, loc.id, {
      dryRun: args.dryRun,
    });
    console.log(`  set: ${set.id} (${DISPLAY_TYPE})`);

    const existing = await listScreenshots(token, set.id);
    if (existing.length && !args.dryRun) {
      console.log(`  deleting ${existing.length} existing…`);
      for (const shot of existing) {
        await deleteScreenshot(token, shot.id);
      }
    } else if (existing.length && args.dryRun) {
      console.log(`  (dry-run) would delete ${existing.length} existing`);
    }

    for (const filePath of files) {
      await createAndUploadScreenshot(token, set.id, filePath, {
        dryRun: args.dryRun,
      });
    }
  }

  console.log(`\nDone. dryRun=${args.dryRun}`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
