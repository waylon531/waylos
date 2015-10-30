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
    pop rax ;Save the return address
    and rdi,0x000FFFFFFFFFF000 ;Clear reserved bits
    mov cr3,rdi
    mov rsp,0xFFFFF00000000D00
    xor rdi,rdi
    push rax
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
    call clear_registers
    call save_registers
    ret

setup_stack_user: ;rip is already on the stack
    push 0
    push 0x18
    ret

setup_stack_kernel: ;rip is already on the stack
    pop rax ;return address
    push 0x10
    push 0xFFFFF00000000100 ;This will get changed anyways
    push 0
    push 0x08
    push rdx
    push rax
    xor rax,rax
    ret
    
save_registers:
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
    mov [qword 0xFFFFF00000000E00],rax
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
    mov rax,[qword 0xFFFFF00000000E00] 
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
    extern create_thread_memory_area
    call create_thread_memory_area
    mov rdi,rax ;rax should have the fixed memory address
    mov rsp,rbp ;rust might have messed with rbp
    pop rdx ;save RIP
    call setup_stack_register
    push rbx ;save return address
    push rdx ;save rip onto the stack
    call setup_registers
    ;pop rdx
    pop rdx
    pop rbx
    call setup_stack_kernel
    mov rax,0xFFFFF00000000E38
    mov [rax],rsp
    push rbx 
    ;xor rdx,rdx
    ret


; vim: ft=nasm
