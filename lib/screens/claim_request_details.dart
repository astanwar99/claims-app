import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClaimRequestDetails extends StatefulWidget {
  static const id = 'claim_request_details';
  final DocumentSnapshot requestDetails;

  ClaimRequestDetails(this.requestDetails);
  @override
  _ClaimRequestDetailsState createState() => _ClaimRequestDetailsState();
}

class _ClaimRequestDetailsState extends State<ClaimRequestDetails> {
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
  Future<void> _launchedBill;
  Future<void> _launchedSheet;

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  void getDetails() {
    _title = widget.requestDetails.data['title'];
    _description = widget.requestDetails.data['description'];
    _amount = widget.requestDetails.data['amount'];
    _date = widget.requestDetails.data['date'].toDate();
    _billUrl = widget.requestDetails.data['billUrl'];
    _sheetUrl = widget.requestDetails.data['sheetUrl'];
    _user = widget.requestDetails.data['user'].split(".")[1];
    _approved = widget.requestDetails.data['approved'];
    _attachmentSubtitle = "Download for more details";
    if (!_approved)
      _status = "Pending";
    else
      _status = "Approved";
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
                        ? _launchedBill = _launchURL(_billUrl)
                        : Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Bill not uploaded'),
                          ));
                  }),
                  child: new Text('Load Bill'),
                ),
                RaisedButton(
                  onPressed: () => setState(() {
                    _sheetUrl != null
                        ? _launchedSheet = _launchURL(_sheetUrl)
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
                _buildDetail('Status', _status),
                _buildAttachments(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
