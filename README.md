# This is solution to labs of COMP130191.03!
This is what this repository is all about. 

# Disclaimer
Since I have limited knowledge of Computer Architecture, there may be bugs in my solution.
So you'd better check yourself(The only guarantee is that **the program can be run on Vivido or QtSpim**)!  
Also, **do not copy codes directly from this repository**! These codes will just be helpful when you get stuck and want to
get some idea.

# Lab 1
*Reading the fucking manual* will be of great help.

# Lab 2
## Adding ori
First we have to add it to decoding truth table(`lab2/Dec_tt.csv`) and ALU truth table(`lab2/ALU_tt.csv`).
Solution: observe that each R-type operator has its I-type one, for simplicity, just use 'func' field to 
tell them apart.  
Workflow: `aludec.sv` $\rightarrow$ `controller.sv`.
## Adding bne
Add a new field `branchsrc` to controller will work. Truth tables are updated.

# Lab 3
I'm still working on it, please be patient...
