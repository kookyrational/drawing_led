

import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:ui';

import 'package:drawing_led/structures/blocks.dart';
import 'package:flutter/material.dart';

class BlocksPainter extends CustomPainter
{
  List<List<Blocks>> mBlocksList;
  Paint mWirePaint;

  int mFocusRow = 0;
  int mFocusCol = 0;

  BlocksPainter(List<List<Blocks>> aBlocksList)
  {
    mBlocksList = aBlocksList;
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

    for(int i=0;i<mBlocksList.length;i++)
    {
      for(int j=0;j<mBlocksList[i].length;j++)
      {
        List<Offset> points = [];
        points.add(Offset(i.toDouble(),j.toDouble()));
        mBlocksList[i][j].mPaint.blendMode = BlendMode.srcOver;
        canvas.drawRect(Rect.fromLTWH(j.toDouble(),i.toDouble(),1,1), mBlocksList[i][j].getPaint());
      }
    }

    final picture = recorder.endRecording();

    final img = await picture.toImage((16), (16));

    final pngBytes = await img.toByteData(format: ImageByteFormat.png);
    return pngBytes;
  }

  void saveBitmap() async
  {
    final recorder = ui.PictureRecorder();

    final canvas = Canvas(
        recorder,
        Rect.fromPoints(
            Offset(0.0, 0.0), Offset((mBlocksList[0][0].mBlockRectangle.width*16),
            (mBlocksList[0][0].mBlockRectangle.height*16)))
    );

    for(int i=0;i<mBlocksList.length;i++)
    {
      for(int j=0;j<mBlocksList[i].length;j++)
      {
        canvas.drawRect(mBlocksList[i][j].mBlockRectangle, mBlocksList[i][j].getPaint());
        canvas.drawRect(mBlocksList[i][j].mBlockRectangle,mWirePaint);
      }
    }

    final picture = recorder.endRecording();
    final img = picture.toImage((mBlocksList[0][0].mBlockRectangle.width*16).toInt(), (mBlocksList[0][0].mBlockRectangle.width*16).toInt());
  }

  void repaintR(int aR)
  {
    mBlocksList[mFocusRow][mFocusCol].mR = aR;
  }

  void repaintG(int aG)
  {
    mBlocksList[mFocusRow][mFocusCol].mG = aG;
  }

  void repaintB(int aB)
  {
    mBlocksList[mFocusRow][mFocusCol].mB = aB;
  }

  @override
  void paint(Canvas canvas, Size size)
  {
    for(int i=0;i<mBlocksList.length;i++)
    {
      for(int j=0;j<mBlocksList[i].length;j++)
      {
        canvas.drawRect(mBlocksList[i][j].mBlockRectangle, mBlocksList[i][j].getPaint());
        canvas.drawRect(mBlocksList[i][j].mBlockRectangle,mWirePaint);
      }
    }
  }

  @override
  bool shouldRepaint(BlocksPainter oldDelegate)
  {
    if(oldDelegate.mBlocksList[mFocusRow][mFocusCol].mR!=oldDelegate.mBlocksList[mFocusRow][mFocusCol].mR)
    {
      return true;
    }
    else if(oldDelegate.mBlocksList[mFocusRow][mFocusCol].mG!=oldDelegate.mBlocksList[mFocusRow][mFocusCol].mG)
    {
      return true;
    }
    else if(oldDelegate.mBlocksList[mFocusRow][mFocusCol].mB!=oldDelegate.mBlocksList[mFocusRow][mFocusCol].mB)
    {
      return true;
    }
    else{
      return true;
    }
  }
}