import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;
import java.util.Stack;
import java.util.Scanner;
import java.io.*;

class Types {
    public static enum supported {
        Integer,
        String,
        Array       // of integers
    };

    public static enum registers {
        // t-type register, for storing temproray variables.
        T0,
        T1,
        T2,
        T3,
        T4,
        T5,
        T6,
        T7,
        // a-type register, for passing function parameters.
        A0,
        A1,
        A2,
        A3,
        // registers used for storing variables.
        S0,
        S1,
        S2,
        S3,
        S4,
        S5,
        S6,
        S7,
        // oops, not in registers! have to fetch in stack!
        InStack
    };

    public static final registers[] regnames = {
        registers.S0,
        registers.S1,
        registers.S2,
        registers.S3,
        registers.S4,
        registers.S5,
        registers.S6,
        registers.S7,
    };

    public static enum nodetype {
        // constant node
        Constant,
        // variable node
        Variable,
        Add,       // +
        Sub,       // -
        Mult,      // *
        Div,       // / 
        Rem,       // %
        LessThan,  // <
        GreaterThan, // >
        Equal,     // ==
        Not,       // !
        And,       // &&
        Or,        // ||
        NextInt,
        LeftParentese,  // (
        RightParentese  // ), maybe unused
    };
}

class VariableMeta {
    // domain of that variable, if this stack is empty, the variable does not exists.
    public Stack<Integer> domains;
    // address in the data memory(may be different for different domains!)
    public Stack<Integer> addresses;
    public Types.supported type;
    public Types.registers reg;

    public VariableMeta(Types.supported type) {
        this.type = type;
        domains = new Stack<>();
        this.reg = Types.registers.InStack;
        this.domains = new Stack<>();
        this.addresses = new Stack<>();
    }

    /**
     * @return true if is a global varaible, false otherwise
     */
    public boolean endFunc() {
        boolean res = false;
        while (!domains.isEmpty()) {
            int d = domains.pop();
            int addr = addresses.pop();
            if (d == 0) {
                domains.push(d);
                addresses.push(addr);
                res = true;
                break;
            }
        }

        return res;
    }
}

class RegisterManager {
    private boolean[] occupied;
    // time stamp used to decide which variable to evict.
    private HashMap<String, VariableMeta> variable_table_;
    // difference of register $sp.
    private int dsp;
    private int id;

    private static Types.registers[] regnames = {
        Types.registers.S0,
        Types.registers.S1,
        Types.registers.S2,
        Types.registers.S3,
        Types.registers.S4,
        Types.registers.S5,
        Types.registers.S6,
        Types.registers.S7
    };

    public RegisterManager() {
        variable_table_ = new HashMap<>();
        occupied = new boolean[8];   // w.r.t 8 s registers
        for (int i = 0; i < 8; ++i) {
            occupied[i] = false;
        }

        this.dsp = 0;
        this.id = 0;
    }

    public String nextId() {
        return Integer.valueOf(id++).toString();
    }

    /**
     * Evict the variable that occupied the register $s[res].
     */
    private void evict(int reg, ArrayList<String> instrs) {
        for (final String var : variable_table_.keySet()) {
            VariableMeta meta = variable_table_.get(var);
            if (meta.reg == regnames[reg]) {
                meta.reg = Types.registers.InStack;
                int adr = meta.addresses.pop();
                // store the evited variable back to stack.
                instrs.add("sw $s" + Integer.valueOf(reg).toString() + ", " + Integer.valueOf(dsp - adr) + "($sp)");
                meta.addresses.push(adr);
                break;
            }
        }
    }

    /**
     * @return an integer 0-7 representing $s0 - $s7.
     */
    private int allocReg(ArrayList<String> instrs) {
        for (int i = 0; i < 8; ++i) {
            if (!occupied[i]) {
                occupied[i] = true;
                return i;
            }
        }
        Random random = new Random();
        int res = random.nextInt(8);
        this.evict(res, instrs);

        return res;
    } 

    /**
     * @brief declare a variable in a new domain and store it in memory
     * @param varname variable name
     * @param vartype variable type
     * @param domain current domain of program
     * @throws RuntimeException if type mismatch or redeclare existing variables
     */ 
    public void declare(String varname, Types.supported vartype, int domain, ArrayList<String> instrs) {
        // allocate stack memory for var.
        if (variable_table_.containsKey(varname)) {
            VariableMeta meta = variable_table_.get(varname);
            if (meta.type != vartype) {
                throw new RuntimeException("variable in different domains has differet type?? Impossible!");
            }
            this.dsp += 4;
            meta.addresses.push(dsp);
            meta.domains.push(domain);
            meta.reg = Types.registers.InStack;
        }  else  {
            VariableMeta meta = new VariableMeta(vartype);  // set meta.type: done.
            this.dsp += 4;
            meta.addresses.push(dsp);
            meta.domains.push(domain);
            meta.reg = Types.registers.InStack;
            variable_table_.put(varname, meta);
        }
        instrs.add("    addi $sp, $sp, -4");
    }

    /**
     * Require a variable from the registers(if in data memory, load to register).
     * @param instrs[out] add `lw` instructions needed to complete the task.
     * @throws RuntimeException if the variable does not exists.
     */
    public Types.registers require(String varname, ArrayList<String> instrs) {
        // not implemented
        if (!variable_table_.containsKey(varname)) {
            throw new RuntimeException("unable to recognize variable " + varname + "?? Impossible!");
        }
        VariableMeta meta = this.variable_table_.get(varname);
        if (meta.reg != Types.registers.InStack) {
            return meta.reg;
        }

        int res = this.allocReg(instrs);
        final int adr = meta.addresses.pop();
        instrs.add("    lw $s" + Integer.valueOf(res).toString() + ", " + Integer.valueOf(dsp - adr) + "($sp)");
        meta.reg = regnames[res];
        meta.addresses.push(adr);

        return regnames[res];
    }

