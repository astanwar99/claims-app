import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:claims_app/constants.dart';
import 'package:claims_app/components/multi_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:claims_app/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:claims_app/auth.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

enum loginType { admin, user }

class _RegistrationScreenState extends State<RegistrationScreen> {
//  final _auth = FirebaseAuth.instance;
  String _email;
  String _password;
  bool showSpinner = false;
  loginType _type = loginType.user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('assets/logo1.jpg'),
                  ),
                ),
              ),
              ListTile(
                title: const Text('User'),
                leading: Radio(
                  value: loginType.user,
                  groupValue: _type,
                  onChanged: (loginType value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Admin'),
                leading: Radio(
                  value: loginType.admin,
                  groupValue: _type,
                  onChanged: (loginType value) {
                    setState(() {
                      _type = value;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  if (_type == loginType.user)
                    value = 'user.' + value;
                  else
                    value = 'admin.' + value;
                  _email = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email.',
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  _password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password.',
                ),
              ),
              SizedBox(
                height: 24.0,
              ),
              MultiButton('Register', Colors.blueAccent, () async {
                setState(() {
                  showSpinner = true;
                });
                try {
                  FirebaseUser newUser = await Provider.of<AuthService>(context)
                      .createUser(
                          firstName: "a",
                          lastName: "b",
                          email: _email,
                          password: _password);
                  if (newUser != null) {
                    Navigator.pushReplacementNamed(context, LoginScreen.id);
                  }
                  setState(() {
                    showSpinner = false;
                  });
                } catch (e) {
                  print(e);
                }
              })
            ],
          ),
        ),
      ),
    );
  }
}
