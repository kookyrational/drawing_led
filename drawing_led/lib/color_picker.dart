import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

class ColorPicker
{
  Uint8List bytes;
  img.Image _decodedImage;
  String mImagePath;
  VoidCallback mLoadImageCallback;
  ColorPicker(this.mImagePath,this.mLoadImageCallback);

  Future<void> load() async
  {
    loadImageByFile(mImagePath).then((value)
    {
      value.toByteData(format: ui.ImageByteFormat.png).then((value)
      {
        final _imageBuffer = value.buffer;
        final _uint8List = _imageBuffer.asUint8List();
        _decodedImage = img.decodeImage(_uint8List);
        mLoadImageCallback();
      });
    });
  }

  Future<ui.Image> loadImageByFile(String path) async{
    var list =await File(path).readAsBytes();
    return loadImageByUint8List(list);
  }

  Future<ui.Image> loadImageByUint8List(Uint8List list, {int width, int height,}) async
  {
    ui.Codec codec = await ui.instantiateImageCodec(list,
        targetWidth: width, targetHeight: height);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  Color getColor(Offset pixelPosition)
  {
    final _abgrPixel = _decodedImage.getPixelSafe(
      pixelPosition.dx.toInt(),
      pixelPosition.dy.toInt(),
    );

    final _rgba = abgrToRgba(_abgrPixel);

    final _color = Color(_rgba);

    return _color;
  }

  int abgrToRgba(int argb) {
    int r = (argb >> 16) & 0xFF;
    int b = argb & 0xFF;

    final _rgba = (argb & 0xFF00FF00) | (b << 16) | r;

    return _rgba;
  }
}