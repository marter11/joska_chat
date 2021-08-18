import 'package:flutter/material.dart';
import 'newRoom.dart';
import 'network.dart';
import 'home.dart';

void main() 
{
  // main function much simpler
  runApp(MaterialApp
  (
    routes: 
    {
      '/': (context) => Home(), // default route
      '/new_room': (context) => NewRoom(), // route called on pressing button to create new room
    },
  ));
}