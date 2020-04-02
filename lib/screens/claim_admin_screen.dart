import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:claims_app/components/custom_popup_menu.dart';
import 'package:claims_app/constants.dart';
import 'package:claims_app/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:claims_app/auth.dart';

final _firestore = Firestore.instance;

class ClaimAdminScreen extends StatefulWidget {
  static const String id = 'claim_admin_screen';
  final FirebaseUser currentAdmin;

  ClaimAdminScreen(this.currentAdmin);
  @override
  _ClaimAdminScreenState createState() => _ClaimAdminScreenState();
}

class _ClaimAdminScreenState extends State<ClaimAdminScreen> {
  final _auth = FirebaseAuth.instance;
  List<RequestCard> requestCards = [];

  void _select(CustomPopupMenu choice) async {
    if (choice.title == "Logout") {
      await Provider.of<AuthService>(context, listen: false).logout();
      setState(() {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      });
    }
  }

  Future<List<String>> getUsers() async {
    List<String> usersWithClaims = [];
    final userAdmin = await _firestore.collection('user-admin').getDocuments();

    print(widget.currentAdmin.email);
    for (var users in userAdmin.documents) {
      //check if user is under current admin
      if (widget.currentAdmin.email == users.data['admin'] &&
          !usersWithClaims.contains(users.data['user'])) {
        //add user to user claim list
        usersWithClaims.add(users.data['user']);
        print(users.data['user']);

        //Initialize Request card for the user
        requestCards.add(new RequestCard(
            client: users.data['user'], titles: [], descriptions: []));
      }
    }
    print(usersWithClaims);
    return usersWithClaims;
  }

  Future<String> updateRequestCardList() async {
    List<String> usersWithClaims = await getUsers();
    if (usersWithClaims.isEmpty) return null;
    final claimRequests =
        await _firestore.collection('ClaimRequests').getDocuments();
    for (var requests in claimRequests.documents) {
      if (usersWithClaims.contains(requests.data['user'])) {
        for (var card in requestCards) {
          if (card.client == requests.data['user']) {
            card.titles.add(requests.data['title']);
            card.descriptions.add(requests.data['description']);
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ListView"),
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
      body: Container(
        child: FutureBuilder<String>(
            future: updateRequestCardList(), // a Future<String> or null
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  else
                    return ListView.separated(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: requestCards.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(10.0),
                            itemCount: requestCards[index].titles.length,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (BuildContext context, int cindex) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '${requestCards[index].titles[cindex]}',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                              '${requestCards[index].descriptions[cindex]}'),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider());
              }
            }),
      ),
    );
  }
}

class RequestCard {
  String client;
  List<String> titles = [];
  List<String> descriptions = [];

  RequestCard({@required this.client, this.titles, this.descriptions});
}
