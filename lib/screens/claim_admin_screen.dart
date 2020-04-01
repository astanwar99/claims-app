import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:claims_app/components/custom_popup_menu.dart';
import 'package:claims_app/constants.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInAdmin;

class ClaimAdminScreen extends StatefulWidget {
  static String id = 'claim_admin_screen';
  @override
  _ClaimAdminScreenState createState() => _ClaimAdminScreenState();
}

class _ClaimAdminScreenState extends State<ClaimAdminScreen> {
  final _auth = FirebaseAuth.instance;
  List<RequestCard> requestCards = [];

  @override
  void initState() {
    super.initState();
    getCurrentAdmin();
  }

  void getCurrentAdmin() async {
    try {
      final admin = await _auth.currentUser();
      if (admin != null) {
        loggedInAdmin = admin;
      }
    } catch (e) {
      print(e);
    }
  }

  void _select(CustomPopupMenu choice) {
    setState(() {
      if (choice.title == "Logout") {
        _auth.signOut();
        Navigator.pop(context);
      }
    });
  }

  Future<List<String>> getUsers() async {
    List<String> usersWithClaims = [];
    final userAdmin = await _firestore.collection('user-admin').getDocuments();

    print(loggedInAdmin.email);
    for (var users in userAdmin.documents) {
      //check if user is under current admin
      if (loggedInAdmin.email == users.data['admin'] &&
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