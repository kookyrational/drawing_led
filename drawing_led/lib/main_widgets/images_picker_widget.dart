


import 'dart:io';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../defines.dart';

class ImagePickerWidget extends StatefulWidget
{

  var mScreenWidth;

  ImagePickerWidget(this.mScreenWidth,{Key key}):super(key: key);


  @override
  _ImagePickerWidget createState() => _ImagePickerWidget();
}

class _ImagePickerWidget extends State<ImagePickerWidget>
{

  String directory;
  List<FileSystemEntity> mFiles = [];

  @override
  void initState()
  {
    super.initState();
    _listOfFiles();
  }

  // Make New Function
  void _listOfFiles() async
  {
    directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      mFiles = io.Directory("$directory/${Defines.sImageFolder}/").listSync();
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return
       Scaffold(
         appBar: AppBar(
           title: Text("選取圖片"),
          ),
          body: GridView.builder(
              reverse: false,
              // shrinkWrap:true,
              padding: EdgeInsets.all(0),
              gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: (widget.mScreenWidth/2),
                  mainAxisSpacing:8,
                  crossAxisSpacing: 5.0,
                  childAspectRatio: 1
              ),
              itemCount: mFiles.length,
              itemBuilder: (context, index)
              {
                return
                  InkWell(
                  child: Image(image:FileImage(File(mFiles[index].path)),fit: BoxFit.fill,),
                  onTap: ()
                  {
                    Navigator.pop(context, mFiles[index].path);
                  },
                );
              }),
       );
  }
}