import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:drawing_led/channel/background_process.dart';
import 'package:drawing_led/others_widgets/blocks_painter.dart';
import 'package:drawing_led/structures/blocks.dart';
import 'package:flutter/material.dart';
import '../utility.dart';

class PreviewWidget extends StatefulWidget {
  Size mScreenSize;

  int mPaddingSize;

  List<Uint16List> mText;

  PreviewWidget(this.mScreenSize, this.mPaddingSize, this.mText, {Key key})
      : super(key: key);

  @override
  _PreviewWidget createState() => _PreviewWidget();
}

class _PreviewWidget extends State<PreviewWidget> {
  List<List<Blocks>> mBlocksList;
  double mRSliderValue = 255;
  double mGSliderValue = 255;
  double mBSliderValue = 255;
  BlocksPainter mBlocksPainter;
  int mPreviewOffset = 0;
  Timer mPreviewTimer;
  Timer mActualTimer;
  bool mIsLocked = false;

  void updateBlocks(int r, int g, int b) {
    var nL = mPreviewOffset ~/ 16;
    var nR = ((mPreviewOffset ~/ 16) + 1) % min(widget.mText.length, 20);
    var cL = widget.mText[nL];
    var cR = widget.mText[nR];
    Uint16List cM = Uint16List(16);
    var offset = mPreviewOffset % 16;
    for (int i = 0; i < 16; i++) {
      var pL = cL[i] << offset;
      var pR = cR[i] >> (16 - offset);
      cM[i] = pL | pR;
    }
    for (int j = 0; j < 16; j++) {
      var byte = cM[j];
      for (int i = 0; i < 16; i++) {
        if ((byte & 0x8000) > 0) {
          if (r >= 0) {
            mBlocksList[j][i].mR = r;
          }
          if (g >= 0) {
            mBlocksList[j][i].mG = g;
          }
          if (b >= 0) {
            mBlocksList[j][i].mB = b;
          }
        } else {
          mBlocksList[j][i].mR = 0;
          mBlocksList[j][i].mG = 0;
          mBlocksList[j][i].mB = 0;
        }
        byte <<= 1;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    mBlocksList = Utility.generateBlocksCoordinate(
        widget.mScreenSize, widget.mPaddingSize);
    updateBlocks(
        mRSliderValue.toInt(), mGSliderValue.toInt(), mBSliderValue.toInt());
    mBlocksPainter = BlocksPainter(mBlocksList);
    mPreviewTimer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      mPreviewOffset += 1;
      if (mPreviewOffset >= min(widget.mText.length, 160~/8) * 16) {
        mPreviewOffset = 0;
      }
      setState(() {
        updateBlocks(mRSliderValue.toInt(), mGSliderValue.toInt(),
            mBSliderValue.toInt());
        mBlocksPainter = BlocksPainter(mBlocksList);
      });
    });
  }

  @override
  void dispose() {
    mPreviewTimer?.cancel();
    mActualTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('預覽'),
      ),
      body: Column(
        children: [
          SizedBox(
              width: widget.mScreenSize.width,
              height: (mBlocksList[0][0].mBlockRectangle.height * 16) + 20,
              child: GestureDetector(
                child: CustomPaint(painter: mBlocksPainter),
                onPanDown: (DragDownDetails details) {
                  //
                },
                onPanUpdate: (DragUpdateDetails details) {
                  //
                },
                onTapUp: (TapUpDetails details) {
                  //
                },
              )),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Center(
                      child: Text(
                    "R",
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  )),
                  flex: 1,
                ),
                Expanded(
                  flex: 9,
                  child: Slider(
                    activeColor: Colors.red,
                    thumbColor: Colors.red,
                    value: mRSliderValue,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: mRSliderValue.round().toString(),
                    onChangeEnd: (double value) {
                      mRSliderValue = value;
                      setState(() {
                        updateBlocks(value.toInt(), -1, -1);
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
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Center(
                      child: Text(
                    "G",
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  )),
                  flex: 1,
                ),
                Expanded(
                  flex: 9,
                  child: Slider(
                    activeColor: Colors.green,
                    thumbColor: Colors.green,
                    value: mGSliderValue,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: mGSliderValue.round().toString(),
                    onChangeEnd: (double value) {
                      mGSliderValue = value;
                      setState(() {
                        updateBlocks(-1, value.toInt(), -1);
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
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Center(
                      child: Text(
                    "B",
                    style: TextStyle(fontSize: 20, color: Colors.blue),
                  )),
                  flex: 1,
                ),
                Expanded(
                  flex: 9,
                  child: Slider(
                    activeColor: Colors.blue,
                    thumbColor: Colors.blue,
                    value: mBSliderValue,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: mBSliderValue.round().toString(),
                    onChangeEnd: (double value) {
                      mBSliderValue = value;
                      setState(() {
                        updateBlocks(-1, -1, value.toInt());
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
          const Divider(
            thickness: 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                  child: TextButton(
                onPressed: () {
                  if (!mIsLocked) {
                    mIsLocked = true;
                    mActualTimer?.cancel();
                    BackgroundProcess.invokeSendLEDData(Uint8List.fromList([0x5A, 0x45]));
                    int r = mRSliderValue.toInt();
                    int g = mGSliderValue.toInt();
                    int b = mBSliderValue.toInt();
                    int idOfLed = 0;
                    int idOfPCmd = 1;
                    int actualOffset = 0;

                    mActualTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {

                      var nL = actualOffset ~/ 16;
                      var nR = ((actualOffset ~/ 16) + 1) % min(widget.mText.length, 160~/8);
                      var cL = widget.mText[nL];
                      var cR = widget.mText[nR];
                      Uint16List cM = Uint16List(16);
                      var offset = actualOffset % 16;
                      for (int i = 0; i < 16; i++) {
                        var pL = cL[i] << offset;
                        var pR = cR[i] >> (16 - offset);
                        cM[i] = pL | pR;
                      }

                      List<int> data = [0x50, idOfPCmd];
                      for(int i = 0; i < 6; i++) {
                        var row = cM[idOfLed ~/ 16];
                        var mask = 0x0001 << (idOfLed%16);
                        if (row & mask > 0) {
                          data.add(r);
                          data.add(g);
                          data.add(b);
                        } else {
                          data.add(0);
                          data.add(0);
                          data.add(0);
                        }
                        idOfLed++;
                        if (idOfLed >= 256) {
                          break;
                        }
                      }
                      BackgroundProcess.invokeSendLEDData(Uint8List.fromList(data));
                      idOfPCmd++;
                      if (idOfPCmd > 43) {
                        idOfLed = 0;
                        idOfPCmd = 1;
                        actualOffset++;
                        if (actualOffset >= min(widget.mText.length, 20) * 16) {
                          actualOffset = 0;
                        }
                        mIsLocked = false;
                      }
                    });
                  }
                },
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.blue),
                    foregroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      return states.contains(MaterialState.pressed)
                          ? Colors.blue
                          : Colors.grey;
                    }),
                    backgroundColor: MaterialStateProperty.all(Colors.grey)),
                child: const Text(
                  "送出",
                  style: TextStyle(color: Colors.white),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
