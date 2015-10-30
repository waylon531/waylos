/*  Waylos, a kernel built in rust
    Copyright (C) 2015 Waylon Cude

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
use screen::Screen;
use screen::SCREEN;
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
#[no_mangle]
pub extern fn print_6(a: u64, b: u64, c: u64, d: u64,e: u64,f: u64) {
    unsafe{write!(SCREEN,"{} {} {} {} {} {}\n",a,b,c,d,e,f);}
}
#[no_mangle]
pub extern fn print_1(a: u64) {
    unsafe{write!(SCREEN,"{}\n",a);}
}
