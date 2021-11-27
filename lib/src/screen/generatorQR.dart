import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fidelitycard/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fidelitycard/src/models/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GeneratedQR extends StatefulWidget {
  final myQR;

  const GeneratedQR(this.myQR);

  @override
  _GeneratedQRState createState() => _GeneratedQRState();
}

class _GeneratedQRState extends State<GeneratedQR> {
   GlobalKey globalKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Generated QR "),
        backgroundColor:  HexColor("60282e"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ),
                  );
          },
          
        ),
          actions: <Widget>[
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _captureAndSharePng,
          )
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: globalKey,
          child: QrImage(
            data: widget.myQR,
            version: QrVersions.auto,
            size: 250.0,
            gapless: false,
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndSharePng() async {
    try {
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      //await Share.file(widget.myQR, '$_dataString.png', pngBytes, 'image/png');
      //final channel = const MethodChannel('channel:me.alfian.share/share');
      //channel.invokeMethod('shareFile', 'image.png');
      

    } catch(e) {
      print(e.toString());
    }
  }
}
