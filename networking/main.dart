import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:async';

// Description of variables and functions
//
// queue sessions are based on DateTime.now().millisecondsSinceEpoch which is timestamp in miliseconds

const String SERVER_ADDRESS = "127.0.0.1";
const int SERVER_PORT = 4567;
const int OWN_PORT = 4890;

void timeri()
{

}

// Runs on different thread from the rest of the code
// void keepConnection(ConnectionHandler Connection)
// {
//   var k = 0;
//   while (k < 2) {
//     var timer = Timer(Duration(seconds: 2), () => {
//       print("Keep connection packet sent"), print(k),
//       Connection.sendData("keep", "0")
//     });
//     k++;
//   }
//
// }


// EXAMPLE START

// Callback should define a variable for the incoming data and for the session itself...

// Every callback must define arguments: [ ConnectionHandler <Connection>, String <status_code>, String <message> ]
void displayChatRoomUI(ConnectionHandler Connection, String status_code, String message)
{
  if (status_code == "201")
  {
    // Show user the chat room UI
    print("UI displayed");
  }
  else
  {
    // Show user the error message
    print("Error displayed");
  }

  Connection.closeSession();

}

// EXAMPLE END

const int SessionTimeout = 10;
List Connections = [];

void QueueHandler(String session, String status_code, String message, dynamic udp_packet)
{
  int queue_counter;
  var Connection;

  // TODO: if connection with the corresponding ip and port doesn't exist throw error same for session
  for (queue_counter=0; queue_counter<Connections.length; queue_counter++)
  {
    Connection = Connections[queue_counter];
    if (udp_packet.address == InternetAddress(Connection.ip_address) && udp_packet.port == Connection.port)
    {
      // PRIORITY TODO: i don't know if race condition happens here or not when multiple UDP packets arrive with valid sessions
      Connection.last_session = session;

      // This is the callback
      Connection.Sessions[session][0](Connection, status_code, message);

    }
  }
}

class ConnectionHandler {
  String ip_address;
  int port;
  String last_session;

  // structure of <Sessions>: { String <session identifier>: [Function <callback function>, String <retransmission data> }
  Map Sessions = {};

  ConnectionHandler(String ip_address, int port) {
    this.ip_address = ip_address;
    this.port = port;
    Connections.add(this);
  }

  int sendData(String data, String session)
  {
    if (session != "0")
    {
      data += "," + ( session.toString() );

      // Store this data for retransmission
      this.Sessions[session].add(data);
    }

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
    this.Sessions[session] = [callback];
    return session;
  }

  void closeConnection()
  {
    Connections.remove(this);
  }

  void closeSession()
  {
    this.Sessions.remove(this.last_session);
  }

}

void EventLoopHandler() async
{
  int connection_counter;
  var Connection;

  while (true)
  {
    print("FROM EVENT LOOP");
    print(Connections);
    for (connection_counter=0; connection_counter<Connections.length; connection_counter++)
    {

      Connection = Connections[connection_counter];

      // Keep alive all connections until ConnectionHandler.closeConnection() is not called upon and object
      // Send keep alive messages only when other message is not scheduled
      if (Connection.Sessions.length == 0)
      {
        Connection.sendData("keep");
      }

      Connection.Sessions.values.forEach( (value) => {
        Connection.sendData(value[1], "0") // send retrasmission_data
      });

    }
    await sleep(Duration(seconds:3));
  }
}

void g() async
{

}

void main()
{
  RawDatagramSocket.bind(InternetAddress.anyIPv4, OWN_PORT).then((socket) {
    socket.listen((RawSocketEvent event)
    {
       if (event == RawSocketEvent.read)
       {
         print("GET");
         Datagram udp_packet = socket.receive();
         if (udp_packet == null) return;

         // structure: [return code, response message, session if any]
         final recvd_data = String.fromCharCodes(udp_packet.data);
         var splitted_data = recvd_data.split(",");

         // If this is > 2 then session is sent along with the message
         if (splitted_data.length > 2)
         {
           // splitted_data[2] = session
           // splitted_data[0] and splitted_data[1] = [String response code, String response message]
           QueueHandler(splitted_data[2], splitted_data[0], splitted_data[1], udp_packet);
         }

         // if (recvd_data == "ping") socket.send(Utf8Codec().encode("ping ack"), udp_packet.address, SERVER_PORT);
       }
     });
   });

  EventLoopHandler();

  ConnectionHandler d = ConnectionHandler('127.0.0.1', 4567);
  String s = d.expectResponse(displayChatRoomUI);
  // keepConnection(d);
  for (int i=0;i<3;i++) {
    d.sendData("register:main", s);
  }


  // while (true)
  // {
  //   sleep(Duration(seconds:1));
  // }
  // sendData("register:alma", SERVER_ADDRESS, SERVER_PORT);

}
