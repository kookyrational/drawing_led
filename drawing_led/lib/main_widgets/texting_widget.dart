import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:drawing_led/channel/background_process.dart';
import 'package:drawing_led/main_widgets/preview_widget.dart';
import 'package:drawing_led/others_widgets/text_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextingWidget extends StatefulWidget {
  Size mScreenSize;

  int mPaddingSize;

  TextingWidget(this.mScreenSize, this.mPaddingSize, {Key key})
      : super(key: key);

  @override
  _TextingWidget createState() => _TextingWidget();
}

class _TextingWidget extends State<TextingWidget> {
  String mText = '';
  var mTextController = TextEditingController();
  Timer mActualTimer;
  bool mIsLocked = false;

  TextsPainter mTextsPainter;

  @override
  void dispose() {
    mActualTimer?.cancel();
    super.dispose();
  }

  Future<List<Uint16List>> generateTextUint32List(String str) async {

    const TextStyle style = TextStyle(
      color: Colors.white,
      fontSize: 15.0,
      fontFamily: 'FreePixel',
      fontWeight: FontWeight.w100,
      // TODO Add more for testing ;)
    );

    List<Uint16List> dotCharList = [];
    for (var c in str.split('')) {

      final recorder = ui.PictureRecorder();

      final canvas = Canvas(
          recorder,
          const Rect.fromLTRB(0,0,16,16));

      final TextPainter textPainter = TextPainter(
          text: TextSpan(text: c, style: style), // TextSpan could be whole TextSpans tree :)
          textAlign: TextAlign.center,
          //maxLines: 25, // In both TextPainter and Paragraph there is no option to define max height, but there is `maxLines`
          textDirection: TextDirection.ltr // It is necessary for some weird reason... IMO should be LTR for default since well-known international languages (english, esperanto) are written left to right.
      )
        ..layout(maxWidth: 16); // TextPainter doesn't need to have specified width (would use infinity if not defined).
      // BTW: using the TextPainter you can check size the text take to be rendered (without `paint`ing it).
      textPainter.paint(canvas, Offset((16 - textPainter.width) * 0.5, (16 - textPainter.height) * 0.5,));

      final picture = recorder.endRecording();

      final img = await picture.toImage((16), (16));

      final pngBytes = await img.toByteData(format: ImageByteFormat.rawRgba);
      final Uint32List pixelList = pngBytes.buffer.asUint32List();

      Uint16List dotChar = Uint16List(16);
      for (int i = 0; i < 16; i++) {
        var row = 0;
        var mask = 0x8000;
        for (int j = 0; j < 16; j++) {
          if (pixelList[i*16+j] > 0x77777777) {
            row |= mask;
          }
          mask >>= 1;
        }
        dotChar[i] = row;
      }
      dotCharList.add(dotChar);
    }
    return dotCharList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(30),
            child: TextField(
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(), hintText: '輸入文字'),
              maxLength: 20,
              onChanged: (text) {
                mText = text;
              },
              controller: mTextController,
            ),
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
                  mText = '';
                  mTextController.clear();
                }
              },
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.blue),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                    return states.contains(MaterialState.pressed)
                        ? Colors.blue
                        : Colors.grey;
                  }),
                  backgroundColor: MaterialStateProperty.all(Colors.grey)),
              child: const Text(
                "清除",
                style: TextStyle(color: Colors.white),
              ),
            )),
            Center(
                child: TextButton(
                  onPressed: () {
                    if (!mIsLocked) {
                      generateTextUint32List(mText).then((list) {
                        if (list.isNotEmpty) {
                          mActualTimer?.cancel();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PreviewWidget(widget.mScreenSize, 20, list)));
                        }
                      });
                    }
                  },
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.blue),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                    return states.contains(MaterialState.pressed)
                        ? Colors.blue
                        : Colors.grey;
                  }),
                  backgroundColor: MaterialStateProperty.all(Colors.grey)),
              child: const Text(
                "預覽",
                style: TextStyle(color: Colors.white),
              ),
            )),
            Center(
                child: TextButton(
              onPressed: () {
                if (!mIsLocked) {
                  mIsLocked = true;
                  generateTextUint32List(mText).then((list) {
                    if (list.isNotEmpty) {
                      mActualTimer?.cancel();
                      BackgroundProcess.invokeSendLEDData(Uint8List.fromList([0x5A, 0x45]));
                      int idOfLed = 0;
                      int idOfPCmd = 1;
                      int actualOffset = 0;

                      mActualTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {

                        var nL = actualOffset ~/ 16;
                        var nR = ((actualOffset ~/ 16) + 1) % min(list.length, 160~/8);
                        var cL = list[nL];
                        var cR = list[nR];
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
                            data.add(0xff);
                            data.add(0xff);
                            data.add(0xff);
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
                          if (actualOffset >= min(mText.length, 20) * 16) {
                            actualOffset = 0;
                          }
                          mIsLocked = false;
                        }
                      });
                    }
                  });
                }
              },
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.blue),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
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
        CustomPaint(
          painter: mTextsPainter
        ),
      ],
    );
  }
}
