# Reproducer: Decorators on classes ignored in Apache/2.4.51, mod_wsgi/4.9.0 Python/3.10

This is a simple flask app to reproduce an issue our team met with our
`mod_wsgi` served apps, once upgrading their base images to Fedora Linux 35: it
seems, that decorators applied to classes are ignored, and so modifications
they would do to classes do not take place.

This seem to be happening only when the code is run by `mod_wsgi`. Using
flask's build in server, or gunicorn does not have this issue.

The application code is in `app/app.py`.

Building and running the reproducer requires `podman`.

In order to reproduce the issue, first build the application container image
based on Fedora Linux 35:

    $ make f35

Then run the application:

    $ make run

In an another terminal query the app:

    $ curl -i 0.0.0.0:8080
    HTTP/1.1 500 INTERNAL SERVER ERROR
    Date: Fri, 12 Nov 2021 18:06:04 GMT
    Server: Apache/2.4.51 (Fedora) mod_wsgi/4.9.0 Python/3.10
    Content-Length: 290
    Connection: close
    Content-Type: text/html; charset=utf-8

    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
    <title>500 Internal Server Error</title>
    <h1>Internal Server Error</h1>
    <p>The server encountered an internal error and was unable to complete your request. Either the server is overloaded or there is an error in the application.</p>

The server logs have a `TypeError: Greeting() takes no arguments` message,
although the `@tweak_init` decorator changes the `__init__` method of the
class to take a `name` argument.

