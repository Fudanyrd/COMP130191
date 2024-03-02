# assembly            Description                  machine code 
addi $2, $0, 3       # init $2 = 3                 20020003
addi $3, $0, 7       # init $3 = 7                 20030007
bne  $2, $3, next    # jump to next                14430001
add $3, $3, $2       # will not be executed        00621420
next:
sw $3, 40($0)        # store(disp) the value       ac030028
# if it executes correctly, dataadr = 16, writedata = 7.
