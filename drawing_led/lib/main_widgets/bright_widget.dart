import 'dart:async';
import 'dart:typed_data';

import 'package:drawing_led/channel/background_process.dart';
import 'package:drawing_led/defines.dart';
import 'package:flutter/material.dart';

class BrightWidget extends StatefulWidget
{
  bool mDelayTimeFinish = true;

  BrightWidget({Key key}) : super(key: key);

  @override
  _BrightWidget createState() => _BrightWidget();
}

class _BrightWidget extends State<BrightWidget>
{
  int _brightness = (Defines.BRIGHTNESS_MAX - Defines.BRIGHTNESS_MIN) ~/ 2;
  Timer _timer;

  _updateTime()
  {
    widget.mDelayTimeFinish = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(30),
            child: Slider(
              value: _brightness.toDouble(),
              min: Defines.BRIGHTNESS_MIN.toDouble(),
              max: Defines.BRIGHTNESS_MAX.toDouble(),
              divisions: (Defines.BRIGHTNESS_MAX - Defines.BRIGHTNESS_MIN),
              label: _brightness.round().toString(),
              onChangeEnd: (double value)
              {
                _brightness = value.toInt();
                if(widget.mDelayTimeFinish)
                {
                  BackgroundProcess.invokeSendLEDData(Uint8List.fromList([0x48, _brightness, 0x45]));
                  widget.mDelayTimeFinish = false;
                  _timer?.cancel();
                  _timer = Timer(Duration(milliseconds: 600),
                    _updateTime,
                  );
                }
              },
              onChanged: (double value)
              {
                  setState(() => _brightness = value.toInt());
              },
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
                child: Text("")),
          ],
        ),
      ],
    );
  }
}
