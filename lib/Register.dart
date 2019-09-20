import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import './main.dart';

// This class allows the application to ignore invalid certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Register",
  ));
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  GlobalKey<FormState> _key = new GlobalKey();

  // This boolean is for the Autov alidation settings
  bool _validate = false;
  String fname, lname, email, phone, password;
  Size size;
  String emailVal;

  //These controllers allow us to access the TextFormFields later in the document
  static TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();
  TextEditingController controllerFname = new TextEditingController();
  TextEditingController controllerLname = new TextEditingController();
  TextEditingController controllerPhone = new TextEditingController();

  void emailExists() async {
    // this is the url to our php Rest api
    var url1 = "https://cs1908.scem.westernsydney.edu.au/validateEmail.php";
    // this code takes the values from the controllers and sends them to the rest api
    final response = await http.post(url1, body: {
      "email": controllerEmail.text,
    });
    var data2 = json.decode(response.body);
    emailVal = data2[0]["Email"];
  }

  void addData() {
    // this is the url to our php Rest api
    var url = "https://cs1908.scem.westernsydney.edu.au/adduser.php";
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
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
            automaticallyImplyLeading: true,
            title: new Text('Register'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        body: new SingleChildScrollView(
          child: new Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('images/background.png'),
              ),
            ),
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
        new SizedBox(height: 25.0),
        new Container(
          width: 375.0,
          child: new TextFormField(
              controller: controllerEmail,
              decoration: new InputDecoration(
                hintText: "Example@email.com",
                labelText: "Email",
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
              validator: validateEmail,
              onSaved: (String val) {
                email = val;
              }),
        ),
        new Container(
          width: 375.0,
          child: new TextFormField(
              controller: controllerPassword,
              decoration: new InputDecoration(
                hintText: "Must be 8 characters long",
                labelText: "Password",
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
              maxLength: 50,
              validator: validatePass,
              onSaved: (String val) {
                phone = val;
              }),
        ),
        new Container(
          width: 375.0,
          child: new TextFormField(
              controller: controllerFname,
              decoration: new InputDecoration(
                hintText: "First Name",
                labelText: "First Name",
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
              maxLength: 50,
              validator: validateFName,
              onSaved: (String val) {
                fname = val;
              }),
        ),
        new Container(
          width: 375.0,
          child: new TextFormField(
              controller: controllerLname,
              decoration: new InputDecoration(
                hintText: "Last Name",
                labelText: "Last Name",
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
              maxLength: 50,
              validator: validateLName,
              onSaved: (String val) {
                lname = val;
              }),
        ),
        new Container(
          width: 375.0,
          child: new TextFormField(
              controller: controllerPhone,
              decoration: new InputDecoration(
                hintText: "Must be 10 digits",
                labelText: "Phone Number",
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                  borderSide: new BorderSide(),
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: validatePhone,
              onSaved: (String val) {
                phone = val;
              }),
        ),
        new SizedBox(height: 15.0),
        new ButtonTheme(
            minWidth: 175.0,
            height: 50.0,
            child: new RaisedButton(
              child: new Text('Create Account'),
              color: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              onPressed: () async{
                await emailExists();
                // this if statement ensures that invalid data cant be sent to the PHP rest api
                if (_key.currentState.validate()) {
                  addData();
                  // these lines of code clear the textfield after the button is pressed

                  controllerPassword.clear();
                  controllerFname.clear();
                  controllerLname.clear();
                  controllerPhone.clear();
                  FocusScope.of(context).requestFocus(new FocusNode());
                  setState(() {
                    _validate = false;
                  });
                  Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new MyApp(),
                  ));
                } else {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  // if the code isn't valid this else statement sets autovalidate to true
                  setState(() {
                    _validate = true;
                  });
                }
              },
            ))
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
    } else if (value.length < 8) {
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
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (emailVal == controllerEmail.text) {
      return "Email Already Exists";
    }
    if (value.length == 0) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }
}
