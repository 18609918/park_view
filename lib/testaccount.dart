import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import './main.dart';


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main(){
  HttpOverrides.global = new MyHttpOverrides();
  runApp(new MaterialApp(
    title:"Account",
  )
  );
}

class Account extends StatefulWidget {
  Account(this.passemail) : super();
  final String passemail;
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final String passemai = controllerEmail.text;
  GlobalKey<FormState> _key = new GlobalKey();
  // This boolean is for the Autov alidation settings
  bool _validate = false;
  String fname, lname, email, phone, password;

  //These controllers allow us to access the TextFormFields later in the document
  static TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();
  TextEditingController controllerFname = new TextEditingController();
  TextEditingController controllerLname = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();

  void loadData() async{
    // this is the url to our php Rest api
    var url1="https://cs1908.scem.westernsydney.edu.au/loadData.php";
    // this code takes the values from the controllers and sends them to the rest api
    final response2 = await http.post(url1, body: {
      "email": widget.passemail,
    });

    var data = json.decode(response2.body);

    controllerEmail.text = data[0]["Email"];
    controllerPassword.text = data[0]["Password"];
    controllerFname.text = data[0]["Fname"];
    controllerLname.text = data[0]["Lname"];
    controllerPhone.text = data[0]["Phone"];
  }

  void editData(){
    // this is the url to our php Rest api
    var url="https://cs1908.scem.westernsydney.edu.au/updateUser.php";
    // this code takes the values from the controllers and sends them to the rest api
    http.post(url, body: {
      "email": controllerEmail.text,
      "password": controllerPassword.text,
      "fname": controllerFname.text,
      "lname": controllerLname.text,
      "phone": controllerPhone.text,
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Account'),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("LogIn"),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                title: Text("Check-In"),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                title: Text("Compare Capacity"),
                trailing: Icon(Icons.arrow_forward),
              ),
              ListTile(
                title: Text("Account"),
                trailing: Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ),
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              key: _key,
              autovalidate: _validate,
              child: FormUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget FormUI() {
    return new Column(
      children: <Widget>[
        new TextFormField(
            controller: controllerEmail,
            decoration: new InputDecoration(
              hintText: "Example@email.com",
              labelText: "Enter Email",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: new BorderSide(
                ),
              ), //fillColor: Colors.green
            ),
            keyboardType: TextInputType.emailAddress,

            maxLength: 50,
            validator: validateEmail,
            onSaved: (String val) {
              email = val;
            }
        ),
        new TextFormField(
            controller: controllerPassword,
            decoration: new InputDecoration(
              hintText: "Must be 8 characters long", labelText: "Password",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: new BorderSide(
                ),
              ), //fillColor: Colors.green
            ),

            maxLength: 50,
            validator: validatePass,
            onSaved: (String val) {
              phone = val;
            }
        ),
        new TextFormField(
            controller: controllerFname,
            decoration: new InputDecoration(
              hintText: "First Name", labelText: "First Name",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: new BorderSide(
                ),
              ), //fillColor: Colors.green
            ),
            maxLength: 50,
            validator: validateFName,
            onSaved: (String val) {
              fname = val;
            }
        ),
        new TextFormField(
            controller: controllerLname,
            decoration: new InputDecoration(
              hintText: "Last Name", labelText: "Last Name",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: new BorderSide(
                ),
              ), //fillColor: Colors.green
            ),
            maxLength: 50,
            validator: validateLName,
            onSaved: (String val) {
              lname = val;
            }
        ),
        new TextFormField(
            controller: controllerPhone,
            decoration: new InputDecoration(
              hintText: "Must be 10 digits", labelText: "Phone Number",
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10.0),
                borderSide: new BorderSide(
                ),
              ), //fillColor: Colors.green
            ),
            keyboardType: TextInputType.phone,
            maxLength: 10,
            validator: validatePhone,
            onSaved: (String val) {
              phone = val;
            }
        ),
        new SizedBox(height: 15.0, width: 60.0),
        new ButtonTheme(
          minWidth: 400.0,
          height: 50.0,
          child:  RaisedButton(
            child: new Text('Edit Account'),
            color: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            onPressed: ()
            {
              // this if statement ensures that invalid data cant be sent to the PHP rest api
              if(_key.currentState.validate()) {
                editData();
                // these lines of code clear the textfield after the button is pressed
                // controllerEmail.clear();

                // controllerPassword.clear();
                // controllerFname.clear();
                //  controllerLname.clear();
                //  controllerPhone.clear();
                FocusScope.of(context).requestFocus(new FocusNode());
                setState(() {
                  _validate = false;
                });
              }else {
                FocusScope.of(context).requestFocus(new FocusNode());
                // if the code isn't valid this else statement sets autovalidate to true
                setState(() {
                  _validate = true;
                });
              }
            },
          ),
        ),
        new SizedBox(height: 15.0, width: 60.0),
        new ButtonTheme(
            minWidth: 400.0,
            height: 50.0,
            child:  RaisedButton(
              child: new Text('Delete Button'),
              color: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              onPressed: ()
              {

              },
            )
        )
      ],

    );

  }
  //Validation for  First name
  String validateFName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "First Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "First Name must be a-z and A-Z";
    }
    return null;
  }
  //Validation for Last Name
  String validateLName(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "last Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Last Name must be a-z and A-Z";
    }
    return null;
  }
  //Validation for Password
  String validatePass(String value) {

    if (value.length == 0) {
      return "Password is Required";
    }
    else if (value.length < 8) {
      return "Password must be atleast 8 characters";
    }
    return null;
  }
  //Validation for Phone Number
  String validatePhone(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Phone Number is Required";
    } else if (value.length != 10) {
      return "Phone Number must 10 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Phone Number must be digits";
    }
    return null;
  }
  //Validation for Email
  String validateEmail(String value) {
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

}