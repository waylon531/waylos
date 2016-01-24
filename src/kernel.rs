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
#![feature(lang_items,core_str_ext,asm,core_panic,core_intrinsics,custom_derive,alloc,unicode,collections)]
#![no_std]
extern crate alloc;
extern crate rustc_unicode;
extern crate collections;
extern crate raw_cpuid;
extern crate x86;
extern crate lib;
extern crate walloc;
extern {
    fn get_cr3() -> u64;
}

mod std {
    pub use core::{fmt,cmp,ops,iter,option,marker};
}

mod screen;
mod hydrogen;
mod io;
mod tests;
pub mod memory;
pub mod unwind;
pub mod interrupts;
pub mod thread;
pub mod servers;

pub use core::intrinsics::*;
pub use core::prelude::*;
pub use core::panicking;
pub use core::num::*;
pub use core::fmt::Write;
use core::mem;
use screen::Screen;
use screen::SCREEN;
use memory::PageStack;
use memory::PageTable;
use collections::vec::Vec;
#[no_mangle]
#[lang="start"]
pub extern fn kmain() {
    unsafe {
    SCREEN.clear();
    write!(SCREEN,"Printing initialized\n");
    write!(SCREEN,"CR3: {}\n",get_cr3());
    let info = unsafe{*(0x14C000 as *const hydrogen::hy_info)};
    write!(SCREEN,"Info table read\n");
    //unsafe {asm!("INT 8"::::"intel");}
    write!(SCREEN, "Magic: {}, should be {}\n",info.magic,0x52445948);
    write!(SCREEN, "{:?}\n",info);
    let info2 = unsafe{*(0x14C08A as *const hydrogen::hy_info_second_half)};
    write!(SCREEN, "{:?}\n",info2);
    unsafe {write!(SCREEN, "MMAP entries: {}\n",*(0x14C09A as *const u16));}
    let mmap_entries: &[hydrogen::mmap_info];
    unsafe {mmap_entries = core::slice::from_raw_parts((0x14D000 as *mut hydrogen::mmap_info),(*(0x14C09A as *const u16)) as usize);}
    PageStack::init(mmap_entries);
    write!(SCREEN,"Page Stack created\n");
    tests::test(&mut SCREEN);
    let PML4 = 0x10A000 as *const PageTable;
    /*let PDP = ((*PML4)[511] & 0xFFFFFFFFFFFFF000) as *const PageTable;
    for i in 0 .. 512 {
        if (*PML4)[i] != 0 {
            write!(SCREEN,"i {} addr PML4E {}\n",i,(*PML4)[i]);
        }
    }
    for i in 0 .. 512 {
        if (*((*PML4)[511] as *const PageTable))[i] != 0 {
            write!(SCREEN,"i {} addr PDPE {}\n",i,(*((*PML4)[511] as *const PageTable))[i]);
        }
    }*/
    *(0x100000 as *mut u64) = (*PML4).pages[511];
    write!(SCREEN,"Kernel Page Addr {}\n",*(0x100000 as *mut u64));
    //for i in 0 .. 300 {
    //    memory::palloc(); //For some reason a bunch of memory already has stuff in it
    //}
    let p = memory::palloc(); //Test writing to a random address
    *(p as *mut u64) = 30;
    write!(SCREEN,"30: {} @ {}\n",*(p as *mut u64),p);
    *(0x300000 as *mut u64) = 0x10A000;
    memory::create_page(0xFFFFF00000000000,0x10A000);
    *(0xFFFFF00000000000 as *mut u64) = 42;
    write!(SCREEN,"42: {} @ {}\n",*(0xFFFFF00000000000 as *mut u64),0xFFFFF00000000000);
    *(0xFFFFF10000000000 as *mut u64) = 0x42;
    write!(SCREEN,"66: {} @ {}\n",*(0xFFFFF10000000000 as *mut u64),0xFFFFF10000000000);
    let mut x = Vec::new();
    x.push(3);
    x.push(2);
    write!(SCREEN,"HEAPTEST 2={}\n",x.pop().unwrap());
    write!(SCREEN,"Successful bootup\n");
    }
}
#[no_mangle]
pub extern fn out(argh: u8) {
    unsafe{io::outb(0x3F8,argh);}
}
