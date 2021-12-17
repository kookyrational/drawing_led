package com.spreadout.drawing_led;

import android.app.ProgressDialog;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler,BleCallBack
{
    private final int ENABLE_BLUETOOTH_REQUESTCODE = 2019;

    private final int SEARCH_PEN_INTERVALS_TIME = 6500;

    private BleWrapper mBleWrapper;

    private MethodChannel mMethodChannel;
    
    private List<String> mBLERSSI = null;
    
    Handler mMainActivityHandler = new Handler()
    {
        public void handleMessage(Message msg)
        {
            if (msg.what == R.id.search_ble)
            {
                if (mBleWrapper != null)
                {
                    if (!mBleWrapper.isConnected())
                        new SearchBLEAsyncTask().execute();
                }
            }
            super.handleMessage(msg);
        }
    };

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine)
    {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

          mMethodChannel = new MethodChannel(flutterEngine.getDartExecutor(), Define.Channel.MethodChannel);
          mMethodChannel.setMethodCallHandler(this);

          if (mBleWrapper == null)
          {
              mBleWrapper = new BleWrapper(this, this, mMainActivityHandler);
              mBleWrapper.initialize();
          }
    }

    private Runnable mDeviceNotFoundRunnable = new Runnable()
    {
        @Override
        public void run()
        {
            if (mBleWrapper != null)
            {
                mBleWrapper.stopScanning();
                if (mBleWrapper.isConnected())
                    mBleWrapper.disconnect();
            }

            mMainActivityHandler.removeCallbacks(mDeviceNotFoundRunnable);
            mMainActivityHandler.sendEmptyMessage(R.id.search_ble);
        }
    };

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result)
    {
        String method = call.method;
        if (method.equals(Define.ChannelMethod.bg_method_start_scan))
        {
            if(mBLERSSI==null)
                mBLERSSI = new ArrayList();
            else
                mBLERSSI.clear();

            if (mBleWrapper != null)
            {
                if (!mBleWrapper.isConnected())
                    new SearchBLEAsyncTask().execute();
            }
        }
        else if (method.equals(Define.ChannelMethod.bg_method_stop_scan))
        {
            mMainActivityHandler.removeCallbacks(mDeviceNotFoundRunnable);
            if (mBleWrapper != null)
            {
                if (!mBleWrapper.isConnected())
                    mBleWrapper.stopScanning();
            }
        }
        else if(method.equals(Define.ChannelMethod.bg_method_start_connect))
        {
            mMainActivityHandler.removeCallbacks(mDeviceNotFoundRunnable);

            if (call.arguments != null)
            {
                if(call.arguments instanceof ArrayList)
                {
                    ArrayList<String> address = (ArrayList<String>)call.arguments;
                    if(mBleWrapper!=null)
                    {
                        mBleWrapper.startConnect(address.get(0));
                    }
                }
            }
        }
        else if(method.equals(Define.ChannelMethod.bg_method_send_led_data))
        {
            if (call.arguments != null)
            {
                if(call.arguments instanceof byte[])
                {
                    byte[] data = (byte[])call.arguments;
                    if(mBleWrapper!=null)
                    {
                        mBleWrapper.writeCharacteristics(data);
                    }
                }
            }
        }
        else if(method.equals(Define.ChannelMethod.bg_method_disconnect))
        {
            if(mBleWrapper!=null)
            {
                mBleWrapper.disconnect();
            }
        }
    }

    @Override
    protected void onDestroy()
    {
        super.onDestroy();
        if(mBleWrapper!=null)
        {
            mBleWrapper.disconnect();
        }
    }

    @Override
    public void onBLEConnected()
    {

        //連線成功
        mMethodChannel.invokeMethod(Define.ChannelMethod.bg_method_callback_start_connect,"");
    }

    @Override
    public void onBLEDisconnected()
    {

        mMethodChannel.invokeMethod(Define.ChannelMethod.bg_method_callback_disconnect,"");
    }
    
    @Override
    public void onWriteDataFinish()
    {
        mMethodChannel.invokeMethod(Define.ChannelMethod.bg_method_callback_send_led_data,"");
    }

    @Override
    public void onScanBLEResult(String aBLEAddress)
    {

        boolean isDuplicate = false;
        for(String address:mBLERSSI)
        {
            if(address.equals(aBLEAddress))
            {
                isDuplicate = true;
                break;
            }
        }

        if(!isDuplicate) 
        {
            mBLERSSI.add(aBLEAddress);
            mMethodChannel.invokeMethod(Define.ChannelMethod.bg_method_callback_start_scan,mBLERSSI);
        }
    }

    @Override
    public void onBLEIndexChanged(int index)
    {

    }

    @Override
    public void onBLEBatteryStatusChanged(int battery)
    {

    }

    class SearchBLEAsyncTask extends AsyncTask<Void, Integer, String>
    {
        protected void onPreExecute()
        {
        }

        protected String doInBackground(Void... urls)
        {
            if (!mBleWrapper.isConnected())
            {
                mMainActivityHandler.removeCallbacks(mDeviceNotFoundRunnable);
                mBleWrapper.startScanning();
                mMainActivityHandler.postDelayed(mDeviceNotFoundRunnable, SEARCH_PEN_INTERVALS_TIME);
            }
            return "ok";
        }

        @Override
        protected void onProgressUpdate(Integer... progress)
        {
        }

        protected void onPostExecute(String result)
        {
        }
    }
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        super.onActivityResult(requestCode, resultCode, data);
        
         //載入圖片
        if(requestCode == ENABLE_BLUETOOTH_REQUESTCODE && resultCode == RESULT_CANCELED)
        {
            MainActivity.this.finish();
        }
    }
}