Full server logs:

    AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.0.2.100. Set the 'ServerName' directive globally to suppress this message
    [Fri Nov 12 18:06:02.309623 2021] [suexec:notice] [pid 1:tid 1] AH01232: suEXEC mechanism enabled (wrapper: /usr/sbin/suexec)
    AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.0.2.100. Set the 'ServerName' directive globally to suppress this message
    [Fri Nov 12 18:06:02.326895 2021] [lbmethod_heartbeat:notice] [pid 1:tid 1] AH02282: No slotmem from mod_heartmonitor
    [Fri Nov 12 18:06:02.327529 2021] [http2:info] [pid 1:tid 1] AH03090: mod_http2 (v1.15.24-git, feats=CHPRIO+SHA256+INVHD+DWINS, nghttp2 1.45.1), initializing...
    [Fri Nov 12 18:06:02.327601 2021] [proxy_http2:info] [pid 1:tid 1] AH03349: mod_proxy_http2 (v1.15.24-git, nghttp2 1.45.1), initializing...
    [Fri Nov 12 18:06:02.329389 2021] [wsgi:debug] [pid 1:tid 1] src/server/mod_wsgi.c(8512): mod_wsgi (pid=1): Socket for 'app' is '/etc/httpd/run/wsgi.1.0.1.sock'.
    [Fri Nov 12 18:06:02.329662 2021] [wsgi:debug] [pid 1:tid 1] src/server/mod_wsgi.c(8581): mod_wsgi (pid=1): Listen backlog for socket '/etc/httpd/run/wsgi.1.0.1.sock' is '100'.
    [Fri Nov 12 18:06:02.330450 2021] [wsgi:info] [pid 3:tid 3] mod_wsgi (pid=3): Starting process 'app' with uid=48, gid=48 and threads=4.
    [Fri Nov 12 18:06:02.331769 2021] [wsgi:info] [pid 3:tid 3] mod_wsgi (pid=3): Initializing Python.
    [Fri Nov 12 18:06:02.332253 2021] [mpm_event:notice] [pid 1:tid 1] AH00489: Apache/2.4.51 (Fedora) mod_wsgi/4.9.0 Python/3.10 configured -- resuming normal operations
    [Fri Nov 12 18:06:02.332346 2021] [mpm_event:info] [pid 1:tid 1] AH00490: Server built: Oct 12 2021 00:00:00
    [Fri Nov 12 18:06:02.332422 2021] [core:notice] [pid 1:tid 1] AH00094: Command line: 'httpd -D FOREGROUND'
    [Fri Nov 12 18:06:02.333593 2021] [wsgi:info] [pid 4:tid 4] mod_wsgi (pid=4): Initializing Python.
    [Fri Nov 12 18:06:02.334354 2021] [wsgi:info] [pid 5:tid 5] mod_wsgi (pid=5): Initializing Python.
    [Fri Nov 12 18:06:02.336530 2021] [wsgi:info] [pid 7:tid 7] mod_wsgi (pid=7): Initializing Python.
    [Fri Nov 12 18:06:02.373102 2021] [wsgi:info] [pid 3:tid 3] mod_wsgi (pid=3): Attach interpreter ''.
    [Fri Nov 12 18:06:02.373229 2021] [wsgi:info] [pid 5:tid 5] mod_wsgi (pid=5): Attach interpreter ''.
    [Fri Nov 12 18:06:02.373582 2021] [wsgi:info] [pid 4:tid 4] mod_wsgi (pid=4): Attach interpreter ''.
    [Fri Nov 12 18:06:02.373631 2021] [wsgi:info] [pid 7:tid 7] mod_wsgi (pid=7): Attach interpreter ''.
    [Fri Nov 12 18:06:02.388295 2021] [wsgi:info] [pid 3:tid 3] mod_wsgi (pid=3): Imported 'mod_wsgi'.
    [Fri Nov 12 18:06:02.388295 2021] [wsgi:info] [pid 7:tid 7] mod_wsgi (pid=7): Imported 'mod_wsgi'.
    [Fri Nov 12 18:06:02.388598 2021] [wsgi:debug] [pid 3:tid 103] src/server/mod_wsgi.c(9142): mod_wsgi (pid=3): Started thread 0 in daemon process 'app'.
    [Fri Nov 12 18:06:02.388700 2021] [wsgi:debug] [pid 3:tid 107] src/server/mod_wsgi.c(9142): mod_wsgi (pid=3): Started thread 3 in daemon process 'app'.
    [Fri Nov 12 18:06:02.388775 2021] [wsgi:debug] [pid 3:tid 105] src/server/mod_wsgi.c(9142): mod_wsgi (pid=3): Started thread 2 in daemon process 'app'.
    [Fri Nov 12 18:06:02.388813 2021] [wsgi:debug] [pid 3:tid 104] src/server/mod_wsgi.c(9142): mod_wsgi (pid=3): Started thread 1 in daemon process 'app'.
    [Fri Nov 12 18:06:02.390246 2021] [wsgi:info] [pid 5:tid 5] mod_wsgi (pid=5): Imported 'mod_wsgi'.
    [Fri Nov 12 18:06:02.390516 2021] [wsgi:info] [pid 4:tid 4] mod_wsgi (pid=4): Imported 'mod_wsgi'.
    [Fri Nov 12 18:06:04.715509 2021] [wsgi:info] [pid 5:tid 135] mod_wsgi (pid=5): Create interpreter '0.0.0.0:8080|'.
    [Fri Nov 12 18:06:04.728934 2021] [wsgi:info] [pid 5:tid 135] [client 10.0.2.100:59768] mod_wsgi (pid=5, process='', application='0.0.0.0:8080|'): Loading Python script file '/usr/share/app/app.wsgi'.
    [Fri Nov 12 18:06:04.895185 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768] [2021-11-12 18:06:04,894] ERROR in app: Exception on / [GET]
    [Fri Nov 12 18:06:04.895198 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768] Traceback (most recent call last):
    [Fri Nov 12 18:06:04.895201 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]   File "/usr/lib/python3.10/site-packages/flask/app.py", line 2070, in wsgi_app
    [Fri Nov 12 18:06:04.895203 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]     response = self.full_dispatch_request()
    [Fri Nov 12 18:06:04.895205 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]   File "/usr/lib/python3.10/site-packages/flask/app.py", line 1515, in full_dispatch_request
    [Fri Nov 12 18:06:04.895207 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]     rv = self.handle_user_exception(e)
    [Fri Nov 12 18:06:04.895209 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]   File "/usr/lib/python3.10/site-packages/flask/app.py", line 1513, in full_dispatch_request
    [Fri Nov 12 18:06:04.895211 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]     rv = self.dispatch_request()
    [Fri Nov 12 18:06:04.895213 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]   File "/usr/lib/python3.10/site-packages/flask/app.py", line 1499, in dispatch_request
    [Fri Nov 12 18:06:04.895215 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]     return self.ensure_sync(self.view_functions[rule.endpoint])(**req.view_args)
    [Fri Nov 12 18:06:04.895217 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]   File "/usr/local/lib/python3.10/site-packages/app-1.0.0-py3.10.egg/app/app.py", line 18, in main
    [Fri Nov 12 18:06:04.895219 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768]     return Greeting("Pete").text
    [Fri Nov 12 18:06:04.895221 2021] [wsgi:error] [pid 5:tid 135] [client 10.0.2.100:59768] TypeError: Greeting() takes no arguments
    10.0.2.100 - - [12/Nov/2021:18:06:04 +0000] "GET / HTTP/1.1" 500 290

The above works if the app is running on top of Fedora Linux 34 (`make f34`),
which has Apache/2.4.51, mod_wsgi/4.7.1, Python/3.9.

Running a similar code in an interactive Python interpreter or as a standalone
Python script also works as expected on Fedora Linux 35, Python 3.10.
