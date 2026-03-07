import 'package:flutter/material.dart';
import '../../domain/entities/image_batch.dart';
import '../../domain/entities/upload_status.dart';

/// Shows the list of image batches that are pending or failed upload.
class PendingUploadsList extends StatelessWidget {
  final List<ImageBatch> batches;
  final VoidCallback onRetryTapped;
  final bool isConnected;
  final bool isUploading;

  const PendingUploadsList({
    super.key,
    required this.batches,
    required this.onRetryTapped,
    required this.isConnected,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    final visibleBatches = batches.where((b) => !b.isUploaded).toList();

    if (visibleBatches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.cloud_done_outlined,
                color: Colors.green, size: 44),
            const SizedBox(height: 8),
            Text(
              'All uploads complete',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.green),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                'Pending Uploads (${visibleBatches.length})',
                style:
                    Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
              ),
              const Spacer(),

              // Online / offline badge
              _ConnectivityBadge(isConnected: isConnected),

              if (isConnected && !isUploading) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onRetryTapped,
                  icon: const Icon(Icons.upload, size: 14),
                  label: const Text('Sync',
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Batch list ───────────────────────────────────────────────────
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleBatches.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final batch = visibleBatches[index];
            return _BatchTile(
              batch: batch,
              // Use 1-based display index for human-readable numbering
              displayNumber: index + 1,
              isUploading: isUploading,
            );
          },
        ),
      ],
    );
  }
}

// ── Small connectivity badge ───────────────────────────────────────────────
class _ConnectivityBadge extends StatelessWidget {
  final bool isConnected;
  const _ConnectivityBadge({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            isConnected ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual batch tile ──────────────────────────────────────────────────
class _BatchTile extends StatelessWidget {
  final ImageBatch batch;
  final int displayNumber;
  final bool isUploading;

  const _BatchTile({
    required this.batch,
    required this.displayNumber,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    final imageCount = batch.images.length;
    return ListTile(
      dense: true,
      leading: _buildStatusIcon(),
      title: Text(
        'Batch #$displayNumber — $imageCount image${imageCount != 1 ? 's' : ''}',
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _humanReadableTimeSince(batch.createdAt),
        style: const TextStyle(fontSize: 11),
      ),
      trailing: _buildStatusChip(),
    );
  }

  Widget _buildStatusIcon() {
    switch (batch.uploadStatus) {
      case UploadStatus.pending:
        return const Icon(Icons.hourglass_empty,
            color: Colors.orange, size: 20);
      case UploadStatus.uploading:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UploadStatus.uploaded:
        return const Icon(Icons.cloud_done,
            color: Colors.green, size: 20);
      case UploadStatus.failed:
        return const Icon(Icons.error_outline,
            color: Colors.red, size: 20);
    }
  }

  Widget _buildStatusChip() {
    late Color chipColor;
    late String label;

    switch (batch.uploadStatus) {
      case UploadStatus.pending:
        chipColor = Colors.orange;
        label = 'Pending';
        break;
      case UploadStatus.uploading:
        chipColor = Colors.blue;
        label = 'Uploading…';
        break;
      case UploadStatus.uploaded:
        chipColor = Colors.green;
        label = 'Uploaded';
        break;
      case UploadStatus.failed:
        chipColor = Colors.red;
        label = 'Failed (×${batch.retryCount})';
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: chipColor.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _humanReadableTimeSince(DateTime timestamp) {
    final elapsed = DateTime.now().difference(timestamp);
    if (elapsed.inSeconds < 60) return 'Just now';
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes}m ago';
    if (elapsed.inHours < 24) return '${elapsed.inHours}h ago';
    return '${timestamp.day}/${timestamp.month} '
        '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
