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

  void _logIn() async {
    _currentUser = await _getUser();
    setState(() {});
    if (_currentUser == null) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível fazer o login, tente novamente"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _sendMessages({String text, File imgFile, FirebaseUser user}) async {
    user = _currentUser;
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
          .ref()
          .child("imagens")
          .child(
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0xff320007), Color(0xff510505)],
            stops: [0, 0.6],
          )),
        ),
        title: _currentUser != null
            ? Text("Olá ${_currentUser.displayName}")
            : Text("Bate-Papo do Gustavo"),
        centerTitle: true,
        elevation: 0,
        leading: _currentUser != null
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
            : Container(),
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.delete_sweep),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Apagar suas mensagens?"),
                            content: Text(
                              "Você irá apagar todas as suas mensagens!",
                            ),
                            actions: [
                              TextButton(
                                child: Text("confirmar",
                                    style: TextStyle(color: Colors.grey)),
                                onPressed: () {
                                  Firestore.instance
                                      .collection("mensagens")
                                      .getDocuments()
                                      .then((snapshot) {
                                    for (DocumentSnapshot document
                                        in snapshot.documents) {
                                      if (document["uid"] == _currentUser.uid) {
                                        document.reference.delete();
                                      }
                                    }
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancelar"))
                            ],
                          );
                        });
                  })
              : Container()
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff14213d), Color(0xff142130)], //14213d
              stops: [0.3, 1]),
          color: Color(0xff14213d), //14213d
        ),
        child: _currentUser != null
            ? Column(
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
                          return Center(child: CircularProgressIndicator());
                        default:
                          List<DocumentSnapshot> documents =
                              snapshot.data.documents.reversed.toList();
                          return ListView.builder(
                            itemCount: documents.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              return ChatMessage(
                                map: documents[index].data,
                                mine: documents[index].data["uid"] ==
                                    _currentUser?.uid,
                                id: documents[index].documentID,
                                user: _currentUser,
                              );
                            },
                          );
                      }
                    },
                  )),
                  _isloading ? LinearProgressIndicator() : Container(),
                  TextComposer(_sendMessages),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Entre\npara\nparticipar",
                      style: TextStyle(color: Colors.white, fontSize: 50),
                      textAlign: TextAlign.center,
                    ),
                    MaterialButton(
                      onPressed: () {
                        _logIn();
                      },
                      minWidth: 200,
                      height: 100,
                      child: Text(
                        "Entrar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Color(0xff510505),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Colors.white,
                          width: 5,
                        ),
                      ),
                      elevation: 8,
                      highlightElevation: 2,
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
