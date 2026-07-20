import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app manifest explicitly removes camera plugin audio and storage', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(
      manifest,
      contains(
        'android:name="android.permission.RECORD_AUDIO"\n'
        '        tools:node="remove"',
      ),
    );
    expect(
      manifest,
      contains(
        'android:name="android.permission.WRITE_EXTERNAL_STORAGE"\n'
        '        tools:node="remove"',
      ),
    );
    expect(
      RegExp(
        r'<uses-permission\s+android:name="android.permission.(RECORD_AUDIO|WRITE_EXTERNAL_STORAGE)"\s*/>',
      ).hasMatch(manifest),
      isFalse,
    );
  });
}
