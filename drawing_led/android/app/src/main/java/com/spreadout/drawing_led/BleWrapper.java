package com.spreadout.drawing_led;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothProfile;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Handler;
import android.util.Log;

import java.util.Arrays;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

public class BleWrapper
{
    public static final String LED_BLE = "LED_BLE";
    
    public static final int CONNECT_BLUETOOTH = -999999;

    private static final int RSSI_UPDATE_TIME_INTERVAL = 1500; // 1.5 seconds

    private static final BleCallBack NULL_CALLBACK = new BleCallBack.Null();
    
    private boolean mTimerEnabled = false;
    private boolean cmd_sending = false;
    private boolean mConnected = false;
    private boolean mIsConnecting = false;
    
    private String mMaxAddress = "";
    
    private String mDeviceAddress = "";

    private Activity mParent = null;

    private BluetoothManager mBluetoothManager = null;
    private BluetoothAdapter mBluetoothAdapter = null;
    private BluetoothDevice mBluetoothDevice = null;
    private BluetoothGatt mBluetoothGatt = null;
    
    private BluetoothGattCharacteristic mLEDCharGatt;

    private Hashtable<String, Integer> mBLERSSI = null;
    
    private List<BluetoothGattService> mBluetoothGattServices = null;

    private BleCallBack mBleCallback = null;
    
    private Handler mTimerHandler = new Handler();
    
    private Handler mMainactivityHandler;
    
    public BleWrapper(Activity parent, BleCallBack aBleCallback,Handler aMainactivityHandler)
    {
        mParent = parent;
        mBleCallback = aBleCallback;
        mMainactivityHandler = aMainactivityHandler;
        if (mBleCallback == null)
        {
            mBleCallback = NULL_CALLBACK;
        }
    }
    
    public boolean isConnected()
    {
        return mConnected;
    }
    
    public boolean initialize()
    {
        if (mBluetoothManager == null)
        {
            mBluetoothManager = (BluetoothManager) mParent.getSystemService(Context.BLUETOOTH_SERVICE);
            if (mBluetoothManager == null)
            {
                return false;
            }
        }

        if (mBluetoothAdapter == null)
            mBluetoothAdapter = mBluetoothManager.getAdapter();
        
        if (mBluetoothAdapter == null)
            return false;
        
        return true;
    }
    
    public void disconnect()
    {
        if (mBluetoothGatt != null)
        {
            mBluetoothGatt.disconnect();
        }
    }
    
    private void resetConfigs()
    {
        mLEDCharGatt = null;
        mIsConnecting = false;
        mBLERSSI = null;
        mBluetoothManager = null;
        mBluetoothAdapter = null;
        mBluetoothDevice = null;
        mBluetoothGatt = null;
        this.initialize();
    }
    
