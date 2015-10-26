global setup_stack_kernel
global setup_stack_user
global save_registers
global restore_registers
global setup_registers
global reset_cr3
global setup_stack_register
create_thread_memory_area:
    mov rax,0x10A000
    mov cr3,rax
    mov rax,[0x300010] ;greatest processor id
    mov rbx, rax
    imul rax,5 ;Each thread is 5 bytes
    add rax,0x300018 ;Start of thread array
    mov al,[rax]
    mov rbx,[rax+1]
    ret
reset_cr3:
    push rax
    mov rax,[0x300000]
    mov cr3,rax
    pop rax
    ret
setup_stack_register:
    mov rsp,0xF000000000000000
    ret

setup_registers:
    pop rax ;page addr
    pop rbx ;rip
    mov cr3,rax 
    push rbx ;This isn't the real rip
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
    ;call save_registers
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
    mov [0xFFFFFFFFFFFFFF00],rax
    mov [0xFFFFFFFFFFFFFF08],rbx
    mov [0xFFFFFFFFFFFFFF10],rcx
    mov [0xFFFFFFFFFFFFFF18],rdx
    mov [0xFFFFFFFFFFFFFF20],rsi
    mov [0xFFFFFFFFFFFFFF28],rdi
    mov [0xFFFFFFFFFFFFFF30],rbp
    mov [0xFFFFFFFFFFFFFF38],rsp
    mov [0xFFFFFFFFFFFFFF40],r8
    mov [0xFFFFFFFFFFFFFF48],r9
    mov [0xFFFFFFFFFFFFFF50],r10
    mov [0xFFFFFFFFFFFFFF58],r11
    mov [0xFFFFFFFFFFFFFF60],r12
    mov [0xFFFFFFFFFFFFFF68],r13
    mov [0xFFFFFFFFFFFFFF70],r14
    mov [0xFFFFFFFFFFFFFF78],r15
    ret

restore_registers:
    mov rax,[0xFFFFFFFFFFFFFF00] ;Storing these at fixed locations should
    mov rbx,[0xFFFFFFFFFFFFFF08] ;save some time
    mov rcx,[0xFFFFFFFFFFFFFF10]
    mov rdx,[0xFFFFFFFFFFFFFF18]
    mov rsi,[0xFFFFFFFFFFFFFF20]
    mov rdi,[0xFFFFFFFFFFFFFF28]
    mov rbp,[0xFFFFFFFFFFFFFF30]
    mov rsp,[0xFFFFFFFFFFFFFF38]
    mov r8,[0xFFFFFFFFFFFFFF40]
    mov r9,[0xFFFFFFFFFFFFFF48]
    mov r10,[0xFFFFFFFFFFFFFF50]
    mov r11,[0xFFFFFFFFFFFFFF58]
    mov r12,[0xFFFFFFFFFFFFFF60]
    mov r13,[0xFFFFFFFFFFFFFF68]
    mov r14,[0xFFFFFFFFFFFFFF70]
    mov r15,[0xFFFFFFFFFFFFFF78]
    ret

; vim: ft=nasm
