import 'package:claims_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:claims_app/components/custom_popup_menu.dart';
import 'package:claims_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:claims_app/auth.dart';

final _firestore = Firestore.instance;

class ClaimUserScreen extends StatefulWidget {
  static const String id = 'claim_user_screen';
  final FirebaseUser currentUser;

  ClaimUserScreen(this.currentUser);

  @override
  _ClaimUserScreenState createState() => _ClaimUserScreenState();
}

class _ClaimUserScreenState extends State<ClaimUserScreen> {
//  final _auth = FirebaseAuth.instance;

  bool registeredAdmin = false;
  String loggedInUserAdmin;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title;
  String description;

  Future<String> getAdmin() async {
    final userAdmin = await _firestore.collection('user-admin').getDocuments();
    print(widget.currentUser.email);
    for (var admins in userAdmin.documents) {
      if (widget.currentUser.email == admins.data['user']) {
        loggedInUserAdmin = admins.data['admin'];
        registeredAdmin = true;
        break;
      }
    }
    return null;
  }

  //Popup menu selected choice update
  void _select(CustomPopupMenu choice) async {
    if (choice.title == "Logout") {
      await Provider.of<AuthService>(context, listen: false).logout();
      setState(() {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      });
    }
  }

  Widget _buildAdminWarning() {
    return FutureBuilder<String>(
      future: getAdmin(), // a Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return Visibility(
                visible: !registeredAdmin,
                child: Row(children: <Widget>[
                  Text('Update your Admin details.'),
                  RaisedButton(
                    child: Text('Add now'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextFormField(
                                    decoration: InputDecoration(
                                        labelText: 'Admin email id'),
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Admin is required';
                                      }
                                      return null;
                                    },
                                    onSaved: (String value) {
                                      loggedInUserAdmin = 'admin.' + value;
                                    },
                                  ),
                                  RaisedButton(
                                    child: Text("Submit"),
                                    onPressed: () {
                                      setState(() {
                                        if (!_formKey.currentState.validate()) {
                                          return;
                                        }
                                        _formKey.currentState.save();
                                        registeredAdmin = true;
                                        _firestore
                                            .collection('user-admin')
                                            .add({
                                          'user': widget.currentUser.email,
                                          'admin': loggedInUserAdmin
                                        });
                                        Navigator.pop(context);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ]),
              );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Claims'),
        actions: <Widget>[
          PopupMenuButton<CustomPopupMenu>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return kPopupMenuChoices.map((CustomPopupMenu choice) {
                return PopupMenuItem<CustomPopupMenu>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildAdminWarning(),
          MessageStream(widget.currentUser),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Title'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          title = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                        onSaved: (String value) {
                          description = value;
                        },
                      ),
                      RaisedButton(
                        child: Text("Submit"),
                        onPressed: () {
                          setState(() {
                            if (!_formKey.currentState.validate()) {
                              return;
                            }
                            _formKey.currentState.save();
                            _firestore.collection('ClaimRequests').add({
                              'title': title,
                              'description': description,
                              'user': widget.currentUser.email
                            });
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  final FirebaseUser currentUser;
  MessageStream(this.currentUser);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('ClaimRequests').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || currentUser == null) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        var claims = snapshot.data.documents;
        List<ClaimRequest> claimRequests = [];

        for (var claim in claims) {
          if (currentUser.email == claim.data['user']) {
            final titleText = claim.data['title'];
            final descriptionText = claim.data['description'];

            final claimWidget = ClaimRequest(
              title: titleText,
              description: descriptionText,
            );
            claimRequests.add(claimWidget);
          }
        }

        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: claimRequests,
          ),
        );
      },
    );
  }
}

class ClaimRequest extends StatelessWidget {
  final String title;
  final String description;

  ClaimRequest({this.title, this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blueGrey,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.red,
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(description),
              ],
            ),
          )
        ],
      ),
    );
  }
}
