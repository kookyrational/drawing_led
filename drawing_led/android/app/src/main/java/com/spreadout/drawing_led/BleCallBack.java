package com.spreadout.drawing_led;

import java.util.Hashtable;

public interface BleCallBack
{
    public void onBLEConnected();
    
    public void onBLEDisconnected();
    
    public void onWriteDataFinish();

    public void onScanBLEResult(String aBLEResult);
    
    public void onBLEIndexChanged(int index);
    
    public void onBLEBatteryStatusChanged(int battery);
    
    public static class Null implements BleCallBack {

        @Override
        public void onBLEConnected() {

        }

        @Override
        public void onBLEDisconnected() {
        }

        @Override
        public void onWriteDataFinish()
        {
            
        }
        
        @Override
        public void onScanBLEResult(String aBLEResult)
        {
            
        }
        

        @Override
        public void onBLEIndexChanged(int index) {
        }

        @Override
        public void onBLEBatteryStatusChanged(int battery) {

        }
    }
}
