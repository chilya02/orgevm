.model small 
.stack 1000h

.data 
  old_handler dd 0          ; Для хранения старого обработчика (сегмент+смещение)
  input_buffer db 53, 0, 50 dup (?)  ; Буфер для ввода: макс длина = 50
  filtered_string db 50 dup ('$')    ; Буфер для отфильтрованной строки
  crlf db 0dh, 0ah, '$'
  prompt db "Введите строку: $"
  result_msg db "Отфильтрованная строка: $"

.code 
  start:
    mov ax, @data
    mov ds, ax
    
    ; Сохраняем старый обработчик прерывания 23h (Ctrl+C)
    mov ah, 35h           ; Функция получения вектора прерывания
    mov al, 23h           ; Номер прерывания Ctrl+C
    int 21h
    mov word ptr [old_handler], bx    ; сохраняем смещение
    mov word ptr [old_handler+2], es  ; сохраняем сегмент
    
    ; Устанавливаем свой обработчик для прерывания 23h
    mov dx, offset handle_ctrl_c
    mov ax, seg handle_ctrl_c
    mov ds, ax
    mov ah, 25h           ; Функция установки вектора прерывания
    mov al, 23h           ; Номер прерывания Ctrl+C
    int 21h
    mov ax, @data         ; Восстанавливаем DS
    mov ds, ax
    
    ; Основная программа - ожидание ввода
    mov dx, offset prompt
    mov ah, 09h
    int 21h
    
    ; Ввод строки с клавиатуры
    mov dx, offset input_buffer
    mov ah, 0Ah
    int 21h
    
    ; Ждем, пока пользователь нажмет Ctrl+C
    ; или просто завершаем программу
    mov dx, offset crlf
    mov ah, 09h
    int 21h
    mov dx, offset result_msg
    mov ah, 09h
    int 21h
    
    ; Показываем, что было введено до фильтрации
    mov si, offset input_buffer
    mov bl, [si+1]        ; Длина введенной строки
    mov bh, 0
    mov byte ptr [si+bx+2], '$'  ; Добавляем конец строки
    
    mov dx, offset input_buffer
    add dx, 2             ; Пропускаем служебные байты
    mov ah, 09h
    int 21h
    
    ; Ждем Ctrl+C
wait_for_ctrl_c:
    jmp wait_for_ctrl_c   ; Бесконечный цикл ожидания
    
    ; Восстанавливаем старый обработчик (хотя программа уже завершится)
    lds dx, [old_handler]
    mov ah, 25h
    mov al, 23h
    int 21h
    
    ; Завершение программы
    mov ax, 4c00h
    int 21h         

  ; =============================================
  ; Обработчик прерывания Ctrl+C (23h)
  ; Фильтрует строку: удаляет русские буквы и цифры
  ; =============================================
  handle_ctrl_c proc far
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    
    mov ax, @data
    mov ds, ax
    
    ; Выводим сообщение о начале обработки
    mov dx, offset crlf
    mov ah, 09h
    int 21h
    mov dx, offset result_msg
    mov ah, 09h
    int 21h
    
    ; Подготовка к фильтрации
    mov si, offset input_buffer + 2  ; Начало строки (пропускаем служебные байты)
    mov di, offset filtered_string   ; Буфер для результата
    mov cl, [input_buffer + 1]       ; Длина введенной строки
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
    
  handle_ctrl_c endp

end start
