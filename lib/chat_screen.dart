import 'dart:io';

import 'package:chat/chat_message.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;

  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  void _sendMessages({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível fazer o login, tente novamente"),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> map = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now()
    };
    if (imgFile != null) {
      setState(() {
        _isloading = true;
      });
      StorageUploadTask task = FirebaseStorage.instance
          .ref().child("imagens").child(
            user.uid + DateTime.now().millisecondsSinceEpoch.toString(),
          )
          .putFile(imgFile);
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      map["imageUrl"] = url;
    }
    if (text != null) {
      map["text"] = text;
    }

    Firestore.instance.collection("mensagens").add(map);

    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: _currentUser != null
            ? Text("Olá ${_currentUser.displayName}")
            : Text("Não logado.."),
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null
              ? BackButton(
                  onPressed: () {
                    setState(() {
                      FirebaseAuth.instance.signOut();
                      googleSignIn.signOut();
                      scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text("Você saiu..."),
                      ));
                    });
                  },
                )
              : IconButton(icon: Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("mensagens")
                .orderBy("time")
                .snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  List<DocumentSnapshot> documents =
                      snapshot.data.documents.reversed.toList();
                  return ListView.builder(
                    itemCount: documents.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return ChatMessage(
                        map: documents[index].data,
                        mine: documents[index].data["uid"] == _currentUser?.uid,
                      );
                    },
                  );
              }
            },
          )),
          _isloading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessages),
        ],
      ),
    );
  }
}
