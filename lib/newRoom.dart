import 'package:flutter/material.dart';
import 'network.dart';

class RoomPicker extends StatefulWidget
{
  @override
  _RoomPicker createState() => _RoomPicker();
}

class _RoomPicker extends State<RoomPicker>
{
  final nameController = TextEditingController();
  final numberController = TextEditingController();

  bool ok1 = false;
  bool ok2 = false;

  String name = "";
  String number = '';
  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text("Create Room"),
      ),
      body: Column
      (
        children: <Widget>
        [
          Container
          (
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: TextField
            (
              controller: nameController,
              onChanged: (String value)
              {
                if(value != "")
                {
                  ok1 = true;
                  name = value;
                }
                else ok1 = false;
              }
            )
          ),
          Container
          (
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: TextField
            (
              keyboardType: TextInputType.number,
              controller: numberController,

              onChanged: (String value)
              {
                if(value != null)
                {
                  ok2 = true;
                  number = value;
                }
                else ok2 = false;
              }
            )
          ),
          Container
          (
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: RaisedButton
            (
              elevation: 10,
              onPressed: ()
              {
                if(ok1 && ok2)
                  createRoom(name, number);
              }
            )
          ),
        ],
      ),
    );
  }
}