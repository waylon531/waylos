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
extern {
    fn thread_switch();
}
mod io;
#[no_mangle]
pub extern fn serial_counter() {
    let mut i: u8 = 33;
    loop {
        i +=1;
        unsafe { io::outb(0x3F8,i);}
        //unsafe {asm!("INT 32"::::"intel");}
        unsafe {thread_switch();}
    }
}
