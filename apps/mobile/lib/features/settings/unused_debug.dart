  // void _showUrlDialog(BuildContext context, WidgetRef ref) {
  //   final controller = TextEditingController(
  //     text: ref.read(customApiUrlProvider),
  //   );

  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       title: const Text('Change Server URL'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             'Enter the ngrok or server URL:',
  //             style: TextStyle(fontSize: 14, color: Colors.grey),
  //           ),
  //           const SizedBox(height: 12),
  //           TextField(
  //             controller: controller,
  //             decoration: InputDecoration(
  //               hintText: 'https://example.ngrok-free.app',
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               contentPadding: const EdgeInsets.symmetric(
  //                 horizontal: 12,
  //                 vertical: 10,
  //               ),
  //             ),
  //             keyboardType: TextInputType.url,
  //             style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             'Default: ${ref.read(customApiUrlProvider.notifier).defaultUrl}',
  //             style: const TextStyle(fontSize: 11, color: Colors.grey),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             final newUrl = controller.text.trim();
  //             if (newUrl.isNotEmpty) {
  //               await ref.read(customApiUrlProvider.notifier).setUrl(newUrl);
  //               if (context.mounted) {
  //                 Navigator.pop(context);
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text('URL updated to: $newUrl')),
  //                 );
  //               }
  //             }
  //           },
  //           child: const Text('Save'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _testConnection(BuildContext context, WidgetRef ref) async {
  //   final url = ref.read(apiBaseUrlProvider);

  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text('Testing connection...')));

  //   try {
  //     final response = await http
  //         .get(
  //           Uri.parse('$url/health'),
  //           headers: {
  //             'ngrok-skip-browser-warning':
  //                 'true', // Skip ngrok browser warning
  //           },
  //         )
  //         .timeout(const Duration(seconds: 5));

  //     if (!context.mounted) return;

  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text('✓ Connection successful!'),
  //           backgroundColor: Colors.green.shade600,
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('✗ Server returned: ${response.statusCode}'),
  //           backgroundColor: Colors.orange.shade600,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (!context.mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           '✗ Connection failed: ${e.toString().split(':').last.trim()}',
  //         ),
  //         backgroundColor: Colors.red.shade600,
  //       ),
  //     );
  //   }
  // }