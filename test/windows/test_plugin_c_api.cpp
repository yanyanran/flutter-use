#include "include/test/test_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "test_plugin.h"

void TestPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  test::TestPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
