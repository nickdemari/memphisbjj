import 'package:flutter/material.dart';

class MemberDependentsScreen extends StatefulWidget {
  @override
  _MemberDependentsScreenState createState() => _MemberDependentsScreenState();
}

class _MemberDependentsScreenState extends State<MemberDependentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Dependents"),
      ),
    );
  }
}