import 'package:fidelitycard/src/models/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import 'generatorQR.dart';

class QRGenerator extends StatefulWidget{

  QRGenerator({Key key}) : super(key: key);

  @override
  _QRGeneratorState createState() => _QRGeneratorState();
}


TextEditingController mycontroller = TextEditingController();

class _QRGeneratorState extends State<QRGenerator>{


@override
void dispose() {
  mycontroller.clear();
  firstNameController.clear();
  lastNameController.clear();
  super.dispose();
}

 TextEditingController lastNameController = TextEditingController();
 TextEditingController firstNameController = TextEditingController();
 final _globalKey = GlobalKey<FormState>();
FirebaseFirestore data_instance = FirebaseFirestore.instance;
 List categories = ["CC", "ICC", "VICC"];
String valueChoose;
double montant;


  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scanner"),
        backgroundColor:  HexColor("60282e"),

      ),
      body: Container(
        child: Form(
          key: _globalKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTextField(Icons.person,true, firstNameController),
              buildTextField(Icons.person,true, lastNameController),

               Container(
            padding: EdgeInsets.only(left: 16, right: 16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(35.0)),
            child: DropdownButton(
                hint: Text(
                  'Selectionnez le type de carte',
                  style: TextStyle(fontSize: 14, color: Palette.textColor1),
                ),
                dropdownColor: Colors.white,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 30,
                isExpanded: true,
                underline: SizedBox(),
                style: TextStyle(fontSize: 14, color: Palette.textColor1),
                value: valueChoose,
                onChanged: (newValue) {
                  setState(() {
                    valueChoose = newValue;

                    if(newValue == "CC")
                      montant = 50000;
                    else if(newValue == "ICC")
                      montant = 75000;
                    else if(newValue == "VICC")
                      montant = 100000;
                  });
                },
                items: categories.map((valueItem) {
                  return DropdownMenuItem(
                      value: valueItem,
                      child: Text(
                        valueItem,
                        style:
                            TextStyle(fontSize: 14, color: Palette.textColor1),
                      ));
                }).toList()),
          ),
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
                            "Generate QR",
                            style: TextStyle(fontSize: 15 )
                          ),
                          onPressed: navigate,
                        ),
                      )
            ],
          ),
        ),
      ),
    );
    }

void navigate() {

String userUid;
var addDt = DateTime.now();
      // Add a new document with a generated id.
Map<String, dynamic> data = {
        "nom" : lastNameController.text,
        "prenom" : firstNameController.text
};
  CollectionReference users = data_instance.collection("utilisateurs");
  users.add(data)
   .then((value) {
     setState(() {
       userUid = value.id;     
     });
    
    var validationDate = addDt.add(Duration(days: 30));
    
Map<String, dynamic> data1 = {
        "cardType" : valueChoose,
        "montant" : montant,
        "validationDate": validationDate,
        "user" : userUid
};

  CollectionReference cards = data_instance.collection("cards");
  cards.add(data1)
   .then((value1){ 
     print("card created");

       Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) => GeneratedQR(value1.id))
            );

     })
    .catchError((error) => print("Failed to add cards: $error"));

      print("User Added");
      })
    .catchError((error) => print("Failed to add user: $error"));

    }

     Widget buildTextField( IconData icon, bool enabled, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        obscureText: false,
        controller: controller,
        style: TextStyle(color: Colors.black),
       keyboardType: TextInputType.number,
       enabled: enabled,
       validator: (value){
        
           if(value.isEmpty)
              return "Entrer le montant ";       
         
         return null;
         
       },
        decoration: InputDecoration(
        
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Palette.textColor1),
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Palette.textColor1),
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          contentPadding: EdgeInsets.all(10),
          hintText: "Montant",
          hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
         
        ),
      ),
    );
  }

  }