# Copyright (c) 2021, Nicolás Ruiz Requejo
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


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
