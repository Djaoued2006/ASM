; print number in hex

jmp main

numbers dw 0FFFFh, 1021h, 0h, 3922h

main:
    mov ax, offset numbers
    mov cx, 4
    call print_numbers
    ret

proc print_numbers
    ; offset passed in ax, length of the array passed in cx
    mov si, ax
    jmp start
    
    start:
        cmp cx, 0
        je exit_function  
        mov dx, [si]
        call print_number   
        inc si
        dec cx        
        
        call print_space
        
        jmp start            
    
    exit_function:
        ret      

endp print_numbers

proc print_char 
    push ax
    mov ah, 2
    int 21h
    pop ax
    ret
endp 
                  
proc print_hex
    ; input passed in bl 
    push dx
    
    cmp bl, 10
    jl print_digit
    jmp print_letter
    
    
    print_digit:
        mov dl, bl
        add dl, "0"
        call print_char
        jmp done
        
    print_letter:
        mov dl, bl
        add dl, "A" - 10
        call print_char 
        jmp done
     
    done:  
        pop dx
        ret
endp print_hex 
      
proc print_number
    ; input passed in dx
    
    jmp get_first_nibble
    
    get_first_nibble:
        mov bx, dx
        shr bx, 12
        call print_hex
        jmp get_second_nibble
    
    get_second_nibble:
        mov bx, dx
        shr bx, 8
        and bx, 0Fh
        call print_hex
        jmp get_third_nibble
    
    get_third_nibble:
        mov bx, dx
        shr bx, 4
        and bx, 0Fh
        call print_hex
        jmp get_low_nibble
    
    get_low_nibble:
        mov bx, dx
        and bx, 0Fh
        call print_hex
        jmp exit
    
    exit:
        ret
endp print_number                 

proc print_space
    push dx
    mov dl, " "
    call print_char
    pop dx
    ret
endp print_space
