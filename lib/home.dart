import 'package:flutter/material.dart';
// create 'Home' class
class Home extends StatefulWidget
{
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
{
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
      body: Center
      (
        // this is just temporary, so that it doesn't look like total dogshit
        child: Text("No chats yet"),
      ),
      floatingActionButton: FloatingActionButton
      (
        // button for creating new room, I don't really think, this will be final
        onPressed: () 
        {
          setState(() 
          {
            Navigator.pushNamed(context, '/new_room');
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}