#Waylos
Waylos is going to be a 64-bit microkernel written in Rust.

To build waylos you need the nightly version of rust. Waylos uses Hydrogen as a loader.

To build from source:
```
git submodule update --init
make run
```

````make test; make run```` to run with runtime tests

Current features:
* A watermark memory allocator
* x86-64 only
* Printing to the screen
* Paging
* Pages are allocated on page fault

Planned features:
* Multithreading (WIP)
* Message passing
