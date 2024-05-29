
import 'test_platform_interface.dart';

class Test {
  Future<String?> getPlatformVersion() {
    return TestPlatform.instance.getPlatformVersion();
  }

  // todo 暴露给调用方
  Future<String?> addEventToCalendar(String eventName) {
    return TestPlatform.instance.addEventToCalendar(eventName);
  }
}
