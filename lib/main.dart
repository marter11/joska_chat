import 'package:flutter/material.dart';
import 'newRoom.dart';
import 'network.dart';

void main() 
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joska Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  int count = 0;
  String input = "";

  void _incrementCounter() 
  {
    count ++;
    setState(() {
      input = receiveMessage(count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$input',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()
        {
          setState(()
          {
            // Navigator.pushNamed(context, '/new_room');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoomPicker()),
            );
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), 
    );
  }
}