    /**
     * Start a function
     * manage $si, $sp, $ra registers.
     */
    public void startFunc(ArrayList<String> instrs) {
        this.dsp = 0;
        instrs.add(
            "    addi $sp, $sp, -40\n" + 
            "    sw $s0, 0($sp)\n" +  
            "    sw $s1, 4($sp)\n" +  
            "    sw $s2, 8($sp)\n" +  
            "    sw $s3, 12($sp)\n" +  
            "    sw $s4, 16($sp)\n" +  
            "    sw $s5, 20($sp)\n" +  
            "    sw $s6, 24($sp)\n" +  
            "    sw $s7, 28($sp)\n" +  
            "    sw $ra, 32($sp)\n" +  
            "    addi $t0, $sp, 40\n" +  
            "    sw $t0, 36($sp)\n" 
        );
    }

    /**
     * @return the reset instructions to get to initial state.
     */
    public String reset() {
        return
            "    addi $sp, $sp, " + Integer.valueOf(dsp).toString() + "\n" +
            "    lw $s0, 0($sp)\n" +  
            "    lw $s1, 4($sp)\n" +  
            "    lw $s2, 8($sp)\n" +  
            "    lw $s3, 12($sp)\n" +  
            "    lw $s4, 16($sp)\n" +  
            "    lw $s5, 20($sp)\n" +  
            "    lw $s6, 24($sp)\n" +  
            "    lw $s7, 28($sp)\n" +  
            "    lw $ra, 32($sp)\n" +  
            "    lw $sp, 36($sp)\n";
    }

    public void endFunc(ArrayList<String> instrs) {
        instrs.add(
            this.reset()
        );

        // evict any variables unsed in the domain of the function
        HashMap<String, VariableMeta> new_vartb_  = new HashMap<>();
        for (String varname : this.variable_table_.keySet()) {
            VariableMeta meta = variable_table_.get(varname);
            if (meta.endFunc()) {
                new_vartb_.put(varname, meta);
            }
        }
    }
}

/**
 * Node type of Parse Tree.
 */
class ParseTreeNode {
    public Types.nodetype nodetype;
    // value can be constants, variable names, operators.
    public String value;
    // a tree node may have zero to multiple childrens.
    public ArrayList<ParseTreeNode> children;

    public ParseTreeNode(Types.nodetype tp, String val) {
        this.value = val;
        this.nodetype = tp;
        this.children = new ArrayList<>();
    }

    /**
     * Code generation!
     * NOTE that the result is always in register $t0.
     * @param instrs[out]: output to an ArrayList of instructions.
     */
    public void genCode(ArrayList<String> instrs, RegisterManager manager) {
        switch (this.nodetype) {
            case Constant: {
                instrs.add("    addi $t0, $0, " + this.value);
                break;
            }
            case Add: {
                ParseTreeNode left = children.get(0);
                ParseTreeNode right = children.get(1);
                right.genCode(instrs, manager);
                instrs.add("    add $t1, $t0, $0");
                left.genCode(instrs, manager);
                instrs.add("    add $t0, $t1, $t0");
                break;
            }
            case Sub: {
                ParseTreeNode left = children.get(0);
                ParseTreeNode right = children.get(1);
                right.genCode(instrs, manager);
                instrs.add("    add $t1, $t0, $0");
                left.genCode(instrs, manager);
                instrs.add("    sub $t0, $t0, $t1");
                break;
            }
            case Mult: {
                ParseTreeNode left = children.get(0);
                ParseTreeNode right = children.get(1);
                right.genCode(instrs, manager);
                instrs.add("    add $t1, $t0, $0");
                left.genCode(instrs, manager);
                instrs.add("    mul $t0, $t1, $t0");
                break;
            }
            case Div: {
                ParseTreeNode left = children.get(0);
                ParseTreeNode right = children.get(1);
                right.genCode(instrs, manager);
                instrs.add("    add $t1, $t0, $0");
                left.genCode(instrs, manager);
                instrs.add("    div $t0, $t0, $t1");
                break;
            }
            case Rem: {
                ParseTreeNode left = children.get(0);
                ParseTreeNode right = children.get(1);
                right.genCode(instrs, manager);
                instrs.add("    add $t1, $t0, $0");
                left.genCode(instrs, manager);
                instrs.add("    rem $t0, $t0, $t1");
                break;
            }
            case LessThan: {
                ParseTreeNode left = children.get(0);
                ParseTreeNode right = children.get(1);
                right.genCode(instrs, manager);
                instrs.add("    add $t1, $t0, $0");
                left.genCode(instrs, manager);
                instrs.add("    slt $t0, $t0, $t1");
                break;
            }
            case GreaterThan: {
                ParseTreeNode left = children.get(0);
                ParseTreeNode right = children.get(1);
                right.genCode(instrs, manager);
                instrs.add("    add $t1, $t0, $0");
                left.genCode(instrs, manager);
                instrs.add("    slt $t0, $t1, $t0");
                break;
            }
            case NextInt: {
                instrs.add("    addi $v0, $0, 5");
                instrs.add("    syscall");
                instrs.add("    add $t0, $v0, $0");
                break;
            }
            case Equal: {
                ParseTreeNode left = children.get(0);
                ParseTreeNode right = children.get(1);
                final String id = manager.nextId();
                right.genCode(instrs, manager);
                instrs.add("    add $t1, $t0, $0");
                left.genCode(instrs, manager);
                // $t0 = ($t0 == $t1)
                instrs.add(
                    "    beq $t0, $t1, eq" + id + "\n" + 
                    "    j neq" + id + "\n" +
                    "eq" + id + ":\n" + 
                    "    addi $t0, $0, 1\n" + 
                    "    j endeq" + id + "\n" + 
                    "neq" + id + ":\n" + 
                    "    add $t0, $0, $0\n" + 
                    "endeq" + id + ":"
                );
                break;
            }
            case Not: {
                ParseTreeNode left = children.get(0);
                final String id = manager.nextId();
                left.genCode(instrs, manager);
                // $t0 = ($t0 == $0)
                instrs.add(
                    "    beq $t0, $0, eq" + id + "\n" + 
                    "    j neq" + id + "\n" +
                    "eq" + id + ":\n" + 
                    "    addi $t0, $0, 1\n" + 
                    "    j endeq" + id + "\n" + 
                    "neq" + id + ":\n" + 
                    "    add $t0, $0, $0\n" + 
                    "endeq" + id + ":"
                );
                break;
            }

            case Variable: {
                Types.registers reg = manager.require(value, instrs);
                int r = 0;
                for (; r < 8; ++r) {
                    if (Types.regnames[r] == reg) { break; }
                }
                instrs.add("    add $t0, $0, $s" + Integer.valueOf(r).toString());
                break;
            }
            default: {
                break;
            }
        }
    }


