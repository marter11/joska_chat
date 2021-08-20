# This is the controll server which won't be included in the mobile application bundle

import socket
import time
import threading

CACHE = {}

LISTEN_PORT = 4567
LISTEN_IP = '127.0.0.1'

DEBUG = True

# TODO: what if someone faking or duplicate session is found (keep only the first one since the session could duplicate because it tied to current time)
# CLIENT_QUEUE only used when we need a response for reliability for example: when creating a room
CLIENT_QUEUE = {}

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
sock.bind((LISTEN_IP, LISTEN_PORT)) # 0.0.0.0 means assigned ip address

print("Server started! IP: %s PORT: %d" % (LISTEN_IP, LISTEN_PORT))
while 1:

    # incoming data should look like this "<action parameter>:<action value>"
    data, (ip, port) = sock.recvfrom(1024)
    data = data.decode()
    session = 0 # null means invalid session

    print(data,ip,port)

    try:
        data, session = data.split(',')
        if data == '200':
            del CLIENT_QUEUE[session]

        if not CLIENT_QUEUE.get(session, None): CLIENT_QUEUE[session] = [ip, port]

    except: pass

    # try:
    data = data.split(":")
    action, value = data
    return_message = ""

    # register new room, <value> is the room's name
    if action == "register":

        # This assumes that the CLIENT_QUEUE[session] must exist
        if len( CLIENT_QUEUE.get(session, []) ) < 3:
            if not CACHE.get(value, None):
                clientObject = ClientObject( (ip, port) )
                CACHE[value] = clientObject
                return_message = "201,Room %s registered." % value
            else:
                return_message = "409,Room with name %s already exist." % value

            CLIENT_QUEUE[session].append(return_message+','+session)

        else:
            return_message = CLIENT_QUEUE[session][2]

    elif action == "join":
        room = CAHCE.get(value, None)
        if room:

            # TODO: this needs more error handling; might use setter and getter to handle when new peer appended
            sock.sendto( ("%d:%d" % (ip, port)).encode(), (room[0], room[1]) )
            room.peers.append((ip,port)) # this uncover the ip addresses of the room's participant no good...
            return_message = "302,%d:%d" % (room[0], room[1])
        else:
            return_message = "404,%s is not found." % value

    time.sleep(0.1)

    print(CLIENT_QUEUE)
    print("RETURN MESS", return_message)

    sock.sendto(return_message.encode(), (ip,port) )

    # except: pass
    # print(data, ip, port)
    # print(CACHE)

if __name__ == "__main__":
    pass
