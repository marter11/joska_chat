import 'package:Joska_Chat/main.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'networking/main.dart';


// NOTE: Might put these kind of functions into a separate file
void createRoom(String name, String number)
{
  ConnectionHandler serverConnection = ConnectionHandler(SERVER_ADDRESS, SERVER_PORT);
  String sessionForRoomCreation = serverConnection.expectResponse(displayChatRoomUI);

  String dataToSend = "register:"+name;
  serverConnection.sendData(dataToSend, sessionForRoomCreation);

  // should block this until callback or timeout is called
}
=======
import 'network.dart';
import 'main.dart';
>>>>>>> 760e95eaca84142309a47e17a91162c1f88ca592

class NewRoom extends StatefulWidget
{
  @override
  NewRoomState createState() => NewRoomState();
}

class NewRoomState extends State<NewRoom>
{
  final nameController = TextEditingController();
  final numberController = TextEditingController();

  bool ok1 = false;
  bool ok2 = false;

  String name = "";
  String number = '';
  @override
  Widget build(BuildContext context)
  {
    // main 'widget tree' of the room creation page
    return Scaffold
    (
      backgroundColor: Colors.grey[800],
      // appBar: AppBar
      // (
      //   // app bar, so we know where we are (and so it doesn't look like dogshit)
      //   title: Text("Create Room"),
      //   centerTitle: true,
      //   backgroundColor: Colors.grey[900],
      // ),
      body: Column
      (
        // necessary, so that we can put widgets under eachother
        children: <Widget>
        [
          Container
          (
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Text
            (
              "Create Room",
              textScaleFactor: 1.5,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Container
          (
            // text field for room name with some padding
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 0),
            child: TextField
            (
              textCapitalization: TextCapitalization.words,
              controller: nameController,
              decoration: InputDecoration
              (
                // minimalistic design so it doesn't look like dogshit
                border: OutlineInputBorder(),
                labelText: "Room Name"
              ),
              onChanged: (String value)
              {
                // ok1 boolean in order to know if the field contains something
                if(value != "")
                {
                  ok1 = true;
                  name = value;
                }
                else ok1 = false;
              }
            )
          ),
          Container
          (
            // text field for room number, if those will exist
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: TextField
            (
              keyboardType: TextInputType.number,
              decoration: InputDecoration
              (
                // design
                border: OutlineInputBorder(),
                labelText: "Room Number"
              ),
              controller: numberController,

              onChanged: (String value)
              {
                // ok2 boolean in order to know if the field contains something
                if(value != null)
                {
                  ok2 = true;
                  number = value;
                }
                else ok2 = false;
              }
            )
          ),
          Container
          (
            // button, for actually creating the room
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 0),
            //flutter wants to use the new 'ElevatedButton', but this is much better
            child: RaisedButton
            (
              elevation: 10,
              color: Colors.grey[400],
              child: Text("Create Room"),
              onPressed: ()
              {
                if(ok1 && ok2)
                {
                  // calls backend function for creating room
                  createRoom(name, number);
                  // closes room creation page
                  Navigator.pop(context);
                }
              },
              // just for testing, couldn't get it working
              disabledColor: Colors.red,
              disabledElevation: 1,
            )
          ),
        ],
      ),
    );
  }
}