    /** 
     * Helper function of genTree, merge an operator node and possibly two operand nodes.
     * @return true if succeeded, false if the top of operator stack is a left parentese.
     * @throws RuntimeException if missing operands.
     */
    private static boolean mergeNode(Stack<ParseTreeNode> operators, Stack<ParseTreeNode> operands) {
        // merge two operand and one operator.
        if (operators.isEmpty()) {
            return false;
        }
        ParseTreeNode node = operators.pop();
        if (node.nodetype == Types.nodetype.LeftParentese) {
            operators.push(node);
            // failure!
            return false; 
        }  else  {
            if (node.nodetype == Types.nodetype.Not) {
                if (operands.isEmpty()) {
                    throw new RuntimeException("operator missing operands?? Impossible!");
                }
                ParseTreeNode op = operands.pop();
                node.children.add(op);
                operands.push(node);
            }  else  {
                if (operands.size() < 2) {
                    throw new RuntimeException("operator missing operands?? Impossible!");
                }
                ParseTreeNode rightOp = operands.pop();
                ParseTreeNode leftOp = operands.pop();
                node.children.add(leftOp);
                node.children.add(rightOp);
                operands.push(node);
            }
        }

        return true;
    }
    /**
     * Given a subset of token stream, generate arithmetic expression tree.
     * @return the root of the parse tree
     */
    public static ParseTreeNode genTree(ArrayList<String> tokenStream, int b, int e) {
        if (b >= e) {
            // empty series
            return null;
        }
        // operator stack.
        Stack<ParseTreeNode> operators = new Stack<>();
        // operand stack.
        Stack<ParseTreeNode> operands  = new Stack<>();

        for (int i = b; i < e; ++i) {
            final String word = tokenStream.get(i);
            if (word.charAt(0) >= '0' && word.charAt(0) <= '9') {
                // operand
                operands.push(new ParseTreeNode(Types.nodetype.Constant, word));
                if (!operators.isEmpty()) {
                    mergeNode(operators, operands);   // try merge
                }
            }  else  {
                // variables or operators.
                switch (word.charAt(0)) {
                    case '+': {
                        operators.push(new ParseTreeNode(Types.nodetype.Add, null));
                        break;
                    }
                    case '-': {
                        operators.push(new ParseTreeNode(Types.nodetype.Sub, null));
                        break;
                    }
                    case '*': {
                        operators.push(new ParseTreeNode(Types.nodetype.Mult, null));
                        break;
                    }
                    case '/': {
                        operators.push(new ParseTreeNode(Types.nodetype.Div, null));
                        break;
                    }
                    case '%': {
                        operators.push(new ParseTreeNode(Types.nodetype.Rem, null));
                        break;
                    }
                    case '(': {
                        operators.push(new ParseTreeNode(Types.nodetype.LeftParentese, null));
                        break;
                    }
                    case '=': {
                        // must be equal assertion
                        operators.push(new ParseTreeNode(Types.nodetype.Equal, null));
                        break;
                    }
                    case '<': {
                        if (word.length() == 1) {
                            // less than
                            operators.push(new ParseTreeNode(Types.nodetype.LessThan, null));
                        }  else  {
                            // less than or equal, not implemented
                        }
                        break;
                    }
                    case '>': {
                        if (word.length() == 1) {
                            // less than
                            operators.push(new ParseTreeNode(Types.nodetype.GreaterThan, null));
                        }  else  {
                            // less than or equal, not implemented
                        }
                        break;
                    }
                    case '!': {
                        if (word.length() == 1) {
                            // not operator
                            ParseTreeNode root = (new ParseTreeNode(Types.nodetype.Not, null));
                            operators.add(root);
                        }  else  {
                            // not equal(not implemented)
                        }
                        break;
                    }
                    case ')': {
                        // operators.push(new ParseTreeNode(Types.nodetype.RightParentese, null));
                        ParseTreeNode rt = operators.pop();
                        if (rt.nodetype != Types.nodetype.LeftParentese) {
                            throw new RuntimeException("unmatched parentese?? Impossible!");
                        }
                        while (ParseTreeNode.mergeNode(operators, operands));
                        break;
                    }

                    default: {
                        // must be an variable(nextInt) or function name.
                        if (word.compareTo("nextInt") == 0) {
                            operands.push(new ParseTreeNode(Types.nodetype.NextInt, null));
                        }  else  {
                            operands.push(new ParseTreeNode(Types.nodetype.Variable, word));
                        }
                        if (!operators.isEmpty()) {
                            mergeNode(operators, operands);   // try merge
                        }
                    }
                }
            }
        }

        return operands.pop();
    }
}

/**
 * Parse a stream of token into syntax tree.
 */
