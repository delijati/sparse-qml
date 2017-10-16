import json
import os
import pyotherside
import datetime

from matrix_client.client import MatrixClient
from backend.config import FILENAME
from backend.utils import create_path

__version__ = "0.1.0"


class SparseManager(object):

    def __init__(self):
        self.active_room = None
        self.active_listener_id = None
        self.active_start = None

    def login(self, url, username, password):
        self.client = MatrixClient(url)

        # New user
        # token = client.register_with_password(username="foobar", password="monkey")

        # Existing user
        create_path(FILENAME)
        token = self.client.login_with_password(
            username=username, password=password)
        print("Logged in with token: {token}".format(token=token))

        data = {
            'token': token,
            'user_id': self.client.user_id,
            'url': url
        }

        with open(FILENAME, 'w') as f:
            json.dump(data, f, ensure_ascii=False)

        return data

    def login_with_token(self):
        with open(FILENAME, 'r') as f:
            data = json.load(f)

        self.client = MatrixClient(data["url"], user_id=data["user_id"],
                                   token=data["token"])
        return data

    def get_rooms(self):
        self.rooms = self.client.get_rooms()
        ids = [{"name": x.display_name,
                "topic": x.topic,
                "room_id": x.room_id} for x in self.rooms.values()]
        return ids

    def enter_room(self, room_id):
        import threading
        print("Threads running: %s self: %s" % (
            len(threading.enumerate()),
            id(self)
        ))
        if self.active_room and self.active_room.room_id == room_id:
            return
        if self.active_room:
            self.deactivate_room()

        # self.active_room = self.client.join_room(room_id)

        self.active_room = self.rooms[room_id]
        self.active_listener_id = self.active_room.add_listener(
            self.on_message)
        self.active_room.get_room_messages(limit=20)
        self.client.start_listener_thread()

    def get_next_messages(self):
        # TODO prepend at beginning 
        self.active_start = self.active_room.get_room_messages(
            limit=20, start=self.active_start
        )
        return self.active_start

    def deactivate_room(self):
        self.active_room.remove_listener(self.active_listener_id)
        self.client.stop_listener_thread(blocking=False)
        self.active_room = None
        self.active_listener_id = None
        self.active_start = None

    def on_message(self, room, event):
        if event['type'] in ("m.room.message", "m.room.encrypted"):
            to_send = {}
            if "msgtype" in event["content"] and event["content"]["msgtype"] == "m.image":
                to_send["image_url"] = self.client.api.get_download_url(
                    event["content"]["url"])
                to_send["msgtype"] = "image"
            if event["sender"] == self.client.user_id:
                user_id = self.client.user_id
            else:
                user_id = event["user_id"]
            if "body" in event["content"]:
                to_send["body"] = event["content"]["body"]
            elif "ciphertext" in event["content"]:
                to_send["body"] = "... encrypted ..."
            user = room._members.get(user_id)
            avatar_url = None
            displayname = None
            if user and user.avatar_url:
                avatar_url = user.avatar_url
            if user and user.displayname:
                displayname = user.displayname
            # XXX to expensive take up to 2 sec member and message
            # elif user and not user.avatar_url:
            #     avatar_url = user.get_avatar_url()
            to_send["time"] = datetime.datetime.fromtimestamp(
                event["origin_server_ts"]/1000, datetime.timezone.utc)
            to_send["avatar_url"] = avatar_url
            to_send["displayname"] = displayname if displayname else event["sender"]
            pyotherside.send('r.room.message', {"event": to_send})
        else:
            print(event["type"])
            print(event)

    def send_text(self, text):
        self.active_room.send_text(text)


def get_token_file_path(reset=False):
    if reset and os.path.exists(FILENAME):
        os.remove(FILENAME)
    return FILENAME


def file_exists():
    return os.path.exists(FILENAME)


mgr = SparseManager()
