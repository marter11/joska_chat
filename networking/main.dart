import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';

String SERVER_ADDRESS = "127.0.0.1";
int SERVER_PORT = 4567;

int sendData(String data, dynamic ip_addr, int port)
{
  // Port 0 is a random number
  RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
   socket.send(Utf8Codec().encode(data), InternetAddress(ip_addr), port);
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
   //sendData("hey");
   RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((socket) {
     socket.listen((RawSocketEvent event) {
       if (event == RawSocketEvent.read) {
         Datagram dg = socket.receive();
         if (dg == null) return;
         final recvd = String.fromCharCodes(dg.data);

         /// send ack to anyone who sends ping
         if (recvd == "ping") socket.send(Utf8Codec().encode("ping ack"), dg.address, SERVER_PORT);
         print("$recvd from ${dg.address.address}:${dg.port}");
       }
     });
   });
}
