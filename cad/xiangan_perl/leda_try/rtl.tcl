rule_deselect -all
rule_select -rule DCVER_192 -ruleset RTL -policy DC
rule_select -rule DCVHDL_165 -ruleset RTL -policy DC
rule_select -rule DFT_021 -ruleset INFORMATIONAL -policy DFT
rule_select -rule NTL_STR47
rule_select -rule DFT_022 -ruleset INFORMATIONAL -policy DFT
rule_select -rule FM_2_10 -ruleset SIMULATION_MISMATCH -policy FORMALITY  
rule_select -rule FM_2_12 -ruleset SIMULATION_MISMATCH -policy FORMALITY
rule_select -rule FM_2_13 -ruleset SIMULATION_MISMATCH -policy FORMALITY
rule_select -rule FM_2_17 -ruleset SIMULATION_MISMATCH -policy FORMALITY
rule_select -rule FM_2_18 -ruleset SIMULATION_MISMATCH -policy FORMALITY
rule_select -rule FM_2_4 -ruleset SIMULATION_MISMATCH -policy FORMALITY
rule_select -rule FM_2_7 -ruleset SIMULATION_MISMATCH -policy FORMALITY
rule_select -rule FM_2_9 -ruleset SIMULATION_MISMATCH -policy FORMALITY
rule_select -rule B_1204 -ruleset CLOCKS -policy LEDA   
rule_select -rule B_1202 -ruleset CLOCKS -policy LEDA
rule_select -rule NTL_STR61
rule_select -rule NTL_CLK04
rule_select -rule NTL_CLK09
rule_select -rule B_3010 -ruleset DATA_TYPES -policy LEDA
rule_select -rule B_1002 -ruleset DESIGN_STRUCTURE -policy LEDA
rule_select -rule B_1011 -ruleset DESIGN_STRUCTURE -policy LEDA
rule_select -rule NTL_STR33
rule_select -rule NTL_STR29
rule_select -rule NTL_STR72
rule_select -rule NTL_DFT38
rule_select -rule B_3203 -ruleset EXPRESSIONS -policy LEDA 
rule_select -rule B_3208 -ruleset EXPRESSIONS -policy LEDA
rule_select -rule B_3209 -ruleset EXPRESSIONS -policy LEDA
rule_select -rule B_2001 -ruleset RTL_SYNTHESIS -policy LEDA
rule_select -rule B_2011 -ruleset RTL_SYNTHESIS -policy LEDA
rule_select -rule B_3602 -ruleset STATE_MACHINES -policy LEDA
rule_select -rule B_3604 -ruleset STATE_MACHINES -policy LEDA
rule_select -rule B_3605_A -ruleset STATE_MACHINES -policy LEDA
rule_select -rule B_3605_B -ruleset STATE_MACHINES -policy LEDA

rule_select -rule B_3408 -ruleset STATEMENTS -policy LEDA 
rule_select -rule B_3409 -ruleset STATEMENTS -policy LEDA
rule_select -rule B_3410 -ruleset STATEMENTS -policy LEDA
rule_select -rule B_3416 -ruleset STATEMENTS -policy LEDA
rule_select -rule B_3417 -ruleset STATEMENTS -policy LEDA
rule_select -rule B_3419 -ruleset STATEMENTS -policy LEDA
rule_select -rule R_521_10 -ruleset BASIC_CODING_PRACTICES -policy RMM_RTL_CODING_GUIDELINES
rule_select -rule R_529_1 -ruleset BASIC_CODING_PRACTICES -policy RMM_RTL_CODING_GUIDELINES
rule_select -rule NTL_RST06
rule_select -rule G_551_1_8 -ruleset CODING_FOR_SYNTHESIS -policy RMM_RTL_CODING_GUIDELINES
rule_select -rule W154 -ruleset CHECKER_ERROR -policy VERILINT
rule_select -rule VER_2_1_1_2 -ruleset S_2_1_COMBINATIONAL_LOGIC -policy VER_STARC_DSG   
rule_select -rule VER_2_1_3_1 -ruleset S_2_1_COMBINATIONAL_LOGIC -policy VER_STARC_DSG
rule_select -rule VER_2_1_3_2 -ruleset S_2_1_COMBINATIONAL_LOGIC -policy VER_STARC_DSG
rule_select -rule VER_2_8_1_6 -ruleset S_2_8_COMBINATIONAL_LOGIC -policy VER_STARC_DSG
rule_select -rule VER_2_10_1_4 -ruleset S_2_10_COMBINATIONAL_LOGIC -policy VER_STARC_DSG
rule_select -rule VER_2_10_3_1 -ruleset S_2_10_COMBINATIONAL_LOGIC -policy VER_STARC_DSG
rule_select -rule VER_2_10_3_2 -ruleset S_2_10_COMBINATIONAL_LOGIC -policy VER_STARC_DSG
rule_select -rule VER_2_1_1_2 -ruleset S_2_1_COMBINATIONAL_LOGIC -policy VER_STARC_DSG
rule_select -rule VER_2_1_1_2 -ruleset S_2_1_COMBINATIONAL_LOGIC -policy VER_STARC_DSG
rule_set_severity -rule verilog.LEDA.DESIGN_STRUCTURE.B_1001 -severity ERROR
rule_set_severity -rule verilog.LEDA.EXPRESSIONS.B_3208 -severity ERROR





