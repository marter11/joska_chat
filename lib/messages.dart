import 'package:Joska_Chat/networking/main.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'networking/main.dart';

// test data
//Map rooms = {"kecske": ["192", "8080"], "gika": ["sda"]};
Map rooms = {};

//returns either the IP or the name(ID) of a room
//ip - false ==> ID;;; ip - true ==> IP

class Messages extends StatefulWidget 
{
  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> 
{
  MessagesState()
  {
    // acts like getRooms()
    ConnectionHandler serverGetRoomConnection = ConnectionHandler(SERVER_ADDRESS, SERVER_PORT);
    String roomListSession = serverGetRoomConnection.expectResponse((Connection, json_data) => {
      rooms = json_data,
      Connection.closeSession(),
      Connection.closeConnection(),

      // update content and reload page
      this.build(context),
      setState((){})
    });
    serverGetRoomConnection.sendData("show_rooms:all", roomListSession);
  }

  @override
  Widget build(BuildContext context) {
    //print("build");
    return ListView.builder
    (
      itemCount: rooms.length,
      itemBuilder: (context, index)
      {
        return Card
        (
          // child: Text("rooms[index]"),
          elevation: 10,
          child: Container
          (
            decoration: BoxDecoration(color: Colors.grey[600]),
            child: StatefulBuilder
            (
              builder: (BuildContext context, StateSetter timer)
              {
                return ListTile
                (
                  onTap: () 
                  {
                    print(getRoomData(rooms, index, false));
                    setState(() 
                    {
                      Navigator.pushNamed(context, '/room', arguments: <String, String>
                      {
                        'id': getRoomData(rooms, index, false),
                        'ip': getRoomData(rooms, index, true)
                      });
                    });
                  },
                  isThreeLine: false,
                  title: Text(getRoomData(rooms, index, false)),
                  subtitle: Text(getRoomData(rooms, index, true)),
                );
              },
            ),
          ),
        );
      },
    );
  }
}