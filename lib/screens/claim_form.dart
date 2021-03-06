import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;

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
  String _title;
  String _description;
  double _amount;
  String _category;
  bool _billExists;
  File _image;
  String _uploadedFileURL;
  bool _sheetExists;
  String _spreadsheetUrl;
  List<String> _categories = ['Other', 'Accomodation', 'Travel', 'Food'];
  bool isSavingForm;

  String formattedDate;
  TextEditingController dateController;

  _ClaimFormState() {
    _dateTime = DateTime.now();
    _category = 'Other';
    _billExists = false;
    isSavingForm = false;
    _uploadedFileURL = null;
    _sheetExists = false;
    _spreadsheetUrl = null;
    updateDate();
  }

  void updateDate() {
    formattedDate = "${_dateTime.day}/${_dateTime.month}/${_dateTime.year}";
    dateController = TextEditingController(text: formattedDate);
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future uploadPic(BuildContext context, String title, String category) async {
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        '${widget.currentUser.email}/${title}_${category}_${Path.basename(_image.path)}.jpg');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    await uploadTask.onComplete;
    _uploadedFileURL = await firebaseStorageRef.getDownloadURL();
    setState(() {
      print("Picture uploaded");
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    setState(() {
      isSavingForm = true;
    });
    _formKey.currentState.save();
    if (_image != null) {
      await uploadPic(context, _title, _category);
    }
    _firestore.collection('ClaimRequests').add({
      'date': _dateTime,
      'amount': _amount,
      'title': _title,
      'description': _description,
      'billUrl': _uploadedFileURL,
      'sheetUrl': _spreadsheetUrl,
      'user': widget.currentUser.email,
      'approved': false,
    });
    Navigator.pop(context);
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
              FormField(
                builder: (FormFieldState state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.category),
                      labelText: 'Category',
                    ),
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton(
                        value: _category,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            _category = newValue;
                            state.didChange(newValue);
                          });
                        },
                        items: _categories.map((String value) {
                          return new DropdownMenuItem(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(labelText: 'Amount'),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
                onSaved: (String value) {
                  _amount = double.parse(value);
                  print(_amount);
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
              CheckboxListTile(
                  title: Text('I have bill'),
                  value: _billExists,
                  onChanged: (val) {
                    setState(() => _billExists = val);
                  }),
              Visibility(
                visible: _billExists,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _image == null
                        ? Text('Choose image')
                        : Text('${Path.basename(_image.path)}'),
                    RaisedButton(
                      child: Text("Pick Image"),
                      onPressed: getImage,
                    ),
                  ],
                ),
              ),
              CheckboxListTile(
                  title: Text('I have spread sheet'),
                  value: _sheetExists,
                  onChanged: (val) {
                    setState(() => _sheetExists = val);
                  }),
              Visibility(
                visible: _sheetExists,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Sheet Link'),
                  onSaved: (String value) {
                    _spreadsheetUrl = value;
                  },
                ),
              ),
              RaisedButton(
                child: Text("Submit"),
                onPressed: _submitForm,
              ),
              Visibility(
                visible: isSavingForm,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
