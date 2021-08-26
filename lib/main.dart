import 'package:flutter/material.dart';
import 'dart:core';
import 'room.dart';
import 'newRoom.dart';
import 'networking/main.dart';
import 'home.dart';

String getRoomData(Map rooms, int index, bool ip)
{
  rooms = rooms["message"];
  if(ip)
  {
    return rooms.values.toList()[index][0];
  }
  else
  {
    return rooms.keys.toList()[index];
  }
}

void main()
{

  // Setup initial networking requirements
  listenDatagram();
  EventLoopHandler();

  // main function much simpler
  runApp(MaterialApp
  (
    routes:
    {
      '/': (context) => Home(), // default route
      '/room': (context) => Room(id: '', ip:''),
    },
  ));
}
