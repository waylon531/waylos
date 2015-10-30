extern clear_registers
extern double_fault_rust
extern general_protection_rust
extern kb_handle
extern thread_table_switch
extern save_registers
extern restore_registers
extern create_page
extern serial_counter
extern first_thread_create
extern create_framebuffer_page
global get_cr3
global argh
extern missing_page

HYDROGEN_HEADER_MAGIC equ  0x52445948
section .hydrogen
align 4
global hydrogen_header
hydrogen_header: 
        dd HYDROGEN_HEADER_MAGIC
        dd 0 ;Flags

        dq 0,0,0,0
        dq 0,0
        dq isr_table;ISR entry table
        ;Each 2 bytes after this corrsepond to an irq entry
        db 0
        db 32 ;Timer interrupt, for threading
        db 0
        db 33 ;PS/2 Interrupt
        times 28 db 0 ;Do I really want to be sending out divide by zero errors?

isr_table:
    times 8 dq interrupt_main
    dq double_fault
    times 5 dq interrupt_main
    dq add_page
    times 17 dq interrupt_main
    ;And now for custom interrupts
    dq thread_switch
    dq keyboard_input
    dq framebuffer_page
    times 221 dq interrupt_main
section .text
global start
start:
    extern thread_table_create
    call thread_table_create ;Setup thread table
    extern kmain
    call kmain
    mov rdi,serial_counter
    call first_thread_create
    mov rax,0x10A000
    mov cr3,rax
    int 32

.hang:
    hlt
    jmp .hang
keyboard_input: ;Send a message to the keyboard driver
    ;call kb_handle ;I need to implement message passing first
    iret
thread_switch:
    call save_registers
    mov rax, 0x10A000 ;Enable identity paging
    mov cr3, rax
    call thread_table_switch
    mov rax, [0x300000] ;Load the correct page table
    mov cr3, rax
    call restore_registers
    iret

framebuffer_page:
    push rax
    mov rax, 0x10A000
    mov cr3, rax
    push r8 ;This is where the caller should store stuff
    call create_framebuffer_page
    mov rax, 0x300000
    mov cr3,rax
    iret

double_fault:
    ;pushad
    ;cld
    call double_fault_rust
    hlt
    ;popad
    iret

add_page:
    call save_registers ;This might not be needed
    call clear_registers
    mov rax, 0x10A000
    mov cr3, rax ;Enable identity paging
    mov rsp,0xFFFFF00000000D00 ;This page is gauranteed to be allocated
    call missing_page
    ;mov rsp,[0xFFFFFFFFFFFFFF38]

    mov rax,[0x300000] ; Reenable the current thread's page table
    mov cr3, rax
    ;mov rax,[0xFFFFFFFFFFFFFF00]
    call restore_registers
    add rsp,8 ;Throw away the error code
    iretq

interrupt_main:
    ;pushad
    ;cld
    call general_protection_rust
    hlt
    ;popad
    iret

get_cr3:
    mov rax,cr3
    ret

; vim: ft=nasm
