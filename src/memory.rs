extern {
    fn get_cr2() -> u64;
}
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
#[repr(packed)]
pub struct PageTable{
    pub pages: [u64; 512],
}
impl PageTable {
    pub fn get_entry(&self, entry: usize) -> u64 {
        self.pages[entry] & 0xFFFFFFFFFFFFF000
    }
    pub fn next_level(&self, entry: usize) -> *mut PageTable {
        self.get_entry(entry) as *mut PageTable
    }
    pub fn is_null(&self, entry: usize) -> bool {
        if self.get_entry(entry) == 0 {
            true
        } else {
            false
        }
    }
    pub fn set_entry(&mut self,entry: usize,data: u64) {
        self.pages[entry] = data;
    }
    pub fn clear(&self, entry: usize){ //Broken
        unsafe{
            *((self.pages[entry] & 0xFFFFFFFFF000) as *mut PageTable) = PageTable {pages: [0;512]};
        }
    }
}
#[no_mangle]
pub extern fn create_page(u64_addr: u64,page_addr: u64) { //This function both finds a free page and sets it up
    //Odds are that this functions uses the stack and causes 
    let addr = u64_addr as usize; //Doing any allocation is probably bad
    let PML4O = (addr >> 39) & 0x1FF;
    let PDPO = (addr >> 30) & 0x1FF;
    let PDO = (addr >> 21) & 0x1FF;
    let PTO = (addr >> 12) & 0x1FF;
    let page_table = page_addr as *mut PageTable;
    unsafe{write!(SCREEN,"u64: {} page: {} {} {} {} {}\n",u64_addr,page_addr,PML4O,PDPO,PDO,PTO);}
    unsafe {
        //I probably should check the page size, 
        //Hydrogen uses 2MB? pages
        if (*page_table).is_null(PML4O) {
            //For some reason data is already here
            (*page_table).set_entry(PML4O,palloc());
        }
        //write!(SCREEN,"{} {}\n",(*page_table).get_entry(PML4O),*(palloc() as *mut u64));
        if (*(*page_table).next_level(PML4O)).is_null(PDPO) {
            (*(*page_table).next_level(PML4O)).set_entry(PDPO,palloc());
        }
        if (*(*(*page_table).next_level(PML4O)).next_level(PDPO)).is_null(PDO) {
            (*(*(*page_table).next_level(PML4O)).next_level(PDPO)).set_entry(PDO,palloc());
        }
        if (*(*(*(*page_table).next_level(PML4O)).next_level(PDPO)).next_level(PDO)).is_null(PTO) {
            (*(*(*(*page_table).next_level(PML4O)).next_level(PDPO)).next_level(PDO)).set_entry(PTO,palloc());
        }
        
    }
}

pub fn palloc() -> u64 {
    unsafe {((*(0x500000 as *mut PageStack)).pop() & 0x7FFFFFFFFFFFF000)| 0b111} //Set the last 3 bits and clear the NX bit, also clear bits 8-11
}
#[no_mangle]
pub extern fn create_framebuffer_page(u64_addr: u64,page_addr: u64) {
    /*let addr = u64_addr as usize; //Doing any allocation is probably bad
    let PML4O = (addr >> 39) & 0x1FF;
    let PDPO = (addr >> 30) & 0x1FF;
    let PDO = (addr >> 21) & 0x1FF;
    let PTO = (addr >> 12) & 0x1FF;
    let page_table = (page_addr as *mut PageTable);
    unsafe {
        //I probably should check the page size, 
        //Hydrogen uses 2MB? pages
        if *(0x300000 as *const u64) == 0 {
            *(0x300000 as *mut u64) = palloc();
        }
        if (*(page_table))[PML4O] == 0 {
            (*(page_table))[PML4O] = palloc();
        }
        if (*((*(page_table))[PML4O] as *const PageTable))[PDPO] == 0 {
            (*((*(page_table))[PML4O] as *mut PageTable))[PDPO] = palloc();
        }
        if (*(((*((*(page_table))[PML4O] as *const PageTable))[PDPO]) as *const PageTable))[PDO] == 0 {
            (*(((*((*(page_table))[PML4O] as *const PageTable))[PDPO]) as *mut PageTable))[PDO] = palloc();
        }
        (*((*(((*((*(page_table))[PML4O] as *const PageTable))[PDPO]) as *const PageTable))[PDO] as *mut PageTable))[PTO] = 0xb8000 | 0b111;
    }*/
}
#[no_mangle]
pub extern fn missing_page() {  //For some reason passing arguments to create
                                //page on the stack isn't working
    unsafe {create_page(get_cr2(),*(0x300000 as *const u64));}
}
