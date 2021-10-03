import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidelitycard/src/controller/reductionController.dart';
import 'package:fidelitycard/src/models/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class ScanQR extends StatefulWidget{

  ScanQR({Key key}) : super(key: key);

  @override
  _ScanQRState createState() => _ScanQRState();
}

var data;
bool hasdata = false;

class _ScanQRState extends State<ScanQR>{

  @override 
  Widget build (BuildContext context) {
    return Hero(
      tag: "Scan QR",
      child: Scaffold(

        appBar: AppBar(
          title: Text("QR Scanner"),
          backgroundColor:  HexColor("60282e"),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      "Raw Data: ${(qrData)}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20
                      ),
                    ),
                    ),
              
                IconButton(
                  icon: Icon(Icons.launch_outlined),
                  onPressed: hasdata ? ()async {
                    if( await canLaunch(qrData) ){
                      await launch(qrData);
                    } else {
                      throw "Could not Launch";
                    }
                  } 
                  : null
                  
                  )
            ],
            ),
            SizedBox(height: 15,),
            Container(
                      width: ((MediaQuery.of(context).size.width) / 2) - 45,
                      height: 35,
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
                          style: TextStyle(fontSize: 17 )
                        ),
                        onPressed: ()async {
                          var option = ScanOptions(autoEnableFlash: true);
                          data = await BarcodeScanner.scan(
                            options: option
                          );
                          setState(() {
                            qrData = data.rawContent.toString();
                            hasdata = true;
                            
                            FirebaseFirestore.instance
                                  .collection('cards')
                                  .doc(qrData)
                                  .get()
                                  .then((DocumentSnapshot documentSnapshot) {
                                    if (documentSnapshot.exists) {
                                      Map <String, dynamic> data1 = documentSnapshot.data();

                                      FirebaseFirestore.instance
                                          .collection('utilisateurs')
                                          .doc(data1['user'])
                                          .get()
                                          .then((DocumentSnapshot documentSnapshot1) {

                                          if (documentSnapshot.exists) {
                                              Map <String, dynamic> data2 = documentSnapshot1.data();
                                              var date = DateTime.now();

                                              var newFormat = DateFormat("yyyy-MM-dd");
                                              validationDate = newFormat.format(data1["validationDate"]);

                                              if(date.isAfter(data1["validationDate"]))
                                                validate = false;

                                             setState(() {
                                               balance = data1["montant"] ;
                                               typeCard = data1["cardType"];  
                                               nom = data2["nom"];
                                               prenom = data2["prenom"];                     
                                             });

                                               Navigator.push(context, 
                                                 MaterialPageRoute(
                                                   builder: (context) => Home())
                                              );


                                         } else {
                                      print('Document does not exist on the database');

                                    }
                                  });

                                      print('Document data: $data1');
                                    } else {
                                     dialog();

                                    }
                                  });
                          });
                        },
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }



Future<Null> dialog() async {
  return AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: true,
        title: 'Error',
        desc:
            'Code QR invalide',
        btnOkOnPress: () {},
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red)
      ..show();
}



}