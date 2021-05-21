import 'package:chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async{
  runApp(MaterialApp(home: MyApp()));
  Firestore.instance.collection("mensagens").document("msg1").snapshots().listen((event) {
    print(event.data);
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(color: Colors.blue)
      ),
      home: ChatScreen(),
    );
  }
}
