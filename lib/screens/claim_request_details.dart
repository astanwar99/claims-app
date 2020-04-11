import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  bool _approved;
  String _status;

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
    _user = widget.requestDetails.data['user'].split(".")[1];
    _approved = widget.requestDetails.data['approved'];
    if (!_approved)
      _status = "Pending";
    else
      _status = "Approved";
  }

  Widget _buildDetail(String text) {
    return Flexible(
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SourceSansPro',
          fontSize: 25.0,
//        color: Colors.teal.shade100,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double fWidth = MediaQuery.of(context).size.width * 0.3;
    double sWidth = MediaQuery.of(context).size.width * 0.6;

    return Scaffold(
      appBar: AppBar(
        title: Text('Request Details'),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          margin: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: fWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildDetail('User'),
                    _buildDetail('Title'),
                    _buildDetail('Description'),
                    _buildDetail('Date'),
                    _buildDetail('Amount'),
                    _buildDetail('Status'),
                  ],
                ),
              ),
              Container(
                width: sWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildDetail(':   $_user'),
                    _buildDetail(':   $_title'),
                    _buildDetail(':   $_description'),
                    _buildDetail(':   ${_date.toString()}'),
                    _buildDetail(':   ${_amount.toString()}'),
                    _buildDetail(':   $_status'),
//                    _billUrl != null
//                        ? Expanded(child: Image.network(_billUrl))
//                        : Text('Bill not available'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
