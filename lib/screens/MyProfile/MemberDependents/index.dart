import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memphisbjj/components/TextFields/inputField.dart';
import 'package:memphisbjj/services/validations.dart';

class MemberDependentsScreen extends StatefulWidget {
  final String parentFbUid;

  MemberDependentsScreen({this.parentFbUid});
  @override
  _MemberDependentsScreenState createState() => _MemberDependentsScreenState();
}

class _MemberDependentsScreenState extends State<MemberDependentsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Validations _validations = Validations();

  String fullDependentName;

  void _addDependent() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      var dependentCollection = Firestore.instance
          .collection("users")
          .document(widget.parentFbUid)
          .collection("dependents");
      var child = Map.of({"displayName": this.fullDependentName});
      var newDependentDoc = await dependentCollection.add(child);

      await dependentCollection
          .document(newDependentDoc.documentID)
          .updateData(Map.of({"firebaseId": newDependentDoc.documentID}));

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
              child: Container(
                height: 75,
                child: Column(
                  children: <Widget>[
                    InputField(
                      hintText: "Dependents Full Name",
                      obscureText: false,
                      textInputType: TextInputType.text,
                      icon: Icons.perm_identity,
                      iconColor: Colors.black54,
                      bottomMargin: 20.0,
                      validateFunction: _validations.validateEmpty,
                      onSaved: (String first) {
                        this.fullDependentName = first;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () => Navigator.of(context).pop()),
              new FlatButton(
                  child: new Text('SAVE'), onPressed: () => _addDependent())
            ],
          );
        });
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
          onPressed: () => _promptAddDependentDialog(),
          icon: Icon(FontAwesomeIcons.plus),
          label: Text("ADD DEPENDENT"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("users")
                      .document(widget.parentFbUid)
                      .collection("dependents")
                      .snapshots(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot,
                  ) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    final int collectionSize = snapshot.data.documents.length;
                    return ListView.builder(
                      itemCount: collectionSize,
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot document =
                            snapshot.data.documents[index];
                        return ListTile(
                          title: Text(document["displayName"]),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
