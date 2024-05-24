org 100h

; 1 - printing numbers:

; 1- print_number_dec : input in ax, it prints the number in decimal in signed representation 
; 2 - print_number_hex : input in ax, it prints the number in the hexadecimal format

; 2- array functions:

; 1- print_byte_arr: offset in ax, size in cx, it prints an array of bytes
; 2- reverse_arr : offset in ax, size in cx, it reverses the array  
; 3- sort_byte_arr: offset in ax, size in cx   
; 4 - search_byte_arr: offset in ax, value in bl, size in cx, it searches a given value in a byte array                    
; 5 - search_byte_arr_print: offset in ax, value in bl, size in cx, it applies the previous function and prints whether the number is found or not

jmp main   

size equ 10
arr db 9, 8, 7, 6, 5, 4, 3, 2, 1, 0   

print_arr_msg db "ARRAY: ", "$"  
sort_arr_msg db "SORTING...", "$"
reverse_arr_msg db "REVERSING...", "$"
result_msg db "RESULT: ", "$"


main:
    mov ax, offset arr   
    mov cx, size  
    
    ; printing the byte arr
    call print_byte_arr
    call print_new_line
    
    ; sorting it 
    lea dx, sort_arr_msg
    call print_string
    call print_new_line
    call sort_byte_arr
    
    ;; printing the byte arr
    call print_byte_arr
    call print_new_line
     
    ; reversing it     
    
    lea dx, reverse_arr_msg
    call print_string
    call print_new_line
    call reverse_arr
    
    ; printing it again
    call print_byte_arr
    call print_new_line
    
    ; searching for an existing value        
    mov bl, 0      
    lea dx, result_msg
    call print_string                   
    call search_byte_arr_print
    call print_new_line
    
    ; searching for not an existing value 
    mov bl, 10
    lea dx, result_msg
    call print_string                   
    call search_byte_arr_print
    call print_new_line
    ret

; IMPLEMENTATION

proc get_msb
    ; input in ax
    ; output in dl
    
    push ax
    shr ax, 15
    and ax, 1
    mov dl, al
    pop ax
    ret

endp get_msb    

proc print_sign 
    push ax 
    push dx
    
    mov ah, 2
    
    cmp dl, 0
    jne print_minus
    jmp exit_print_sign 
    
    print_minus:
        mov dl, "-"
        int 21h
        jmp exit_print_sign
    
    
    exit_print_sign: 
        pop dx      
        pop ax
        ret
endp print_sign


proc print_number_dec
    ; input in ax
    ; first print the sign   
    
    
    pusha
    
    call get_msb
    call print_sign
    
    mov bx, 10
    mov cx, 0 
    mov dx, 0
    
    cmp ax, 0
    jge print_pos_number
    jmp print_neg_number
    
    
    print_pos_number: 
        div bx
        add dx, "0"
        push dx
        mov dx, 0
        inc cx   
        cmp ax, 0
        je start_printing
        jmp print_pos_number
    
    print_neg_number:
        neg ax
        jmp print_pos_number
    
    start_printing:
        mov ah, 2
        jmp start
        
        start:
            pop dx
            int 21h
            loop start
     
        done: 
            popa 
        
            ret      
endp print_number_dec    

proc print_number_hex
    ; input in ax
    
    pusha  
    
    push ax  
    mov si, 1
    
    print_number_hex_start:
        cmp si, 4
        je print_number_hex_print
        
        shr ax, 4
        push ax
        
        inc si
        jmp print_number_hex_start    
    
    print_number_hex_print: 
        mov cx, 0 
        mov ah, 2
        
        print_number_hex_print_start:
            cmp cx, 4
            je print_number_hex_done 
            
            pop dx
            and dx, 0Fh   
            
            cmp dx, 10
            jb print_number_hex_digit
            jmp print_number_hex_letter    
            
        print_number_hex_digit:
            add dx, "0"   
            int 21h
            inc cx
            jmp print_number_hex_print_start
        
        print_number_hex_letter:
            add dx, "A" - 10
            int 21h
            inc cx
            jmp print_number_hex_print_start 
        
    print_number_hex_done:
        popa   
    
        ret
    
