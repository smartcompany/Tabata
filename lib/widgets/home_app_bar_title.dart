import 'package:flutter/material.dart';

class _TitleParts {
  const _TitleParts({required this.lead, required this.emphasis});

  final String lead;
  final String emphasis;
}

_TitleParts _splitAppTitle(String title, Locale locale) {
  switch (locale.languageCode) {
    case 'ko':
      return const _TitleParts(lead: '모두의', emphasis: '타바타');
    case 'en':
      return const _TitleParts(lead: "Everyone's", emphasis: 'Tabata');
    case 'ja':
      return const _TitleParts(lead: 'みんなの', emphasis: 'タバタ');
    case 'zh':
      return const _TitleParts(lead: '大家的', emphasis: '塔巴塔');
    default:
      final parts = title.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return _TitleParts(
          lead: parts.sublist(0, parts.length - 1).join(' '),
          emphasis: parts.last,
        );
      }
      return _TitleParts(lead: '', emphasis: title);
  }
}

/// 홈 AppBar용 브랜드 타이틀 — 좌측 액센트 마크 + 2단 타이포.
class HomeAppBarTitle extends StatelessWidget {
  const HomeAppBarTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final parts = _splitAppTitle(title, Localizations.localeOf(context));

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.45),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (parts.lead.isNotEmpty)
              Text(
                parts.lead,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  height: 1.1,
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            Text(
              parts.emphasis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.05,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
