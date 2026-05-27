import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/widgets/primary_scaffold.dart';

class StoragePerformanceScreen extends StatefulWidget {
  const StoragePerformanceScreen({super.key});

  @override
  State<StoragePerformanceScreen> createState() =>
      _StoragePerformanceScreenState();
}

class _StoragePerformanceScreenState extends State<StoragePerformanceScreen> {
  bool _batterySaver = false;
  late Future<_StorageBreakdown> _storageFuture;

  @override
  void initState() {
    super.initState();
    _storageFuture = _loadStorageBreakdown();
  }

  Future<_StorageBreakdown> _loadStorageBreakdown() async {
    final tempDir = await getTemporaryDirectory();
    final documentsDir = await getApplicationDocumentsDirectory();
    final supportDir = await getApplicationSupportDirectory();

    final cacheBytes = await _directorySize(tempDir);
    final documentsBytes = await _directorySize(documentsDir);
    final supportBytes = await _directorySize(supportDir);

    return _StorageBreakdown([
      _StorageSegment(
        color: Colors.blue,
        label: 'Local Documents',
        bytes: documentsBytes,
      ),
      _StorageSegment(
        color: Colors.orange,
        label: 'App Support Files',
        bytes: supportBytes,
      ),
      _StorageSegment(
        color: Colors.grey,
        label: 'Cached Data',
        bytes: cacheBytes,
      ),
    ]);
  }

  Future<int> _directorySize(Directory directory) async {
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entity
        in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {
          // Some platform/cache files may disappear while being measured.
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Storage & Performance',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manage device storage and optimize app performance.',
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Storage Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<_StorageBreakdown>(
              future: _storageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ListTile(
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: const Text('Storage details unavailable'),
                    subtitle: Text(snapshot.error.toString()),
                  );
                }

                final breakdown = snapshot.data ?? _StorageBreakdown.empty();
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: breakdown.segments.map((segment) {
                          return Expanded(
                            flex: breakdown.flexFor(segment),
                            child: Container(height: 20, color: segment.color),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...breakdown.segments.map(
                      (segment) => _StorageLegendItem(
                        color: segment.color,
                        label: segment.label,
                        size: _formatBytes(segment.bytes),
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Measured App Data',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatBytes(breakdown.totalBytes),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Battery Saver Mode'),
            subtitle: const Text(
                'Pause heavy avatar animations and reduce sync frequency when battery is low.'),
            value: _batterySaver,
            secondary: const Icon(Icons.battery_saver_rounded),
            onChanged: (val) {
              setState(() => _batterySaver = val);
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Performance settings saved.')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  final gb = mb / 1024;
  return '${gb.toStringAsFixed(2)} GB';
}

class _StorageBreakdown {
  const _StorageBreakdown(this.segments);

  factory _StorageBreakdown.empty() {
    return const _StorageBreakdown([
      _StorageSegment(color: Colors.blue, label: 'Local Documents', bytes: 0),
      _StorageSegment(
          color: Colors.orange, label: 'App Support Files', bytes: 0),
      _StorageSegment(color: Colors.grey, label: 'Cached Data', bytes: 0),
    ]);
  }

  final List<_StorageSegment> segments;

  int get totalBytes =>
      segments.fold<int>(0, (total, item) => total + item.bytes);

  int flexFor(_StorageSegment segment) {
    if (totalBytes <= 0) return 1;
    final ratio = segment.bytes / totalBytes;
    return (ratio * 100).round().clamp(1, 100);
  }
}

class _StorageSegment {
  const _StorageSegment({
    required this.color,
    required this.label,
    required this.bytes,
  });

  final Color color;
  final String label;
  final int bytes;
}

class _StorageLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String size;

  const _StorageLegendItem({
    required this.color,
    required this.label,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(size, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
