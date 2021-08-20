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
void keepConnection(ConnectionHandler Connection)
{
  var k = 0;
  while (k < 2) {
    var timer = Timer(Duration(seconds: 2), () => {
      print("Keep connection packet sent"), print(k),
      Connection.sendData("keep", "0")
    });
    k++;
  }

}


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

// const int SessionTimeout = 10;
List Connections = [];

void QueueHandler(String session, String status_code, String message, dynamic udp_packet)
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

          // PRIORITY TODO: i don't know if race condition happens here or not when multiple UDP packets arrive with valid sessions
          Connection.session_position = session_counter;

          // This is the callback
          Sessions[session_counter][1](Connection, status_code, message);

        }
      }
    }
  }
}

class ConnectionHandler {
  String ip_address;
  int port;

  // Used to close sessions based on List index
  int session_position = -1;

  // structure of <Sessions>: [ String <session identifier>, Function <callback function> ]
  List<List> Sessions = [];
  // Map Sessions = {};

  ConnectionHandler(String ip_address, int port) {
    this.ip_address = ip_address;
    this.port = port;
    Connections.add(this);
  }

  int sendData(String data, String session)
  {
    if (session != "0") data += "," + ( session.toString() );

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
    // this.Sessions[session] = [callback];
    return session;
  }

  void closeConnection()
  {
    Connections.remove(this);
  }

  void closeSession()
  {
    if (this.session_position >= 0 && this.session_position < this.Sessions.length)
    {
      this.Sessions.removeAt(this.session_position);
      this.session_position = -1;
    }
  }

}

void EventLoopHandler() async
{
  while (true)
  {

    await sleep(Duration(seconds:3));
  }
}

void main()
{
  RawDatagramSocket.bind(InternetAddress.anyIPv4, OWN_PORT).then((socket) {
    socket.listen((RawSocketEvent event)
    {
       if (event == RawSocketEvent.read)
       {
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


   // EventLoopHandler();

  ConnectionHandler d = ConnectionHandler('127.0.0.1', 4567);
  String s = d.expectResponse(displayChatRoomUI);
  keepConnection(d);
  for (int i=0;i<3;i++) {
    d.sendData("register:main", s);
  }


  // while (true)
  // {
  //   sleep(Duration(seconds:1));
  // }
  // sendData("register:alma", SERVER_ADDRESS, SERVER_PORT);

}
