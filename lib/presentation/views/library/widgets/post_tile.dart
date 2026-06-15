import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../data/models/post.dart';
import '../../../../data/models/social_platform.dart';

/// Compact summary row for a saved post (draft, scheduled or published).
class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.post,
    this.onEdit,
    this.onDelete,
  });

  final Post post;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final String preview = post.baseText.trim().isEmpty
        ? '(no text)'
        : post.baseText.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Leading(post: post),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    for (final SocialPlatform p in post.selectedPlatforms)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(p.icon, size: 14, color: p.brandColor),
                      ),
                    const Spacer(),
                    _StatusChip(post: post),
                  ],
                ),
                const SizedBox(height: 4),
                Text(_subtitle(), style: context.textTheme.bodySmall),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String v) =>
                v == 'edit' ? onEdit?.call() : onDelete?.call(),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'edit', child: Text('Open in composer')),
              const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitle() {
    if (post.status == PostStatus.scheduled && post.scheduledAt != null) {
      return 'Scheduled · ${DateFormat('MMM d, h:mm a').format(post.scheduledAt!)} (${post.scheduledAt!.relativeLabel})';
    }
    return 'Updated ${post.updatedAt.relativeLabel}';
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    if (post.hasMedia) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(post.media.first.originalPath),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.notes, color: context.colors.onSurfaceVariant),
      );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.post});
  final Post post;

  Color get _color => switch (post.status) {
        PostStatus.draft => Colors.grey,
        PostStatus.scheduled => AppColors.facebook,
        PostStatus.publishing => AppColors.warning,
        PostStatus.published => AppColors.success,
        PostStatus.partiallyFailed => AppColors.warning,
        PostStatus.failed => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        post.status.label,
        style: TextStyle(
            color: _color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
