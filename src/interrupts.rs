use screen::Screen;
use core::fmt::Write;
use io;
#[no_mangle]
pub extern fn double_fault_rust() {
    let mut screen = Screen::new();
    screen.clear();
    write!(screen,"DOUBLE FAULT");
}
#[no_mangle]
pub extern fn general_protection_rust() {
    let mut screen = Screen::new();
    screen.clear();
    write!(screen,"General protection fault");
}
