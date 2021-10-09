# This is the controll server which won't be included in the mobile application bundle

import socket
import time
import threading
import json

CACHE = {}

DEBUG = True
LISTEN_PORT = 4567

if DEBUG:
    # add temporary rooms
    CACHE["test room which you cant connect to"] = ["127.0.0.1", 1920]

    LISTEN_IP = '127.0.0.1'
else:
    LISTEN_IP = '192.168.0.105'

# TODO: what if someone faking or duplicate session is found (keep only the first one since the session could duplicate because it tied to current time)
# CLIENT_QUEUE only used when we need a response for reliability for example: when creating a room
CLIENT_QUEUE = {}

class ClientObject(object):

    """
    stored in form (ip, port)
    Client: - Means the current user
    Peers: - only could be none at initial state. // currently disabled
    Chat rooms: we store chatroom info at server
        Room Info: - if clinet hosts a chat room (name, owner identified by ip)
    """

    def __init__(self, client):
        self.client = client

    # Returns [ip, port]
    def __str__(self):
        return "%s:%s" % (self.client[0], self.client[1])

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((LISTEN_IP, LISTEN_PORT)) # 0.0.0.0 means assigned ip address

# Inform host for incoming connections
def host_inform():
    pass

print("Server started! IP: %s PORT: %d" % (LISTEN_IP, LISTEN_PORT))
while 1:

    # incoming data should look like this "<action parameter>:<action value>"
    data, (ip, port) = sock.recvfrom(1024)
    data = data.decode()
    session = 0 # null means invalid session


    if data == "keep": continue

    try:
        data, session = data.split(',')
        if data == '200':
            del CLIENT_QUEUE[session]

        if not CLIENT_QUEUE.get(session, None): CLIENT_QUEUE[session] = [ip, port]

    except: pass

    try:
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
                    return_message = {"status_code": "201", "messsage": "Room %s registered." % value}
                else:
                    return_message = {"status_code": "409", "message": "Room with name %s already exist." % value}

                return_message["session"] = session
                CLIENT_QUEUE[session].append(return_message)

            else:
                return_message = CLIENT_QUEUE[session][2]

        elif action == "join":
            room = CACHE.get(value, None)
            if room:

                # TODO: this needs more error handling; might use setter and getter to handle when new peer appended
                # sock.sendto( ("%d:%d" % (ip, port)).encode(), (room[0], room[1]) )
                inform_host_message = json.dumps({"action": "incoming_join", "ip_address": ip, "port": port})

                if not DEBUG:
                    sock.sendto(inform_host_message, ( room[0], room[1] ))

                # room.peers.append((ip,port))
                return_message = {"status_code": 302, "ip_address": room[0], "port": room[1]}
            else:
                return_message = {"status_code": 404}

            return_message["session"] = session

        # TODO: implement return room size if specified because sending all at once is not very productive
        elif action == "show_rooms" and value == "all":
            return_message = CACHE.copy()
            for key, value in return_message.items():
                return_message[key] = [value[0], value[1]]

            if CLIENT_QUEUE.get(session, None):
                return_message = {"session": session, "message": return_message}

            # will throw error make errror handler at client side
            # error cause because dart jsonDecode decodes json data even is it isn't
            # return_message = "alma"

        # print(CLIENT_QUEUE)
        # print("RETURN MESS", return_message)
        print(data,ip,port)

        return_message = json.dumps(return_message)
        time.sleep(0.1)

        print(return_message)
        sock.sendto(return_message.encode(), (ip,port) )

    except: pass

    # print(data, ip, port)
    # print(CACHE)

if __name__ == "__main__":
    pass
