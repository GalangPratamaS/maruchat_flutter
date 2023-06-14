import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

final _fireStore = FirebaseFirestore.instance;
late User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String routeName = "CHAT_SCREEN";
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageTextController = TextEditingController();
  late DateTime now;
  late String formattedDate;
  late String messageText;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.forum),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CHAT LIST
            MessageStream(),
            // FIELD SEND MESSAGE
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: TextField(
                    controller: messageTextController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onChanged: (newValue) {
                      messageText = newValue;
                    },
                    style: const TextStyle(color: Colors.black),
                    decoration: kMessageTextFieldDecoration,
                  )),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        now = DateTime.now();
                        formattedDate = DateFormat('kk:mm:ss').format(now);
                      });
                      messageTextController.clear();
                      _fireStore.collection('messages').add({
                        'text' : messageText.trim(),
                        'sender':loggedInUser!.email!.trim(),
                        'time':formattedDate.trim()
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getMessage();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      loggedInUser = user;
      print(loggedInUser?.email);
    } catch (e) {
      print(e);
    }
  }

  void getMessage() async {
    var messages = await _fireStore.collection('messages').get();
    for (var message in messages.docs) {
      print(message.data());
    }
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _fireStore
            .collection('messages')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlue,
              ),
            );
          }

          final messages = snapshot.data!.docs;
          List<MessageBubble> messageBubbles = [];
          for (var message in messages) {
            final messageText = message['text'];
            final messageSender = message['sender'];

            final currentUserEmail = loggedInUser?.email;

            final messageBubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                isMe: currentUserEmail == messageSender);
            messageBubbles.add(messageBubble);
          }

          return Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageBubbles,
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  const MessageBubble(
      {Key? key, required this.sender, required this.text, required this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
          const SizedBox(
            height: 5,
          ),
          Material(
            borderRadius: BorderRadius.only(
                topLeft:
                    isMe ? const Radius.circular(30) : const Radius.circular(0),
                topRight:
                    isMe ? const Radius.circular(0) : const Radius.circular(30),
                bottomLeft: const Radius.circular(30),
                bottomRight: const Radius.circular(30)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlue : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.black54,
                    fontSize: 15.0),
              ),
            ),
          )
        ],
      ),
    );
  }
}
