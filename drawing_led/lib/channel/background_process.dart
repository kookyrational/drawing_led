

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

import '../defines.dart';
import 'method_channel_manager.dart';

class BackgroundProcess
{
  static var pluginChannel = MethodChannelManager.instance.methodChannel;

  static void initialInvokeNativeMethod(Function aCallBack) async
  {
    pluginChannel.setMethodCallHandler((MethodCall call) async
    {
      if(call.method == Defines.bg_method_callback_start_scan)
      {
         List<dynamic> bleAddress = call.arguments;
         aCallBack(Defines.bg_method_callback_start_scan,bleAddress);
      }
      else if(call.method == Defines.bg_method_callback_start_connect)
      {
        List<dynamic> bleAddress =[];
        aCallBack(Defines.bg_method_callback_start_connect,bleAddress);
      }
      else if(call.method == Defines.bg_method_callback_stop_scan)
      {
        List<dynamic> bleAddress =[];
        aCallBack(Defines.bg_method_callback_stop_scan,bleAddress);
      }
      else if(call.method == Defines.bg_method_callback_send_led_data)
      {
        Uint8List bleData = call.arguments;
        aCallBack(Defines.bg_method_callback_send_led_data, bleData);
      }
      else if(call.method == Defines.bg_method_callback_disconnect)
      {
        List<dynamic> bleAddress =[];
        aCallBack(Defines.bg_method_callback_disconnect, bleAddress);
      }
    });
  }

  static void invokeStartScan() async
  {
    await pluginChannel.invokeMethod(Defines.bg_method_start_scan);
  }

  static void invokeStopScan() async
  {
    await pluginChannel.invokeMethod(Defines.bg_method_stop_scan);
  }

  static void invokeStartConnect(String aAddress) async
  {
    await pluginChannel.invokeMethod(Defines.bg_method_start_connect,[aAddress]);
  }

  static void invokeSendLEDData(Uint8List aData) async
  {
    await pluginChannel.invokeMethod(Defines.bg_method_send_led_data, aData);
  }

  static void invokeDisconnect() async
  {
    await pluginChannel.invokeMethod(Defines.bg_method_disconnect);
  }

}