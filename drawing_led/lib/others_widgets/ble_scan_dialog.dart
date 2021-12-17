

import 'package:drawing_led/structures/ble_address_structure.dart';
import 'package:flutter/material.dart';

import '../defines.dart';

class BleScanDialog extends StatefulWidget
{
  List<BLEAddressStructure> mBLEScanStructure;

  Function mBLEScanCallback;

  BleScanDialog(this.mBLEScanStructure,this.mBLEScanCallback);

  @override
  State<StatefulWidget> createState()
  {
    return BleScanDialogState();
  }
}

class BleScanDialogState extends State<BleScanDialog>
{

  @override
  Widget build(BuildContext context)
  {
    Size screenSize = MediaQuery.of(context).size;
    var reSizeWidth = screenSize.width/1.5;
    var reSizeHeight = reSizeWidth * 1.25;
    double textSize = (screenSize.width/20);

    return Container(
              width: screenSize.width,
              height: screenSize.height,
              decoration:
              const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Color.fromARGB(135, 0, 0, 0),
              ),
              child:
              Center(
                child:
                Container(
                    width: reSizeWidth,
                    height: reSizeHeight,
                    decoration:
                    BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(255, 192, 192, 192),
                          ),
                        ]
                    ),
                    child:
                    Center(
                      child:
                      Stack(
                        children: [
                          Align(
                              alignment: Alignment.bottomCenter,
                              child:
                              Padding(
                                padding: EdgeInsets.fromLTRB(20,0, 20, 15),
                                child:
                                Container(
                                    width: reSizeWidth,
                                    height: (reSizeHeight/3)*2.2,
                                    decoration:
                                    BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(22),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromARGB(255, 255, 255, 255),
                                          ),
                                        ]
                                    ),
                                    child:
                                    Column(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child:
                                          Align(
                                            alignment: Alignment.center,
                                            child:
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(10,10, 10, 10),
                                                  child:
                                                      SizedBox(
                                                        width: reSizeWidth,
                                                        height: (reSizeHeight/3)*2.2,
                                                        child:
                                                        ListView.separated(
                                                            padding: EdgeInsets.all(0),
                                                            itemCount: widget.mBLEScanStructure.length,
                                                            itemBuilder: (BuildContext context, int i)
                                                            {
                                                              return
                                                                InkWell(
                                                                    onTap: ()
                                                                    {
                                                                      widget.mBLEScanCallback(Defines.BLE_SCAN_DIALOG_ACTON_CLICK_ITEM,widget.mBLEScanStructure[i].mAddress);
                                                                    },
                                                                    child: SizedBox(
                                                                        height: reSizeWidth/5,
                                                                        child:
                                                                            Center(
                                                                              child:
                                                                              Text(widget.mBLEScanStructure[i].mAddress,style: TextStyle(fontSize: (reSizeWidth/5)/5),),
                                                                            )

                                                                    )
                                                                );
                                                            },
                                                            separatorBuilder: (BuildContext context, int i)
                                                            {
                                                              return const Divider(thickness: 2,color:Colors.black,);
                                                            }
                                                        ),
                                                      )
                                                )
                                          ),
                                        ),
                                        Expanded(
                                          child:
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child:
                                          Padding(
                                              padding:
                                              EdgeInsets.fromLTRB(0, 0, 0,10),
                                              child:
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                    Center(
                                                      child:
                                                      InkWell(
                                                          onTap: ()
                                                          {
                                                            print("取消");
                                                            widget.mBLEScanCallback(Defines.BLE_SCAN_DIALOG_ACTON_CANCEL,"");
                                                          },
                                                          child:
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                                            child:
                                                            Container(
                                                              width: reSizeWidth/3*2,
                                                              height: reSizeWidth/5,
                                                              alignment:
                                                              FractionalOffset.center,
                                                              decoration: const BoxDecoration(
                                                                color: Color.fromARGB(255, 68, 78, 114),
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(
                                                                        10.0)),
                                                              ),
                                                              child:
                                                              Text("取消",
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    letterSpacing: 0.3,
                                                                  )),
                                                            ),
                                                          )
                                                      ),
                                                    ),
                                                    flex: 1,
                                                  ),
                                                  Expanded(
                                                    child:
                                                    Center(
                                                      child:
                                                      InkWell(
                                                          onTap: ()
                                                          {
                                                            widget.mBLEScanCallback(Defines.BLE_SCAN_DIALOG_ACTON_SCAN,"");
                                                          },
                                                          child:
                                                          Padding(
                                                            padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                                            child:
                                                            Container(
                                                              width: reSizeWidth/3*2,
                                                              height: reSizeWidth/5,
                                                              alignment:
                                                              FractionalOffset.center,
                                                              decoration: const BoxDecoration(
                                                                color: Color.fromARGB(255, 68, 78, 114),
                                                                borderRadius: BorderRadius.all(
                                                                    Radius.circular(
                                                                        10.0)),
                                                              ),
                                                              child: Text("搜尋",
                                                                  style: TextStyle(
                                                                    color: Colors.white,
                                                                    letterSpacing: 0.3,
                                                                  )),
                                                            ),
                                                          )
                                                      ),
                                                    ),
                                                    flex: 1,
                                                  ),
                                                ],
                                              )
                                          ),
                                        ),
                                        flex: 1,),
                                      ],
                                    )
                                ),
                              )
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child:
                            Container(
                                alignment: Alignment.topLeft,
                                child:
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
                                  child:
                                  Column(
                                    children: [
                                      Text("搜尋藍芽",
                                        style: TextStyle(
                                            fontSize: textSize,
                                            color: Color.fromARGB(255, 68, 78, 114)
                                        ),)
                                    ],
                                  ),
                                )
                            ),
                          ),

                        ],
                      ),
                    )
                ),
              )
          );
  }
}