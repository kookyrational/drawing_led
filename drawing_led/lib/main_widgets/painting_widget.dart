
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drawing_led/channel/background_process.dart';
import 'package:drawing_led/others_widgets/blocks_painter.dart';
import 'package:drawing_led/others_widgets/text_painter.dart';
import 'package:drawing_led/structures/blocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../defines.dart';
import '../utility.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:uuid/uuid.dart';
import 'package:toast/toast.dart';

class PaintingWidget extends StatefulWidget
{
  Size mScreenSize;

  int mPaddingSize;

  PaintingWidget(this.mScreenSize,this.mPaddingSize,{Key key}):super(key: key);

  @override
  PaintingStateWidget createState() => PaintingStateWidget();
}

class PaintingStateWidget extends State<PaintingWidget>
{
  List<List<Blocks>> mBlocksList;
  double mRSliderValue = 0;
  double mGSliderValue = 0;
  double mBSliderValue = 0;
  BlocksPainter mBlocksPainter;
  BlocksPainter mLastBlocksPainter;
  bool mIsLocked = false;
  TextsPainter mTextsPainter;

  @override
  void initState()
  {
    super.initState();

    mBlocksList = Utility.generateBlocksCoordinate(widget.mScreenSize,widget.mPaddingSize);
    mBlocksPainter = BlocksPainter(mBlocksList);
  }

  void update()
  {
    setState(() {
    });
  }

  void redo()
  {
    setState(() {
      mBlocksPainter = BlocksPainter(mLastBlocksPainter.mBlocksList);
      mBlocksPainter.mFocusCol = mLastBlocksPainter.mFocusCol;
      mBlocksPainter.mFocusRow = mLastBlocksPainter.mFocusRow;
    });
  }

