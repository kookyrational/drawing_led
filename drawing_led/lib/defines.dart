


import 'package:flutter/material.dart';

typedef ValueChanged = void Function(int value,List<dynamic> aBleList);

class Defines
{

  static final String COPY_FILE_KEY = "COPY_FILE_KEY";

  static String sImageFolder = "DrawingImages";

  static const int BRIGHTNESS_MIN = 1;
  static const int BRIGHTNESS_MAX = 30;

  static const String METHOD_CHANNEL_BACKGROUND_ISOLATE_INITIALIZED="backgroundIsolateInitialized";
  static const String METHOD_CHANNEL_CALCULATE="calculate";

  static const String bg_method_start_scan = "bg_method_start_scan";
  static const String bg_method_callback_start_scan = "bg_method_callback_start_scan";

  static const String bg_method_stop_scan = "bg_method_stop_scan";
  static const String bg_method_callback_stop_scan = "bg_method_callback_stop_scan";

  static const String bg_method_send_led_data = "bg_method_send_led_data";
  static const String bg_method_callback_send_led_data = "bg_method_callback_send_led_data";

  static const String bg_method_start_connect = "bg_method_start_connect";
  static const String bg_method_callback_start_connect = "bg_method_callback_start_connect";

  static const String bg_method_disconnect = "bg_method_disconnect";
  static const String bg_method_callback_disconnect = "bg_method_callback_disconnect";

  static const int BLE_SCAN_DIALOG_ACTON_SCAN = 0;
  static const int BLE_SCAN_DIALOG_ACTON_CANCEL = 1;
  static const int BLE_SCAN_DIALOG_ACTON_CLICK_ITEM = 2;
}

enum DrawerItems
{
   PAINTING,
   TEXTING,
   IMAGES,
   BRIGHT
}

extension DrawerItemsExtension on DrawerItems
{
   String get name
   {
     switch(this)
     {
         case DrawerItems.PAINTING:
         {
           return "塗鴉顯示";
         }
         case DrawerItems.TEXTING:
         {
           return "文字顯示";
         }
         case DrawerItems.IMAGES:
         {
           return "圖片顯示";
         }
         case DrawerItems.BRIGHT:
         {
           return "亮度顯示";
         }
     }
   }
}