class Parser {
    // parsed instructions
    public ArrayList<String> instrs;
    private HashMap<String, Integer> keywords;
    private Integer domain;
    private RegisterManager manager;
    private Integer loopCount;
    private Stack<Integer> loopStack;
    private Integer ifCount;
    // string literal table
    private HashMap<String, String> strConsts;
    private Integer anonymous = 0;

    private void check(boolean predicate, String msg) {
        if (!predicate) {
            throw new RuntimeException(msg + "?? Impossible!");
        }
    }

    /**
     * Collect all static data(almost certainly string literals)
     * NOTE: in special c, string literals are immutable
     */
    public ArrayList<String> collectStatic() {
        ArrayList<String> res = new ArrayList<>();
        res.add(".data");
        final String pred = ": .asciiz ";
        for (final String key : strConsts.keySet()) {
            res.add("  " + key + pred + strConsts.get(key)); 
        }
        res.add(".text");

        return res;
    }

    private int matchBracket(ArrayList<String> tokenStream, int b, int e) {
        final char left = tokenStream.get(b).charAt(0);
        char right;

        switch (left) {
            case '{': right = '}'; break;
            case '(': right = ')'; break;
            case '[': right = ']'; break;
            default: throw new RuntimeException(tokenStream.get(b) + " is not a left brachket?? Impossible!");
        }
        int c = 1;
        for (int i = b + 1; i < e; ++i) {
            if (tokenStream.get(i).charAt(0) == left) {
                c += 1;
            }  else  {
                if (tokenStream.get(i).charAt(0) == right) {
                    c--;
                }
            }
            if (c == 0) {
                return i;
            }
        }
        throw new RuntimeException("unable to match bracket?? Impossible!");
    }
    private int findWord(ArrayList<String> tokenStream, String target, int b, int e) {
        for (int i = b; i < e; ++i) {
            if (tokenStream.get(i).compareTo(target) == 0) {
                return i;
            }
        }
        throw new RuntimeException("unable to find " + target + "?? Impossible!");
    }

    public void printToken(ArrayList<String> tokenStream, int b, int e) {
        for (int i = b; i < e; ++i) {
            System.out.println(tokenStream.get(i));
        }
    }

