extern double_fault_rust
extern general_protection_rust
HYDROGEN_HEADER_MAGIC equ  0x52445948
section .hydrogen
align 4
global hydrogen_header
hydrogen_header: 
        dd HYDROGEN_HEADER_MAGIC
        dd 0

        dq 0,0,0,0
        dq 0,0
        dq isr_table;ISR entry table

isr_table:
    times 8 dq general_protection
    dq double_fault
    times 247 dq general_protection
section .text
global start
start:
    extern kmain
    call kmain

.hang:
    hlt
    jmp .hang

double_fault:
    ;pushad
    ;cld
    call double_fault_rust
    hlt
    ;popad
    iret

general_protection:
    ;pushad
    ;cld
    ;call general_protection_rust
    ;popad
    iret

