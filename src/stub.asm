;    Waylos, a kernel built in rust
;    Copyright (C) 2015 Waylon Cude
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.


extern clear_registers
extern out
global thread_switch
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
extern print_6
extern print_1

HYDROGEN_HEADER_MAGIC equ  0x52445948
section .hydrogen
align 4
global hydrogen_header
hydrogen_header: 
        dd HYDROGEN_HEADER_MAGIC
        dd 0 ;Flags

        dq 0xFFFFF00000003000 ;Virtual stack address
        dq 0,0,0
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
    mov rdi,serial_counter
    call first_thread_create
    mov rax,0x10A000
    mov cr3,rax
    call thread_table_switch ;set PID 1 as active and set 0x300000
    mov rax, [0x300000]
    mov cr3,rax
    call restore_registers
    jmp serial_counter

.hang:
    hlt
    jmp .hang

argh:
    jmp argh

panic:
    int 8
    jmp panic

keyboard_input: ;Send a message to the keyboard driver
    ;call kb_handle ;I need to implement message passing first
    iret
thread_switch:
    pop rdx ;rdx is caller saved
    mov rax,0xFFFFF00000000E80 ;Save the return address
    mov [rax],rdx
    pushfq
    ;pop rdi
    ;pop rsi
    ;pop rdx
    ;pop rcx
    ;pop r8
    call save_registers
    mov rax, 0x10A000 ;Enable identity paging
    mov cr3, rax
    call thread_table_switch
    mov rax, [0x300000] ;Load the correct page table
    mov cr3, rax
    ;mov rdi,'a'
    call out
    call restore_registers
    ;mov rdi,'b'
    call out
    ;mov rax,0xFFFFF00000000EA0
    ;mov rdi,[rax]
    ;cmp rdi,75
    ;jne panic ;Something is wrong with memory
    ;pop rdi
    ;pop rsi
    ;pop rdx
    ;pop rcx
    ;pop r8
    ;pop r9
    ;mov rax, 0x10A000
    ;mov cr3,rax
    ;call print_6
    ;hlt
    ;pop rdi
    ;mov rax, 0x10A000 ;Enable identity paging
    ;mov cr3, rax
    ;call print_1
    ;mov rdi,serial_counter
    ;call print_1
    ;hlt
    ;mov rax, [0x300000] ;Enable identity paging
    ;mov cr3, rax
    ;push rdi
    popfq
    ;mov rdi,'$'
    call out
    mov rax,0xFFFFF00000000E80
    mov rdx,[rax]
    push rdx
    ret

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
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9
    mov rax, 0x10A000
    mov cr3,rax
   
    call print_6
    hlt
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
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop r8
    pop r9
    mov rax, 0x10A000
    mov cr3,rax
   
    call print_6
    hlt
    ;popad
    iret

get_cr3:
    mov rax,cr3
    ret

; vim: ft=nasm
