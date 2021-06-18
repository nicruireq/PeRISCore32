
####################################
#### Microcode generator params ####
####################################

GEN_TOOL = python3 gen_microcode.py
# --lines and --begin parameters for each
# image memory that it's being generated
MAIN_CONTROL_L			= 6
MAIN_CONTROL_B			= 1
SPECIAL_CONTROL_L		= 6
SPECIAL_CONTROL_B		= 2
ALU_NOT_CLASS_CONTROL_L = 4
ALU_NOT_CLASS_CONTROL_B = 2

###########################
####       Rules       ####
###########################

.PHONY: clean microcode

all: microcode

# Rules to generate microcode memory images
microcode: control_unit.dat alu_control_special.dat \
		   alu_control_not_class.dat

control_unit.dat: control_unit.csv
	$(GEN_TOOL) -l $(MAIN_CONTROL_L) -b $(MAIN_CONTROL_B) \
	$^ $@

alu_control_special.dat: gen_alu_control_SPECIAL.csv
	$(GEN_TOOL) -l $(SPECIAL_CONTROL_L) -b $(SPECIAL_CONTROL_B) \
	$^ $@

alu_control_not_class.dat: gen_alu_control_not_class.csv
	$(GEN_TOOL) -l $(ALU_NOT_CLASS_CONTROL_L) -b \
	$(ALU_NOT_CLASS_CONTROL_B) $^ $@

clean:
	rm -f *.dat
