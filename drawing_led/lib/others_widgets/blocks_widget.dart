

import 'package:flutter/material.dart';

class BlocksWidget extends StatefulWidget
{

  BlocksWidget({Key key}):super(key: key);

  @override
  _BlocksWidget createState() => _BlocksWidget();
}

class _BlocksWidget extends State<BlocksWidget>
{

  @override
  Widget build(BuildContext context)
  {
    return Container(
      child: Text("亮度調整"),
    );
  }
}