    private void parse(ArrayList<String> tokenStream, int b, int e) {
        for (int i = b; i < e; ) {
            int j = i + 1;

            if (!keywords.containsKey(tokenStream.get(i))) {
                // must be assignment, `a = 1 + 2 + 3` or maybe `a = do func(...)`
                while (j < e && tokenStream.get(j).charAt(0) != ';') {
                    ++j;
                }

                char ch = tokenStream.get(i).charAt(0);
                if (ch >= '0' && ch <= '9') {
                    ParseTreeNode root = ParseTreeNode.genTree(tokenStream, i, j);
                    root.genCode(this.instrs, this.manager);
                    i = j + 1;
                    continue;
                }

                boolean isFuncCall = tokenStream.get(i + 2).compareTo("do") == 0;
                if (isFuncCall) {
                    this.call(tokenStream, i + 2, j + 1);
                }  else  {
                    ParseTreeNode root = ParseTreeNode.genTree(tokenStream, i + 2, j);
                    root.genCode(this.instrs, this.manager);
                }
                // put the value in $t0 into the target register
                Types.registers reg = this.manager.require(tokenStream.get(i), this.instrs);
                int r = 0;
                for (; r < 8; ++r) {
                    if (Types.regnames[r] == reg) { break; }
                }
                this.instrs.add("    add $s" + Integer.valueOf(r).toString() + ", $t0, $0");
                i = j + 1;   // tokenStream[j] = ";"
                continue;
            }

            int keyId = this.keywords.get(tokenStream.get(i));
            if (keyId > 1 && keyId < 5) {  // variable declaration
                while (tokenStream.get(j).charAt(0) != ';') { ++j; }
                if (keyId == 2) {
                    int k = i + 1; // tokenStream[k] == ",";
                    while (k < j) {
                        i = k;
                        while (tokenStream.get(k).charAt(0) != ',' && k < j) { ++k; }
                            // for (int it = i; it < j; ++it) {
                            //     System.out.println(tokenStream.get(it));
                            // }
                        this.manager.declare(tokenStream.get(i), Types.supported.Integer, this.domain, this.instrs);
                        if (k > i + 1) {
                            boolean isFuncCall = tokenStream.get(i + 2).compareTo("do") == 0;
                            if (isFuncCall) {
                                this.call(tokenStream, i + 2, j + 1);
                            }  else  {
                                ParseTreeNode root = ParseTreeNode.genTree(tokenStream, i + 2, k);
                                // for (int it = i; it < k; ++it) {
                                //     System.out.println(tokenStream.get(it));
                                // }
                                root.genCode(this.instrs, this.manager);
                            }
                            // write back to register belonging to the new variable
                            Types.registers reg = this.manager.require(tokenStream.get(i), this.instrs);
                            int r;
                            for (r = 0; r < 8; ++r) {
                                if (Types.regnames[r] == reg) { break; }
                            }
                            instrs.add("    add $s" + Integer.valueOf(r).toString() + ", $t0, $0");
                        }

                        k += 1;
                    }
                }  else  {
                    if (keyId == 4) {
                        j = this.findWord(tokenStream, ";", i, e);
                        int k = i + 1;
                        while (k < j) {
                            i = k;
                            while (tokenStream.get(k).charAt(0) != ',' && k < j) { ++k; }
                            String key = tokenStream.get(i) + this.domain.toString();
                            this.strConsts.put(key, tokenStream.get(k - 1));
                            k += 1;
                        }
                    }  else  {
                        // array is not implemented
                    }
                }
                i = j + 1;   // tokenStream[j] = ";"
            }  else  {
                switch (keyId) {
                    // if 
                    case 5: {
                        final String name = this.ifCount.toString();
                        this.ifCount += 1;
                        this.check(tokenStream.get(i + 1).charAt(0) == '(', "if statement does not follow a predicate");
                        int k = i + 1;   // if (<predicate>)
                        // match right bracket
                        k = this.matchBracket(tokenStream, i + 1, e);
                        // parse the predicate, result in $t0.
                        ParseTreeNode root = ParseTreeNode.genTree(tokenStream, i + 1, k + 1);
                        root.genCode(this.instrs, this.manager);
                        this.instrs.add("    beq $t0, $0, else" + name);
                        this.instrs.add("if" + name + ": ");
                        i = k + 1;  // token[i] = "{" if block, token[i] = <statement> otherwise
                        if (tokenStream.get(i).charAt(0) == '{') {
                            // deal with what's in the block.
                            k = this.matchBracket(tokenStream, i, e);
                            this.domain += 1;
                            this.parse(tokenStream, i + 1, k);
                            this.domain -= 1;
                            i = k + 1;
                        }  else  {
                            // deal with one single sentence, find next semicolon
                            k = this.findWord(tokenStream, ";", k, e);
                            this.parse(tokenStream, i, k + 1);
                            i = k + 1;
                        }

                        this.instrs.add("    j endif" + name);
                        this.instrs.add("else" + name + ":");

                        if (i < e && tokenStream.get(i).compareTo("else") == 0) {
                            i = i + 1;
                            if (tokenStream.get(i).charAt(0) == '{') {
                                // else block
                                k = this.matchBracket(tokenStream, i, e);
                                this.domain += 1;
                                this.parse(tokenStream, i + 1, k);
                                this.domain -= 1;
                            }  else  {
                                k = this.findWord(tokenStream, ";", i, e);
                                this.parse(tokenStream, i + 1, k);
                            }
                            i = k + 1;
                        } 

                        // finally: if count increment
                        this.instrs.add("endif" + name + ":");
                        break;
                    }

                    // else  
                    case 6: {  // else
                        this.check(false, "else does not follow a \'if\'");
                    }
                    case 9: {  // printInt
                        this.check(tokenStream.get(i + 1).charAt(0) == '(', "printInt does not follow a ()");
                        j = this.findWord(tokenStream, ";", i, e);
                        int k = this.matchBracket(tokenStream, i + 1, j);
                        ParseTreeNode root = ParseTreeNode.genTree(tokenStream, i + 2, k);
                        root.genCode(this.instrs, this.manager);
                        this.instrs.add("    addi $sp, $sp, -4\n" + 
                                        "    sw $a0, 0($sp)\n    add $a0, $t0, $0\n" +
                                        "    addi $v0, $0, 1\nsyscall\n" + 
                                        "    lw $a0, 0($sp)\n    addi $sp, $sp, 4");
                        i = j + 1;
                        break;
                    }
                    case 11: {  // print str, will check undefined string literal
                        boolean found = false;
                        for (int d = this.domain; d >= 0; --d) {
                            String key = tokenStream.get(i + 2) + Integer.valueOf(d).toString();
                            if (this.strConsts.containsKey(key)) {
                                found = true;
                                this.instrs.add(
                                    "    la $a0, " + key + "\n" +
                                    "    addi $v0, $0, 4\n" +
                                    "syscall"
                                );
                                break;
                            }
                        }
                        if (!found) {
                            if (tokenStream.get(i + 2).charAt(0) == '\"') {
                                // anounymous
                                String key = "ano" + this.anonymous.toString();
                                this.strConsts.put(key, tokenStream.get(i + 2));
                                this.anonymous += 1;
                                this.instrs.add(
                                    "    la $a0, " + key + "\n" +
                                    "    addi $v0, $0, 4\n" +
                                    "syscall"
                                );
                            }  else  {
                                throw new RuntimeException("unable to recognize variable " + tokenStream.get(i + 2) + "?? Impossible!");
                            }
                        }
                        i = this.findWord(tokenStream, ";", i, e) + 1;
                        break;
                    }
                    case 10: {  // exit: terminate the program
                        this.instrs.add("    addi $v0, $0, 10");
                        this.instrs.add("syscall");
                        j = this.findWord(tokenStream, ";", i, e);
                        i = j + 1;
                        break;
                    }
                    case 1: {  // while!
                        final String name = this.loopCount.toString();
                        this.loopStack.push(this.loopCount);
                        this.loopCount += 1;
                        this.check(tokenStream.get(i + 1).charAt(0) == '(', "if statement does not follow a predicate");
                        int k = i + 1;   // if (<predicate>)
                        // match right bracket
                        k = this.matchBracket(tokenStream, i + 1, e);
                        // parse the predicate, result in $t0.
                        ParseTreeNode root = ParseTreeNode.genTree(tokenStream, i + 1, k + 1);
                        this.instrs.add("beginlp" + name + ": ");  // loop begin, check predicate
                        root.genCode(this.instrs, this.manager);
                        // the loop predicate does not hold at the beginning, goto end loop.
                        this.instrs.add("    beq $t0, $0, endlp" + name);
                        this.instrs.add("lp" + name + ": ");
                        i = k + 1;  // token[i] = "{" if block, token[i] = <statement> otherwise
                        if (tokenStream.get(i).charAt(0) == '{') {
                            // deal with what's in the block.
                            k = this.matchBracket(tokenStream, i, e);
                            this.domain += 1;
                            this.parse(tokenStream, i + 1, k);
                            this.domain -= 1;
                            i = k + 1;
                        }  else  {
                            // deal with one single sentence, find next semicolon
                            k = this.findWord(tokenStream, ";", k, e);
                            this.parse(tokenStream, i, k + 1);
                            i = k + 1;
                        }

                        // root.genCode(this.instrs, this.manager);
                        this.instrs.add("    j beginlp" + name);
                        this.instrs.add("endlp" + name + ":");
                        // discard the loop
                        this.loopStack.pop();
                        break;
                    }
                    case 7: {   // continue: jump to the start of the loop;
                        this.check(!this.loopStack.isEmpty(), "keyword continue used outside of loop");
                        Integer count = loopStack.pop();
                        this.instrs.add("    j beginlp" + count.toString());
                        loopStack.push(count);
                        i = this.findWord(tokenStream, ";", i, e) + 1;
                        break;
                    }
                    case 8: {  // break: jump to end of the loop;
                        this.check(!this.loopStack.isEmpty(), "keyword break used outside of loop");
                        Integer count = loopStack.pop();
                        this.instrs.add("    j endlp" + count.toString());
                        loopStack.push(count);
                        i = this.findWord(tokenStream, ";", i, e) + 1;
                        break;
                    }

                    case 12: {  // function! function funcname(<param list>) { <block> }
                        // parse the function name and deal with invariants
                        this.domain += 1;
                        String funcname = tokenStream.get(i + 1);
                        this.instrs.add(funcname + ":");
                        if (funcname.compareTo("main") != 0) {
                            this.manager.startFunc(this.instrs);
                        }
                        this.check(tokenStream.get(i + 2).charAt(0) == '(', "function " + funcname + " missing param list");

                        int k = this.matchBracket(tokenStream, i + 2, e);  // tokenStream[k] = ")"
                        i = i + 3;
                        // <param list> int var1 , string var2 , ...
                        Integer aReg = 0;
                        while (i < k) {
                            int tp = this.keywords.get(tokenStream.get(i));
                            String varname = tokenStream.get(i + 1);
                            Types.registers reg = null;
                            if (tp == 2) {  // integer type
                                this.manager.declare(varname, Types.supported.Integer, this.domain, this.instrs); 
                                reg = this.manager.require(varname, this.instrs);
                            }  else  {
                                if (tp == 4) {
                                    this.manager.declare(tokenStream.get(i + 1), Types.supported.Integer, this.domain, this.instrs); 
                                    reg = this.manager.require(varname, this.instrs);
                                } else {
                                    throw new RuntimeException("type " + tokenStream.get(i) + " cannot found?? Impossible!");
                                }
                            }
                            int r = 0;
                            for (; r < 8; ++r) {
                                if (Types.regnames[r] == reg) { break; }
                            }
                            this.instrs.add("    add $s" + Integer.valueOf(r).toString() + ", $a" + aReg.toString() + ", $0");
                            i += 3;
                            aReg += 1;
                        }

                        i = k + 1;
                        this.check(tokenStream.get(i).compareTo("{") == 0, "function body is not block");
                        j = this.matchBracket(tokenStream, i, e);
                        this.parse(tokenStream, i + 1, j);

                        if (funcname.compareTo("main") != 0) {
                            this.manager.endFunc(this.instrs);
                        }
                        this.domain -= 1;
                        i = j + 1;
                        break;
                    }
                
                    case 13: {  // return
                        j = this.findWord(tokenStream, ";", i, e);
                        ParseTreeNode root = ParseTreeNode.genTree(tokenStream, i + 1, j);
                        root.genCode(this.instrs, this.manager);
                        this.instrs.add("    add $a0, $t0, $0");
                        instrs.add(
                            this.manager.reset() + 
                            "    jr $ra"
                        );
                        i = j + 1;
                        break;
                    }

                    case 14: {  // do, linking to other function
                        i = this.call(tokenStream, i, e);
                        break;
                    }
                }
            }

        }
    } 

