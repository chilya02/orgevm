.MODEL SMALL    ; Модель памяти - SMALL (малая)

.STACK 100h     ; Отвести под Стек 256 байт

.DATA           ; Начало сегмента данных
  a DW  1
  b DW  2
  i DW  1    
  k DW  1
  i1 DW ?
  i2 DW ?
  res DW ?

.CODE           ; Начало сегмента кода
START:
  mov ax, @data ; Загрузка в DS адреса начала
  mov ds, ax    ; Сегмента данных
  
  
  mov bx, i     ;bx = 3*i
  shl bx, 1
  add bx, i

  mov ax, a     ; Сравнение а и b
  cmp ax, b

  jg ag         ; Условный переход (a > b)
  
                ; a <= b
  
                ; i1 = 3 * (i + 2)
                ; = 3*i + 6

  mov ax, 6     ; ax = 6

  add ax, bx    ; ax = 3*i + 6

  mov i1, ax    ; i1 = 3 * (i + 2)

                ;

                ; i2 = -(6 * i - 6)
                ; = -2(3 * i - 3)
  
  sub bx, 3     ; bx = 3 * i - 3
  
  shl bx, 1     ; bx = 6 * i - 6

  neg bx        ; bx = -(6 * i - 6)

  mov i2, bx    ; i2 = -(6 * i - 6)
  
  jmp calc_res  ; Безусловный переход

ag:             
                ; a > b
  
                ; i1 = -(6 * i - 4)

  mov ax, bx    ; ax = 6 * i
  shl ax, 1     

  sub ax, 4     ; ax = 6 * i - 4

  neg ax        ; ax = -(6 * i - 4)

  mov i1, ax    ; i1 = -(6 * i - 4)
                
                ;

                ; i2 =  20 - 4 * i
  
  add bx, i     ; bx = 4 * i

  mov ax, 20    ; ax = 20

  sub ax, bx    ; ax = 20 - 4 * i
  
  mov i2, ax    ; i2 = 20 - 4 * i

calc_res:
  
  mov ax, i1    ; bx = abs(i1)
  cwd
  xor ax, dx
  sub ax, dx 
  mov bx, ax

  cmp k, 0      ; Сравнение k с 0

  jge k_nn      ; Условный переход (k >= 0)

                ; k < 0

                ; res = |i1| + |i2|
  
  mov ax, i2    ; ax = abs(i2)
  cwd
  xor ax, dx
  sub ax, dx

  add ax, bx    ; ax = |i1| + |i2|

  mov res, ax   ; res = |i1| + |i2|

k_nn:          
                ; k >= 0
                
                ; res = max(6, |i1|)

  mov ax, 6     ; ax = 6

  cmp ax, bx

  jle save_res  ; Условный переход (6 >= |i1|)

  mov ax, bx    ; ax = |i1|

save_res:
  
  mov res, ax   ; Сохранение результата

  mov ah, 4ch   ; Заверщение программы
  int 21h
  
END START
  ; 4 5 7
