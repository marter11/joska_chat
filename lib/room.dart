import 'package:flutter/material.dart';

class Room extends StatefulWidget 
{
  final String id;
  final String ip;

  const Room({Key? key, required this.id, required this.ip}) : super(key: key);

  @override
  RoomState createState() => RoomState();
}

class RoomState extends State<Room> 
{
  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(widget.id),
      ),
    );
  }
}