use screen::Screen;
use core::fmt::Write;
use io;
extern {
    fn get_stack_entry() -> u64;
}
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
    write!(screen,"Stack:");
    //for i in 0 .. 10 {
        unsafe{write!(screen,"{}: {}\n",0,get_stack_entry());}
        unsafe{write!(screen,"{}: {}\n",1,get_stack_entry());}
        unsafe{write!(screen,"{}: {}\n",2,get_stack_entry());}
        unsafe{write!(screen,"{}: {}\n",3,get_stack_entry());}
    //}
    loop{}
}
