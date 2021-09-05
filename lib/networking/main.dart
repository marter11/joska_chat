import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:async';

// Description of variables and functions
//
// queue sessions are based on DateTime.now().millisecondsSinceEpoch which is timestamp in miliseconds

const String SERVER_ADDRESS = "10.0.2.2";
const int SERVER_PORT = 4567;
const int OWN_PORT = 4890;
const int PACKET_SEND_DELAY = 2;

// EXAMPLE START

// Callback should define a variable for the incoming data and for the session itself...

// Every callback must define arguments: [ ConnectionHandler <Connection>, var <data_json this is in form of JSON> ]
void displayChatRoomUI(ConnectionHandler Connection, var data_json)
{
  if (data_json["status_code"] == "201")
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
List RoomParticipants = []; // might use it instead of a bool value to determine if user is currently part of a room


// dynamic ip_address is comparable with string using ip_address == InternetAddress(variable)
dynamic getParticipantConnectionFromRoom(dynamic ip_address, int port)
{
  int participantCount = RoomParticipants.length, participantIndex;
  ConnectionHandler connection;

  for(participantIndex=0; participantIndex<participantCount; participantIndex++)
  {
    connection = RoomParticipants[participantIndex];
    if(InternetAddress(connection.ip_address) == ip_address && connection.port == port) return connection;
  }

  return null;
}

void RouteIncomingData(var data_json, dynamic udp_packet)
{
  int queue_counter;
  var Connection;
  var session = data_json["session"];

  // TODO: if connection with the corresponding ip and port doesn't exist throw error same for session
  for (queue_counter=0; queue_counter<Connections.length; queue_counter++)
  {
    Connection = Connections[queue_counter];
    if (udp_packet.address == InternetAddress(Connection.ip_address) && udp_packet.port == Connection.port)
    {

      print(session);
      if (session != null)
      {

        // Session is not started from this device
        if (Connection.Sessions[session] != null)
        {
          // PRIORITY TODO: i don't know if race condition happens here or not when multiple UDP packets arrive with valid sessions
          Connection.last_session = session;
          data_json.remove("session");

          print("From Incoming Data Router session part");

          // This is the callback
          Connection.Sessions[session][0](Connection, data_json);
        }

        // Session is started from other device, and expecting response
        else {
          if(data_json["action"] == "establish")
          {
            ConnectionHandler handshakeClientEstablishConnection;
            var participant = getParticipantConnectionFromRoom(udp_packet.address, udp_packet.port);

            if(participant != null)
            {
              handshakeClientEstablishConnection = participant;
            }
            else {
              handshakeClientEstablishConnection = ConnectionHandler(udp_packet.address, udp_packet.port);
              RoomParticipants.add(handshakeClientEstablishConnection);

              // If response is not coming until timeout then the participant is removed from the room
              String handShakeClientEstablishSession = handshakeClientEstablishConnection.expectResponse((ConnectionHandler Connection, var json_data) {
                
              });

              handshakeClientEstablishConnection.sendData("keep", handShakeClientEstablishSession);

            }

            // Confirm establish connection
            handshakeClientEstablishConnection.sendData(jsonEncode({"status_code": 200, "action": "establish", "session": data_json["session"]}), "0");
          }

        }
      }

      // Starting point for every incoming data which is not tied to session
      else {
        bool connectedToARoom = true; // PRIORITY TODO: change this to anything which could check if user already/currently connected to any room aka expecting a room message to display it in the chat
        if (data_json["room_message"] != null && connectedToARoom)
        {
          print("Displayed room_message: ${data_json["room_message"]}");
        }

        if(data_json["action"] != null)
        {
          // Get ready for receiving establishing handshake from incoming client
          if(data_json["action"] == "incoming_join")
          {
            ConnectionHandler informClientConnection = ConnectionHandler(data_json["ip_address"], data_json["port"]);
            informClientConnection.sendData('{"action": "expect_response"}', "0");
            informClientConnection.closeConnection();
          }

        }
      }
    }
  }
}

class ConnectionHandler {
  String ip_address = "";
  int port = 0;
  String last_session = "";

  // this counts how many times EventLoop has run since the session is open
  // used for timeout handling
  int EvenLoopCyclesSession = 0;

  // structure of <Sessions>: { String <session identifier>: [Function <callback function>, String <retransmission data> }
  Map Sessions = {};

  ConnectionHandler(String ip_address, int port) {

    if (port > 65535) throw "Invalid port number";
    this.ip_address = ip_address;
    this.port = port;
    Connections.add(this);
  }

  int __modifySessionData(var data, String session)
  {
    try {
      this.Sessions[session][0] = data;
      return 0;
    }
    catch(e) { return 1; }
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

    print("From sendData ${data}");

    return 0;
  }

  // creates session identifier and set up exception for response
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
    print(Connections);
    for (connection_counter=0; connection_counter<Connections.length; connection_counter++)
    {

      Connection = Connections[connection_counter];

      // Keep alive all connections in the List Connections until ConnectionHandler.closeConnection() is not called upon them
      // Send keep alive messages only when other message is not scheduled
      if (Connection.Sessions.length == 0)
      {
        Connection.sendData("keep", "0");
      }
      else
      {
        // print(Connection.Sessions);
        Connection.Sessions.values.forEach( (value) => {
          Connection.sendData(value[1], "0") // resend data until Connection.closeSession() is not called
        });
      }

      // count for timeout
      Connection.EventLoopCyclesSession++;
    }
    await Future.delayed(Duration(seconds:PACKET_SEND_DELAY));
  }
}

