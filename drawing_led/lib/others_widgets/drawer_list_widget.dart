

import 'package:flutter/material.dart';

import '../defines.dart';

class DrawerListWidget extends StatelessWidget
{
  ValueSetter<DrawerItems> mDrawerClickCallBack;

  DrawerListWidget({Key key, this.mDrawerClickCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          title: const Text(' '),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('塗鴉顯示'),
          onTap: () {
            mDrawerClickCallBack(DrawerItems.PAINTING);
            Navigator.pop(context);
          },
        ),
        Divider(color:Colors.black),
        ListTile(
          title: const Text('文字顯示'),
          onTap: () {
            mDrawerClickCallBack(DrawerItems.TEXTING);
            Navigator.pop(context);
          },
        ),
        Divider(color:Colors.black),
        ListTile(
          title: const Text('圖片顯示'),
          onTap: () {
            mDrawerClickCallBack(DrawerItems.IMAGES);
            Navigator.pop(context);
          },
        ),
        Divider(color:Colors.black),
        ListTile(
          title: const Text('亮度調整'),
          onTap: ()
          {
            mDrawerClickCallBack(DrawerItems.BRIGHT);
            Navigator.pop(context);
          },
        ),
        Divider(color:Colors.black),
      ],
    );
  }
}