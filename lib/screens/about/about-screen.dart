import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildSectionCard('Mission', 'mission'),
                _buildSectionCard('History', 'history'),
                _buildSocialMediaLinks(),
                _buildVersionInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String documentId) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('about')
                  .doc(documentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data?.data();
                if (data == null) return const Text('No data available');

                return Text(
                  (data as Map<String, dynamic>)['body']
                      .toString()
                      .replaceAll('\\n', '\n'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaLinks() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildSocialMediaIcon(
            icon: FontAwesomeIcons.facebook,
            url: 'https://m.facebook.com/MemphisJudoandJiuJitsu/',
          ),
          const SizedBox(width: 20),
          _buildSocialMediaIcon(
            icon: FontAwesomeIcons.instagram,
            url:
                'https://www.instagram.com/explore/locations/264327003/memphis-judo-and-jiu-jitsu/',
          ),
          const SizedBox(width: 20),
          _buildSocialMediaIcon(
            icon: FontAwesomeIcons.twitter,
            url: 'https://twitter.com/memphisbjj',
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon({required IconData icon, required String url}) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: Icon(icon, size: 30),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('versioning').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var versionData = snapshot.data?.docs.first.data();
          if (versionData == null) {
            return const Text('No version information available');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text((versionData as Map<String, dynamic>)['displayVersion']),
              Text((versionData)['details']),
            ],
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
