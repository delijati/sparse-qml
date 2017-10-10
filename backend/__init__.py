import sys
import json
import os
import pyotherside

from matrix_client.client import MatrixClient
from matrix_client.api import MatrixRequestError
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
        try:
            create_path(FILENAME)
            token = self.client.login_with_password(username=username, password=password)
            print("Logged in with token: {token}".format(token=token))

            with open(FILENAME, 'w') as f:
                data = {
                    'token': token,
                    'user_id': self.client.user_id,
                    'url': url
                }
                json.dump(data, f, ensure_ascii=False)

        except MatrixRequestError as e:
            # TODO handle also in GUI
            print(e)
            if e.code == 403:
                print("Bad username or password.")
            else:
                print("Check your sever details are correct.")

        return token

    def login_with_token(self):
        with open(FILENAME, 'r') as f:
            data = json.load(f)

        self.client = MatrixClient(data["url"], user_id=data["user_id"],
                                   token=data["token"])
        return self.get_rooms()

    def get_rooms(self):
        rooms = self.client.get_rooms().values()
        ids = [{"name": x.display_name,
                "topic": x.topic,
                "room_id": x.room_id} for x in rooms]
        return ids

    def join_room(self, room_id):
        import threading
        print("Threads running: %s self: %s" % (
            len(threading.enumerate()),
            id(self)
        ))
        if self.active_room and self.active_room.room_id == room_id:
            return
        if self.active_room:
            self.deactivate_room()
        try:
            self.active_room = self.client.join_room(room_id)
        except MatrixRequestError as e:
            print(e)
            if e.code == 400:
                print("Room ID/Alias in the wrong format")
                sys.exit(11)
            else:
                print("Couldn't find room.")
                sys.exit(12)
        self.active_listener_id = self.active_room.add_listener(
            self.on_message)
        self.active_room.backfill_previous_messages()
        self.client.start_listener_thread()

    def deactivate_room(self):
        self.active_room.remove_listener(self.active_listener_id)
        self.client.stop_listener_thread(blocking=False)

    def on_message(self, room, event):
        if event['type'] == "m.room.message":
            if event['content']['msgtype'] == "m.text":
                pyotherside.send('r.room.message', event)
                print("{0}: {1}".format(
                    event['sender'], event['content']['body']))

        else:
            print(event['type'])


def get_token_file_path(reset=False):
    if reset and os.path.exists(FILENAME):
        os.remove(FILENAME)
    return FILENAME


def file_exists():
    return os.path.exists(FILENAME)


mgr = SparseManager()
