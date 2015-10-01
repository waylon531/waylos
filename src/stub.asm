extern double_fault_rust
extern general_protection_rust
extern kb_handle
extern thread_switch
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
    times 23 dq interrupt_main
    ;And now for custom interrupts
    dq thread_change
    dq keyboard_input
    times 222 dq interrupt_main
section .text
global start
start:
    extern kmain
    call kmain

.hang:
    hlt
    jmp .hang
keyboard_input: ;Send a message to the keyboard driver
    ;call kb_handle ;I need to implement message paassing first
    iret
thread_change:
    push rax
    mov rax,0x10A000
    mov cr3,rax ;Enable identity paging so the thread list can be accessed
    pop rax
    call thread_switch
    iret
double_fault:
    ;pushad
    ;cld
    call double_fault_rust
    hlt
    ;popad
    iret

interrupt_main:
    ;pushad
    ;cld
    ;call general_protection_rust
    ;popad
    iret

