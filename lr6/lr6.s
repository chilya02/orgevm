.data
abc:     .word 20 # 434522
         .word 9  # Черепанов
         .word 4  # Илья

threshold:  .word 100     # пороговое значение

# Массив из 10 элементов
array:        .zero 40     # 10 слов * 4 байта = 40 байт

# Результаты
res1:       .word 0
res2:       .word 0

.text
.globl main

main:
    # Загрузка констант в регистры
    la t0, abc
    lw s0, 0(t0)        # s0 = a (регистровая адресация)
    lw s1, 4(t0)        # s1 = b
    lw s2, 8(t0)        # s2 = c
    
    # Инициализация массива (базовая адресация)
    la t0, array        # t0 = базовый адрес массива
    
    # array[0] = a + b + c (регистровая адресация)
    add t1, s0, s1      # t1 = a + b
    add t1, t1, s2      # t1 = a + b + c
    sw t1, 0(t0)        # array[0] = t1
    
    # Вычисление остальных элементов массива (array[i+1] = array[i] + a + b - c)
    li t2, 1            # t2 = i = 1 (непосредственная адресация)
    li s3, 10           # константа для границы итераций
    
init_loop:
    # Загружаем array[i-1]
    addi t3, t2, -1     # t3 = i-1
    slli t3, t3, 2      # t3 = (i-1)*4
    add t3, t3, t0      # t3 = &array[i-1]
    lw t4, 0(t3)        # t4 = array[i-1]
    
    # Вычисляем array[i] = array[i-1] + a + b - c
    add t4, t4, s0      # + a
    add t4, t4, s1      # + b
    sub t4, t4, s2      # - c
    
    # Сохраняем array[i]
    slli t3, t2, 2      # t3 = i*4
    add t3, t0, t3      # t3 = &array[i]
    sw t4, 0(t3)        # array[i] = t4
    
    # Проверяем условие цикла
    addi t2, t2, 1      # i++
    blt t2, s3, init_loop  # if i < 10, continue (адресация относительно PC)

    # Вычисление выражения  ЕСЛИ (arr[6] + arr[7] + arr[5] < threshold)
    #                             ТО (res1 = arr[8] & arr[9])
    #                             ИНАЧЕ (res2 = arr[1] & c)
    
    # Загрузка threshold в регистр s1
    lw s1, threshold
    
    # Загрузка нужных элементов массива
    lw t1, 24(t0)       # t1 = array[7] (базовая адресация: array + 7*4)
    lw t2, 28(t0)       # t2 = array[4]
    lw t3, 20(t0)       # t3 = array[1]
    
    # Вычисление суммы: array[6] + array[7] + array[5]
    add t4, t1, t2      # t4 = array[6] + array[7]
    add t4, t4, t3      # t4 = array[6] + array[7] + array[5]
    
    # Проверка условия: если sum < threshold
    blt t4, s1, then_branch  # if sum < threshold
    
    # иначе: res2 = array[1] & c
    lw t5, 4(t0)          # t5 = array[1]
    and t6, t5, s2        # t6 = array[1] & c (регистровая адресация)
    
    # Сохраняем результат в res2
    la t0, res2
    sw t6, 0(t0)        # res2 = array[1] & c
    j end_if
    
then_branch: # то: res1 = array[8] & array[9]
    # Восстанавливаем адрес массива в t5
    la t5, array        # t5 = адрес массива
    lw t6, 32(t5)       # t6 = array[8]
    lw t1, 36(t5)       # t1 = array[9]
    and t6, t6, t1      # t6 = array[8] & array[9]
    
    # Сохраняем результат в res1
    la t0, res1
    sw t6, 0(t0)        # res1 = array[8] & array[9]
    
end_if:
    # Выход из программы
    li a7, 10           # номер системного вызова exit
    ecall
