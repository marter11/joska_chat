import 'package:flutter/material.dart';
import 'dart:core';
import 'room.dart';
import 'newRoom.dart';
import 'network.dart';
import 'home.dart';


String getRoomData(List<String> rooms, int index, bool ip)
{
  //returns either the IP or the name(ID) of a room
  //ip - false ==> ID;;; ip - true ==> IP

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

class RoomData
{
  String id;
  String ip;

  RoomData(this. id, this.ip);
}

void main() 
{
  // main function much simpler
  runApp(MaterialApp
  (
    //disable 'DEBUG' banner for later use
    // debugShowCheckedModeBanner: false,
    routes: 
    {
      '/': (context) => Home(), // default route
      '/room': (context) => Room(),
    },
  ));
}