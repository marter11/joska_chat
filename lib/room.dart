import 'package:flutter/material.dart';
import 'main.dart';
import 'network.dart';

class Room extends StatefulWidget 
{
  const Room({Key? key}) : super(key: key);

  @override
  RoomState createState() => RoomState();
}

class RoomState extends State<Room> 
{
  final messageController = TextEditingController();
  String message = "";
  @override
  Widget build(BuildContext context) 
  {
    final data = ModalRoute.of(context)!.settings.arguments as RoomData;
    return Scaffold
    (
      backgroundColor: Colors.grey[800],
      appBar: AppBar
      (
        title: Text(data.id),
        backgroundColor: Colors.grey[900],
        actions: 
        [
          IconButton
          (
            color: Colors.white,
            icon: Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column
      (
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: 
        [
          Expanded
          (
            child: Container
            (
              color: Colors.red,
              child: Row
              (
                children:
                [
                  // incoming messages from other users
                  Column
                  (
                    children: 
                    [
                      Text('INmessage1'),
                      Text('INmessage2'),
                    ],
                  ),
                  Column
                  (
                    // users messages
                    children:
                    [
                      Text('OUTmessage1'),
                      Text('OUTmessage2'),
                    ],
                  ),
                ]
              ),
            ),
          ),
          Container
          (
            // color: Colors.grey[400],
            child: Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
              [
                Flexible
                (
                  child: Container
                  (
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    child: TextField
                    (
                      cursorColor: Colors.grey[900],
                      decoration: InputDecoration
                      (
                        hintText: "Send a message!",
                        border: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder
                        (
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Colors.grey.shade900),
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      controller: messageController,
                      onChanged: (String value) 
                      {
                        message = value;
                      },
                    ),
                  ),
                ),
                Container
                (
                  child: IconButton
                  (
                    splashColor: null,
                    onPressed: () 
                    {
                      if(message != "")
                      {
                        messageController.clear();
                        sendMessage(message);
                      }
                    },
                    icon: Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}