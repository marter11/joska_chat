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

void ExampleCallback()
{
  print("CALLBACK IS RUNNING!!!!");
}

const int SessionTimeout = 10;
List Connections = [];

void QueueHandler(String session, dynamic udp_packet)
{
  int queue_counter, session_counter;
  var Sessions, Connection;

  // TODO: if connection with the corresponding ip and port doesn't exist throw error same for session
  for (queue_counter=0; queue_counter<Connections.length; queue_counter++)
  {
    Connection = Connections[queue_counter];
    if (udp_packet.address == InternetAddress(Connection.ip_address) && udp_packet.port == Connection.port)
    {
      Sessions = Connection.Sessions;
      for (session_counter=0; session_counter<Sessions.length; session_counter++)
      {
        if (session == Sessions[session_counter][0])
        {

          // This is the callback
          Sessions[session_counter][1]();

        }
      }
    }
  }
}

class ConnectionHandler {
  String ip_address;
  int port;

  // structure of <Sessions>: [ String <session identifier>, dynamic <callback function> ]
  List<List> Sessions = [];

  ConnectionHandler(String ip_address, int port) {
    this.ip_address = ip_address;
    this.port = port;
    Connections.add(this);
  }

  int sendData(String data, String session)
  {
    if (session != 0) data += "," + ( session.toString() );

    RawDatagramSocket.bind(InternetAddress.anyIPv4, OWN_PORT).then((socket) {
      socket.send(Utf8Codec().encode(data), InternetAddress(this.ip_address), this.port);
      socket.listen((event) {
        if (event == RawSocketEvent.write) {
          socket.close();
        }
      });
    });

    return 0;
  }

  // creates session identifier and set up expection for response
  String expectResponse(dynamic callback)
  {
    String session = (DateTime.now().millisecondsSinceEpoch).toString();
    this.Sessions.add( [session, callback] );
    return session;
  }

  void closeConnection()
  {
    Connections.remove(this);
  }

}

void main()
{
  RawDatagramSocket.bind(InternetAddress.anyIPv4, OWN_PORT).then((socket) {
    socket.listen((RawSocketEvent event) {
       if (event == RawSocketEvent.read) {
         Datagram udp_packet = socket.receive();
         if (udp_packet == null) return;

         // structure: [return code, response message, session if any]
         final recvd_data = String.fromCharCodes(udp_packet.data);
         var splitted_data = recvd_data.split(",");

         // If this is > 2 then session is sent along with the message
         if (splitted_data.length > 2)
         {
           print(splitted_data[2]);
           QueueHandler(splitted_data[2], udp_packet);
         }


         // if (recvd_data == "ping") socket.send(Utf8Codec().encode("ping ack"), udp_packet.address, SERVER_PORT);
         // print("$recvd_data from ${udp_packet.address.address}:${udp_packet.port}");
       }
     });
   });

  ConnectionHandler d = ConnectionHandler('127.0.0.1', 4567);
  String s = d.expectResponse(keepConnection);
  for (int i=0;i<3;i++) {
    d.sendData("register:main", s);
  }

  // while (true)
  // {
  //   sleep(Duration(seconds:1));
  // }
  // sendData("register:alma", SERVER_ADDRESS, SERVER_PORT);

}
