mod io;
#[no_mangle]
pub extern fn serial_counter() {
    let mut i: u8 = 0;
    loop {
        i +=1;
        unsafe { io::outb(0x3F8,i)}
        unsafe {asm!("INT 32"::::"intel");}
    }
}
