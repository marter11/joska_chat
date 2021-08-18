import 'dart:io';

String okxd = "xd";

String receiveMessage(int count)
{
  String input = stdin.readLineSync();
  if(input != null)
    okxd = input;
  print(okxd);
  return okxd;
}

void createRoom(String name, String number)
{
  print('Searching for room named "$name" with number "$number"');
}