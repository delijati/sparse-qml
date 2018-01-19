Sparse
======

Experimental matrix python client for ubuntu touch.

Development
-----------

CLI 
~~~

Start::

    $ qmlscene Main.qml

Docker start::

    $ docker build -t ubports_xenial .
    $ docker run -ti --rm -e DISPLAY=:0 -v /tmp/.X11-unix:/tmp/.X11-unix -v `pwd`:/home/developer/ubports_build ubports_xenial bash -c "qmlscene Main.qml"
