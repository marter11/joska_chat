import 'package:flutter/material.dart';
import 'dart:core';
import 'room.dart';
import 'newRoom.dart';
import 'network.dart';
import 'home.dart';

String getRoomData(List<String> rooms, int index, bool ip)
{
  if (rooms.length <= index) return ' ';

  String temp = rooms[index];
  int colonI = temp.indexOf(':');

  if(colonI < 0) return ' ';

  if(ip)
  {
    return temp.substring(0, colonI);
  }
  else
  {
    return temp.substring(colonI + 1);
  }
}

void main() 
{
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