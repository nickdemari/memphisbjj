import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memphisbjj/screens/ScheduleMain/SelectedSchedule/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/index.dart';
import 'package:memphisbjj/utils/StickyHeaderList/StickyHeaderList.dart';
import 'package:memphisbjj/utils/StickyHeaderList/StickyRow.dart';
import 'package:memphisbjj/utils/ListItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void buildByDateView(BuildContext context) {
  showBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(10.0),
              topRight: const Radius.circular(10.0),
            ),
          ),
          child: Column(
            children: <Widget>[],
          ),
        );
      });
}

Container _buildRowHeaderContents(String title) {
  return Container(
      color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
      ));
}

StreamBuilder<QuerySnapshot> buildByDateFb(BuildContext context, String documentRef, GlobalKey<ScaffoldState> scaffoldState) {
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection("schedules").document("bartlett").collection("dates").orderBy("date").snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData)
        return Center(
          child: CircularProgressIndicator(),
        );

      final int documentCount = snapshot.data.documents.length;
      return Material(
        child: StickyList.builder(
          builder: (BuildContext context, int index) {
            final DocumentSnapshot doc = snapshot.data.documents[index];

            final ListItem item = !doc.data.containsKey("class") ? HeadingItem(doc['date']) : ScheduleItem(doc['date'], doc['leadBy'], new Map<String, dynamic>.from(doc['class']), doc.documentID);

            if (item is HeadingItem) {
              HeaderRow header = HeaderRow(
                  child: Container(
                      color: Colors.blueGrey,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          item.day.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                      )),
                  height: 20.0);
              return header;
            } else if (item is ScheduleItem) {
              RegularRow row = RegularRow(
                  height: 20.0,
                  child: ListTile(
                      leading: new CircleAvatar(
                        child: new Text(item.displayDateTime.toString()),
                        radius: 27.0,
                      ),
                      title: new Text(item.className),
                      subtitle: Text(item.instructor)));
              return row;
            }
          },
          itemCount: documentCount,
        ),
      );
    },
  );
}

List<StickyListRow> _getData(AsyncSnapshot<QuerySnapshot> snapshot) {
  List<StickyListRow> items = new List<StickyListRow>();

  for (DocumentSnapshot doc in snapshot.data.documents) {
    final ListItem item = !doc.data.containsKey("class") ? HeadingItem(doc['date']) : ScheduleItem(doc['date'], doc['leadBy'], new Map<String, dynamic>.from(doc['class']), doc.documentID);

    if (item is HeadingItem) {
      HeaderRow header = HeaderRow(
          child: Container(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  item.day.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              )),
          height: 40.0);
      items.add(header);
    } else if (item is ScheduleItem) {
      RegularRow row = RegularRow(
          height: 20.0,
          child: ListTile(
              leading: new CircleAvatar(
                child: new Text(item.displayDateTime.toString()),
                radius: 27.0,
              ),
              title: new Text(item.className),
              subtitle: Text(item.instructor)));
      items.add(row);
    }
  }
  return items;
}

StreamBuilder buildByDateTab(DateTime lastMidnight, ScheduleMainScreen widget) {
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection("schedules").document("bartlett").collection("dates").where('date', isGreaterThanOrEqualTo: lastMidnight).orderBy("date").limit(600).snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

      final int documentCount = snapshot.data.documents.length;
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final DocumentSnapshot doc = snapshot.data.documents[index];
          final ListItem item = !doc.data.containsKey("class") ? HeadingItem(doc['date']) : ScheduleItem(doc['date'], doc['instructor'], new Map<String, dynamic>.from(doc['class']), doc.documentID);
          final CollectionReference classParticipants = doc.reference.collection("participants");

          if (item is HeadingItem) {
            Widget header = Container(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    item.day,
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ));
            return header;
          } else if (item is ScheduleItem) {
            Query userQuery = classParticipants.where("uid", isEqualTo: widget.user.uid);

            Widget row = GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectedScheduleScreen(
                          locationName: widget.locationName,
                          user: widget.user,
                          scheduleItem: item,
                          usersInClassCollection: classParticipants,
                          distanceToMjj: widget.distanceToMjj,
                        )));
              },
              child: ListTile(
                  leading: new CircleAvatar(
                    child: new Text(item.displayDateTime.toString()),
                    radius: 27.0,
                  ),
                  title: new Text(item.className),
                  subtitle: Text(item.instructor),
                  trailing: FutureBuilder(
                      future: userQuery.getDocuments(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData && snapshot.data.documents.length > 0) {
                          return AnimatedOpacity(
                            opacity: 1.0,
                            duration: Duration(milliseconds: 500),
                            child: Icon(Icons.schedule),
                          );
                        } else {
                          return AnimatedOpacity(
                            opacity: 0.0,
                            duration: Duration(milliseconds: 500),
                            child: Icon(Icons.schedule),
                          );
                        }
                      })),
            );
            return row;
          }
        },
        itemCount: documentCount,
      );
    },
  );
}

