import 'package:flutter/material.dart';
import '../../domain/entities/image_batch.dart';
import '../../domain/entities/upload_status.dart';

class PendingUploadsList extends StatelessWidget {
  final List<ImageBatch> batches;
  final VoidCallback onRetry;
  final bool isConnected;
  final bool isUploading;

  const PendingUploadsList({
    super.key,
    required this.batches,
    required this.onRetry,
    required this.isConnected,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    final displayBatches = batches.where((b) => !b.isUploaded).toList();

    if (displayBatches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.cloud_done_outlined,
                color: Colors.green, size: 40),
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
        // ── Header ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                'Pending Uploads (${displayBatches.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Connectivity badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isConnected ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 11,
                        color: isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnected && !isUploading) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.upload, size: 14),
                  label:
                  const Text('Sync', style: TextStyle(fontSize: 12)),
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
          itemCount: displayBatches.length,
          separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final batch = displayBatches[index];
            // Show batch number based on position in list (1-based)
            // This fixes "all batches show same name" issue
            return _BatchTile(
              batch: batch,
              batchNumber: index + 1,
              isUploading: isUploading,
            );
          },
        ),
      ],
    );
  }
}

class _BatchTile extends StatelessWidget {
  final ImageBatch batch;
  final int batchNumber;
  final bool isUploading;

  const _BatchTile({
    required this.batch,
    required this.batchNumber,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    final imageCount = batch.images.length;
    return ListTile(
      dense: true,
      leading: _statusIcon(),
      title: Text(
        // Show unique batch number + image count
        'Batch #$batchNumber — $imageCount image${imageCount != 1 ? 's' : ''}',
        style:
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _formatTime(batch.createdAt),
        style: const TextStyle(fontSize: 11),
      ),
      trailing: _statusChip(),
    );
  }

  Widget _statusIcon() {
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

  Widget _statusChip() {
    Color color;
    String label;
    switch (batch.uploadStatus) {
      case UploadStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case UploadStatus.uploading:
        color = Colors.blue;
        label = 'Uploading…';
        break;
      case UploadStatus.uploaded:
        color = Colors.green;
        label = 'Uploaded';
        break;
      case UploadStatus.failed:
        color = Colors.red;
        label = 'Failed (×${batch.retryCount})';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
