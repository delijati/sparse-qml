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

    def login(self, url, username, password):
        self.client = MatrixClient(url)

        # New user
        # token = client.register_with_password(username="foobar", password="monkey")

        # Existing user
        create_path(FILENAME)
        token = self.client.login_with_password(
            username=username, password=password)
        print("Logged in with token: {token}".format(token=token))

        with open(FILENAME, 'w') as f:
            data = {
                'token': token,
                'user_id': self.client.user_id,
                'url': url
            }
            json.dump(data, f, ensure_ascii=False)

        return token

    def login_with_token(self):
        with open(FILENAME, 'r') as f:
            data = json.load(f)

        self.client = MatrixClient(data["url"], user_id=data["user_id"],
                                   token=data["token"])
        return self.get_rooms()

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
        self.active_room.backfill_previous_messages(limit=20)
        self.client.start_listener_thread()

    def deactivate_room(self):
        self.active_room.remove_listener(self.active_listener_id)
        self.client.stop_listener_thread(blocking=False)

    def on_message(self, room, event):
        if event['type'] == "m.room.message":
            if event["content"]["msgtype"] == "m.image":
                event["image_url"] = self.client.api.get_download_url(
                    event["content"]["url"])
            user = room._members.get(event["user_id"])
            avatar_url = None
            displayname = None
            if user and user.avatar_url:
                avatar_url = user.avatar_url
            if user and user.displayname:
                displayname = user.displayname
            # XXX to expensive take up to 2 sec member and message
            # elif user and not user.avatar_url:
            #     avatar_url = user.get_avatar_url()
            event["time"] = datetime.datetime.fromtimestamp(
                event["origin_server_ts"]/1000, datetime.timezone.utc)
            event["avatar_url"] = avatar_url
            event["displayname"] = displayname if displayname else event["sender"]
            pyotherside.send('r.room.message', {"event": event})


def get_token_file_path(reset=False):
    if reset and os.path.exists(FILENAME):
        os.remove(FILENAME)
    return FILENAME


def file_exists():
    return os.path.exists(FILENAME)


mgr = SparseManager()
