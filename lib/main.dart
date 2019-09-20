import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import './Register.dart';
import './CheckIn.dart';
import './Account.dart';




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
    debugShowCheckedModeBanner: false,
    title:"Register",
    home: new MyApp(),
  )
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<FormState> _key = new GlobalKey();
  // This boolean is for the Autov alidation settings
  bool _validate = false;
  String email, password, loginVal, passUserID;
  int userId;
  Size size;
  bool _obscureText = true;


  //These controllers allow us to access the TextFormFields later in the document
  static TextEditingController controllerEmail = new TextEditingController();
  TextEditingController controllerPassword = new TextEditingController();

  void getUserId() async{

    var url1 = "https://cs1908.scem.westernsydney.edu.au/userID.php";
    // this code takes the values from the controllers and sends them to the rest api
    final response2 = await http.post(url1, body: {
      "email": controllerEmail.text,
    });

    var data = json.decode(response2.body);

    passUserID = data[0]["User_Id"];
    print(passUserID);
  }

   void login() async{
    // this is the url to our php Rest api
    var url="https://cs1908.scem.westernsydney.edu.au/userLogin.php";
    // this code takes the values from the controllers and sends them to the rest api
    final response = await http.post(url, body: {
      "email": controllerEmail.text,
      "password": controllerPassword.text,
    });
    var data2= json.decode(response.body);
    loginVal= data2;
  }




  @override
  Widget build(BuildContext context){
    size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(

        appBar: new AppBar(
          title: new Text('Login'),
        ),
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
        Container(
          margin: EdgeInsets.only(top: size.height * 0.15),
          alignment: Alignment.center,
          height: size.width / 2.5,
          child: Image.asset(
            'images/logo.jpg',
            fit: BoxFit.fitWidth,
          ),
        ),
        SizedBox(
          height: size.height * 0.05,
        ),
    new Container(
    width: 375.0,
        child: new TextFormField(
            controller: controllerEmail,
            decoration: new InputDecoration(
              icon: new Icon(Icons.email),
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
    ),
        new Container(
        width: 375.0,
        child: new TextFormField(
            controller: controllerPassword,
            decoration: new InputDecoration(
              icon: new Icon(Icons.lock),
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
            obscureText: _obscureText,
            onSaved: (String val) {
              password = val;
            }
        ),
        ),
        new SizedBox(height: 15.0, width: 60.0),
        new ButtonTheme(
          minWidth: 150.0,
          height: 50.0,
          child:  RaisedButton(
            child: new Text('Login'),
            color: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () async
            {
              // this if statement ensures that invalid data cant be sent to the PHP rest api
              await login();
              if(_key.currentState.validate()) {
                await getUserId();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => new Account(controllerEmail.text,passUserID)),
                );
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
            minWidth: 150.0,
            height: 50.0,
            child:  RaisedButton(
              child: new Text('Register'),
              color: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              onPressed: ()
              {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => new Register()),
               );
              },
            )
        )
      ],

    );

  }

  //Validation for Password
  String validatePass(String value) {
    if (loginVal != "Password is valid!") {
      return "Password is incorrect";
    }
    if (value.length == 0) {
      return "Password is Required";
    }
    else if (value.length < 8) {
      return "Password must be atleast 8 characters";
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
