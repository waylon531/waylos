#![feature(no_std,lang_items,core,core_prelude,core_str_ext,asm,core_panic,core_intrinsics,custom_derive)]
#![no_std]

//#[macro_use]
//extern crate core;

mod std {
    pub use core::{fmt,cmp,ops,iter,option,marker};
}


mod unwind;
mod screen;
mod hydrogen;
mod io;
pub mod interrupts;
pub mod thread;

pub use core::intrinsics::*;
pub use core::prelude::*;
pub use core::panicking;
pub use core::num::*;
pub use core::fmt::Write;
use core::mem;
use screen::Screen;

#[no_mangle]
#[lang="start"]
pub extern fn kmain() {
    let mut screen = Screen::new();
    screen.clear();
    write!(screen,"Printing initialized\n");
    let info = unsafe{*(0x14C000 as *const hydrogen::hy_info)};
    write!(screen,"Info table read\n");
    //unsafe {asm!("INT 8"::::"intel");}
    write!(screen, "Magic: {}\n",info.magic);
    write!(screen,"Successful bootup");
}
