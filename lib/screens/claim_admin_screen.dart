import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:claims_app/components/custom_popup_menu.dart';
import 'package:claims_app/components/claim_card.dart';
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
  List<RequestCard> requestCards;
  List<RequestDetails> requestDetails;

  void _select(CustomPopupMenu choice) async {
    if (choice.title == "Logout") {
      await Provider.of<AuthService>(context, listen: false).logout();
      setState(() {
        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      });
    }
  }

  Future<List<String>> getClients() async {
    List<String> clientsWithClaims = [];
    requestCards = [];
    requestDetails = [];
    final userAdmin = await _firestore.collection('user-admin').getDocuments();

    print(widget.currentAdmin.email);
    for (var client in userAdmin.documents) {
      //check if user is under current admin
      if (widget.currentAdmin.email == client.data['admin'] &&
          !clientsWithClaims.contains(client.data['user'])) {
        //add user to user claim list
        clientsWithClaims.add(client.data['user']);

        //Initialize Request card for the user
        requestCards.add(new RequestCard(
            client: client.data['user'], titles: [], descriptions: []));
        requestDetails
            .add(new RequestDetails(client: client.data['user'], requests: []));
      }
    }
    return clientsWithClaims;
  }

  Future<String> updateRequestCardList() async {
    List<String> clientsWithClaims = await getClients();
    if (clientsWithClaims.isEmpty) return null;
    final claimRequests =
        await _firestore.collection('ClaimRequests').getDocuments();
    for (var requests in claimRequests.documents) {
      if (clientsWithClaims.contains(requests.data['user'])) {
        for (int i = 0; i < requestCards.length; i++) {
          if (requestCards[i].client == requests.data['user']) {
            requestCards[i].titles.add(requests.data['title']);
            requestCards[i].descriptions.add(requests.data['description']);
            requestDetails[i].requests.add(requests);
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
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                else
                  return ListView.separated(
                    itemCount: requestCards.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('${requestCards[index].client.substring(5)}'),
                            ListView.separated(
                              itemCount: requestCards[index].titles.length,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (BuildContext context, int cindex) {
                                List args = [
                                  requestDetails[index].requests[cindex],
                                  widget.currentAdmin
                                ];
                                return Container(
                                  padding: EdgeInsets.all(10.0),
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ClaimRequest(
                                    title:
                                        '${requestCards[index].titles[cindex]}',
                                    description:
                                        '${requestCards[index].descriptions[cindex]}',
                                    arguments: args,
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      SizedBox(height: 5),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(height: 15),
                  );
            }
          },
        ),
      ),
    );
  }
}

class RequestCard {
  String client;
  List<String> titles;
  List<String> descriptions;

  RequestCard({@required this.client, this.titles, this.descriptions});
}

class RequestDetails {
  String client;
  List<DocumentSnapshot> requests;

  RequestDetails({this.client, this.requests});
}
