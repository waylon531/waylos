use hydrogen;
use core;
use hydrogen::mmap_info;
use collections::vec::Vec;
use screen::Screen;
use core::fmt::Write;
use screen::SCREEN;
#[no_mangle]
pub extern fn __morestack() -> ! {
    loop {}
}
#[repr(packed)]
pub struct PageStack {
    index: usize,
    data: [u64; (1<<17)-1] //Supports 512GB of mem, this might be a slice later
}
impl PageStack {
    pub fn init(mmap_entries: &[mmap_info]){
        let mut page_stack = (0x500000 as *mut PageStack);
        for mmap in mmap_entries {
            if mmap.available == 1 && mmap.address + mmap.length > 0x600000 {
                //The bottom 6 MiBs are reserved for kernel stuff
                let mut addr: u64 = 0;
                if mmap.address%(4*1024) == 0 {//We need a 4KiB aligned address
                    addr = mmap.address;
                } else {
                    addr = ((mmap.address/(4*1024))+1)*4*1024;
                }
                while mmap.contains(addr,4*1024) {
                    if addr >= 0x600000 {
                        unsafe{(*page_stack).push(addr);}
                    }
                    addr+=4*1024;
                }
            } 
        }
    }
    pub fn pop(&mut self) -> u64 {
        self.index -= 1;
        self.data[self.index]
    }
    pub fn push(&mut self, address: u64) {
        self.data[self.index] = address;
        self.index += 1;
    }
}
pub type PageTable = [u64; 512];
#[no_mangle]
pub extern fn create_page(u64_addr: u64) { //This function both finds a free page and sets it up
    let addr = u64_addr as usize; //Doing any allocation is probably bad
    let PML4O = (addr >> 39) & 0x1FF;
    let PDPO = (addr >> 30) & 0x1FF;
    let PDO = (addr >> 21) & 0x1FF;
    let PTO = (addr >> 12) & 0x1FF;
    unsafe {
        //I probably should check the page size, 
        //Hydrogen uses 2MB? pages
        if *(0x300000 as *const u64) == 0 {
            *(0x300000 as *mut u64) = palloc();
        }
        if (*(0x300000 as *const PageTable))[PML4O] == 0 {
            (*(0x300000 as *mut PageTable))[PML4O] = palloc();
        }
        if (*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable))[PDPO] == 0 {
            (*((*(0x300000 as *mut PageTable))[PML4O] as *mut PageTable))[PDPO] = palloc();
        }
        if (*(((*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable))[PDPO]) as *const PageTable))[PDO] == 0 {
            (*(((*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable))[PDPO]) as *mut PageTable))[PDO] = palloc();
        }
        if (*((*(((*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable))[PDPO]) as *const PageTable))[PDO] as *const PageTable))[PTO] == 0 {
            (*((*(((*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable))[PDPO]) as *const PageTable))[PDO] as *mut PageTable))[PTO] = palloc();
        }
    }
}

pub fn palloc() -> u64 {
    unsafe {(*(0x500000 as *mut PageStack)).pop() | 0b111} //Set the last 3 bits
}
#[no_mangle]
pub extern fn create_framebuffer_page(u64_addr: u64) {
    let addr = u64_addr as usize; //Doing any allocation is probably bad
    let PML4O = (addr >> 39) & 0x1FF;
    let PDPO = (addr >> 30) & 0x1FF;
    let PDO = (addr >> 21) & 0x1FF;
    let PTO = (addr >> 12) & 0x1FF;
    unsafe {
        //I probably should check the page size, 
        //Hydrogen uses 2MB? pages
        if *(0x300000 as *const u64) == 0 {
            *(0x300000 as *mut u64) = palloc();
        }
        if (*(0x300000 as *const PageTable))[PML4O] == 0 {
            (*(0x300000 as *mut PageTable))[PML4O] = palloc();
        }
        if (*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable))[PDPO] == 0 {
            (*((*(0x300000 as *mut PageTable))[PML4O] as *mut PageTable))[PDPO] = palloc();
        }
        if (*(((*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable))[PDPO]) as *const PageTable))[PDO] == 0 {
            (*(((*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable))[PDPO]) as *mut PageTable))[PDO] = palloc();
        }
        (*((*(((*((*(0x300000 as *const PageTable))[PML4O] as *const PageTable)    )[PDPO]) as *const PageTable))[PDO] as *mut PageTable))[PTO] = 0xb8000 | 0b111;
    }
}
