import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:async';
import 'a/k.dart';

void trigger()
{
  int variab = 0;
  // event loop
  var timer = Timer(Duration(seconds: 2), () => {
    // variab++,
    print(variab),
    trigger()
  });
  // while (true)
  // {
  //   print("RUN");
  //   await sleep(Duration(seconds:2));
  // }

}

void f() async
{
  int k=0;
  while (k<100)
  {
    print("HEY");
    await Future.delayed(Duration(seconds:2));
  }
}

void main()
{


  // f();
  print(1);
  // Future.delayed(Duration(seconds:2));
  print(2);

  Map a = {"a":1,"b":2,"c":3};
  print(a["h"] == null);

  var k = jsonDecode('{"a":1,"akf":66}');
  print(k["a"]);
  // a.values.forEach((e) => print(a));

  // trigger();
  // print("WE");
  // while (true)
  // {
  //   print("IN");
  //   sleep(Duration(seconds:1));
  // }

}
