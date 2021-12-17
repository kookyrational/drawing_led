package com.spreadout.drawing_led;

import android.util.Log;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

public class Define
{
    public static class Channel
    {
        public static String MethodChannel = "com.spreadout.drawing_led/method/ble";
    }

    public static class ChannelMethod
    {
        public static String bg_method_start_scan = "bg_method_start_scan";
        public static String bg_method_callback_start_scan = "bg_method_callback_start_scan";
        
        public static String bg_method_stop_scan = "bg_method_stop_scan";
        public static String bg_method_callback_stop_scan = "bg_method_callback_stop_scan";

        public static String bg_method_start_connect = "bg_method_start_connect";
        public static String bg_method_callback_start_connect = "bg_method_callback_start_connect";

        public static String bg_method_disconnect = "bg_method_disconnect";
        public static String bg_method_callback_disconnect = "bg_method_callback_disconnect";

        public static String bg_method_send_led_data = "bg_method_send_led_data";
        public static String bg_method_callback_send_led_data = "bg_method_callback_send_led_data";
        
    }

    protected static long getCurrentUnixTime()
    {
        return System.currentTimeMillis();
    }

    protected static long getCurrentUnixTimeSecond()
    {
        return System.currentTimeMillis() / 1000;
    }

    protected static String convertUnixTimeToString(long unixTime, String pattern)
    {
        return convertUnixTimeToString(unixTime, pattern, TimeZone.getTimeZone("UTC"));
    }

    protected static String convertUnixTimeToString(long unixTime, String pattern, TimeZone targetTimeZone)
    {
        return convertDateToString(new Date(unixTime), pattern, targetTimeZone);
    }

    protected static String convertDateToString(Date date, String pattern, TimeZone targetTimeZone)
    {
        SimpleDateFormat dateFormat = new SimpleDateFormat(pattern, Locale.US);
        dateFormat.setTimeZone(targetTimeZone);
        return dateFormat.format(date);
    }

}
