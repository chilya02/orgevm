.data
abc:     .word 20 # 434522
         .word 9  # Черепанов
         .word 4  # Илья

xyz1:    .word 0
         .word 1
         .word 128

xyz2:    .word 5
         .word -14
         .word 3

endl:    .string "\n"

.text
 main:
    la t0, abc    
    lw s0, 0(t0) # a
    lw s1, 4(t0) # b
    lw s2, 8(t0) # c
    
    #((x + a) + (y & c)) & (z & (-b))
    
    la t0, xyz1
    lw a2, 0(t0) # x
    lw a3, 4(t0) # y
    lw a4, 8(t0) # z
    
    la t0, xyz2
    lw a5, 0(t0) # x
    lw a6, 4(t0) # y
    lw a7, 8(t0) # z
    
    add t0, a2, s0 # t0 = x+a
    and t1, a3, s2 # t1 = y&c
    neg t2, s1     # t2 = -b
    and t3, a4, t2 # t3 = z&(-b)
    add t4, t0, t1 # t4 = (x+a)+(y&c)
    and s3, t4, t3 # s3 = ((x+a)+(y&c)) & (z&(-b))
    
    add t0, a5, s0 # t0 = x+a
    and t1, a6, s2 # t1 = y&c
    neg t2, s1     # t2 = -b
    and t3, a7, t2 # t3 = z&(-b)
    add t4, t0, t1 # t4 = (x+a)+(y&c)
    and s4, t4, t3 # s4 = ((x+a)+(y&c)) & (z&(-b))
    
    mv a0, s3      # a0 = s3 (r1)
    li a7, 1       # код системного вызова
    ecall          # вывод r1
    
    la a0, endl    # a0 = addr("\n")
    li a7, 4       # код системного вызова
    ecall          # вывод "\n"
    
    mv a0, s4      # a0 = s4 (r2)
    li a7, 1       # код системного вызова
    ecall          # вывод r2
    
    la a0, endl    # a0 = addr("\n")
    li a7, 4       # код системного вызова
    ecall          # вывод "\n"
    
    mv a0, s3      # сохраняем r1 в a0
    mv a1, s4      # сохраняем r2 в a1
    
    li a7, 10      # код системного вызова
    ecall          # завершение программы
    

