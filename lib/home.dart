//import 'dart:html';
import 'package:flutter/material.dart';
import 'networking/main.dart';
import 'package:Joska_Chat/newRoom.dart';
import 'messages.dart';
// create 'Home' class
class Home extends StatefulWidget
{
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
{
  int _currentIndex = 0;

  final List<Widget> _children = 
  [
    Messages(),
    Center
    (
      child: Text("Search Chats"),
    ),
    NewRoom(),
    
  ];

  void changeIndex(int index)
  {
    setState(() 
    {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context)
  {
    // main 'widget tree' of the homepage
    return Scaffold
    (
      backgroundColor: Colors.grey[800],
      appBar: AppBar
      (
        // app bar, so we know what app are we using (and so it doesn't look like dogshit)
        title: Text("Joska Chat"),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar
      (
        unselectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: changeIndex,
        fixedColor: Colors.white,
        backgroundColor: Colors.grey[900],
        items: 
        [
          BottomNavigationBarItem
          (
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem
          (
            icon: Icon(Icons.search),
            label: "Search"
          ),
          BottomNavigationBarItem
          (
            icon: Icon(Icons.add),
            label: "Add",
          ),
        ],
      ),
    );
  }
}