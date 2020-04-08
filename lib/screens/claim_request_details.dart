import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  String _user;

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
    _user = widget.requestDetails.data['user'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Claims Form'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: <Widget>[
            Text('User: $_user'),
            Text('Title: $_title'),
            Text('Description: $_description'),
            Text('Date: ${_date.toString()}'),
            Text('Amount: ${_amount.toString()}'),
            _billUrl != null
                ? Image.network(_billUrl)
                : Text('Bill not available'),
          ],
        ),
      ),
    );
  }
}
