import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

AudioPlayer? audioPlayer;
late AudioCache audioCache;

class alarmPage extends StatefulWidget {
  const alarmPage({Key? key}) : super(key: key);

  @override
  _alarmPageState createState() => _alarmPageState();
}

class _alarmPageState extends State<alarmPage> {
  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('STOP'),
          onPressed: () {
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            }
            audioPlayer!.stop();
          },
        ),
      ),
    );
  }
}
