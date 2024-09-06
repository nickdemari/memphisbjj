import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/admin/user-classes/user-classes-screen.dart';

class UserAdminScreen extends StatefulWidget {
  final String userUid;
  final String displayName;

  const UserAdminScreen({
    Key? key,
    required this.userUid,
    required this.displayName,
  }) : super(key: key);

  @override
  _UserAdminScreenState createState() => _UserAdminScreenState();
}

class _UserAdminScreenState extends State<UserAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .orderBy("displayName")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final users = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];

              return FutureBuilder<QuerySnapshot>(
                future: userDoc.reference.collection("registeredClasses").get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> classSnapshot) {
                  if (!classSnapshot.hasData)
                    return const CircularProgressIndicator();

                  final userClasses = classSnapshot.data?.docs ?? [];

                  return ListTile(
                    leading: CircleAvatar(
                      child: ClipOval(
                        child: Image.network(
                          userDoc["photoUrl"] ?? "",
                          fit: BoxFit.cover,
                          width: 90.0,
                          height: 90.0,
                        ),
                      ),
                      radius: 27.0,
                    ),
                    title: Text(userDoc["displayName"] ?? "Unknown"),
                    subtitle: Text(userDoc["email"] ?? "No email"),
                    trailing: Text(userClasses.length.toString()),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserClassesScreen(
                          userUid: userDoc["firebaseUid"] ?? "",
                          displayName: userDoc["displayName"] ?? "",
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
