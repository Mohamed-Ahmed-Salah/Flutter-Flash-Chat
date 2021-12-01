
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;


class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String messageText;

  void getCurrentUSer() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = _auth.currentUser;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void getMessegesStream() async {
    final snapshots =
        FirebaseFirestore.instance.collection('messeges').snapshots();
    await for (var snapshots
        in FirebaseFirestore.instance.collection('messeges').snapshots()) {
      for (var messages in snapshots.docs) {
        print(messages.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUSer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                getMessegesStream();
                // _auth.signOut();
                //Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //MessagesStream(),

            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      messageTextController.clear();
                      await _firestore.collection('messeges').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'time':DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now()),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class MessagesStream extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messeges').orderBy('time',descending: true).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data.docs;
          List<MessageBubble> messageWidget = [];
          var tempmessageText;

          var i=0;
          for (var m in messages) {
            print('${m.data()} ${i}');
             tempmessageText = Map<String, dynamic>.from(m.data());
             i++;
            final messageText = tempmessageText['text'];
            final from = tempmessageText['sender'];
            final currentUSer=loggedInUser.email;

            //  print("${messageText}  ffffffffffffffffffffffff    ${from}   ");
            final messagewidget =MessageBubble(messageText: messageText,from: from,isMe: currentUSer==from ,);
            messageWidget.add(messagewidget);
          }
         // print( "${tempmessageText[0]['text']}      text measssss");


          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              children: messageWidget,
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      },
    );
  }
}



class MessageBubble extends StatelessWidget {
final String messageText,from;
final bool isMe;
MessageBubble({this.messageText,this.from,this.isMe});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text('$from', style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 7.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20),
              child: Text(
                '$messageText',
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