void InformServerCallback(ConnectionHandler Connection, var json_data)
{

}

void EstablishedCommunicationWithRoomHostCallback(ConnectionHandler Connection, var json_data)
{
  if (json_data["status_code"] == 200)
  {
    Connection.closeSession();

  }
}

// RoomIdentifier currently refers to the room's name
void InformServerForConnectingToRoom(String RoomIdentifier)
{
    ConnectionHandler serverConnection = ConnectionHandler(SERVER_ADDRESS, SERVER_PORT);
    String sessionForRoomCreation = serverConnection.expectResponse((ConnectionHandler Connection, var json_data) {

      Connection.closeSession();
      Connection.closeConnection();

      if (json_data["status_code"] == 404)
      {
        // TODO: display (room not found)/(invalid room) error message to user
        return;
      }

      // NOTE: we could use the the ip and port which are already saved to memory, but instead use the newly received parameters
      // reason: we will optimize to send as few data as possible when we get the ROOM LIST from server
      ConnectionHandler roomHostConnection = ConnectionHandler(json_data["ip_address"], json_data["port"]);
      String roomHostSession = roomHostConnection.expectResponse(EstablishedCommunicationWithRoomHostCallback);

      Map request = {"action": "establish"};
      String data = jsonEncode(request);

      roomHostConnection.sendData(data, roomHostSession);

    });

    String dataToSend = "join:"+RoomIdentifier;
    serverConnection.sendData(dataToSend, sessionForRoomCreation);
}

void listenDatagram()
{
  // NOTE: if this cause any problem put this into a void function() async and await like form
  RawDatagramSocket.bind(InternetAddress.anyIPv4, OWN_PORT).then((socket) {
    socket.listen((RawSocketEvent event)
    {
       if (event == RawSocketEvent.read)
       {
         Datagram? udp_packet = socket.receive();
         if (udp_packet == null) return;

         // structure: [return code, response message, session if any]
         final recvd_data = String.fromCharCodes(udp_packet.data);
         var data_json = jsonDecode(recvd_data); // this should be Map like

         print("From listenDatagram ${data_json}");

         // handle error if invalid data is received like not appropiate type
         try {RouteIncomingData(data_json, udp_packet);}

         // TODO: maybe display error to user if this happens
         // you can reproduce this error is you uncomment the return_messsage = "alma" at main.py
         catch (error)
         {
           print(error);
         }

         // RouteIncomingData(data_json, udp_packet);
         // if (recvd_data == "ping") socket.send(Utf8Codec().encode("ping ack"), udp_packet.address, SERVER_PORT);
       }
     });
   });
}

// void main()
// {
//
//   ListenDatagram();
//   EventLoopHandler();
//
//   ConnectionHandler d = ConnectionHandler('127.0.0.1', 4567);
//   String s = d.expectResponse(displayChatRoomUI);
//   d.sendData("register:main", s);
//
//   d.sendData("show_rooms,all", "0");
//   d.sendData("show_rooms:all", "0");
//
//
// }
