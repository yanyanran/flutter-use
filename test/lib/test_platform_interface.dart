import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'test_method_channel.dart';

abstract class TestPlatform extends PlatformInterface {
  /// Constructs a TestPlatform.
  TestPlatform() : super(token: _token);

  static final Object _token = Object();

  static TestPlatform _instance = MethodChannelTest();

  /// The default instance of [TestPlatform] to use.
  ///
  /// Defaults to [MethodChannelTest].
  static TestPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TestPlatform] when
  /// they register themselves.
  static set instance(TestPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  // todo 定义
  Future<String?> addEventToCalendar(String eventName) {
    throw UnimplementedError();
  }
}
