.model small 
.stack 1000h

.data 
  keep_ip dw 0
  keep_cs dw 0
  string db 53 dup (?)
  filtered_string db 53 dup (?)
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
    mov bx, dx
    mov al, 51
    mov [bx], al
    mov ah, 0ah
    int 21h

    mov dx, offset crlf
    mov ah, 09h
    int 21h

    int 23h
    
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
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    
    mov ax, @data
    mov ds, ax
    
    ; Подготовка к фильтрации
    mov si, offset string + 2  ; Начало строки (пропускаем служебные байты)
    mov di, offset filtered_string   ; Буфер для результата
    mov cl, [string + 1]       ; Длина введенной строки
    mov ch, 0
    
  filter_loop:
    jcxz filter_done                 ; Если длина = 0, завершаем
    mov al, [si]                     ; Берем текущий символ
    
    ; Проверяем, является ли символ цифрой (0-9)
    cmp al, '0'
    jb check_russian                 ; Меньше '0' - не цифра
    cmp al, '9'
    ja check_russian                 ; Больше '9' - не цифра
    ; Если попали сюда - это цифра, пропускаем
    jmp next_char
    
  check_russian:
    ; Проверяем русские буквы (для кодировки CP866)
    ; Русские заглавные буквы: А(80h)-Я(AFh) и Ё(F0h)
    ; Русские строчные буквы: а(E0h)-я(F7h) и ё(F1h)
    
    ; Проверяем диапазон заглавных русских букв (кроме Ё)
    cmp al, 80h          ; А
    jb check_yo_upper
    cmp al, 0AFh         ; Я
    ja check_yo_upper
    jmp next_char        ; Русская заглавная буква - пропускаем
    
  check_yo_upper:
    cmp al, 0F0h         ; Ё (заглавная)
    jne check_lower
    jmp next_char        ; Буква Ё - пропускаем
    
  check_lower:
    ; Проверяем диапазон строчных русских букв (кроме ё)
    cmp al, 0E0h         ; а
    jb check_yo_lower
    cmp al, 0F7h         ; я
    ja check_yo_lower
    jmp next_char        ; Русская строчная буква - пропускаем
    
  check_yo_lower:
    cmp al, 0F1h         ; ё (строчная)
    jne save_char
    jmp next_char        ; Буква ё - пропускаем
    
  save_char:
    ; Сохраняем символ, если это не русская буква и не цифра
    mov [di], al
    inc di
    
  next_char:
    inc si
    loop filter_loop
    
  filter_done:
    ; Добавляем конец строки
    mov byte ptr [di], '$'
    
    ; Выводим отфильтрованную строку
    mov dx, offset filtered_string
    mov ah, 09h
    int 21h
    
    ; Восстанавливаем регистры
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    
    ; Выход из обработчика
    iret
  handle_string endp
end start
