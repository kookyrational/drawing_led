import 'dart:io';

import 'package:drawing_led/main_widgets/bright_widget.dart';
import 'package:drawing_led/main_widgets/painting_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'channel/background_process.dart';
import 'defines.dart';
import 'main_widgets/images_picker_widget.dart';
import 'main_widgets/images_widget.dart';
import 'main_widgets/texting_widget.dart';
import 'others_widgets/ble_scan_dialog.dart';
import 'others_widgets/disconnect_ble_dialog.dart';
import 'others_widgets/drawer_list_widget.dart';
import 'main_widgets/painting_widget.dart';
import 'structures/ble_address_structure.dart';
import 'utility.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toast/toast.dart';

void main()
{
  runApp(const MyApp());
}

typedef MyFunction = int Function(int, List<dynamic>);

class MyApp extends StatelessWidget
{
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(

      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget
{
  MyHomePage({Key key}) : super(key: key);

  String title = "塗鴉顯示";

  Size mScreenSize;

  PaintingWidget mPaintingWidget;

  ImagesWidget mImagesWidget;

  final _paintKey = GlobalKey<PaintingStateWidget>();
  final _imagePaintKey = GlobalKey<ImagesWidgetState>();

  Widget pageSelectedFunction(aDrawerItems)
  {
    switch(aDrawerItems)
    {
        case DrawerItems.PAINTING:
        {
          mPaintingWidget ??= PaintingWidget(mScreenSize,20,key:_paintKey);
          return mPaintingWidget;
        }
        case DrawerItems.TEXTING:
        {
          return TextingWidget(mScreenSize,20);
        }
        case DrawerItems.IMAGES:
        {
          mImagesWidget ??= ImagesWidget(mScreenSize,20,key:_imagePaintKey);
          return mImagesWidget;
        }
        case DrawerItems.BRIGHT:
        {
          return BrightWidget();
        }
    }
  }

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  SharedPreferences _prefs;

  List<BLEAddressStructure> mBLEScanStructure =[];

  ProgressDialog progressDialog;
  var assetsImageFile = ["apple.png","unknow.png"];

  DrawerItems aDrawerIndex = DrawerItems.PAINTING;

  bool mIsCopyImages = false;
  bool mIsScanBle = false;
  bool mIsConnected = false;
  bool mIsShowDisconnectBleDialog = false;

  Widget mPage;

  void changeTitle(String aTitle)
  {
    setState(() {
      widget.title = aTitle;
    });
  }

  @override
  void initState()
  {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    mIsScanBle = true;

    scanCallback(aActionCallBack, aBleScanResult)
    {
      if(aActionCallBack == Defines.bg_method_callback_start_scan)
      {
        mBLEScanStructure.clear();
        for(int i=0;i<aBleScanResult.length;i++)
        {
          mBLEScanStructure.add(BLEAddressStructure(aBleScanResult[i]));
        }
        setState(() {

        });
      }
      else if(aActionCallBack == Defines.bg_method_callback_start_connect)
      {
        setState(() {
          mIsScanBle = false;
          mIsConnected = true;
        });
      }
      else if(aActionCallBack == Defines.bg_method_callback_stop_scan)
      {
      }
      else if(aActionCallBack == Defines.bg_method_callback_send_led_data)
      {
      }
      else if(aActionCallBack == Defines.bg_method_callback_disconnect)
      {
        setState(()
        {
          mIsShowDisconnectBleDialog = false;
          mIsConnected = false;
        });
      }
    }

    BackgroundProcess.initialInvokeNativeMethod(scanCallback);


    if (Platform.isIOS)
    {
    }
    else
    {

      requestPermission(Permission.location).then((value)
      {
        if(!value)
        {
          Toast.show("請到設定中，手動開啟定位的使用權限", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
          SystemNavigator.pop();
        }
        else{
          requestPermission(Permission.locationAlways).then((value)
          {
            if(!value)
            {
              Toast.show("請到設定中，手動開啟定位的使用權限", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
              SystemNavigator.pop();
            }
            else{
                  requestPermission(Permission.storage).then((value)
                  {
                    if(value)
                    {
                      SharedPreferences.getInstance().then((prefsTemp)
                      {
                        _prefs = prefsTemp;
                        mIsCopyImages = prefsTemp.getBool(Defines.COPY_FILE_KEY) ?? false;

                        if(!mIsCopyImages)
                        {
                          copyFile();
                        }
                      });
                    }
                    else{
                      Toast.show("請到設定中，手動開啟讀取寫入外部檔案的使用權限", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                      SystemNavigator.pop();
                    }
                  });
            }
          });
        }
      });
    }
  }

  void copyFile() async
  {
    mIsCopyImages = true;
    await progressDialog.show();
    bool sum = await copyAssetsImagesFileToLocal();

    await progressDialog.hide();
    _prefs.setBool(Defines.COPY_FILE_KEY, true);
  }

  void getPreferences() async
  {
    SharedPreferences.getInstance().then((prefsTemp)
    {
      _prefs = prefsTemp;
      mIsCopyImages = prefsTemp.getBool(Defines.COPY_FILE_KEY) ?? false;

      if(!mIsCopyImages)
      {
        copyFile();
      }
    });
  }

  Future<bool> copyAssetsImagesFileToLocal() async
  {
    String dir = (await getApplicationDocumentsDirectory()).path;
    bool isSuccess = false;

    try{

      final Directory _appDocDirFolder = Directory('$dir/${Defines.sImageFolder}/');
      if(await _appDocDirFolder.exists())
      {

      }
      else{
        await _appDocDirFolder.create(recursive: true).then((value)
        {
          for(int i=0;i<assetsImageFile.length;i++)
          {
            rootBundle.load("assets/imagess/${assetsImageFile[i]}").then((bytes)
            {
                writeToFile(bytes,'$dir/${Defines.sImageFolder}/${assetsImageFile[i]}');
            });
          }
          isSuccess = true;
        });
      }
    }
    catch(e)
    {
      print("Copy file exception: ${e.toString()}");
    }

    return isSuccess;
    //read and write
    // final filename = 'test.pdf';
    // var bytes = await rootBundle.load("assets/data/test.pdf");
  }

  //write to app path
  Future<void> writeToFile(ByteData data, String path)
  {
    final buffer = data.buffer;
    return File(path).writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<bool> requestPermission(Permission permission) async
  {
    final status = await permission.request();

    return status.isGranted;
  }

  @override
  Widget build(BuildContext context)
  {
    widget.mScreenSize = MediaQuery.of(context).size;

    progressDialog = ProgressDialog(context);
    progressDialog.style( message: '準備中...', borderRadius: 10.0, backgroundColor: Colors.white, progressWidget: CircularProgressIndicator(), elevation: 10.0, insetAnimCurve: Curves.easeInOut, progressTextStyle: TextStyle( color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400), messageTextStyle: TextStyle( color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600) );

    if(widget.mScreenSize.isEmpty || widget.mScreenSize.width <=0 || widget.mScreenSize.height <=0)
    {
      setState(() {

      });
    }
    else{
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions:[
            (aDrawerIndex != DrawerItems.TEXTING && aDrawerIndex != DrawerItems.BRIGHT)?
            IconButton(
              icon: Image.asset('assets/save.png'),
              onPressed: ()
              {
                switch(aDrawerIndex)
                {
                  case DrawerItems.PAINTING:
                    {
                      widget._paintKey.currentState.saveBitmap();
                    }
                    break;
                  case DrawerItems.TEXTING:
                    {
                    }
                    break;
                  case DrawerItems.IMAGES:
                    {
                      widget._imagePaintKey.currentState.saveBitmap();
                    }
                    break;
                  case DrawerItems.BRIGHT:
                    {
                    }
                    break;
                }
              },
            ): Container(),
            (aDrawerIndex != DrawerItems.TEXTING && aDrawerIndex != DrawerItems.BRIGHT && aDrawerIndex != DrawerItems.IMAGES)?
            IconButton(
              icon: Image.asset('assets/fill.png'),
              onPressed: ()
              {
                switch(aDrawerIndex)
                {
                  case DrawerItems.PAINTING:
                    {
                      widget._paintKey.currentState.fill();
                    }
                    break;
                  case DrawerItems.TEXTING:
                    {
                    }
                    break;
                  case DrawerItems.IMAGES:
                    {
                      widget._imagePaintKey.currentState.fill();
                    }
                    break;
                  case DrawerItems.BRIGHT:
                    {
                    }
                    break;
                }
              },
            )
                : Container(),
            (aDrawerIndex != DrawerItems.TEXTING && aDrawerIndex != DrawerItems.BRIGHT)?
            IconButton(
              icon: Image.asset('assets/undo.png'),
              onPressed: ()
              {
                switch(aDrawerIndex)
                {
                  case DrawerItems.PAINTING:
                    {
                      widget._paintKey.currentState.redo();
                    }
                    break;
                  case DrawerItems.TEXTING:
                    {
                    }
                    break;
                  case DrawerItems.IMAGES:
                    {
                      widget._imagePaintKey.currentState.redo();
                    }
                    break;
                  case DrawerItems.BRIGHT:
                    {
                    }
                    break;
                }
              },
            ): Container(),
            IconButton(
              icon: mIsConnected?
              Image.asset('assets/ble_connect.png')
                  :
              Image.asset('assets/ble_disconnect.png'),
              onPressed: ()
              {
                if(!mIsConnected)
                {
                  mBLEScanStructure = [];
                  setState(() {
                    mIsScanBle = true;
                  });
                }
                else{
                  setState(() {
                    mIsShowDisconnectBleDialog = true;
                  });
                }
              },
            ),
          ],
        ),
        drawer: Drawer(
            child:
            DrawerListWidget(mDrawerClickCallBack: (aDrawerItems)
            {
              switch(aDrawerItems)
              {
                case DrawerItems.PAINTING:
                  {
                    aDrawerIndex = DrawerItems.PAINTING;
                    changeTitle(DrawerItems.PAINTING.name);
                  }
                  break;
                case DrawerItems.TEXTING:
                  {
                    aDrawerIndex = DrawerItems.TEXTING;
                    changeTitle(DrawerItems.TEXTING.name);
                  }
                  break;
                case DrawerItems.IMAGES:
                  {
                    aDrawerIndex = DrawerItems.IMAGES;
                    changeTitle(DrawerItems.IMAGES.name);
                  }
                  break;
                case DrawerItems.BRIGHT:
                  {
                    aDrawerIndex = DrawerItems.BRIGHT;
                    changeTitle(DrawerItems.BRIGHT.name);
                  }
                  break;
              }
            })
        ),
        body: Stack(
          children: [
            Container(
              child:
              mPage = widget.pageSelectedFunction(aDrawerIndex),
            ),
            Align(
                alignment: Alignment.center,
                child: mIsScanBle?
                BleScanDialog(mBLEScanStructure,(aAction,String aAddress)
                {
                  switch(aAction)
                  {
                    case Defines.BLE_SCAN_DIALOG_ACTON_SCAN:
                      {
                        BackgroundProcess.invokeStartScan();
                      }
                      break;
                    case Defines.BLE_SCAN_DIALOG_ACTON_CANCEL:
                      {
                        BackgroundProcess.invokeStopScan();
                        setState(() {
                          mIsScanBle = false;
                        });
                      }
                      break;
                    case Defines.BLE_SCAN_DIALOG_ACTON_CLICK_ITEM:
                      {
                        BackgroundProcess.invokeStartConnect(aAddress);
                      }
                      break;
                  }
                })
                    :
                Text("")
            ),
            Align(
                alignment: Alignment.center,
                child: mIsShowDisconnectBleDialog?
                DisconnectBleDialog((aAction)
                {
                  if(aAction)
                  {
                    BackgroundProcess.invokeDisconnect();
                    mIsConnected = false;
                  }
                  else{
                    setState(()
                    {
                      mIsShowDisconnectBleDialog = false;
                    });
                  }
                })
                    :
                Text("")
            )
          ],
        ),
      );
    }
  }
}
