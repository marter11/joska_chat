import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';

// Description of variables and functions
//
// queue sessions are based on DateTime.now().millisecondsSinceEpoch which is timestamp in miliseconds

const String SERVER_ADDRESS = "127.0.0.1";
const int SERVER_PORT = 4567;
const int OWN_PORT = 4890;

// Runs on different thread from the rest of the code
void keepConnection()
{
   //await Isolate.spawn(echo, None);
}

const int QueueTimeout = 10;
List<List> QueueList = [];

void QueueHandler(String data)
{
  for (queue_counter=0; queue_counter<QueueList.length; queue_counter++) {
    if ( udp_packet.address == QueueList[queue_counter][0] && udp_packet.port == QueueList[queue_counter][1]) {
      print("yeah");
    }
  }
}

class ConnectionHandler {
  String ip_address;
  int port;
  int session = 0;

  ConnectionHandler(String ip_address, int port) {
    this.ip_address = ip_address;
    this.port = port;
  }

  int sendData(String data)
  {
    if (this.session != 0) data += "," + ( this.session.toString() );

    print(data);

    RawDatagramSocket.bind(InternetAddress.anyIPv4, OWN_PORT).then((socket) {
      socket.send(Utf8Codec().encode(data), InternetAddress(this.ip_address), this.port);
      socket.listen((event) {
        if (event == RawSocketEvent.write) {
          print("debug write");
          socket.close();
        }
      });
    });

    return 0;
  }

  // creates session identifier and set up expection for response
  void expectResponse(dynamic callback)
  {
    this.session = DateTime.now().millisecondsSinceEpoch;
    QueueList.add( [InternetAddress(this.ip_address), this.port, this.session, callback] );
  }

}

void main()
{
  int queue_counter;

  RawDatagramSocket.bind(InternetAddress.anyIPv4, OWN_PORT).then((socket) {
    socket.listen((RawSocketEvent event) {
       if (event == RawSocketEvent.read) {
         Datagram udp_packet = socket.receive();
         if (udp_packet == null) return;
         final recvd_data = String.fromCharCodes(udp_packet.data);
         print("HELLO");

         for (queue_counter=0; queue_counter<QueueList.length; queue_counter++) {
           if ( udp_packet.address == QueueList[queue_counter][0] && udp_packet.port == QueueList[queue_counter][1]) {
             print("yeah");
           }
         }


         // if (recvd_data == "ping") socket.send(Utf8Codec().encode("ping ack"), udp_packet.address, SERVER_PORT);
         print("$recvd_data from ${udp_packet.address.address}:${udp_packet.port}");
       }
     });
   });

  ConnectionHandler d = ConnectionHandler('127.0.0.1', 4567);
  d.expectResponse(keepConnection);

  for (int i=0;i<3;i++) {
    d.sendData("register:main");
  }

  // while (true)
  // {
  //   sleep(Duration(seconds:1));
  // }
  // sendData("register:alma", SERVER_ADDRESS, SERVER_PORT);

}
