package com.spreadout.drawing_led;

import java.util.UUID;

public class BleUUIDs
{
    public static class Service
    {
        final static public UUID LED_SERVICE = UUID
                .fromString("d973f2e0-b19e-11e2-9e96-0800200c9a66");
        final static public UUID BATTERY_SERVICE_UUID = UUID
                .fromString("0000180F-0000-1000-8000-00805f9b34fb");
    };

    public static class Characteristic {
        final static public UUID LED_SERVICE = UUID
                .fromString("d973f2e2-b19e-11e2-9e96-0800200c9a66");
        final static public UUID BATTERY_LEVEL = UUID
                .fromString("00002a19-0000-1000-8000-00805f9b34fb");
    }

}
