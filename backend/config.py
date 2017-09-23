import os


DIR = os.path.abspath(os.path.curdir)
APP_ID = "sparse-qml.delijati"

if os.environ.get('XDG_DATA_HOME'):
    DIR = os.path.join(os.environ['XDG_DATA_HOME'], APP_ID)

FILENAME = os.path.join(DIR, "token.txt")
