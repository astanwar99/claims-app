import 'package:claims_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:claims_app/screens/welcome_screen.dart';
import 'package:claims_app/screens/login_screen.dart';
import 'package:claims_app/screens/registration_screen.dart';
import 'package:claims_app/screens/claim_user_screen.dart';
import 'package:claims_app/screens/claim_admin_screen.dart';
import 'package:claims_app/routes.dart';
import 'package:provider/provider.dart';

void main() => runApp(ChangeNotifierProvider<AuthService>(
      child: Claims(),
      create: (BuildContext context) {
        return AuthService();
      },
    ));

class Claims extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Claims App',
      home: FutureBuilder<FirebaseUser>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.error != null) {
              print("Error");
              return Text(snapshot.error.toString());
            }
            if (snapshot.hasData) {
              String userType = snapshot.data.email.split(".")[0];
              return userType == "admin"
                  ? ClaimAdminScreen(snapshot.data)
                  : ClaimUserScreen(snapshot.data);
            } else {
              return WelcomeScreen();
            }
          } else {
            return LoadingCircle();
          }
        },
      ),
      onGenerateRoute: (settings) {
        final FirebaseUser data = settings.arguments;
        switch (settings.name) {
          case welcomeScreen:
            return MaterialPageRoute(builder: (context) => WelcomeScreen());
          case loginScreen:
            return MaterialPageRoute(builder: (context) => LoginScreen());
          case registrationScreen:
            return MaterialPageRoute(
                builder: (context) => RegistrationScreen());
          case claimAdminScreen:
            return MaterialPageRoute(
                builder: (context) => ClaimAdminScreen(data));
          case claimUserScreen:
            return MaterialPageRoute(
                builder: (context) => ClaimUserScreen(data));
          default:
            return MaterialPageRoute(builder: (context) => WelcomeScreen());
        }
      },
    );
  }
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}

//Future<void> main() async {
//  WidgetsFlutterBinding.ensureInitialized();
//  SharedPreferences prefs = await SharedPreferences.getInstance();
//  var email = prefs.getString('email');
//  print(email);
//  if (email == null) {
//    runApp(Login());
//  } else {
//    if (email.split(".")[0] == "admin") {
//      runApp(Admin());
//    } else {
//      runApp(User());
//    }
//  }
//}

//class Login extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      initialRoute: WelcomeScreen.id,
//      routes: {
//        WelcomeScreen.id     : (context) => WelcomeScreen(),
//        LoginScreen.id       : (context) => LoginScreen(),
//        RegistrationScreen.id: (context) => RegistrationScreen(),
//      },
//    );
//  }
//}
//
//class User extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(initialRoute: ClaimUserScreen.id, routes: {
//      ClaimUserScreen.id: (context) => ClaimUserScreen(),
//    });
//  }
//}
//
//class Admin extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//        initialRoute: ClaimAdminScreen.id,
//        routes: {ClaimAdminScreen.id: (context) => ClaimAdminScreen()});
//  }
//}
