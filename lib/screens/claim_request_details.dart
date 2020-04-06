import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;

class ClaimRequestDetails extends StatefulWidget {
  static const id = 'claim_request_details';
  final String client;

  ClaimRequestDetails(this.client);
  @override
  _ClaimRequestDetailsState createState() => _ClaimRequestDetailsState();
}

class _ClaimRequestDetailsState extends State<ClaimRequestDetails> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
