import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final Map<String, dynamic> map;
  final bool mine;

  const ChatMessage({Key key, this.map, this.mine}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(map["senderPhotoUrl"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: mine? CrossAxisAlignment.end: CrossAxisAlignment.start,
              children: [
                map["imageUrl"] != null
                    ? Image.network(
                        map["imageUrl"],
                        width: 150,
                      )
                    : Text(
                        map["text"],
                        style: TextStyle(fontSize: 18),
                  textAlign: mine? TextAlign.end: TextAlign.start,
                      ),
                Text(
                  map["senderName"],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
          mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(map["senderPhotoUrl"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
