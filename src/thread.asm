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
    mov rax,[0x100008]
    and rax,0x000FFFFFFFFFF000 ;Clear reserved bits
    mov cr3,rax
    mov rsp,0xFFFFF00000000D00
    xor rax,rax
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
    hlt
    call clear_registers
    call save_registers
    ret

setup_stack_user: ;rip is already on the stack
    push 0
    push 0x18
    ret

setup_stack_kernel: ;rip is already on the stack
    push 0
    push 0x08
    ret
    
save_registers:
    mov [0xFFFFF00000000E00],rax
    pop rax ;Remove the return address from the old stack
    mov [0xFFFFF00000000E08],rbx
    mov [0xFFFFF00000000E10],rcx
    mov [0xFFFFF00000000E18],rdx
    mov [0xFFFFF00000000E20],rsi
    mov [0xFFFFF00000000E28],rdi
    mov [0xFFFFF00000000E30],rbp
    mov [0xFFFFF00000000E38],rsp
    mov [0xFFFFF00000000E40],r8
    mov [0xFFFFF00000000E48],r9
    mov [0xFFFFF00000000E50],r10
    mov [0xFFFFF00000000E58],r11
    mov [0xFFFFF00000000E60],r12
    mov [0xFFFFF00000000E68],r13
    mov [0xFFFFF00000000E70],r14
    mov [0xFFFFF00000000E78],r15
    push rax
    ret

restore_registers:
    pop rax
    mov rsp,[0xFFFFF00000000E38]
    push rax
    mov rax,[0xFFFFF00000000E00] ;Storing these at fixed locations should
    mov rbx,[0xFFFFF00000000E08] ;save some time
    mov rcx,[0xFFFFF00000000E10]
    mov rdx,[0xFFFFF00000000E18]
    mov rsi,[0xFFFFF00000000E20]
    mov rdi,[0xFFFFF00000000E28]
    mov rbp,[0xFFFFF00000000E30]
    mov r8,[0xFFFFF00000000E40]
    mov r9,[0xFFFFF00000000E48]
    mov r10,[0xFFFFF00000000E50]
    mov r11,[0xFFFFF00000000E58]
    mov r12,[0xFFFFF00000000E60]
    mov r13,[0xFFFFF00000000E68]
    mov r14,[0xFFFFF00000000E70]
    mov r15,[0xFFFFF00000000E78]
    ret

get_stack_entry:
    pop rdx
    pop rax
    push rdx
    ret

; vim: ft=nasm