endp print_number_hex

 
proc print_byte_arr
    ; offset in ax
    ; size in cx 
    
    lea dx, print_arr_msg
    call print_string  
    
    pusha
    
    mov si, ax  
    add cx, ax
    mov ax, 0
    
    jmp print_byte_arr_start
    
    print_byte_arr_start:  
        cmp si, cx
        je print_byte_arr_done   
        
        mov al, b.[si]
        
        call print_number_dec  
        call print_space
        
        inc si
        jmp print_byte_arr_start
    
    jmp print_byte_arr_done
    
    print_byte_arr_done:
        popa     
    
        ret
    
endp print_byte_arr

proc reverse_arr
    pusha
    
    ; using two pointers approach
    mov si, ax
    
    mov di, ax
    add di, cx
    dec di
    
    jmp reverse_arr_start
    
    reverse_arr_start:  
        cmp si, di
        jge reverse_arr_done  
        mov al, b.[si]    
        mov bl, b.[di]
        mov b.[si], bl
        mov b.[di], al
        inc si 
        dec di
        jmp reverse_arr_start
   
    reverse_arr_done:   
        popa
        ret

endp reverse_arr  

proc sort_byte_arr
    pusha  
    
    mov si, ax      ; si will be an index 
    
    mov di, si
    add di, cx      ; di will store a pointer to the end of the array
   
    
    jmp sort_byte_arr_start
    
    
    sort_byte_arr_start: 
        ; if cx == 0 then we exit the loop                        
        cmp cx, 0
        je sort_byte_arr_done
        
        ; get the min value in the rest of the elements 
         mov bx, si        ; bx will store a pointer to the min value    
         mov ah, b.[bx]    ; this will store the current min value
        
         ; push the current value of si to the stack to use it later
         push si                                                    
         
         ; increment si and start searching for the min
         inc si
         
         sort_byte_arr_find_min:  
            ; if we hit the end of the array we exit the loop
            cmp si, di
            je sort_byte_arr_find_min_done
             
            ; we get the current value pointed by si
            mov al, b.[si]                          
            
            ; compare it with the minimum value
            cmp al, ah                         
            
            ; if it's less than the min value the update the bx and ah
            jb sort_byte_arr_update_min
            
            ; else loop
            inc si
            jmp sort_byte_arr_find_min
        
        sort_byte_arr_update_min:
            ; update the current min value
            mov ah, al                      
            
            ; update the current min pointer
            mov bx, si
            
            ; go back to the loop
            inc si
            jmp sort_byte_arr_find_min 
         
        sort_byte_arr_find_min_done:
            ; make the swap
            pop si
            mov al, b.[si]
            mov b.[bx], al  
            mov b.[si], ah
                           
            ; loop again  
            dec cx   
            inc si
            jmp sort_byte_arr_start 
        
    sort_byte_arr_done:
        popa 
        ret
endp sort_arr      
    
proc search_byte_arr
    ; offset passed in ax, value in bl, size in cx, output passed in dl (0 or 1) 
    
    push ax
    push si
    push bx
    push cx
       
    mov si, ax
    
    search_byte_arr_start:        
        mov al, b.[si]
        cmp al, bl 
        je search_byte_arr_found
        inc si
        loop search_byte_arr_start 
    
    jmp search_byte_arr_not_found
    
    search_byte_arr_found:
        mov dl, 1
        jmp search_byte_arr_done
    
    search_byte_arr_not_found:
        mov dl, 0
        jmp search_byte_arr_done
    
    search_byte_arr_done:
        pop cx
        pop bx
        pop si
        pop ax
        ret
 
endp search_byte_arr 

proc search_byte_arr_print   

    jmp search_byte_arr_print_start  
    
    found db "NUMBER FOUND", "$"
    not_found db "NUMBER NOT FOUND", "$"
           
    search_byte_arr_print_start:
        call search_byte_arr
        cmp dl, 0
        je set_not_found
        jmp set_found
    
    set_not_found:
        mov dx, offset not_found
        jmp search_print_msg 
    
    set_found:
        mov dx, offset found 
        jmp search_print_msg
        
    
    search_print_msg:
        call print_string
        ret  
endp search_byte_arr_print




; helper functions

proc print_space
    pusha
    mov dl, " "
    mov ah, 2
    int 21h
    popa
    ret
endp print_space      


proc print_new_line
    pusha      
    mov ah, 2
    
    ; printing cret
    mov dl, 0xD
    int 21h
    
    ; printing new line
    mov dl, 0xA
    int 21h            
    
    popa
    ret
endp print_new_line 

proc print_string
    ; offset in dx
    
    push ax
    
    mov ah, 9
    int 21h
    
    pop ax
    ret
endp print_string