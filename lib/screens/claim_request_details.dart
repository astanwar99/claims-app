import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClaimRequestDetails extends StatefulWidget {
  static const id = 'claim_request_details';
  final List receivedData;
  ClaimRequestDetails(this.receivedData);
  @override
  _ClaimRequestDetailsState createState() =>
      _ClaimRequestDetailsState(receivedData);
}

class _ClaimRequestDetailsState extends State<ClaimRequestDetails> {
  DocumentSnapshot requestDetails;
  FirebaseUser currentUser;
  bool approveButtonVisible = false;

  _ClaimRequestDetailsState(List data) {
    requestDetails = data[0];
    currentUser = data[1];
  }

  String _title;
  String _description;
  double _amount;
  DateTime _date;
  String _billUrl;
  String _sheetUrl;
  String _user;
  bool _approved;
  String _status;
  String _attachmentSubtitle;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  void getDetails() {
    _title = requestDetails.data['title'];
    _description = requestDetails.data['description'];
    _amount = requestDetails.data['amount'];
    _date = requestDetails.data['date'].toDate();
    _billUrl = requestDetails.data['billUrl'];
    _sheetUrl = requestDetails.data['sheetUrl'];
    _user = requestDetails.data['user'].split(".")[1];
    _approved = requestDetails.data['approved'];
    _attachmentSubtitle = "Download for more details";
    if (!_approved)
      _status = "Pending";
    else
      _status = "Approved";

    if (currentUser.email.substring(0, 5) == 'admin')
      approveButtonVisible = true;
  }

  Widget _buildDetail(String head, String body) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              head,
              style: TextStyle(
                fontFamily: 'SourceSansPro',
                fontSize: 17.0,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              body,
              style: TextStyle(
                fontFamily: 'SourceSansPro',
                fontSize: 22.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(String body) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Status",
                  style: TextStyle(
                    fontFamily: 'SourceSansPro',
                    fontSize: 17.0,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'SourceSansPro',
                    fontSize: 22.0,
                  ),
                ),
              ],
            ),
            Visibility(
              visible: approveButtonVisible,
              child: FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () {},
                child: Text(
                  "Approve",
                  style: TextStyle(
                    fontFamily: 'SourceSansPro',
                    fontSize: 17.0,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments() {
    return Builder(
      builder: (context) => Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(
                'Attachments',
                style: TextStyle(
                  fontFamily: 'SourceSansPro',
                  fontSize: 17.0,
                  letterSpacing: 1.2,
                ),
              ),
              subtitle: Text(_attachmentSubtitle),
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  onPressed: () => setState(() {
                    _billUrl != null
                        ? _launchURL(_billUrl)
                        : Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Bill not uploaded'),
                          ));
                  }),
                  child: new Text('Load Bill'),
                ),
                RaisedButton(
                  onPressed: () => setState(() {
                    _sheetUrl != null
                        ? _launchURL(_sheetUrl)
                        : Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Sheet not uploaded'),
                          ));
                  }),
                  child: new Text('Load Sheet'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildDetail('User', _user),
                _buildDetail('Title', _title),
                _buildDetail('Description', _description),
                _buildDetail('Date', _date.toString()),
                _buildDetail('Amount', _amount.toString()),
                _buildStatus(_status),
                _buildAttachments(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
