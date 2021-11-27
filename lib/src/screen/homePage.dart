import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:fidelitycard/src/models/hex_color.dart';
import 'package:fidelitycard/src/screen/generatedQR.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidelitycard/src/controller/reductionController.dart';
import 'package:intl/intl.dart';
import 'home.dart';
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
        title: Text("DBA Card"),
        centerTitle: true,
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
                    "images/dba1.jpg"
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
                      alignment: Alignment.center,
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
                        onPressed: () async {
                         
                           var option = ScanOptions(autoEnableFlash: false);
                          data = await BarcodeScanner.scan(
                            options: option
                          );  
                                
                          setState(() {
                            qrData = data.rawContent.toString();
                            hasdata = true;
                            
                            if(qrData.isNotEmpty)
                            try{
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
                                              validationDate = newFormat.format(data1["validationDate"].toDate());

                                              if(date.isAfter(data1["validationDate"].toDate())){
                                                 validate = false;
                                                 dialog("Carte expiré");
                                               //  Navigator.pop(context);
                                              }
                                                

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
                                    print('Document does not exist on the database one');

                                     dialog('Code QR invalide');

                                    }
                                  });
                            }
                            catch(e) {
                               dialog('Code QR invalide');

                            }    
                          });
                          
                         }
                      ),
                    )
                    ),
                    SizedBox(width: 25,),

                  //  Container(
                  //    width: ((MediaQuery.of(context).size.width) / 2) - 45,
                  //    height: 50,
                  //    child: OutlineButton(
                  //      focusColor: Colors.red,
                  //      highlightColor: Colors.blue,
                  //      hoverColor: Colors.lightBlue[100],
                  //      splashColor: Colors.blue,
                  //      borderSide: BorderSide(
                  //        width: 3,
                  //        color: Colors.blue
                  //      ),
                  //      shape: StadiumBorder(),
                  //      child: Text(
                  //        "Generate QR",
                  //        style: TextStyle(fontSize: 15 )
                  //      ),
                  //      onPressed: () {
                  //          Navigator.push(context, 
                  //        MaterialPageRoute(
                  //          builder: (context) => QRGenerator()));
                  //      }
                  //    ),
                  //  )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }



 dialog(String msg) async {
  return AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: true,
        title: 'Error',
        desc: msg,
        btnOkOnPress: () {},
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red)
      ..show();
}


}