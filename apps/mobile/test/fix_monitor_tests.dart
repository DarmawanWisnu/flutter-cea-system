#!/usr/bin/env dart

import 'dart:io';

void main() async {
  final file = File('C:\\WisnuDarmawan\\Coding\\Project\\flutter-cea-system\\apps\\mobile\\integration_test\\monitor_flow_test.dart');
  var content = await file.readAsString();
  
  // Replace all occurrences of apiKitsListProvider overrides to include mqttProvider
  content = content.replaceAllMapped(
    RegExp(r'overrides: \[\s*apiKitsListProvider\.overrideWith\([^\]]+\]\),', multiLine: true, dotAll: true),
    (match) {
      final matched = match.group(0)!;
      if (matched.contains('mqttProvider')) {
        return matched; // Already has mqttProvider
      }
      // Add mqttProvider before the closing bracket
      return matched.replaceFirst(
        '],',
        'mqttProvider.overrideWith((ref) => Future.value()),\n          ],',
      );
    },
  );
  
  // Replace pumpAndSettle with pump() to avoid timeouts (only in monitor tests, not tap interactions)
  // content = content.replaceAll(
  //   'await tester.pumpAndSettle();',
  //   'await tester.pump();\n      await tester.pump(const Duration(milliseconds: 100));',
  // );
  
  await file.writeAsString(content);
  print('✅ Fixed monitor_flow_test.dart');
}
