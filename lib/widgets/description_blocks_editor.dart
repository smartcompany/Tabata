import 'package:flutter/material.dart';
import 'package:share_lib/share_lib_image_picker.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/description_block.dart';
import '../services/routine_description_media_service.dart';
import '../utils/video_link_utils.dart';
import 'description_block_image.dart';
import 'keyboard_dismiss_scope.dart';

class DescriptionBlocksEditor extends StatefulWidget {
  const DescriptionBlocksEditor({
    super.key,
    required this.routineId,
    required this.blocks,
    required this.onChanged,
  });

  final String routineId;
  final List<DescriptionBlock> blocks;
  final ValueChanged<List<DescriptionBlock>> onChanged;

  @override
  State<DescriptionBlocksEditor> createState() =>
      _DescriptionBlocksEditorState();
}

class _DescriptionBlocksEditorState extends State<DescriptionBlocksEditor> {
  final _mediaService = RoutineDescriptionMediaService();
  late final TextEditingController _textController;
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _joinedText(widget.blocks));
  }

  @override
  void didUpdateWidget(covariant DescriptionBlocksEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routineId != widget.routineId) {
      _textController.text = _joinedText(widget.blocks);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _joinedText(List<DescriptionBlock> blocks) {
    return blocks
        .whereType<TextDescriptionBlock>()
        .map((block) => block.text)
        .join('\n\n');
  }

  List<DescriptionBlock> _mediaBlocks([List<DescriptionBlock>? blocks]) {
    return [
      for (final block in blocks ?? widget.blocks)
        if (block is! TextDescriptionBlock) block,
    ];
  }

  void _emit({String? text, List<DescriptionBlock>? media}) {
    widget.onChanged([
      TextDescriptionBlock(text: text ?? _textController.text),
      ...media ?? _mediaBlocks(),
    ]);
  }

  void _dismissKeyboard() {
    KeyboardDismissScope.dismiss(context);
  }

  Future<void> _addImage() async {
    final l10n = AppLocalizations.of(context);
    if (_pickingImage) return;

    _dismissKeyboard();
    setState(() => _pickingImage = true);
    try {
      final files = await MediaPickerService.pickImages(
        context,
        maxCount: 1,
        permissionDeniedMessage: l10n.photoLibraryPermissionRequired,
        compressFailureMessage: l10n.descriptionImageUploadError,
      );
      if (!mounted || files == null || files.isEmpty) return;

      final imageBlocks = await _mediaService.blocksFromPickedImages(
        scopeId: widget.routineId,
        files: files,
      );
      if (!mounted) return;
      _emit(media: [..._mediaBlocks(), ...imageBlocks]);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.descriptionImageUploadError)),
      );
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _addVideo() async {
    _dismissKeyboard();
    final l10n = AppLocalizations.of(context);
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _VideoUrlInputDialog(l10n: l10n),
    );
    if (url == null || url.isEmpty || !mounted) return;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.descriptionVideoUrlInvalid)),
      );
      return;
    }

    _emit(
      media: [
        ..._mediaBlocks(),
        VideoDescriptionBlock(
          url: url,
          provider: VideoLinkUtils.detectProvider(url),
        ),
      ],
    );
  }

  void _removeMedia(int mediaIndex) {
    _dismissKeyboard();
    final media = _mediaBlocks()..removeAt(mediaIndex);
    _emit(media: media);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = _mediaBlocks();
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.zero,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: l10n.descriptionTextHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                ),
                minLines: 3,
                maxLines: 8,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                onTapOutside: (_) => _dismissKeyboard(),
                onChanged: (value) => _emit(text: value),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _pickingImage ? null : _addImage,
                      tooltip: l10n.descriptionAddImage,
                      visualDensity: VisualDensity.compact,
                      icon: _pickingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.image_outlined, color: iconColor),
                    ),
                    IconButton(
                      onPressed: _addVideo,
                      tooltip: l10n.descriptionAddVideo,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.play_circle_outline, color: iconColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < media.length; i++) ...[
          const SizedBox(height: 10),
          _MediaAttachment(
            block: media[i],
            videoLabel: l10n.descriptionVideoBlockLabel,
            onRemove: () => _removeMedia(i),
          ),
        ],
      ],
    );
  }
}

class _MediaAttachment extends StatelessWidget {
  const _MediaAttachment({
    required this.block,
    required this.videoLabel,
    required this.onRemove,
  });

  final DescriptionBlock block;
  final String videoLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return switch (block) {
      TextDescriptionBlock() => const SizedBox.shrink(),
      ImageDescriptionBlock imageBlock => _AttachmentFrame(
          onRemove: onRemove,
          child: DescriptionBlockImage(
            block: imageBlock,
            height: 160,
            borderRadius: 8,
          ),
        ),
      VideoDescriptionBlock(:final url) => _AttachmentFrame(
          onRemove: onRemove,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(8, 4, 40, 4),
            leading: const Icon(Icons.play_circle_outline),
            title: Text(videoLabel),
            subtitle: Text(url, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ),
    };
  }
}

class _AttachmentFrame extends StatelessWidget {
  const _AttachmentFrame({
    required this.onRemove,
    required this.child,
  });

  final VoidCallback onRemove;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close),
            visualDensity: VisualDensity.compact,
            tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
          ),
        ),
      ],
    );
  }
}

class _VideoUrlInputDialog extends StatefulWidget {
  const _VideoUrlInputDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_VideoUrlInputDialog> createState() => _VideoUrlInputDialogState();
}

class _VideoUrlInputDialogState extends State<_VideoUrlInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close([String? value]) {
    KeyboardDismissScope.dismiss(context);
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return KeyboardDismissScope(
      showAccessoryBar: false,
      child: AlertDialog(
        title: Text(l10n.descriptionAddVideo),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: l10n.descriptionVideoUrlHint,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          autofocus: true,
          onEditingComplete: () => _close(_controller.text.trim()),
          onTapOutside: (_) => KeyboardDismissScope.dismiss(context),
          onSubmitted: (value) => _close(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => _close(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => _close(_controller.text.trim()),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
