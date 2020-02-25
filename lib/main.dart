import 'package:flutter/material.dart';
import 'package:claims_app/screens/welcome_screen.dart';
import 'package:claims_app/screens/login_screen.dart';
import 'package:claims_app/screens/registration_screen.dart';
import 'package:claims_app/screens/claim_user_screen.dart';
import 'package:claims_app/screens/claim_admin_screen.dart';

void main() => runApp(ClaimsApp());

class ClaimsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ClaimUserScreen.id: (context) => ClaimUserScreen(),
        ClaimAdminScreen.id: (context) => ClaimAdminScreen()
      },
    );
  }
}
