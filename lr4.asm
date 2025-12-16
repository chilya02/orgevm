.model small 
.stack 1000h

.data 
  keep_ip dw 0
  keep_cs dw 0
  string db 53 dup (?)
  crlf db 0dh, 0ah, '$'

.code 
  start:
    mov ax, @data
    mov ds, ax

    mov ah, 35h
    mov al, 23h
    int 21h
    mov keep_cs, es
    mov keep_ip, bx

    push ds
    mov dx, offset handle_string
    mov ax, seg handle_string
    mov ds, ax
    mov ah, 25h
    mov al, 23h
    int 21h
    pop ds

    mov dx, offset string
    mov ah, 0ah
    int 21h

    mov dx, offset crlf
    mov ah, 09h
    int 21h

    cli 
    push dx
    mov dx, keep_ip
    mov ax, keep_cs
    mov ds, ax
    mov ah, 25h
    mov al, 23h
    int 21h
    pop dx
    sti
    
    mov ax, 4c00h
    int 21h         

  handle_string proc far
  
    push ax
    push dx
    push ds

    mov dx, offset string
    mov ah, 0ah

    mov si, offset string
    mov bx, 0h
    mov bl, [si + 1]
    mov byte ptr [si+bx+2], '$'
    
    mov dx, offset crlf
    mov ah, 09h
    int 21h

    mov dx, offset string
    add dx, 2
    mov ah, 09h
    int 21h

    pop ds
    pop dx
    pop ax
    
    iret
    handle_string endp
end start
