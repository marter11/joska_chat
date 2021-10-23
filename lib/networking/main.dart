import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:async';
// import '../messages.dart';

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


dynamic advertiseIncomingPeerToRoomParticipants()
{
  int participantIndex;
  ConnectionHandler connection;
  Map advertisementMessage = {"ac tion": "participant_advertisement", "participant_list": []};

  // construct advertisement message
  for(participantIndex=0; participantIndex<RoomParticipants.length; participantIndex++)
  {
    connection = RoomParticipants[participantIndex];
    advertisementMessage["participant_list"].add([InternetAddress(connection.ip_address), connection.port]);

    // String handShakeClientEstablishSession = handshakeClientEstablishConnection.expectResponse((ConnectionHandler Connection, var json_data) {
    //   if(json_data["status_code"] == 200)
    //   {
    //     Connection.closeSession();
    //   }
    // });
    //
    // // If response is not coming until timeout then the participant is removed from the room
    // handshakeClientEstablishConnection.setSessionTimeout((ConnectionHandler Connection, String session) {
    //   RoomParticipants.remove(Connection);
    //   Connection.closeSession();
    //   Connection.closeConnection();
    // }, 15, handShakeClientEstablishSession);
    //
    // handshakeClientEstablishConnection.sendData("keep", handShakeClientEstablishSession);


  }

  for(participantIndex=0; participantIndex<RoomParticipants.length; participantIndex++)
  {

    // TODO: send out if no incoming response send new one
    connection = RoomParticipants[participantIndex];
    // connection.sendData(jsonEncode(advertisementMessage), );
  }

}

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
          Connection.Sessions[session]["response_callback"](Connection, data_json);
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

              // String handShakeClientEstablishSession = handshakeClientEstablishConnection.expectResponse((ConnectionHandler Connection, var json_data) {
              //   if(json_data["status_code"] == 200)
              //   {
              //     Connection.closeSession();
              //   }
              // });
              //
              // // If response is not coming until timeout then the participant is removed from the room
              // handshakeClientEstablishConnection.setSessionTimeout((ConnectionHandler Connection, String session) {
              //   RoomParticipants.remove(Connection);
              //   Connection.closeSession();
              //   Connection.closeConnection();
              // }, 15, handShakeClientEstablishSession);
              //
              // handshakeClientEstablishConnection.sendData("keep", handShakeClientEstablishSession);

            }

            // Confirm establish connection
            // handshakeClientEstablishConnection.sendData(jsonEncode({"status_code": 200, "action": "establish", "responsable_session": handshakeClientEstablishConnection.last_session, "session": data_json["session"]}), "0");
            handshakeClientEstablishConnection.sendData(jsonEncode({"status_code": 200, "action": "establish", "session": data_json["session"]}), "0");

          }

        //  else if(data_json["action"] == "respond")
        //  {
        //    ConnectionHandler respondToAction = ConnectionHandler(udp_packet.address, udp_packet.port);
        //    respondToAction.sendData('{"status_code": 200}', "0");
        //    respondToAction.closeConnection();
        //  }

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
  int EventLoopCyclesSession = 0;

  // structure of <Sessions>: { String <session identifier>: [ {Function <on response callback>, Map timeout {<on timeout callback>, int timeout in secs}, String <retransmission data> } ]
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
      this.Sessions[session]["data"] = data;
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
      this.Sessions[session]["data"] = data;
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

  // only callable if expectResponse is called beforehand, only timeouts session
  // timeout parameter: number of EventLoopCycles * PACKET_SEND_DELAY
  int setSessionTimeout(dynamic timeout_callback, int timeout, String session)
  {
    this.Sessions[session]["timeout"] = {"timeout_callback": timeout_callback, "timeout_in_sec": timeout};
    return 0;
  }

  // creates session identifier and set up exception for response
  String expectResponse(dynamic response_callback)
  {
    String session = (DateTime.now().millisecondsSinceEpoch).toString();
    this.Sessions[session] = {};
    this.Sessions[session]["response_callback"] = response_callback;
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
        Connection.Sessions.keys.forEach( (key) {

          // trigger timeout callback if required
          if(Connection.Sessions[key]["timeout"] != null)
          {
            if(Connection.Sessions[key]["timeout"]["timeout_in_sec"] <= PACKET_SEND_DELAY*Connection.EventLoopCyclesSession)
            {

              // key here is the String session
              Connection.Sessions[key]["timeout"]["timeout_callback"](Connection, key);
            }
          }

          // resend data until Connection.closeSession() is not called
          else {

            // HERE YOU MODIFIED &&& REMOVE THIS COMMENT
            Connection.sendData(Connection.Sessions[key]["data"], "0");
          }
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

// RoomIdentifier currently refers to the room's name
void InformServerForConnectingToRoom(String RoomIdentifier, dynamic EstablishedCommunicationWithRoomHostCallback)
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

      // NOTE: we could/should use the the ip and port which are already saved to memory, but instead we use the newly received parameters
      // reason: we will optimize to send as few data as possible when we get the ROOM LIST from server
      ConnectionHandler roomHostConnection = ConnectionHandler(json_data["ip_address"], json_data["port"]);
      String roomHostSession = roomHostConnection.expectResponse(EstablishedCommunicationWithRoomHostCallback);

      Map request = {"action": "establish"};
      String data = jsonEncode(request);

      roomHostConnection.setSessionTimeout((ConnectionHandler Connection, String session) {
        print("TIMED OUT connecting to room");
        Connection.closeSession();
        Connection.closeConnection();
      }, 15, roomHostSession);

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
