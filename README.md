# This is solution to labs of COMP130191.03!
Progress: Completed pipeline design.

# Disclaimer
Since I have limited knowledge of Computer Architecture, there may be bugs in my solution.
So you'd better check yourself(The only guarantee is that **the program can be run on Vivido or QtSpim**)!  
Also, **do not copy codes directly from this repository**! These codes will just be helpful when you get stuck and want to
get some idea.

# Lab 1
*Reading the fucking manual* will be of great help.

# Lab 2
![Simulation](lab2.png)
## Adding ori
First we have to add it to decoding truth table(`lab2/Dec_tt.csv`) and ALU truth table(`lab2/ALU_tt.csv`).
Solution: observe that each R-type operator has its I-type one, for simplicity, just use 'func' field to 
tell them apart.  
Workflow: `aludec.sv` $\rightarrow$ `controller.sv`.
## Adding bne
Add a new field `branchsrc` to controller will work. Truth tables are updated.

# Lab 3
![Simulation](lab3.png)
Done. Think about how you can leverage figure `7-42` on page `254` to make this task easier.

# Pipeline
![Simulation](pipeline.png)
**NOTE**: This lab is not named `Lab 4` since our distinguished TAs haven't decide the handout of lab 4.  
You may look at comments in `pipeline/HazardUnit.sv` and `pipeline/datapath.sv` for some hints. They are largely the pitfalls I've met...

# Appendix
Standard Testing File looks like this(you can also find it on page 278):
```
20020005
2003000c
2067fff7
00e22025
00642824
00a42820
10a7000a
0064202a
10800001
20050000
00e2202a
00853820
00e23822
ac670044
8c020050
08000011
20020001
ac020054
```
