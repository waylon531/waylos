To build waylos you need the nightly version of rust. You'll probably also have to copy the libcore from that version to lib/libcore. Uses Hydrogen as a loader.

```make run``` to run

````make test; make run```` to run with runtime tests

It doesn't do much right now, it starts up 2 threads that have a counter and output stuff to the serial port. It also handles page faults.
