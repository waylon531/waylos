use memory;
use screen::SCREEN;
use core::fmt::Write;
const THREAD_TABLE_ADDR: u64 = 0x300000;
extern {
    fn setup_registers(instruction_addr: u64);
    fn save_registers();
    fn restore_registers();
    fn setup_stack_kernel();
    fn setup_stack_user();
    fn reset_cr3();
    fn set_cr3();
    fn setup_stack_register();
}
#[no_mangle]
pub extern fn thread_switch() {

}
#[derive(Clone,Copy)]
#[repr(packed)]
struct Thread {
    enabled: u8, //I'm not sure if this can be a bool
    page_addr: u64, //Pointer to the PML4
}
#[repr(packed)]
pub struct Thread_Table { //Im pretty sure this shouldn't implement Copy
    current_page_table: u64,
    current_process_id: usize, //This has to be 64 bits, but I can only index with usize
    greatest_process_id: usize, //For assigning new threads
    threads: [Thread; 5000], //This should be around 1 MiB
}
unsafe fn create_thread_memory_area(paddr: u64,addr: u64) {
    let page_addr = paddr & 0xFFFFFFFFF000;
    (*(page_addr as *mut memory::PageTable)).set_entry(511,*(0x100000 as *const u64));
    memory::create_page(0xF00000000000,page_addr);
    let index = (*(0x300000 as *const Thread_Table)).greatest_process_id;
    (*(0x300000 as *mut Thread_Table)).threads[index] = Thread {enabled: 1, page_addr: page_addr};
    (*(0x300000 as *mut Thread_Table)).greatest_process_id +=1;
    *(0x100008 as *mut u64) = page_addr;//For some reason passing this in the stack doesn't work
    setup_stack_register(); //Rust tries to restore a non-existent stack-frame here
    loop {}
    setup_registers(addr); //Also sets up the stack and cr3
}
#[no_mangle]
pub extern fn user_thread_create(addr: u64) {
    unsafe {
        save_registers();
        create_thread_memory_area(memory::palloc(),addr); //Setup page table
        setup_stack_user();
        reset_cr3();
        restore_registers();
    }
}
#[no_mangle]
pub extern fn first_thread_create(addr: u64) {
    unsafe {
        //save_registers();
        create_thread_memory_area(memory::palloc(),addr); //Setup page table
        loop {}
        setup_stack_kernel();
        //reset_cr3();
        //restore_registers();
    }
}
#[no_mangle]
pub extern fn thread_table_create() {
    unsafe {
        for i in 0..5000 {
            (*(THREAD_TABLE_ADDR as *mut Thread_Table)).threads[i].enabled=0;
        }
        (*(THREAD_TABLE_ADDR as *mut Thread_Table)).current_process_id = 0;
        (*(THREAD_TABLE_ADDR as *mut Thread_Table)).greatest_process_id = 0;
    }
}
#[no_mangle]
pub extern fn thread_table_switch() {
    unsafe{
        (*(THREAD_TABLE_ADDR as *mut Thread_Table)).current_process_id += 1;
        while (*(THREAD_TABLE_ADDR as *mut Thread_Table)).threads[(*(THREAD_TABLE_ADDR as *mut Thread_Table)).current_process_id].enabled != 1 {
            if (*(THREAD_TABLE_ADDR as *mut Thread_Table)).current_process_id >= (*(THREAD_TABLE_ADDR as *mut Thread_Table)).greatest_process_id {
                (*(THREAD_TABLE_ADDR as *mut Thread_Table)).current_process_id = 0;
            } else {
                (*(THREAD_TABLE_ADDR as *mut Thread_Table)).current_process_id += 1;
            }
        }
        (*(THREAD_TABLE_ADDR as *mut Thread_Table)).current_page_table = (*(THREAD_TABLE_ADDR as *const Thread_Table)).threads[(*(THREAD_TABLE_ADDR as *const Thread_Table)).current_process_id].page_addr;
    }
}
