

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'structures/blocks.dart';

class Utility
{
  static double sBlockSize;

  static Uint8List int32bytes(int value)
  {
    return Uint8List(4)..buffer.asInt32List()[0] = value;
  }

  static Uint8List int32BigEndianBytes(int value)
  {
    return Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);
  }

  Future<void> writeToFile(ByteData data, String path)
  {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static List<List<Blocks>> generateBlocksCoordinate(Size aScreen,int aPaddingSize)
  {
     var canvasWidthStart = aPaddingSize;
     var canvasWidthEnd = aScreen.width-(aPaddingSize);
     var canvasHeightStart = aPaddingSize; //高佔比7成
     var canvasHeightEnd = (aScreen.height/10*7)-aPaddingSize; //高佔比7成

     var blockSize = (canvasWidthEnd-canvasWidthStart)/16; //正方形
     sBlockSize = blockSize;
     int row = 16;
     int col = 16;

     var block = List.generate(row, (i) => List<Blocks>(col), growable: false);
     var x = aPaddingSize.toDouble();
     var y = aPaddingSize.toDouble();
     for(int i=0;i<16;i++)
     {
        for(int j=0;j<16;j++)
        {
          var temp = Blocks();
          temp.mBlockRectangle = Rect.fromLTRB(x, y, x+blockSize, y+blockSize);
          block[i][j] =temp;
          x=x+blockSize;
        }
        x = aPaddingSize.toDouble();
        y+=blockSize;
     }
    return block;
  }
}