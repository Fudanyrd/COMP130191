# assembly            Description                  machine code 
addi $2, $0, 3       # init $2 = 3                 20020003
addi $3, $0, 7       # init $3 = 7                 20030007
ori $2, $2, 5;       # $2 = (3 OR 5) = 7           34420005
addi $4, $0, 80      # init $4 = 80                20040050
andi $4, $4, 63      # $4 = (80 & 63) = 16         3084003f
sw $2, 0($4)         # store $2 at $4              ac820000              
# if it executes correctly, dataadr = 16, writedata = 7.
