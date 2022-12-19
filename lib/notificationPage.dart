import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projegiris310/colors.dart';
import 'package:projegiris310/home.dart';
import 'package:projegiris310/objects/notification.dart';
import 'package:projegiris310/profilePage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'analytics.dart';
import 'databaseserviceprofile.dart';


class NotificationView extends StatefulWidget {
  NotificationView({Key key, this.analytics, this.observer}) : super(key: key);

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;


  @override
  _NotificationViewState createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  int postCount = 5;



  /*List <Post> posts = [
    Post(text: "hello world", name: 'tucan', PostImage: "assets/images/8981_f.jpg", ProfileImage: "assets/images/f1ac89bc5d020b542874dc2adbde5026113cebcb.png"),
    Post(text: "hello adsadsadasdsworld2", name: 'turan',PostImage: "assets/images/8981_f.jpg", ProfileImage: "assets/images/f1ac89bc5d020b542874dc2adbde5026113cebcb.png"), // 33 char allowed

  ];*/

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(Globaluid)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
      // print('Activity Feed Item: ${doc.data}');
    });
    return feedItems;
  }

  void buttonPressed(){
    setState((){
      postCount +=1;
    });
  }
  void initState(){
    super.initState();
    setCurrentScreen(widget.analytics, widget.observer, 'Notification Public Page', 'NotificationPublicPageState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor:Color.fromARGB(196, 196, 196, 196),
        title: new Text('Notifications'),
        elevation: 0.0,
      ),

      backgroundColor:  Color.fromARGB(255, 255, 255, 255),
      //body: Column (
         // children: <Widget>[
            //Expanded(child: getActivityFeed()),
          //]),
      body:  Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot) {
          print(snapshot.data);
          if (!snapshot.hasData) {
            print('nothing to see');
          return new Text("There is no Notifications");
          }
        return //Text( {snapshot.data});
          ListView(
            children: snapshot.data,
              );
           },
        )
      ),
    );
  }
}



Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userProfileImg: doc['userProfileImg'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
    );
  }

  configureMediaPreview() {

    if (type == "like" || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => print('showing post'),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(userProfileImg),

                ),
              )),
        ),
      ));
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      activityItemText = "liked your post";
    } else if (type == 'follow') {
      activityItemText = "is following you";
    } else if (type == 'comment') {
      activityItemText = 'replied: $commentData';
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview();

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Expanded(
          child: Container(
        color: Colors.white24,
        child: ListTile(
          title: GestureDetector(
            onTap: () => print('show profile'),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' $activityItemText',
                    ),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          //trailing: mediaPreview,
        ),
      ),
      ),
    );
  }
}






/*Padding(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children:<Widget> [
                Icon(Icons.notifications, size: 40,),
              ],

            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                  ),

                )
              ],
            ),
            Divider(
              color: Colors.black,
              height:40,
              thickness: 2,
            ),
            Column( // postların olduğu kısım
              children: posts.map((post) => PostCardNotification(
                post:post,
                delete: (){
                  setState(() {
                    posts.remove(post);
                  });
                },
              )).toList(),
            )
          ],
        ),

      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black ,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
*/