    /**
     * @param tokenStream the token stream generated by lexer.
     */
    public Parser(ArrayList<String> tokenStream) {
        instrs = new ArrayList<>();
        this.loopStack = new Stack<>();
        this.domain = 0;

        this.keywords = new HashMap<>();
        keywords.put("function", 0);
        keywords.put("while", 1);
        keywords.put("int", 2);
        keywords.put("array", 3);
        keywords.put("string", 4);
        keywords.put("if", 5);
        keywords.put("else", 6);
        keywords.put("continue", 7);
        keywords.put("break", 8);
        keywords.put("printInt", 9);
        keywords.put("exit", 10);
        keywords.put("printStr", 11);
        keywords.put("function", 12);
        keywords.put("return", 13);
        keywords.put("do", 14);

        this.manager = new RegisterManager();
        this.strConsts = new HashMap<>();
        this.loopCount = 0;
        this.ifCount = 0;

        this.parse(tokenStream, 0, tokenStream.size());
    }

    private void fillTuple(ArrayList<String> tokenStream, int b, int e) {
        int j;
        Integer count = 0;
        for (int i = b; i < e; ++i) {
            for (j = i + 1; j < e; ++j) {
                if (tokenStream.get(j).compareTo(",") == 0) { break; }
            }
            ParseTreeNode.genTree(tokenStream, i, j).genCode(this.instrs, this.manager);
            this.instrs.add("add $a" + count.toString() + ", $t0, $0");
            i = j + 1;
            count += 1;
        }
    }
    /**  
     * handle the other function, whose return value is in $t0(and restore all $a registers).
     * @param i: where the 'do' operator apprears(this method will check)
     * @return the beginning position of next expression
     */
    private int call(ArrayList<String> tokenStream, int i, int e) {
        int j = this.findWord(tokenStream, ";", i, e);
        if (tokenStream.get(i).compareTo("do") != 0) {
            throw new RuntimeException("Internal Error: calling Parser.call at the wrong position");
        }
        // syntax: (type var = ) do funcname(arg1, arg2, ...);
        //                       ^i ^i + 1  ^(i+2)
        String funcname = tokenStream.get(i + 1);
        this.instrs.add(
            "    addi $sp, $sp, -20\n" +
            "    sw $a0, 0($sp)\n" +
            "    sw $a1, 4($sp)\n" +
            "    sw $a2, 8($sp)\n" +
            "    sw $a3, 12($sp)\n" +
            "    sw $ra, 16($sp)" 
        );
        this.fillTuple(tokenStream, i + 3, this.matchBracket(tokenStream, i + 2, j));
        this.instrs.add(
            "    jal " + funcname + "\n" +
            "    add $t0, $a0, $0\n" +
            "    lw $a0, 0($sp)\n" +
            "    lw $a1, 4($sp)\n" +
            "    lw $a2, 8($sp)\n" +
            "    lw $a3, 12($sp)\n" +
            "    lw $ra, 16($sp)\n" + 
            "    addi $sp, $sp, 20"
        );
        return j + 1;
    }
};

