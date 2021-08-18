import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';

String SERVER_ADDRESS = "127.0.0.1";
int SERVER_PORT = 4567;

int sendData(String data)
{
  // Port 0 is a random number
  RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
   socket.send(Utf8Codec().encode(data), InternetAddress(SERVER_ADDRESS), SERVER_PORT);
   socket.listen((event) {
     if (event == RawSocketEvent.write) {
       print("debug write");
     }

     else if (event == RawSocketEvent.read) {
       print("debug read");
     }

     socket.close();
   });
  });
}

// Runs on different thread from the rest of the code
void keepConnection() async
{
   //await Isolate.spawn(echo, None);
}

void main()
{
   sendData("hey");
}
