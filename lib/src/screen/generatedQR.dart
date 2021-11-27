import 'package:ars_progress_dialog/ars_progress_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:fidelitycard/src/controller/reductionController.dart';
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
double montant = 50000;
int _currentStep = 0;
StepperType stepperType = StepperType.vertical;

  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scanner"),
        backgroundColor:  HexColor("60282e"),
        centerTitle: true,

      ),
      body: Container(
        child: Form(
          key: _globalKey,
          child: Column(
           // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
              Expanded(
                child: Stepper(
                  type: stepperType,
                  physics: ScrollPhysics(),
                  currentStep: _currentStep,
                   controlsBuilder: (BuildContext context,
                      {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                    return Row(
                      children: <Widget>[
                         TextButton(
                          onPressed: onStepCancel,
                          child: const Text('Annuler' , style: TextStyle(fontSize: 18, color:Colors.red)),
                        ),
                        TextButton(
                          onPressed: onStepContinue,
                          child: _currentStep < 2 ? const Text('Suivant', style: TextStyle(fontSize: 18, color:Colors.green)) : const Text('Terminer', style: TextStyle(fontSize: 19, color:Colors.green)),
                        ),
                       
                      ],
                    );
                  },
                  onStepTapped: (step) => tapped(step),
                  onStepContinue:  continued,
                  onStepCancel: cancel,
                  steps: <Step>[
                     Step(
                      title: new Text('Nom'),
                      content: Column(
                        children: <Widget>[
              buildTextField(Icons.person,true, firstNameController, "Nom"),
                        ]
                     ),
                     isActive: _currentStep >= 0,
                      state: _currentStep >= 0 ?
                      StepState.complete : StepState.disabled,
                  ),
                   Step(
                      title: new Text('Prénom'),
                      content: Column(
                        children: <Widget>[
              buildTextField(Icons.person,true, lastNameController,"Prénom"),
                        ]
                     ),
                     isActive: _currentStep >= 0,
                      state: _currentStep >= 1 ?
                      StepState.complete : StepState.disabled,
                  ),
                   Step(
                      title: new Text('Type de carte'),
                      content: Column(
                        children: <Widget>[
                            Container(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(35.0)),
                            child: DropdownButton(
                                hint: Text(
                                  'Selectionnez le type de carte',
                                  style: TextStyle(fontSize: 14, color:Colors.black),
                                ),
                                dropdownColor: Colors.white,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 30,
                                isExpanded: true,
                                underline: SizedBox(),
                                style: TextStyle(fontSize: 14, color: Colors.black),
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
                                            TextStyle(fontSize: 14, color: Colors.black),
                                      ));
                                }).toList()),
                          ),
                        ]
                     ),
                     isActive: _currentStep >= 0,
                      state: _currentStep >= 2 ?
                      StepState.complete : StepState.disabled,
                  )
                ]
               )
               ),
               
            ],
          ),
        ),
      ),
    );
    }

void navigate() {

ArsProgressDialog progressDialog = ArsProgressDialog(
                	context,
                	blur: 2,
                	backgroundColor: Color(0x33000000),
                	animationDuration: Duration(milliseconds: 500));
                  
 progressDialog.show();
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
        "validation": validate,
        "validationDate": validationDate,
        "user" : userUid
};

  CollectionReference cards = data_instance.collection("cards");
  cards.add(data1)
   .then((value1){ 
     print("card created");
   progressDialog.dismiss();
       Navigator.pushAndRemoveUntil(context, 
            MaterialPageRoute(
              builder: (context) => GeneratedQR(value1.id)),
              (route) => false
            );

     })
    .catchError((error) => print("Failed to add cards: $error"));

      print("User Added");
      })
    .catchError((error) => print("Failed to add user: $error"));

    }

     Widget buildTextField( IconData icon, bool enabled, TextEditingController controller, String hintext) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        obscureText: false,
        controller: controller,
        style: TextStyle(color: Colors.black),
       keyboardType: TextInputType.text,
       enabled: enabled,
       validator: (value){
        
           if(value.isEmpty)
              return "Ce champ peut pas être vide";       
         
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
          hintText: hintext,
          hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
         
        ),
      ),
    );

    
  }
switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step){
    setState(() => _currentStep = step);
  }

  continued(){
    if(_currentStep < 2) 
        setState(() => _currentStep += 1); 
    else{

         if(_globalKey.currentState.validate())
          navigate();
          else
           dialog();
         
    }
  }
  cancel(){
    _currentStep > 0 ?
        setState(() => _currentStep -= 1) : null;
  }


 dialog() async {
  return AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: true,
        title: 'Error',
        desc:
            'Remplissez tout les champs dmandé',
        btnOkOnPress: () {},
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red)
      ..show();
}
  }

  