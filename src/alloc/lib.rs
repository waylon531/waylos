#![feature(allocator)]
#![allocator]
#![no_std]
#![crate_name = "walloc"]

extern crate rlibc;
use rlibc::memmove;

static mut FREE: usize = 0x10000000000; //Start at 64*16 GiB


#[no_mangle]
pub extern fn __rust_allocate(size: usize, _align: usize) -> *mut u8 {
    unsafe{
        let modulus = FREE%_align;
        if modulus == 0 {
            let f=FREE;
            FREE += size;
            return FREE as *mut u8;
        } else {
            let f=FREE+_align-modulus;
            FREE += size+_align-modulus;
            return FREE as *mut u8;
        }
    }
}

#[no_mangle]
pub extern fn __rust_deallocate(ptr: *mut u8, _old_size: usize, _align: usize) {
}

#[no_mangle]
pub extern fn __rust_reallocate(ptr: *mut u8, _old_size: usize, size: usize,
                                                                _align: usize) -> *mut u8 {
    let new_pointer = __rust_allocate(size,_align);
    unsafe{memmove(new_pointer,ptr,_old_size);}
    return new_pointer;
}

#[no_mangle]
pub extern fn __rust_reallocate_inplace(_ptr: *mut u8, old_size: usize,
                                                                                _size: usize, _align: usize) -> usize {
        old_size // this api is not supported by libc
}

#[no_mangle]
pub extern fn __rust_usable_size(size: usize, _align: usize) -> usize {
        size
}

