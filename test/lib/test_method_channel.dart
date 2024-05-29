import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'test_platform_interface.dart';

/// An implementation of [TestPlatform] that uses method channels.
class MethodChannelTest extends TestPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('test');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  // todo 实现
  @override
  Future<String?> addEventToCalendar(String eventName) {
    return methodChannel.invokeMethod<String?>('addEventToCalendar');
  }
}