  Future<void> saveBitmap() async
  {
    try
    {
      final ByteData byteData = await mBlocksPainter.generateImage();

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      String uniqueID = const Uuid().v1();
      //create file
      final String dir = (await getApplicationDocumentsDirectory()).path;
      final String fullPath = '$dir/${Defines.sImageFolder}/$uniqueID.png';
      File capturedFile = File(fullPath);
      await capturedFile.writeAsBytes(pngBytes);
      print(capturedFile.path);

      await GallerySaver.saveImage(capturedFile.path).then((value)
      {
        setState(()
        {
          Toast.show("圖片儲存成功", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
        });
      });
    } catch (e)
    {
      print(e);
    }
  }

  void clone()
  {
    List<List<Blocks>> temp = List.generate(16, (i) => List<Blocks>(16), growable: false);
    for(int i=0;i<mBlocksPainter.mBlocksList.length;i++)
    {
      for(int j=0;j<mBlocksPainter.mBlocksList[i].length;j++)
      {
        var newBlocks =  Blocks();
        newBlocks.mR = mBlocksPainter.mBlocksList[i][j].mR.toInt();
        newBlocks.mG = mBlocksPainter.mBlocksList[i][j].mG.toInt();
        newBlocks.mB = mBlocksPainter.mBlocksList[i][j].mB.toInt();
        newBlocks.mBlockRectangle = mBlocksPainter.mBlocksList[i][j].mBlockRectangle;
        temp[i][j] = newBlocks;
      }
    }

    int tempFocusCol= mBlocksPainter.mFocusCol;
    int tempFocusRow= mBlocksPainter.mFocusRow;
    mLastBlocksPainter = BlocksPainter(temp);
    mLastBlocksPainter.mFocusCol = tempFocusCol;
    mLastBlocksPainter.mFocusRow = tempFocusRow;
  }

  void fill()
  {
    clone();
    for(int i=0;i<mBlocksList.length;i++)
    {
      for(int j=0;j<mBlocksList[i].length;j++)
      {
        var newBlocks =  Blocks();
        newBlocks.mR = mRSliderValue.toInt();
        newBlocks.mG = mGSliderValue.toInt();
        newBlocks.mB = mBSliderValue.toInt();
        newBlocks.mBlockRectangle = mBlocksPainter.mBlocksList[i][j].mBlockRectangle;
        mBlocksPainter.mBlocksList[i][j] = newBlocks;
      }
    }

    setState(()
    {
      mBlocksPainter = BlocksPainter(mBlocksPainter.mBlocksList);
      mBlocksPainter.setFocusIndex(0, 0);
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return
      Column(
        children: [
              SizedBox(
                  width: widget.mScreenSize.width,
                  height: (mBlocksList[0][0].mBlockRectangle.height*16)+20,
                  child:
                  Container(
                      child:
                      GestureDetector(
                        child: CustomPaint(
                            painter: mBlocksPainter
                        ),
                        onPanDown: (DragDownDetails details)
                        {
                          clone();
                        },
                        onPanUpdate: (DragUpdateDetails details)
                        {
                          setState(()
                          {
                              RenderBox object = context.findRenderObject();
                              Offset _localPosition = object.globalToLocal(details.globalPosition);
                              for(int i=0;i<mBlocksList.length;i++)
                              {
                                for(int j=0;j<mBlocksList[i].length;j++)
                                {
                                  if(mBlocksList[i][j].mBlockRectangle.contains(Offset(_localPosition.dx,_localPosition.dy)))
                                  {
                                    setState(()
                                    {
                                      var newBlocks =  Blocks();
                                      newBlocks.mR = mRSliderValue.toInt();
                                      newBlocks.mG = mGSliderValue.toInt();
                                      newBlocks.mB = mBSliderValue.toInt();
                                      newBlocks.mBlockRectangle = mBlocksPainter.mBlocksList[i][j].mBlockRectangle;
                                      mBlocksPainter.mBlocksList[i][j] = newBlocks;
                                      mBlocksPainter = BlocksPainter(mBlocksPainter.mBlocksList);
                                      mBlocksPainter.setFocusIndex(i, j);
                                    });
                                    // return;
                                  }
                                }
                              }
                            },
                          );
                        },
                        onTapUp:(TapUpDetails details)
                        {
                          clone();
                          setState(()
                          {
                            RenderBox object = context.findRenderObject();
                            Offset _localPosition = object.globalToLocal(details.globalPosition);
                            for (int i = 0; i < mBlocksList.length; i++) {
                              for (int j = 0; j < mBlocksList[i].length; j++) {
                                if (mBlocksList[i][j].mBlockRectangle.contains(Offset(_localPosition.dx, _localPosition.dy)))
                                {
                                  setState(() {
                                    var newBlocks = Blocks();
                                    newBlocks.mR = mRSliderValue.toInt();
                                    newBlocks.mG = mGSliderValue.toInt();
                                    newBlocks.mB = mBSliderValue.toInt();
                                    newBlocks.mBlockRectangle = mBlocksPainter.mBlocksList[i][j].mBlockRectangle;
                                    mBlocksPainter.mBlocksList[i][j] = newBlocks;
                                    mBlocksPainter = BlocksPainter(
                                        mBlocksPainter.mBlocksList);
                                    mBlocksPainter.setFocusIndex(i, j);
                                  });
                                  // return;
                                }
                              }
                            }
                          });

                        },
                      )
                  )
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children:
                  [
                    const Expanded(
                      child:  Center(
                        child: Text("R",style: TextStyle(fontSize: 20,color: Colors.red),)
                    ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 9,
                      child:   Slider(
                        activeColor: Colors.red,
                        thumbColor:Colors.red,
                        value: mRSliderValue,
                        min: 0,
                        max: 255,
                        divisions: 255,
                        label: mRSliderValue.round().toString(),
                        onChangeEnd: (double value)
                        {
                          mRSliderValue = value;
                          setState(() {
                            mBlocksPainter.repaintR(value.toInt());
                          });
                        },
                        onChanged: (double value) {
                          setState(() {
                            mRSliderValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children:
                  [
                    const Expanded(
                      child:  Center(
                          child: Text("G",style: TextStyle(fontSize: 20,color:Colors.green),)
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 9,
                      child:   Slider(
                        activeColor: Colors.green,
                        thumbColor:Colors.green,
                        value: mGSliderValue,
                        min: 0,
                        max: 255,
                        divisions: 255,
                        label: mGSliderValue.round().toString(),
                        onChangeEnd: (double value)
                        {
                          mGSliderValue = value;
                          setState(() {
                            mBlocksPainter.repaintG(value.toInt());
                          });
                        },
                        onChanged: (double value) {
                          setState(() {
                            mGSliderValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding   (
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              children:
              [
                const Expanded(
                  child:  Center(
                      child: Text("B",style: TextStyle(fontSize: 20,color:Colors.blue),)
                  ),
                  flex: 1,
                ),
                Expanded(
                  flex: 9,
                  child:   Slider(
                    activeColor: Colors.blue,
                    thumbColor:Colors.blue,
                    value: mBSliderValue,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: mBSliderValue.round().toString(),
                    onChangeEnd: (double value)
                    {
                      mBSliderValue = value;
                      setState(() {
                        mBlocksPainter.repaintB(value.toInt());

                      });
                    },
                    onChanged: (double value) {
                      setState(() {
                        mBSliderValue = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(thickness: 2,),
          Row(
            children: [
              Expanded(
                child:
                    Center(
                    child:
                    TextButton(
                      onPressed: ()
                      {
                        if (!mIsLocked) {
                          for(int i=0;i<mBlocksList.length;i++)
                          {
                            for(int j=0;j<mBlocksList[i].length;j++)
                            {
                              var newBlocks =  Blocks();
                              newBlocks.mR = 0;
                              newBlocks.mG = 0;
                              newBlocks.mB = 0;
                              newBlocks.mBlockRectangle = mBlocksPainter.mBlocksList[i][j].mBlockRectangle;
                              mBlocksPainter.mBlocksList[i][j] = newBlocks;
                            }
                          }
                          setState(()
                            {
                              mBlocksPainter = BlocksPainter(mBlocksPainter.mBlocksList);
                              mBlocksPainter.setFocusIndex(0, 0);
                            },
                          );
                        }
                      },
                      style:ButtonStyle(
                          overlayColor:MaterialStateProperty.all(Colors.blue),
                          foregroundColor: MaterialStateProperty.resolveWith((states)
                          {
                            return states.contains(MaterialState.pressed) ? Colors.blue : Colors.grey;
                          }),
                          backgroundColor:MaterialStateProperty.all(Colors.grey)),
                      child:  Text("清除",style: TextStyle(color: Colors.white),),
                    )
                 ),
                flex: 1,
              ),
              Expanded(
                child:
                  Center(
                  child:
                      TextButton(
                        onPressed: () {
                          if (!mIsLocked) {
                            mIsLocked = true;
                            BackgroundProcess.invokeSendLEDData(Uint8List.fromList([0x5A, 0x45]));
                            int idOfLed = 0;
                            int idOfPCmd = 1;
                            Timer.periodic(const Duration(milliseconds: 50), (timer) {
                              List<int> data = [0x50, idOfPCmd];
                              for(int i = 0; i < 6; i++) {
                                var x = 15 - (idOfLed % 16);
                                var y = idOfLed ~/ 16;
                                data.add(mBlocksPainter.mBlocksList[y][x].mR.toInt());
                                data.add(mBlocksPainter.mBlocksList[y][x].mG.toInt());
                                data.add(mBlocksPainter.mBlocksList[y][x].mB.toInt());
                                idOfLed++;
                                if (idOfLed >= 256) {
                                  break;
                                }
                              }
                              BackgroundProcess.invokeSendLEDData(Uint8List.fromList(data));
                              idOfPCmd++;
                              if (idOfPCmd > 43) {
                                timer.cancel();
                                mIsLocked = false;
                              }
                            });
                          }
                        },
                        style:ButtonStyle(
                            overlayColor:MaterialStateProperty.all(Colors.blue),
                            foregroundColor: MaterialStateProperty.resolveWith((states)
                            {
                                return states.contains(MaterialState.pressed) ? Colors.blue : Colors.grey;
                            }),
                            backgroundColor:MaterialStateProperty.all(Colors.grey)),
                        child:  Text("送出",style: TextStyle(color: Colors.white),),
                      )
                ),
                flex: 1,
              )
            ],
          ),
        ],
      );
  }
}