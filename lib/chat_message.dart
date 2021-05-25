import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> map;
  final bool mine;

  const ChatMessage({Key key, this.map, this.mine}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 5),
      child: Row(
        children: [
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(map["senderPhotoUrl"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                !mine
                    ? Text(
                        map["senderName"],
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      )
                    : Container(),
                Container(
                  decoration: BoxDecoration(
                    color: mine ? Colors.blueGrey : Color(0xfffca311),
                    borderRadius: mine
                        ? BorderRadius.only(
                            topLeft: Radius.circular(50),
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                            topRight: Radius.zero)
                        : BorderRadius.only(
                            topLeft: Radius.zero,
                            bottomLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                            topRight: Radius.circular(50)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        spreadRadius: 0,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        map["imageUrl"] != null
                            ? ClipRRect(
                                borderRadius: mine
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(40),
                                        bottomLeft: Radius.circular(40),
                                        bottomRight: Radius.circular(40),
                                        topRight: Radius.zero)
                                    : BorderRadius.only(
                                        topLeft: Radius.zero,
                                        bottomLeft: Radius.circular(40),
                                        bottomRight: Radius.circular(40),
                                        topRight: Radius.circular(40)),
                                child: Image.network(
                                  map["imageUrl"],
                                  width: 200,
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  map["text"],
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                  textAlign:
                                      mine ? TextAlign.end : TextAlign.start,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(map["senderPhotoUrl"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