/**
 * <h2>Special C Language Documentation </h2>
 * <h3>Types</h3>
 * <p> Currently only support <b>int</b>, <b>string</b>. </p>
 * <ul>
 *   <li>For int type, input can be drawn using <b>nextInt</b> keyword, output
 * can use inline <b>printInt</b> function(more on this later) </li>
 * <li>For string type, no way to get input at runtime, output 
 * can use inline <b>printStr</b> function(more on this later) </li>
 * </ul>
 * 
 * <h3>Branch control </h3>
 * <p> Support <b>if-else</b> statement. You can use only <b>if</b> statement almost 
 * like how you use it in C programming language.</p>
 * 
 * <h3>Function </h3>
 * <p> 
 * Support functions with parameters and return values. Each program begins at its
 * <b> main</b> function(no matter what its parameters is). <b>NOTE</b> that
 * to call another function, you have to use keyword <b>do</b>.</li>
 * </p>
 * <h3> Comments</h3>
 * <p> Currently only support C-style line comments //. Block comments is not supported yet. </p>
 * 
 * <h3> Examples </h3>
 * <ol>
 *   <li>A program that show how function works.
 *<blockquote>
 * <pre>{@code
 * int glb = 0;
 * 
 * function foo() {
 *     glb = 1;
 *     return glb;
 * }
 * 
 * function bar() {
 *     glb = 3;
 *     return glb;
 * }
 * 
 * function main() {
 *     int res = do bar();
 *     printInt(res);
 * 
 *     res = do foo();
 *     printInt(res);
 * 
 *     string msg = "Hello world!";
 *     printStr(msg);
 *     exit(0);
 * }
 * }</pre>
 *</blockquote>
 * The output is 31Hello world!
 *   </li>
 * <li> this shows how <b>nextInt</b> works.
 * <blockquote>
 * <pre>{@code
 * function min() {
 *     int love;
 * 
 *     string msg = "Bye!\n";
 *     string pmpt = "Do u love FDU?(0 no, 1 yes): ";
 *     printStr(pmpt);
 * 
 *     love = nextInt;
 * 
 *     while (1) {
 *         string msg = "You're not alone, that's how I feel too...\n";
 *         if (love) {
 *             string hate = "Oh, you love FDU!?!\n";
 *             printStr(hate);
 *         }  else  {
 *             string msg = "Well, you hate FDU 😇😇😇\n";
 *             printStr(msg);
 *         }
 * 
 *         printStr(msg);
 *         break;
 *     }
 * 
 *     printStr(msg);
 *     return love;
 * }
 * 
 * function main(int argc, string argv) {
 *     do min();
 * 
 *     exit(0);
 * }
 * }</pre>
 * </blockquote>
 * As noted before, you will need a <b>do</b> keyword to complete a function call.
 * </li> 
 * <li>Last example to help you understand special C language
 * <blockquote>
 * <pre>{@code
 * // this is a comment
 * function sumOf(int upper) {
 *     int i = 1;
 *     int res = 0;
 * 
 *     while (i < upper) {
 *         res  = res + i;
 *         i    = i + 1;
 *     }
 * 
 *     return res + upper;
 * }
 * 
 * function main(int argc, string argv) {
 *     int active = 1;
 *     
 *     string take = "upper = ";
 *     string tell = "result = ";
 *     string pmpt = "\nDo you want to continue? (1-Yes, 0-No): ";
 *     string clear = "\n";
 * 
 *     while (active) {
 *         printStr(take);
 *         int upper = nextInt;
 *         int res = do sumOf(upper);
 *         printStr(tell);
 *         printInt(res);
 * 
 *         printStr(pmpt);
 *         active = nextInt;
 *     }
 * 
 *     exit(0);
 * }
 * }</pre>
 * </blockquote>
 * </li>
 * </ol>
 */
