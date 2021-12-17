

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:ui';

import 'package:drawing_led/structures/blocks.dart';
import 'package:flutter/material.dart';

class TextsPainter extends CustomPainter
{
  Paint mWirePaint;

  int mFocusRow = 0;
  int mFocusCol = 0;

  var mSize;

  Color mColor;

  String mText;

  TextsPainter(String aText)
  {
    mText = aText;
    mWirePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
  }

  void setFocusIndex(int row,int col)
  {
    mFocusRow = row;
    mFocusCol = col;
  }

  Future<ByteData> generateImage() async
  {
    final recorder = ui.PictureRecorder();

    final canvas = Canvas(
        recorder,
        Rect.fromLTRB(0,0,16,16));

    final TextStyle style = TextStyle(
      color: Colors.white,
      fontSize: 15.0,
      fontFamily: 'FreePixel',
      fontWeight: FontWeight.w100,
    );

    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: "好", style: style),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr
    )
      ..layout(maxWidth: 16);

    textPainter.paint(canvas, Offset((16 - textPainter.width) * 0.5, (16 - textPainter.height) * 0.5,));

    final picture = recorder.endRecording();

    final img = await picture.toImage((16), (16));

    final pngBytes = await img.toByteData(format: ImageByteFormat.png);
    return pngBytes;
  }

  void repaintRGB(int aR,int aG,int aB)
  {
    mColor = Color.fromARGB(255, aR, aG, aB);
  }

  @override
  void paint(Canvas canvas, Size size)
  {
    mSize = size;

    final TextStyle style = TextStyle(
      color: Colors.black,
      fontSize: 5,
    );

    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: "嗨", style: style),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr
    )
      ..layout(maxWidth: 16);
    textPainter.paint(canvas, const Offset(0,0));
  }

  @override
  bool shouldRepaint(TextsPainter oldDelegate)
  {
     return true;
  }
}