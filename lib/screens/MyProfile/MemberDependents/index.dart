import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memphisbjj/components/TextFields/inputField.dart';
import 'package:memphisbjj/services/validations.dart';

class MemberDependentsScreen extends StatefulWidget {
  final String parentFbUid;

  MemberDependentsScreen({required this.parentFbUid});

  @override
  _MemberDependentsScreenState createState() => _MemberDependentsScreenState();
}

class _MemberDependentsScreenState extends State<MemberDependentsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Validations _validations = Validations();
  String? fullDependentName;

  void _addDependent() async {
    final FormState? form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      CollectionReference dependents = FirebaseFirestore.instance
          .collection("users")
          .doc(widget.parentFbUid)
          .collection("dependents");

      var child = {"displayName": this.fullDependentName};
      var newDependentDoc = await dependents.add(child);

      await dependents
          .doc(newDependentDoc.id)
          .update({"firebaseId": newDependentDoc.id});

      Navigator.of(context).pop();
    }
  }

  void _promptAddDependentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Dependent'),
          content: Form(
            key: _formKey,
            child: SizedBox(
              height: 75,
              child: Column(
                children: <Widget>[
                  InputField(
                    hintText: "Dependent's Full Name",
                    obscureText: false,
                    textInputType: TextInputType.text,
                    icon: Icons.perm_identity,
                    iconColor: Colors.black54,
                    bottomMargin: 20.0,
                    validateFunction: (String? value) =>
                        _validations.validateEmpty(value!),
                    onSaved: (String? name) {
                      this.fullDependentName = name;
                    },
                    textStyle: TextStyle(),
                    hintStyle: TextStyle(), // Provide an empty TextStyle object
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('SAVE'),
              onPressed: () => _addDependent(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Manage Dependents"),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _promptAddDependentDialog,
          icon: Icon(FontAwesomeIcons.plus),
          label: Text("ADD DEPENDENT"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(widget.parentFbUid)
                      .collection("dependents")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final dependents = snapshot.data?.docs ?? [];

                    if (dependents.isEmpty) {
                      return Center(child: Text("No dependents added."));
                    }

                    return ListView.builder(
                      itemCount: dependents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot document = dependents[index];
                        return ListTile(
                          title: Text(document["displayName"]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
