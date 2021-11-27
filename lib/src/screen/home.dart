import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fidelitycard/constants.dart';
import 'package:fidelitycard/src/controller/reductionController.dart';
import 'package:fidelitycard/src/models/hex_color.dart';
import 'package:fidelitycard/src/widget/cards.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  
  @override
void dispose(){
  totalAPayer = 0;
  super.dispose();
}

@override
void initState(){
  init ();
  super.initState();
}
  int number;
  String image;
  String colors;

  TextEditingController mycontroller = TextEditingController();
   final _globalKey = GlobalKey<FormState>();


@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              height: 300,
              decoration: BoxDecoration(
                  color: HexColor("60282e"),
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(60),bottomLeft: Radius.circular(60),)
              ),
            ),
            SafeArea(
              child: ListView(
                children: <Widget>[

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(text: TextSpan(
                          children: [
                            TextSpan(text: "\nTotal Balance\n", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18)),
                            TextSpan(text: "\XOF ", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 30)),
                            TextSpan(text: "$balance \n", style: TextStyle(color: Colors.white, fontSize: 36)),
                            TextSpan(text: " \nYour card", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18)),
                          ]
                        )),
                      ),
                      IconButton(icon: Icon(Icons.more_vert, color: Colors.white,size: 40,), onPressed: (){})
                    ],
                  ),

                  SizedBox(height: 5,),
                  Container(
                    height: 200,
                    
                      child: 
                        CreditCard(color: colors, number: number, image: image, valid: "Expire $validationDate",),
                      
                  ),
                  SizedBox(height: 5,),
                  
                   
                        Container(
                            alignment: Alignment.center,
                            child: Text(
                              "TOTAL ACHETER",
                              
                              style: TextStyle(color: Colors.black, fontSize: 22),
                              
                              ),
                          
                        ),
                   

                  Container(
                    height: 90,
                    child: Form(
                     key: _globalKey,
                    
                      child: Column(
                        children: [
              buildTextField(Icons.mail_outline, true, mycontroller),
                        ]
                    )
                
            )
                  ),

                 Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: HexColor("60282e"),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: RaisedButton( 
                        color: HexColor("60282e"),                      
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text("Confirmer", style: TextStyle(fontSize: 22, color: Colors.white),),
                          ),
                        ),
                        onPressed: (){
                          if(_globalKey.currentState.validate()){
                           setState(() {
                                 totalAcheter = double.parse(mycontroller.text);  
                                 totalAPayer = balance >= totalAcheter*reduction ? totalAcheter - totalAcheter*reduction : totalAcheter;
                                 balance = balance >= totalAcheter*reduction ? balance - totalAcheter*reduction : balance;

                                 FirebaseFirestore.instance
                                  .collection('cards')
                                  .doc(qrData)
                                  .update({"montant": balance})
                                  .then((value) => print("Card Updated"))
                                  .catchError((error) => print("Failed to update cards: $error"));
                   
                            });
                        settingModalBottomSheet(context);
                         
                        }
                        }
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white,

                Colors.white.withOpacity(0.1),

              ])
        ),
        height: 50,
       
      )
    );
    
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


void settingModalBottomSheet(context){
    showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (BuildContext bc){
          return Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topRight: Radius.circular(60), topLeft: Radius.circular(60))
            ),
            child: new Wrap(
              children: <Widget>[

                Row(
                  mainAxisAlignment: MainAxisAlignment.center
                  ,children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(radius: 25,backgroundImage: AssetImage("images/dba2.jpg"),),
                  ),
                ],),
                SizedBox(height: 10,),
            Container(
              alignment: Alignment.center,
              child: Text("$nom $prenom", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ),),
            ),
            SizedBox(height: 25,),
                Container(
                  alignment: Alignment.center,
                  child: Text("Total à payer après reduction"),
                ),
                SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    
                   // SizedBox(width: 20,),
                    Text("$totalAPayer XOF", style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold ),),
                  //  SizedBox(width: 10,),

                  ],
                ),
                SizedBox(height: 80,),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: (){
                      Navigator.pop(bc);
                      Navigator.pop(context);

                  setState(() {
                      totalAPayer = 0;               
                   });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: HexColor("60282e"),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text("OK", style: TextStyle(fontSize: 22, color: Colors.white),),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
    );
  }


Future<Null> dialog() async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext buildcontext) {
      return new AlertDialog(
        title: new Text(
          "$totalAPayer XOF", 
          textScaleFactor: 1.25,
          style: TextStyle(color: Colors.blue),
          textAlign: TextAlign.center,

          ),
        contentPadding: EdgeInsets.all(10.0),
        content: new Text("A payer après reduction de 10%"),
        actions: <Widget>[
          new FlatButton(
            //color: Colors.teal,
            textColor: Colors.white,
            child: new Text(
              'OK',
              textScaleFactor: 1.25,
              style: TextStyle(color: Colors.blue),
              ),
            onPressed: () {
              Navigator.pop(buildcontext);
              Navigator.pop(context);

              setState(() {
                  totalAPayer = 0;               
               });
            }
            
            )
        ],
      );
    }
  ); 
}

void init(){
  if(typeCard == "CC"){
    image = "master.png";
    colors = "2a1214";
    number = 1298;
  }
  else if(typeCard == "ICC"){
    image = "visa.png";
    colors = "000068";
    number = 9856;
  }
  if(typeCard == "VICC"){
    image = "master.png";
    colors = "2a1214";
    number = 7850;
  }
}

}







