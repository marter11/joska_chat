# This is the controll server which won't be included in the mobile application bundle

import socket
import time
import threading

CACHE = {}
LISTEN_PORT = 4567
DEBUG = True

class ClientObject(object):

    """
    stored in form (ip, port)
    Client: - Means the current user
    Peers: - only could be none at initial state.
    Chat rooms: we store chatroom info at server
        Room Info: - if clinet hosts a chat room (name, owner identified by ip)
    """

    def __init__(self, client, peers=[]):
        self.client = client
        self.peers = peers

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(('0.0.0.0', LISTEN_PORT)) # 0.0.0.0 means assigned ip address

print("Server started!")
while 1:
    data, (ip, port) = sock.recvfrom(1024)
    print(ip, port)
    # incoming data should look like this "<action parameter>:<action value>"
    try:
        action, value = data.decode().split(":")
        return_message = ""

        # register new room, <value> is the room's name
        if action == "register":
            if not CACHE.get(value, None):
                clientObject = ClientObject( (ip, port) )
                CACHE[value] = clientObject
                return_message = "201, Room %s registered." % value
            else:
                return_message = "409, Room with name %s already exist." % value

        elif action == "join":
            room = CAHCE.get(value, None)
            if room:

                # TODO: this needs more error handling; might use setter and getter to handle when new peer appended
                sock.sendto( ("%d:%d" % (ip, port)).encode(), (room[0], room[1]) )
                room.peers.append((ip,port)) # this uncover the ip addresses of the room's participant no good...
                return_message = "302, %d:%d" % (room[0], room[1])
            else:
                return_message = "404, %s is not found." % value

        sock.sendto(return_message.encode(), (ip,port) )

    except: pass

    print(data, ip, port)
    print(CACHE)

if __name__ == "__main__":
    pass