    public boolean checkBleHardwareAvailable()
    {
        final BluetoothManager manager = (BluetoothManager) mParent.getSystemService(Context.BLUETOOTH_SERVICE);
        if (manager == null)
            return false;

        final BluetoothAdapter adapter = manager.getAdapter();
        if (adapter == null)
        {
            return false;
        }

        boolean hasBle = mParent.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE);
        return hasBle;
    }
    
    public boolean isBtEnabled()
    {
        final BluetoothManager manager = (BluetoothManager) mParent.getSystemService(Context.BLUETOOTH_SERVICE);
        if (manager == null)
        {
            return false;
        }

        final BluetoothAdapter adapter = manager.getAdapter();
        if (adapter == null)
        {
            return false;
        }
        if (!adapter.isEnabled())
        {
            return adapter.enable();
        }
        return true;
    }

    public void startScanning()
    {
        mBluetoothAdapter.startLeScan(mDeviceFoundCallback);
    }

    public void stopScanning()
    {
        if (mBluetoothAdapter != null)
        {
            try
            {
                mBluetoothAdapter.stopLeScan(mDeviceFoundCallback);
            } catch (Exception e)
            {
                e.printStackTrace();
            }
        }
    }
    
    public boolean connect(final String deviceAddress)
    {
        if (mBluetoothAdapter == null || deviceAddress == null)
            return false;
        
        mDeviceAddress = deviceAddress;

        if (mBluetoothGatt != null && mBluetoothGatt.getDevice().getAddress().equals(deviceAddress))
        {
            return mBluetoothGatt.connect();
        }
        else
        {
            mBluetoothDevice = mBluetoothAdapter.getRemoteDevice(mDeviceAddress);
            if (mBluetoothDevice == null)
            {
                return false;
            }
            mBluetoothGatt = mBluetoothDevice.connectGatt(mParent, false, mBleGattCallback);
        }
        return true;
    }
    
    public void startConnect(String aAddress)
    {
        mMainactivityHandler.sendEmptyMessage(CONNECT_BLUETOOTH);

        if (!mIsConnecting)
        {
            if (this != null)
            {
                stopScanning();
            }
            int max_rssi = -100000000;
            if (mBLERSSI != null)
            {
                Iterator<String> iterator = mBLERSSI.keySet().iterator();
                while (iterator.hasNext())
                {
                    String address = (String) iterator.next();
                    
                    if(aAddress.equals(address))
                    {
                        mMaxAddress = address;
                        break;
                    }
                }
            }
            
            mBLERSSI = null;
            mParent.runOnUiThread(new Runnable()
            {
                @Override
                public void run()
                {
                    connect(mMaxAddress);
                }
            });
            mIsConnecting = true;
        }
    }
    
    public void startServicesDiscovery()
    {
        if (mBluetoothGatt != null)
            mBluetoothGatt.discoverServices();
    }

    public void setNotificationForCharacteristic(BluetoothGattCharacteristic ch, boolean enabled)
    {
        if (mBluetoothAdapter == null || mBluetoothGatt == null)
        {
            return;
        }
        mBluetoothGatt.setCharacteristicNotification(ch, enabled);

        BluetoothGattDescriptor descriptor = ch.getDescriptor(UUID.fromString("00002902-0000-1000-8000-00805f9b34fb"));
        if (descriptor != null)
        {
            byte[] val = enabled ? BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE : BluetoothGattDescriptor.DISABLE_NOTIFICATION_VALUE;
            descriptor.setValue(val);
            mBluetoothGatt.writeDescriptor(descriptor);
        }
    }
    
    public void getCharacteristicsForService(final BluetoothGattService service)
    {
        if (service == null)
        {
            return;
        }
        List<BluetoothGattCharacteristic> chars = null;

        chars = service.getCharacteristics();

        for (BluetoothGattCharacteristic gattchar : chars)
        {
            if (gattchar.getUuid().equals(BleUUIDs.Characteristic.LED_SERVICE))
            {
                mLEDCharGatt = gattchar;
                setNotificationForCharacteristic(mLEDCharGatt, true);
            }
        }
    }
    
    public void getCharacteristicValue(BluetoothGattCharacteristic ch)
    {
        if (mBluetoothAdapter == null || mBluetoothGatt == null || ch == null)
        {
            return;
        }
    }
    
    public void getSupportedServices()
    {
        if (mBluetoothGattServices != null && mBluetoothGattServices.size() > 0)
        {
            mBluetoothGattServices.clear();
        }
        if (mBluetoothGatt != null)
        {
            mBluetoothGattServices = mBluetoothGatt.getServices();
        }
        for (BluetoothGattService service : mBluetoothGattServices)
        {
            if (service.getUuid().equals(BleUUIDs.Service.LED_SERVICE))
            {
                getCharacteristicsForService(service);
            }
        }
    }

    public void writeCharacteristics(byte[] databuffer)
    {
        int totalLength = databuffer.length;
        int bytecountstart = 0;
        int idx2 = 0;
        byte[] datatmp;
        cmd_sending = false;

        while(true)
        {
            int length = ((totalLength/20) > 0) ? 20 : (totalLength%20);
            do {
                if (totalLength <= 0)
                {
                    mBleCallback.onWriteDataFinish();
                    return;
                }
            } while(cmd_sending);

            datatmp = new byte[length];

            for(int idx1 = bytecountstart; idx1 < bytecountstart + length; ++idx1) {
                datatmp[idx2++] = databuffer[idx1];
            }

            totalLength -= length;
            bytecountstart += length;
            cmd_sending = true;
            mLEDCharGatt.setValue(datatmp);
            mBluetoothGatt.writeCharacteristic(mLEDCharGatt);
        }
    }

    private BluetoothAdapter.LeScanCallback mDeviceFoundCallback = new BluetoothAdapter.LeScanCallback()
    {
        @Override
        public void onLeScan(final BluetoothDevice device, final int rssi, final byte[] scanRecord)
        {
            String btName = device.getName();
            String address = device.getAddress();
            String Type = String.valueOf(device.getType());
            
                    if (mBLERSSI == null)
                    {
                        mBLERSSI = new Hashtable<String, Integer>();
                    }
                    
                    if (!mBLERSSI.containsKey(device.getAddress()))
                    {
                        mBLERSSI.put(device.getAddress(), rssi);
                        mBleCallback.onScanBLEResult(device.getAddress());
                    }
                    else{
                    }
        }
    };

    private final BluetoothGattCallback mBleGattCallback = new BluetoothGattCallback()
    {
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState)
        {
            if (newState == BluetoothProfile.STATE_CONNECTED)
            {
                mConnected = true;
                mParent.runOnUiThread(new Runnable()
                {
                    @Override
                    public void run()
                    {
                        mBleCallback.onBLEConnected();
                    }
                });
                
                mBluetoothGatt.readRemoteRssi();
                
                startServicesDiscovery();

            } else if (newState == BluetoothProfile.STATE_DISCONNECTED)
            {
                mConnected = false;
                resetConfigs();
                mParent.runOnUiThread(new Runnable()
                {
                    @Override
                    public void run()
                    {
                        mBleCallback.onBLEDisconnected();
                    }
                });
            }

            mBLERSSI = null;
            if (this != null)
            {
                stopScanning();
            }
        }

        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status)
        {
            if (status == BluetoothGatt.GATT_SUCCESS)
            {
                getSupportedServices();
            }
        }

        @Override
        public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status)
        {
            if (status == BluetoothGatt.GATT_SUCCESS)
            {
                cmd_sending = false;
            }
        }

        @Override
        public void onCharacteristicRead(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status)
        {
            if (status == BluetoothGatt.GATT_SUCCESS)
            {
                getCharacteristicValue(characteristic);
            }
            
            if (characteristic != null)
            {
                if (BleUUIDs.Characteristic.BATTERY_LEVEL.equals(characteristic.getUuid()))
                {
                    byte[] percent = characteristic.getValue();
                    mBleCallback.onBLEBatteryStatusChanged((int) percent[0]);
                }
            }
        }

        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic)
        {
            getCharacteristicValue(characteristic);
            byte[] rawValue = characteristic.getValue();
            final int index = rawValue[0] - 1;
            if (characteristic.getUuid().equals(BleUUIDs.Characteristic.LED_SERVICE))
            {
                if (mLEDCharGatt != null)
                {
                    setNotificationForCharacteristic(mLEDCharGatt, true);
                }
            }
        }
    };
}
