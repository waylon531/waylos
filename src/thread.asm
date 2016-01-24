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
extern print_1
global first_thread_create
global clear_registers
global setup_stack_kernel
global setup_stack_user
global save_registers
global restore_registers
global setup_registers
global reset_cr3
global setup_stack_register
global set_cr3
global get_cr2
global get_stack_entry
set_cr3:
    mov rax,0x10A000
    mov cr3,rax
    ret

get_cr2:
    mov rax,cr2
    ret
    
reset_cr3:
    push rax
    mov rax,[0x300000]
    mov cr3,rax
    pop rax
    ret
setup_stack_register:
    pop rcx ;Save the return address
    mov rax,rdi
    mov r8, 0x000FFFFFFFFFF000
    and rax,r8 ;Clear reserved bits
    mov cr3,rax
    mov rax,qword 0xFFFFF00000000D00
    mov rsp,rax
    mov rax,0xFFFFF00000000E80
    mov [rax],rdx ;Crashes here ;Store RIP in memory
    xor rdi,rdi
    push rcx
    xor rcx,rcx
    ret

clear_registers:
    xor rax,rax
    xor rbx,rbx
    xor rcx,rcx
    xor rdx,rdx
    xor rsi,rsi
    xor rdi,rdi
    xor rbp,rbp
    xor r8,r8
    xor r9,r9
    xor r10,r10
    xor r11,r11
    xor r12,r12
    xor r13,r13
    xor r14,r14
    xor r15,r15
    ret
    

setup_registers:    ;RIP is on the stack
    call clear_registers
    call save_registers
    ret

setup_stack_user: ;rip is already on the stack
    push 0
    push 0x18
    ret

setup_stack_kernel: ;this appears to not work correctly
    pop rcx ;return address
    push 0 ;For alignment
    push 0x10
    mov rax,qword 0xFFFFF00000000D00 
    push qword rax;This will get changed anyways
    push 0
    push 0x08
    push rdx
    push 0 ;Remove once interrupts work
    push rcx
    ret
    
save_registers:
    push rbx
    push rax
    mov rax,0xFFFFF00000000E00
    mov rbx,rax
    pop rax
    mov [rbx],rax ;Save rax first
    pop rbx
    mov rax,0xFFFFF00000000E08
    mov [rax],rbx ;WHY CAN'T I USE 64-BIT IMMEDIATES
    pop rbx ;Remove the return address from the old stack
    mov rax,0xFFFFF00000000E10
    mov [rax],rcx
    mov rax,0xFFFFF00000000E18
    mov [rax],rdx
    mov rax,0xFFFFF00000000E20
    mov [rax],rsi
    mov rax,0xFFFFF00000000E28
    mov [rax],rdi
    mov rax,0xFFFFF00000000E30
    mov [rax],rbp
    mov rax,0xFFFFF00000000E38
    mov [rax],rsp
    mov rax,0xFFFFF00000000E40
    mov [rax],r8
    mov rax,0xFFFFF00000000E48
    mov [rax],r9
    mov rax,0xFFFFF00000000E50
    mov [rax],r10
    mov rax,0xFFFFF00000000E58
    mov [rax],r11
    mov rax,0xFFFFF00000000E60
    mov [rax],r12
    mov rax,0xFFFFF00000000E68
    mov [rax],r13
    mov rax,0xFFFFF00000000E70
    mov [rax],r14
    mov rax,0xFFFFF00000000E78
    mov [rax],r15
    push rbx
    ret

restore_registers:
    pop rbx ;Return address
    mov rax,0xFFFFF00000000E38
    mov rsp,[rax]
    push rbx ;Return address
    mov rax,0xFFFFF00000000E08;Storing these at fixed locations should
    mov rbx,[rax] ;save some time EXCEPT FOR NASM
    mov rax,0xFFFFF00000000E10
    mov rcx,[rax]
    mov rax,0xFFFFF00000000E18 
    mov rdx,[rax]
    mov rax,0xFFFFF00000000E20
    mov rsi,[rax]
    mov rax,0xFFFFF00000000E28
    mov rdi,[rax]
    mov rax,0xFFFFF00000000E30
    mov rbp,[rax]
    mov rax,0xFFFFF00000000E40
    mov r8,[rax]
    mov rax,0xFFFFF00000000E48
    mov r9,[rax]
    mov rax,0xFFFFF00000000E50
    mov r10,[rax]
    mov rax,0xFFFFF00000000E58
    mov r11,[rax]
    mov rax,0xFFFFF00000000E60
    mov r12,[rax]
    mov rax,0xFFFFF00000000E68
    mov r13,[rax]
    mov rax,0xFFFFF00000000E70
    mov r14,[rax]
    mov rax,0xFFFFF00000000E78
    mov r15,[rax]
    mov rax,[abs qword 0xFFFFF00000000E00]
    ;mov rax,[rax] ;Restore rax last
    ret

get_stack_entry: ;I need to figure out a better way to do this
    pop rdx
    pop rax
    push rdx
    ret

first_thread_create:
    pop rbx
    push rdi ;RIP
    xor rdi,rdi
    mov rbp,rsp
    extern palloc
    call palloc
    mov rdi,rax ;rax should have the memory address from palloc
    ;call print_1
    extern create_thread_memory_area
    call create_thread_memory_area
    hlt
    mov rdi,rax ;rax should have the fixed memory address
    mov rsp,rbp ;rust might have messed with rbp
    pop rdx ;save RIP
    call setup_stack_register
    hlt
    ;mov r8,75
    ;mov rax,0xFFFFF00000000EA0
    ;mov [rax],r8
    push rbx ;save return address
    push rdx ;save rip onto the stack
    call setup_registers
    ;pop rdx
    pop rdx
    pop rbx
    call setup_stack_kernel
    xor rcx,rcx
    mov rax,0xFFFFF00000000E38
    mov [rax],rsp
    ;mov rdi,rsp
    ;mov rax,0x10A000
    ;mov cr3,rax
    ;call print_1
    ;hlt
    push rbx 
    ;xor rdx,rdx
    ret


; vim: ft=nasm 
