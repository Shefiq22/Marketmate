import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/providers/locale_provider.dart';
import 'package:market_mate/core/services/translation_service.dart';
import 'package:market_mate/l10n/app_localizations.dart';

final _translationCacheProvider = Provider<CachedTranslationService>((ref) {
  return CachedTranslationService();
});

class DynamicText extends ConsumerStatefulWidget {
  final String text;
  final String fallbackLanguage;
  final TextStyle? style;
  final TextStyle? translatedStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const DynamicText({
    super.key,
    required this.text,
    this.fallbackLanguage = 'en',
    this.style,
    this.translatedStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  ConsumerState<DynamicText> createState() => _DynamicTextState();
}

class _DynamicTextState extends ConsumerState<DynamicText> {
  String? _translatedText;
  bool _showOriginal = false;
  bool _isTranslating = false;
  String? _error;
  String? _previousLocale;

  String get _activeLocale =>
      ref.read(localeProvider).languageCode;

  bool get _needsTranslation =>
      _activeLocale != widget.fallbackLanguage &&
      _activeLocale != widget.fallbackLanguage;

  String _localeDisplayName(String code) => switch (code) {
        'ha' => 'Hausa',
        'ig' => 'Igbo',
        'yo' => 'Yoruba',
        'pcm' => 'Pidgin',
        _ => code.toUpperCase(),
      };

  @override
  void didUpdateWidget(DynamicText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _translatedText = null;
      _showOriginal = false;
      _error = null;
    }
  }

  Future<void> _translate() async {
    if (_translatedText != null) return;

    setState(() {
      _isTranslating = true;
      _error = null;
    });

    try {
      final cache = ref.read(_translationCacheProvider);
      final result = await cache.translate(
        text: widget.text,
        targetLanguage: _activeLocale,
        sourceLanguage: widget.fallbackLanguage,
      );
      if (mounted) {
        setState(() {
          _translatedText = result;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;

    if (_previousLocale != locale) {
      _previousLocale = locale;
      _translatedText = null;
      _showOriginal = false;
      _error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _translate());
    }

    if (!_needsTranslation) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    final showTranslated = _translatedText != null && !_showOriginal;
    final displayText = showTranslated ? _translatedText! : widget.text;
    final displayStyle =
        showTranslated && widget.translatedStyle != null
            ? widget.translatedStyle
            : widget.style;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: displayStyle,
          maxLines: showTranslated ? null : widget.maxLines,
          overflow: showTranslated ? null : widget.overflow,
        ),
        if (_isTranslating)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () {
                _error = null;
                _translate();
              },
              child: Text(
                AppLocalizations.of(context)!.translate_retry,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.error,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          )
        else if (_translatedText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () => setState(() => _showOriginal = !_showOriginal),
              child: Text(
                _showOriginal
                    ? AppLocalizations.of(context)!
                        .translate_to(_localeDisplayName(_activeLocale))
                    : AppLocalizations.of(context)!.translate_show_original,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
