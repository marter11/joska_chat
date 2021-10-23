import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:async';

// Comment out " import '../messages.dart' " at main.dart when running this test file
import '../lib/networking/main.dart';


void EstablishedCommunicationWithRoomHostCallback(ConnectionHandler Connection, var json_data)
{
  print("run");
  if (json_data["status_code"] == 200)
  {
    Connection.closeSession();
    // Connection.sendData(json_data["respondable_session"], "0")
  }
}

void InformServerConnectingRoomTest()
{
  int index = 0;
  Map rooms = {"test": 5};
  InformServerForConnectingToRoom(rooms.keys.toList()[index], EstablishedCommunicationWithRoomHostCallback);
  // return 0;
}

void main() async
{

  InformServerConnectingRoomTest();

}
