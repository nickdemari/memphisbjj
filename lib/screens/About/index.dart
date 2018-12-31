import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Mission",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder(
                          stream: Firestore.instance
                              .collection("about")
                              .document("mission")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (!snapshot.hasData)
                              return Center(child: CircularProgressIndicator());

                            DocumentSnapshot doc = snapshot.data;
                            return Text(doc["body"]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "History",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder(
                          stream: Firestore.instance
                              .collection("about")
                              .document("history")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (!snapshot.hasData)
                              return Center(child: CircularProgressIndicator());

                            DocumentSnapshot doc = snapshot.data;
                            var history = doc["body"];
                            return Text(
                              history.toString().replaceAll("\\n", "\n"),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          _launchURL("https://m.facebook.com/MemphisJudoandJiuJitsu/",);
                        },
                        child: Icon(FontAwesomeIcons.facebook),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          _launchURL("https://www.instagram.com/explore/locations/264327003/memphis-judo-and-jiu-jitsu/",);
                        },
                        child: Icon(FontAwesomeIcons.instagram),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          _launchURL("https://twitter.com/memphisbjj",);
                        },
                        child: Icon(FontAwesomeIcons.twitter),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                  child: StreamBuilder(
                    stream:
                        Firestore.instance.collection("versioning").snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData)
                        return Center(child: CircularProgressIndicator());

                      DocumentSnapshot doc = snapshot.data.documents[0];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(doc["displayVersion"]),
                          Text(doc["details"])
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