Builder buildByInstructorTab(DateTime lastMidnight, ScheduleMainScreen widget) {
  return Builder(
    builder: (BuildContext context) {
      final Stream<QuerySnapshot> instructorsRef = Firestore.instance.collection("instructors").orderBy("name").snapshots();
      final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
      return Scaffold(
          key: _globalKey,
          body: StreamBuilder(
              stream: instructorsRef,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, int index) {
                      DocumentSnapshot document = snapshot.data.documents[index];
                      String name = document["name"];
                      return ListTile(
                          title: Text(name),
                          onTap: () => _globalKey.currentState.showBottomSheet((context) => StreamBuilder(
                              stream: Firestore.instance.collection("schedules").document("bartlett").collection("dates").where("instructor", isEqualTo: name).where('date', isGreaterThanOrEqualTo: lastMidnight).orderBy("date").snapshots(),
                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                                final int documentCount = snapshot.data.documents.length;
                                return Container(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        color: Colors.black12,
                                        child: ListTile(
                                          leading: Text(name),
                                          trailing: Icon(Icons.drag_handle),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemBuilder: (BuildContext context, int index) {
                                            final DocumentSnapshot doc = snapshot.data.documents[index];
                                            final ListItem item = !doc.data.containsKey("class") ? HeadingItem(doc['date']) : ScheduleItem(doc['date'], doc['instructor'], new Map<String, dynamic>.from(doc['class']), doc.documentID);
                                            final CollectionReference classParticipants = doc.reference.collection("participants");
                                            print("$index $item");
                                            if (item is HeadingItem) {
                                              Widget header = Container(
                                                  color: Colors.blue,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Text(
                                                      item.day,
                                                      style: TextStyle(color: Colors.white, fontSize: 18.0),
                                                    ),
                                                  ));
                                              return header;
                                            } else if (item is ScheduleItem) {
                                              var formatter = new DateFormat('EEEE');
                                              var day = formatter.format(item.rawDateTime);
                                              Widget row = GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => SelectedScheduleScreen(
                                                            locationName: widget.locationName,
                                                            user: widget.user,
                                                            scheduleItem: item,
                                                            usersInClassCollection: classParticipants,
                                                            distanceToMjj: widget.distanceToMjj,
                                                          )));
                                                },
                                                child: ListTile(
                                                    leading: CircleAvatar(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          Text(item.displayDateTime),
                                                          Text(
                                                            day,
                                                            style: TextStyle(fontSize: 10.0),
                                                          ),
                                                        ],
                                                      ),
                                                      radius: 28.0,
                                                    ),
                                                    title: new Text(item.className),
                                                    subtitle: Text(item.instructor)),
                                              );
                                              return row;
                                            }
                                          },
                                          itemCount: documentCount,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              })));
                    });
              }));
    },
  );
}

Builder buildByClassTab(DateTime lastMidnight, ScheduleMainScreen widget) {
  return Builder(builder: (BuildContext context) {
    final Stream<QuerySnapshot> eventsRef = Firestore.instance.collection("events").orderBy("class.name").snapshots();
    final GlobalKey<ScaffoldState> _classGlobalKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: _classGlobalKey,
        body: StreamBuilder(
            stream: eventsRef,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();

              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, int index) {
                    DocumentSnapshot document = snapshot.data.documents[index];
                    var event = document["class"];
                    var eventObj = Map<String, dynamic>.from(event);
                    return ListTile(
                        title: Text(eventObj['name']),
                        onTap: () => _classGlobalKey.currentState.showBottomSheet((context) => StreamBuilder(
                            stream: Firestore.instance.collection("schedules").document("bartlett").collection("dates").where("class.name", isEqualTo: eventObj['name']).where('date', isGreaterThanOrEqualTo: lastMidnight).orderBy("date").snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                              final int documentCount = snapshot.data.documents.length;
                              return Material(
                                child: ListView.builder(
                                  itemBuilder: (BuildContext context, int index) {
                                    final DocumentSnapshot doc = snapshot.data.documents[index];
                                    final ListItem item = !doc.data.containsKey("class") ? HeadingItem(doc['date']) : ScheduleItem(doc['date'], doc['instructor'], new Map<String, dynamic>.from(doc['class']), doc.documentID);
                                    final CollectionReference classParticipants = doc.reference.collection("participants");
                                    print("$index $item");
                                    if (item is HeadingItem) {
                                      Widget header = Container(
                                          color: Colors.blue,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              item.day,
                                              style: TextStyle(color: Colors.white, fontSize: 18.0),
                                            ),
                                          ));
                                      return header;
                                    } else if (item is ScheduleItem) {
                                      var formatter = new DateFormat('EEEE');
                                      var day = formatter.format(item.rawDateTime);
                                      Widget row = GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => SelectedScheduleScreen(
                                                        locationName: widget.locationName,
                                                        user: widget.user,
                                                        scheduleItem: item,
                                                        usersInClassCollection: classParticipants,
                                                        distanceToMjj: widget.distanceToMjj,
                                                      )));
                                        },
                                        child: ListTile(
                                            leading: CircleAvatar(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(item.displayDateTime),
                                                  Text(
                                                    day,
                                                    style: TextStyle(fontSize: 10.0),
                                                  ),
                                                ],
                                              ),
                                              radius: 28.0,
                                            ),
                                            title: new Text(item.className),
                                            subtitle: Text(item.instructor)),
                                      );
                                      return row;
                                    }
                                  },
                                  itemCount: documentCount,
                                ),
                              );
                            })));
                  });
            }));
  });
}
