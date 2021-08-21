import 'package:flutter/material.dart';
import 'main.dart';

List<String> rooms = [];

int getRooms()
{
  rooms = [];
  rooms.add("192.168.0.106:TestRoom1");
  rooms.add("127.0.0.1:TestRoom2");
  rooms.add("0.0.0.0:TestRoom3");
  return 0;
}

//returns either the IP or the name(ID) of a room
//ip - false ==> ID;;; ip - true ==> IP

class Messages extends StatefulWidget 
{
  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> 
{
  int xd = getRooms();
  @override
  Widget build(BuildContext context) {
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