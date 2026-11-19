import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bijak_belajar/services/on_device_speech.dart';

/// Speaking practice must never send a child's voice to a server. These tests
/// pin down the availability check that gates the microphone.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('bijak_belajar/speech');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('reports the native answer when the phone has an offline recogniser', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'onDeviceAvailable');
      return true;
    });

    expect(await OnDeviceSpeech.isAvailable(), isTrue);
  });

  test('reports unavailable when the phone has no offline recogniser', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => false);

    expect(await OnDeviceSpeech.isAvailable(), isFalse);
  });

  test('treats a missing native side as unavailable, never online', () async {
    expect(await OnDeviceSpeech.isAvailable(), isFalse);
  });

  test('treats a platform error as unavailable', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'unexpected');
    });

    expect(await OnDeviceSpeech.isAvailable(), isFalse);
  });
}
