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
  State<DescriptionBlocksEditor> createState() => _DescriptionBlocksEditorState();
}

class _DescriptionBlocksEditorState extends State<DescriptionBlocksEditor> {
  final _mediaService = RoutineDescriptionMediaService();
  bool _pickingImage = false;

  void _updateBlocks(List<DescriptionBlock> blocks) {
    widget.onChanged(blocks);
  }

  void _dismissKeyboard() {
    KeyboardDismissScope.dismiss(context);
  }

  void _addTextBlock() {
    _dismissKeyboard();
    _updateBlocks([...widget.blocks, const TextDescriptionBlock(text: '')]);
  }

  Future<void> _addImageBlock() async {
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
      _updateBlocks([...widget.blocks, ...imageBlocks]);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.descriptionImageUploadError)),
      );
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _addVideoBlock() async {
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

    _updateBlocks([
      ...widget.blocks,
      VideoDescriptionBlock(
        url: url,
        provider: VideoLinkUtils.detectProvider(url),
      ),
    ]);
  }

  void _removeBlock(int index) {
    _dismissKeyboard();
    final updated = List<DescriptionBlock>.from(widget.blocks)..removeAt(index);
    _updateBlocks(updated);
  }

  void _moveBlock(int index, int delta) {
    _dismissKeyboard();
    final target = index + delta;
    if (target < 0 || target >= widget.blocks.length) return;
    final updated = List<DescriptionBlock>.from(widget.blocks);
    final item = updated.removeAt(index);
    updated.insert(target, item);
    _updateBlocks(updated);
  }

  void _updateTextBlock(int index, String text) {
    final updated = List<DescriptionBlock>.from(widget.blocks);
    updated[index] = TextDescriptionBlock(text: text);
    _updateBlocks(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.blocks.isEmpty)
          Text(
            l10n.descriptionBlocksEmptyHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        for (var i = 0; i < widget.blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _BlockCard(
            index: i,
            total: widget.blocks.length,
            onMoveUp: () => _moveBlock(i, -1),
            onMoveDown: () => _moveBlock(i, 1),
            onRemove: () => _removeBlock(i),
            child: _buildBlockEditor(context, l10n, i, widget.blocks[i]),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _addTextBlock,
              icon: const Icon(Icons.notes_outlined, size: 18),
              label: Text(l10n.descriptionAddText),
            ),
            OutlinedButton.icon(
              onPressed: _pickingImage ? null : _addImageBlock,
              icon: _pickingImage
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.image_outlined, size: 18),
              label: Text(l10n.descriptionAddImage),
            ),
            OutlinedButton.icon(
              onPressed: _addVideoBlock,
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: Text(l10n.descriptionAddVideo),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBlockEditor(
    BuildContext context,
    AppLocalizations l10n,
    int index,
    DescriptionBlock block,
  ) {
    return switch (block) {
      TextDescriptionBlock(:final text) => TextFormField(
          key: ValueKey('text-$index'),
          initialValue: text,
          decoration: InputDecoration(
            hintText: l10n.descriptionTextHint,
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          minLines: 2,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          onTapOutside: (_) => _dismissKeyboard(),
          onChanged: (value) => _updateTextBlock(index, value),
        ),
      ImageDescriptionBlock imageBlock => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DescriptionBlockImage(
              block: imageBlock,
              height: 160,
              borderRadius: 8,
            ),
            if (imageBlock.alt != null && imageBlock.alt!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                imageBlock.alt!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      VideoDescriptionBlock(:final url) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.play_circle_outline),
          title: Text(l10n.descriptionVideoBlockLabel),
          subtitle: Text(url, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
    };
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

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.index,
    required this.total,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    required this.child,
  });

  final int index;
  final int total;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Spacer(),
                IconButton(
                  onPressed: index > 0 ? onMoveUp : null,
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: index < total - 1 ? onMoveDown : null,
                  icon: const Icon(Icons.arrow_downward),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}
