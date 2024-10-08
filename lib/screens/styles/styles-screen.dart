import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/styles/selected-styles-screen/selected-styles-screen.dart';

class StylesScreen extends StatefulWidget {
  const StylesScreen({super.key});

  @override
  _StylesScreenState createState() => _StylesScreenState();
}

class _StylesScreenState extends State<StylesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Styles'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('styles').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final int collectionCount = snapshot.data!.docs.length;
          if (collectionCount == 0) {
            return const ListTile(
              title: Text('No styles available'),
            );
          }

          return ListView.builder(
            itemCount: collectionCount,
            itemBuilder: (BuildContext context, int index) {
              final DocumentSnapshot doc = snapshot.data!.docs[index];
              if (doc['name'] == 'None') {
                return const SizedBox.shrink();
              }
              return ListTile(
                onTap: () {
                  String uid = doc.id;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectedStyleScreen(
                        styleId: uid,
                        name: doc['name'],
                      ),
                    ),
                  );
                },
                title: Text(doc['name']),
              );
            },
          );
        },
      ),
    );
  }
}
