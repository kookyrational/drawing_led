
import 'package:flutter/services.dart';

import 'bridge_manager.dart';

class MethodChannelManager
{
  MethodChannel methodChannel;

  factory MethodChannelManager() => _getInstance();

  static MethodChannelManager get instance => _getInstance();
  static MethodChannelManager _instance;

  MethodChannelManager._internal()
  {
    methodChannel = MethodChannel(BridgeManager.BLEMethodChannel);
  }

  static MethodChannelManager _getInstance()
  {
    if (_instance == null)
    {
      _instance = MethodChannelManager._internal();
    }
    return _instance;
  }
}