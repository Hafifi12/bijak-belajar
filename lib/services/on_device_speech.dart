import 'dart:io';

import 'package:flutter/services.dart';

/// Tells the app whether speech practice can run entirely on this phone.
///
/// The speech plugin falls back to the online recogniser when the offline one
/// is missing, so the app checks first. A child's voice must never leave the
/// device (see the privacy policy). Checking never opens the microphone.
class OnDeviceSpeech {
  const OnDeviceSpeech._();

  static const _channel = MethodChannel('bijak_belajar/speech');

  static Future<bool> isAvailable() async {
    // iOS: the speech plugin sets requiresOnDeviceRecognition, so Apple's
    // recogniser fails instead of going online.
    if (Platform.isIOS) return true;
    try {
      return await _channel.invokeMethod<bool>('onDeviceAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
