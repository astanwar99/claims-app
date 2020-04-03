import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;

class ClaimForm extends StatefulWidget {
  static const String id = 'claim_form';
  final FirebaseUser currentUser;

  ClaimForm(this.currentUser);
  @override
  _ClaimFormState createState() => _ClaimFormState();
}

class _ClaimFormState extends State<ClaimForm> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  DateTime _dateTime;
  String formattedDate;
  TextEditingController dateController;

  String _title;
  String _description;
  _ClaimFormState() {
    _dateTime = DateTime.now();
    updateDate();
  }

  void updateDate() {
    formattedDate = "${_dateTime.day}/${_dateTime.month}/${_dateTime.year}";
    dateController = TextEditingController(text: formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Claims Form'),
      ),
      body: new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
          key: _formKey,
          autovalidate: true,
          child: new ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  _title = value;
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
                  _description = value;
                },
              ),
              TextFormField(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2015),
                          lastDate: DateTime.now().add(Duration(days: 365)))
                      .then((value) {
                    setState(() {
                      _dateTime = value;
                      updateDate();
                    });
                  });
                },
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date of Bill',
                ),
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
                      'date': _dateTime,
                      'title': _title,
                      'description': _description,
                      'user': widget.currentUser.email
                    });
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
