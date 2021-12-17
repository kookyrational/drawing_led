
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Blocks
{
    int mR=0;
    int mG=0;
    int mB=0;

    int mIndex;

    bool mIsFocus = false;

    Rect mBlockRectangle;
    Paint mPaint;
    PaintingStyle mPaintingStyle = PaintingStyle.fill;

    Paint getPaint()
    {
        if(mPaint == null)
        {
            mPaint =  Paint()
                ..color = Color.fromARGB(255, mR, mG,mB)
                ..style = mPaintingStyle
                ..strokeWidth = 1.0;
        }
        else{
            mPaint.color = Color.fromARGB(255, mR, mG,mB);
        }

        return mPaint;
    }

    ByteData get colorsByte
    {
      return ByteData(4);
    }
}