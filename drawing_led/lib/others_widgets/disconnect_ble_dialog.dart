

import 'package:flutter/material.dart';

class DisconnectBleDialog extends StatefulWidget
{

  Function mDisconnectBLECallback;

  DisconnectBleDialog(this.mDisconnectBLECallback);

  @override
  State<StatefulWidget> createState()
  {
    return DisconnectBleDialogState();
  }
}

class DisconnectBleDialogState extends State<DisconnectBleDialog>
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
                                      color: Color.fromARGB(255, 192, 192, 192),
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
                                                Text("")
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
                                                        widget.mDisconnectBLECallback(false);
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
                                                        widget.mDisconnectBLECallback(true);
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
                                                          child: Text("斷線",
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
                                Text("中斷藍芽連接",
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
    // );
  }
}