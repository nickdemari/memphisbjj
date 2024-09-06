import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memphisbjj/components/text-fields/branded-input-field.dart';
import 'package:memphisbjj/services/validations.dart';

class MemberDependentsScreen extends StatefulWidget {
  final String parentFbUid;

  const MemberDependentsScreen({Key? key, required this.parentFbUid})
      : super(key: key);

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
          .collection('users')
          .doc(widget.parentFbUid)
          .collection('dependents');

      var child = {'displayName': fullDependentName};
      var newDependentDoc = await dependents.add(child);

      await dependents
          .doc(newDependentDoc.id)
          .update({'firebaseId': newDependentDoc.id});

      Navigator.of(context).pop();
    }
  }

  void _promptAddDependentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Dependent'),
          content: Form(
            key: _formKey,
            child: SizedBox(
              height: 75,
              child: Column(
                children: <Widget>[
                  BrandedInputField(
                    hintText: "Dependent's Full Name",
                    obscureText: false,
                    textInputType: TextInputType.text,
                    icon: Icons.perm_identity,
                    iconColor: Colors.black54,
                    bottomMargin: 20.0,
                    validateFunction: (String? value) =>
                        _validations.validateEmpty(value!),
                    onSaved: (String? name) {
                      fullDependentName = name;
                    },
                    textStyle: const TextStyle(),
                    hintStyle:
                        const TextStyle(), // Provide an empty TextStyle object
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('SAVE'),
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
          title: const Text('Manage Dependents'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _promptAddDependentDialog,
          icon: const Icon(FontAwesomeIcons.plus),
          label: const Text('ADD DEPENDENT'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.parentFbUid)
                      .collection('dependents')
                      .snapshots(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot,
                  ) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final dependents = snapshot.data?.docs ?? [];

                    if (dependents.isEmpty) {
                      return const Center(child: Text('No dependents added.'));
                    }

                    return ListView.builder(
                      itemCount: dependents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DocumentSnapshot document = dependents[index];
                        return ListTile(
                          title: Text(document['displayName']),
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
