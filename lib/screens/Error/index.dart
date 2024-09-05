import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  ErrorScreen({Key? key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: cWidth,
                  child: Text(
                    this.message,
                    style: TextStyle(fontSize: 24.0),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
