import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class alarmPage1 extends StatelessWidget {
  const alarmPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 95,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              'Wake up!',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              'You are gonna reach your destination',
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w200),
              ),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          Center(
              child: Image.asset(
            'assets/chillPic.png',
          )),
          SizedBox(
            height: 30,
          ),
          Container(
            height: 20,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(100.0),
                //bottomRight: Radius.circular(40.0),
                topLeft: Radius.circular(100.0),
                //bottomLeft: Radius.circular(40.0)//
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 550,
            width: MediaQuery.of(context).size.width,
            child: DecoratedBox(
              child: Padding(
                padding: const EdgeInsets.all(100.0),
              ),
              decoration: BoxDecoration(
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