public class Jcc {
    private static boolean isDigit(char ch) {
        return (ch >= '0' && ch <= '9') | ch == '.';
    }
    private static boolean isAlpha(char ch) {
        return (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z');
    }
    private static boolean isIdentifier(char ch) {
        return ch == '_' || isAlpha(ch) || isDigit(ch);
    } 

    public static void tokenize(String line, ArrayList<String> tokenStream) {
            final int len = line.length();

            for (int i = 0; i < len; ++i) {
                final char ch = line.charAt(i);
                if (isIdentifier(ch)) {
                    int j = i + 1;
                    while (j < len && isIdentifier(line.charAt(j))) {
                        ++j;
                    }
                    tokenStream.add(line.substring(i, j));
                    i = j - 1;
                    continue;
                }
                if (isDigit(ch)) {
                    int j = i + 1;
                    while (j < len && isDigit(line.charAt(j))) {
                        ++j;
                    }
                    tokenStream.add(line.substring(i, j));
                    i = j - 1;
                    continue;
                }

                // next character.
                final char nextCh = i + 1 < len ? line.charAt(i + 1) : ' ';
                switch (ch) {
                    case '/': {
                        if (nextCh == '/') {
                            // comments, ignore what's in the back.
                            i = len;
                        }  else  {
                            if (nextCh == '=') {
                                i += 1;
                                // division by
                                tokenStream.add("/=");
                            }  else  {
                                // division
                                tokenStream.add("/");
                            }
                        }
                        break;
                    }

                    case '*': {
                        if (nextCh == '=') {
                            // mult by
                            tokenStream.add("*=");
                            i += 1;
                        }  else  {
                            // mult
                            tokenStream.add("*");
                        }
                        break;
                    }
                    case '+': {
                        if (nextCh == '=') {
                            // add by
                            tokenStream.add("+=");
                            i += 1;
                        }  else  {
                            // add
                            tokenStream.add("+");
                        }
                        break;
                    }
                    case '-': {
                        if (nextCh == '=') {
                            // add by
                            tokenStream.add("-=");
                            i += 1;
                        }  else  {
                            // add 
                            tokenStream.add("-");
                        }
                        break;
                    }

                    case '>': {
                        if (nextCh == '=') {
                            // equal or greater than.
                            i += 1;
                            tokenStream.add(">=");
                        }  else  {
                            // greater than
                            tokenStream.add(">");
                        }
                        break;
                    }
                    case '<': {
                        if (nextCh == '=') {
                            // equal or less than.
                            i += 1;
                            tokenStream.add("<=");
                        }  else  {
                            // less than
                            tokenStream.add("<");
                        }
                        break;
                    }
                    case '&': {
                        if (nextCh == '&') {
                            i += 1;
                            tokenStream.add("&&");
                        }  else  {
                            tokenStream.add("&");
                        }
                        break;
                    }
                    case '|': {
                        if (nextCh == '|') {
                            i += 1;
                            tokenStream.add("||");
                        }  else  {
                            tokenStream.add("|");
                        }
                        break;
                    }

                    case '\"': {
                        int j = i + 1;
                        while (line.charAt(j) != '\"') { 
                            ++j; 
                            if (j >= len) {
                                throw new RuntimeException("string literal cross lines?? Impossible!");
                            }
                        }
                        tokenStream.add(line.substring(i, j + 1));
                        i = j;
                        break;
                    }

                    case ';': case '{': case '}': case '(': case ')': case '[': case ']': case '=': 
                    case '%': case ',': case '!': {
                        // include as-is
                        tokenStream.add(line.substring(i, 1 + i));
                        break;
                    }

                    // ignore any other characters.
                    default: break;
                }
            }
    }

    /**
     * @return the generated token stream(as <pre> java.util.ArrayList</pre>).
     */
    public static ArrayList<String> token(String filename) {
        Scanner fin;
        try {
            fin = new Scanner(new BufferedReader(new FileReader(filename)));
        } catch (FileNotFoundException e) {
            throw new RuntimeException(filename + " not found?? Impossible!");
        }

        /** Stage 1: lexical analysis */
        ArrayList<String> tokenStream = new ArrayList<>();

        // do not stop until end of file.
        while (fin.hasNext()) {
            // do not stop until you meet an semicolon ';'.
            String line = fin.nextLine();
            tokenize(line, tokenStream);
        }

        fin.close();

        return tokenStream;
    }

    /** Unit test for Parse Tree */
    public static void runParseTreeTest() {
        String expr;
        Scanner cin = new Scanner(System.in);

        System.out.print(">>> ");
        while (cin.hasNext()) {
            expr = cin.nextLine();
            ArrayList<String> tokens = new ArrayList<>();
            tokenize(expr, tokens);
            ParseTreeNode root = ParseTreeNode.genTree(tokens, 0, tokens.size());
            ArrayList<String> instrs = new ArrayList<>();
            root.genCode(instrs, null);

            for (final String instr : instrs) {
                System.out.println(instr);
            }

            System.out.print(">>> ");
        }

        cin.close();
    }

    /** Unit test for Parse Tree */
    public static void runParserTest() {
        String expr = "";
        Scanner cin = new Scanner(System.in);
        // ArrayList<String> instrs = new ArrayList<>();

        // System.out.print(">>> ");
        while (cin.hasNext()) {
            String line = cin.nextLine();
            expr += line;
            expr += "\n";

            // System.out.print(">>> ");
        }

        cin.close();
        ArrayList<String> tokens = new ArrayList<>();
        tokenize(expr, tokens);
        Parser parser = new Parser(tokens);

        for (final String instr : parser.collectStatic()) {
            System.out.println(instr);
        }
        for (final String instr : parser.instrs) {
            System.out.println(instr);
        }
    }

    public static void exec(String[] argv) throws IOException {
        if (argv.length == 0) {
            System.out.println("Usage: ");
            System.out.println("`java Jcc filename.c` will compile a single c file, output is in a.asm");
            System.out.println("`java Jcc filename.c result` will put output in the file named result");
            return;
        }
        if (argv.length == 1) {
            ArrayList<String> tokens = token(argv[0]);
            PrintWriter writer = (new PrintWriter("a.asm"));
            Parser parser = new Parser(tokens);

            for (final String data : parser.collectStatic()) {
                writer.println(data);
            }
            for (final String instr : parser.instrs) {
                writer.println(instr);
            }

            writer.close();
            return;
        }
        if (argv.length == 2) {
            ArrayList<String> tokens = token(argv[0]);
            PrintWriter writer = (new PrintWriter(argv[1]));
            Parser parser = new Parser(tokens);

            for (final String data : parser.collectStatic()) {
                writer.println(data);
            }
            for (final String instr : parser.instrs) {
                writer.println(instr);
            }

            writer.close();
            return;
        }
        return;
    }

    public static void main(String[] argv) throws IOException {
        exec(argv);
    }
}
