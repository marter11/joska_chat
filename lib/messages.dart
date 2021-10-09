import 'package:Joska_Chat/networking/main.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'networking/main.dart';

// test data
//Map rooms = {"kecske": ["192", "8080"], "gika": ["sda"]};
Map rooms = {};

class Messages extends StatefulWidget
{
  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages>
{
  MessagesState()
  {

    if (route_mapper["home_route"] == null)
    {
      // acts like getRooms()
      ConnectionHandler serverGetRoomConnection = ConnectionHandler(SERVER_ADDRESS, SERVER_PORT);
      String roomListSession = serverGetRoomConnection.expectResponse((Connection, json_data) => {

        // TODO: put error handler here if no message found
        rooms = json_data["message"],
        Connection.closeSession(),
        Connection.closeConnection(),

        // update content and reload page
        this.build(context),
        setState((){})
      });
      serverGetRoomConnection.sendData("show_rooms:all", roomListSession);
      route_mapper["home_route"] = serverGetRoomConnection;
    }

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

                  // When a room name is clicked at the room selection list
                  onTap: ()
                  {

                    try {
                      print("TAPPED");
                      print(getRoomData(rooms, index, false));

                      // Has to define this here to be able to call setState() from the function's body
                      void EstablishedCommunicationWithRoomHostCallback(ConnectionHandler Connection, var json_data)
                      {
                        if (json_data["status_code"] == 200)
                        {
                          Connection.closeSession();
                          setState(()
                          {
                            Navigator.pushNamed(context, '/room', arguments: RoomData
                            (
                              getRoomData(rooms, index, false),
                              getRoomData(rooms, index, true)
                            ));
                          });
                        }
                      }

                      InformServerForConnectingToRoom(rooms.keys.toList()[index], EstablishedCommunicationWithRoomHostCallback);
                      print("AFTER");

                    }
                    catch (error) {}
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
