import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String text, File imgFile}) sendMessage;
  TextComposer(this.sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  TextEditingController textEditingController = TextEditingController();

  bool _isComposing = false;

  void _resetTextField() {
    setState(() {
      textEditingController.clear();
      this._isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
              icon: Icon(Icons.camera),
              onPressed: () async {
                final PickedFile imgPickedFile =
                    await ImagePicker().getImage(source: ImageSource.gallery);
                final File imgFile = File(imgPickedFile.path);
                if (imgFile != null) {
                  widget.sendMessage(imgFile: imgFile);
                }
              }),
          Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                  color: Color(0xffe5e5e5),
                  borderRadius: BorderRadius.circular(50)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 5),
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.text,
                  //tirando foco quando Navigator.pop
                  focusNode: FocusNode(canRequestFocus: false),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                      hintText: "Enviar uma mensagem..."),
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                  onSubmitted: (text) {
                    widget.sendMessage(text: textEditingController.text);
                    _resetTextField();
                  },
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            disabledColor: Color(0xffe5e5e5),
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(text: textEditingController.text);
                    _resetTextField();
                  }
                : null,
          )
        ],
      ),
    );
  }
}
