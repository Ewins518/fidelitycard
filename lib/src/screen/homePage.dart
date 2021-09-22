import 'package:fidelitycard/src/models/hex_color.dart';
import 'package:flutter/material.dart';

import 'generatedQR.dart';
import 'scanQR.dart';

class MyHomePage extends StatefulWidget {
  _MyHomePageState createState() =>  _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        title: Text("QR Scan/ Generate"),
        backgroundColor:  HexColor("60282e"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (MediaQuery.of(context).size.height) - 
              AppBar().preferredSize.height - kToolbarHeight
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                    "images/QR.jpg"
                  ),
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  radius: 150,
                ),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                   Hero(
                    tag: "Scan QR",
                    child: Container(
                      width: ((MediaQuery.of(context).size.width) / 2) - 45,
                      height: 50,
                      child: OutlineButton(
                        focusColor: Colors.red,
                        highlightColor: Colors.blue,
                        hoverColor: Colors.lightBlue[100],
                        splashColor: Colors.blue,
                        borderSide: BorderSide(
                          width: 3,
                          color: Colors.blue
                        ),
                        shape: StadiumBorder(),
                        child: Text(
                          "Scan QR",
                          style: TextStyle(fontSize: 15 )
                        ),
                        onPressed: () {
                          Navigator.push(context, 
                          MaterialPageRoute(
                            builder: (context) => ScanQR())
                          );
                        },
                      ),
                    )
                    ),
                    SizedBox(width: 25,),

                    Container(
                      width: ((MediaQuery.of(context).size.width) / 2) - 45,
                      height: 50,
                      child: OutlineButton(
                        focusColor: Colors.red,
                        highlightColor: Colors.blue,
                        hoverColor: Colors.lightBlue[100],
                        splashColor: Colors.blue,
                        borderSide: BorderSide(
                          width: 3,
                          color: Colors.blue
                        ),
                        shape: StadiumBorder(),
                        child: Text(
                          "Generate QR",
                          style: TextStyle(fontSize: 15 )
                        ),
                        onPressed: () {
                          Navigator.push(context, 
                          MaterialPageRoute(
                            builder: (context) => QRGenerator())
                          );
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}