import 'package:flutter/material.dart';
import '../../domain/entities/image_batch.dart';
import '../../domain/entities/upload_status.dart';

/// Scrollable list of [ImageBatch] entries with status icons and retry counts.
/// Pure widget — receives data and callbacks, no BLoC access.
class PendingUploadsList extends StatelessWidget {
  final List<ImageBatch> batches;
  final bool isOnline;
  final bool isUploading;
  final VoidCallback onUploadNowPressed;

  const PendingUploadsList({
    super.key,
    required this.batches,
    required this.isOnline,
    required this.isUploading,
    required this.onUploadNowPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8.0),
        if (batches.isEmpty)
          _buildEmptyState(context)
        else
          _buildBatchList(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Pending Uploads',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(width: 8.0),
            _buildConnectivityBadge(),
          ],
        ),
        if (batches.isNotEmpty)
          TextButton.icon(
            onPressed: (isOnline && !isUploading) ? onUploadNowPressed : null,
            icon: isUploading
                ? const SizedBox(
                    width: 14.0,
                    height: 14.0,
                    child:
                        CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                  )
                : const Icon(Icons.upload, size: 16.0, color: Colors.white70),
            label: Text(
              isUploading ? 'Uploading…' : 'Upload Now',
              style: const TextStyle(color: Colors.white70, fontSize: 13.0),
            ),
          ),
      ],
    );
  }

  Widget _buildConnectivityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.shade700 : Colors.red.shade700,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            size: 12.0,
            color: Colors.white,
          ),
          const SizedBox(width: 4.0),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: const TextStyle(color: Colors.white, fontSize: 11.0),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          'No pending uploads',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildBatchList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: batches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6.0),
      itemBuilder: (context, index) {
        return _BatchListTile(batch: batches[index]);
      },
    );
  }
}

class _BatchListTile extends StatelessWidget {
  final ImageBatch batch;

  const _BatchListTile({required this.batch});

  Color _buildStatusColor() {
    switch (batch.uploadStatus) {
      case UploadStatus.pending:
        return Colors.orange.shade400;
      case UploadStatus.uploading:
        return Colors.blue.shade400;
      case UploadStatus.uploaded:
        return Colors.green.shade400;
      case UploadStatus.failed:
        return Colors.red.shade400;
    }
  }

  IconData _buildStatusIcon() {
    switch (batch.uploadStatus) {
      case UploadStatus.pending:
        return Icons.hourglass_top;
      case UploadStatus.uploading:
        return Icons.cloud_upload;
      case UploadStatus.uploaded:
        return Icons.cloud_done;
      case UploadStatus.failed:
        return Icons.error_outline;
    }
  }

  String _buildStatusLabel() {
    switch (batch.uploadStatus) {
      case UploadStatus.pending:
        return 'Pending';
      case UploadStatus.uploading:
        return 'Uploading…';
      case UploadStatus.uploaded:
        return 'Uploaded';
      case UploadStatus.failed:
        return 'Failed (retry ${batch.retryCount})';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _buildStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          batch.isUploading
              ? SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: statusColor,
                  ),
                )
              : Icon(_buildStatusIcon(), color: statusColor, size: 20.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.batchName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${batch.imageCount} image${batch.imageCount == 1 ? '' : 's'}  ·  ${_buildStatusLabel()}',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.0,
                  ),
                ),
                if (batch.lastErrorMessage != null && batch.isFailed)
                  Text(
                    batch.lastErrorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 10.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
