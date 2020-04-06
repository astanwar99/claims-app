import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClaimRequest extends StatelessWidget {
  final String title;
  final String description;
  final String screenId;
  final String client;

  ClaimRequest({this.title, this.description, this.screenId, this.client});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (screenId != null)
          Navigator.pushNamed(context, screenId, arguments: client);
      },
      child: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(description),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
