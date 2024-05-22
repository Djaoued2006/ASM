; read a string char by char 
org 100h

jmp main
            
msg db "THE STRING IS : ", "$"
size equ 100

string db size, 0, size dup(?)  

proc print_new_line
    mov ah, 2
    
    mov dl, 0xD
    int 21h
    
    mov dl, 0xA
    int 21h
    
    ret
endp print_new_line

proc read_char
    ; output in al
    mov ah, 1
    int 21h
    ret
endp read_char

proc read_string
    ; input in dx where dx = offset of the string
     mov si, 0 ; counts the number of chars read
     mov bx, dx  ; points to the first byte to write in    
     add bx, 2
    
     ; NOTE: the dx reg is a pointer to the sizeof the string
     mov bp, dx
     
     jmp start
     
     start:   
        mov cx, si
        cmp cl, b.[bp]  
        mov si, cx   
        
        jae done   
        
        call read_char
        
        cmp al, 0xD
        jz done 
        
        mov [bx + si], al  
        inc si
        jmp start
        
     
     done:
        ; set the number of chars read
        mov cx, si
        mov b.[bp], cl
        mov si, cx
        
        ; set the null terminator
        mov [bx + si], "$"
        
        ; return the offset of the string back in ax
        mov dx, bx
        
        ret      
        
endp read_string     

proc print_string
    ; input in dx
    mov ah, 9h
    int 21h
    ret
endp print_string

main:       
    mov dx, offset string      
    call read_string       
    push dx
    call print_new_line 
    mov dx, offset msg
    call print_string
    pop dx   
    call print_string
    jmp exit

exit:
    mov ah, 0
    mov al, 4Ch
    int 21h