
# Name: Makefile

PROJECT_NAME         := blink_transmitter
MCU                  := attiny84
F_CPU                := 20000000UL
EXTRA_INC_DIRS       := .

C_SRC                := $(PROJECT_NAME).c
A_SRC                :=
CPP_SRC              := $(PROJECT_NAME).cpp

EXTRA_C_DEFS         :=
EXTRA_C_UNDEFS       :=
EXTRA_C_OPTIONS      := -Wstrict-prototypes 
EXTRA_CPP_OPTIONS    :=

OBJ_DIR              := Builds
OBJ                  := $(addprefix $(OBJ_DIR)/,$(C_SRC:.c=.o)) $(addprefix $(OBJ_DIR)/,$(CPP_SRC:.cpp=.o)) $(addprefix $(OBJ_DIR)/,$(A_SRC:.S=.o))
LST                  := $(addprefix $(OBJ_DIR)/,$(C_SRC:.c=.lst)) $(addprefix $(OBJ_DIR)/,$(CPP_SRC:.cpp=.lst)) $(addprefix $(OBJ_DIR)/,$(A_SRC:.S=.lst))
GEN_DEP_FLAGS        := -M
DEPS_DIR             := $(OBJ_DIR)/.dep
DEPS                 := $(C_SRC:%.c=$(DEPS_DIR)/%.d)

FORMAT               := ihex
OPTIMIZATION         := s
C_STANDARD           := -std=gnu99
DEBUG                := stabs
REMOVE               := rm -f

C_FLAGS              := -g$(DEBUG)
C_FLAGS              += $(foreach ICDEF,$(EXTRA_C_DEFS),-D"$(ICDEF)")
C_FLAGS              += $(foreach ICUNDEF,$(EXTRA_C_UNDEFS),-U$(ICUNDEF))
C_FLAGS              += -O$(OPTIMIZATION)
C_FLAGS              += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
C_FLAGS              += -Wall
C_FLAGS              += -Wa,-adhlns=$(LST)
C_FLAGS              += $(patsubst %,-I%,$(EXTRA_INC_DIRS))
C_FLAGS              += $(C_STANDARD)
C_FLAGS              += -gstrict-dwarf
C_FLAGS              += $(EXTRA_C_OPTIONS)
C_FLAGS              += -DF_CPU=$(F_CPU)
C_FLAGS              += -fno-exceptions
C_FLAGS              += -fdata-sections -ffunction-sections
C_FLAGS              += -MMD
C_FLAGS              += -mmcu=$(MCU)
C_FLAGS              += -I$(EXTRA_INC_DIRS)

CPP_FLAGS            := -g$(DEBUG)
CPP_FLAGS            += $(foreach ICDEF,$(EXTRA_C_DEFS),-D"$(ICDEF)")
CPP_FLAGS            += $(foreach ICUNDEF,$(EXTRA_C_UNDEFS),-U$(ICUNDEF))
CPP_FLAGS            += -O$(OPTIMIZATION)
CPP_FLAGS            += -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
CPP_FLAGS            += -Wall
CPP_FLAGS            += -Wa,-adhlns=$(LST)
CPP_FLAGS            += $(patsubst %,-I%,$(EXTRA_INC_DIRS))
CPP_FLAGS            += $(EXTRA_CPP_OPTIONS)
CPP_FLAGS            += -DF_CPU=$(F_CPU)
CPP_FLAGS            += -fno-exceptions -fno-threadsafe-statics
CPP_FLAGS            += -fdata-sections -ffunction-sections
CPP_FLAGS            += -MMD
CPP_FLAGS            += -mmcu=$(MCU)
CPP_FLAGS            += -I$(EXTRA_INC_DIRS)

AS_FLAGS             := -Wa,-adhlns=$(LST),-gstabs,--listing-cont-lines=100
AS_FLAGS             += -DF_CPU=$(F_CPU)
AS_FLAGS             += -mmcu=$(MCU)
AS_FLAGS             += -I$(EXTRA_INC_DIRS)
AS_FLAGS             += -x assembler-with-cpp

LD_FLAGS             := -Wl,--gc-sections
LDFLAGS              += $(PRINTF_LIB) $(SCANF_LIB) $(MATH_LIB)

PRINTF_LIB_MIN       := -Wl,-u,vfprintf -lprintf_min
PRINTF_LIB_FLOAT     := -Wl,-u,vfprintf -lprintf_flt
PRINTF_LIB           :=
SCANF_LIB_MIN        := -Wl,-u,vfscanf -lscanf_min
SCANF_LIB_FLOAT      := -Wl,-u,vfscanf -lscanf_flt
SCANF_LIB            :=
MATH_LIB             := -lm

# http://www.engbedded.com/fusecalc
# Ext. Crystal Osc.; Frequency 8.0-    MHz; Start-up time PWRDWN/RESET: 16K CK/14 CK + 65 ms;  [CKSEL=1111 SUT=11]
# FUSES        = -U lfuse:w:0xff:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m

-include $(DEPS)

$(DEPSDIR):
	mkdir -p $(DEPSDIR)

AVRDUDE_PROGRAMMER   := usbasp
AVRDUDE_PORT         := usb
AVRDUDE_CONFIG_FILE  := /Applications/Arduino.app/Contents/Java/hardware/tools/avr/etc/avrdude.conf

AVRDUDE_FLAGS        := -c $(AVRDUDE_PROGRAMMER)
AVRDUDE_FLAGS        += -p $(MCU)
AVRDUDE_FLAGS        += -P $(AVRDUDE_PORT)
AVRDUDE_FLAGS        += -C $(AVRDUDE_CONFIG_FILE)
AVRDUDE_FLAGS        += -v -v
# AVRDUDE_WRITE_FLASH  := -U flash:w:$(PROJECT_NAME).hex:i
# AVRDUDE_WRITE_EEPROM := -U eeprom:w:$(PROJECT_NAME).eep

AVRDUDE              := avrdude

GCC                  := avr-gcc
GPP                  := avr-g++
OBJ_COPY             := avr-objcopy
OBJ_DUMP             := avr-objdump
SIZE                 := avr-size
NM                   := avr-nm

HEX_SIZE             := $(SIZE) --target=$(FORMAT) $(OBJ_DIR)/$(PROJECT_NAME).hex
ELF_SIZE             := $(SIZE) --format=avr --mcu=$(MCU) $(OBJ_DIR)/$(PROJECT_NAME).elf

COMPILE              := $(GCC) $(C_FLAGS) $(CPP_FLAGS)

# Define Messages
# English
# MSG_ERRORS_NONE = Errors: none
# MSG_BEGIN = -------- begin --------
# MSG_END = --------  end  --------
# MSG_SIZE_BEFORE = Size before: 
# MSG_SIZE_AFTER = Size after:
# MSG_COFF = Converting to AVR COFF:
# MSG_EXTENDED_COFF = Converting to AVR Extended COFF:
# MSG_FLASH = Creating load file for Flash:
# MSG_EEPROM = Creating load file for EEPROM:
# MSG_EXTENDED_LISTING = Creating Extended Listing:
# MSG_SYMBOL_TABLE = Creating Symbol Table:
# MSG_LINKING = Linking:
# MSG_COMPILING = Compiling:
# MSG_ASSEMBLING = Assembling:
# MSG_CLEANING = Cleaning project:

all: begin clean build end #sizebefore sizeafter

build: $(OBJ_DIR) elf hex eep lss sym

elf: $(OBJ_DIR)/$(PROJECT_NAME).elf
hex: $(OBJ_DIR)/$(PROJECT_NAME).hex
eep: $(OBJ_DIR)/$(PROJECT_NAME).eep
lss: $(OBJ_DIR)/$(PROJECT_NAME).lss 
sym: $(OBJ_DIR)/$(PROJECT_NAME).sym

$(OBJ_DIR):
	@mkdir -p $@

begin:
# @echo
# @echo $(MSG_BEGIN)

end:
# @echo $(MSG_END)
# @echo

# sizebefore:
# 	@if test -f $(OBJ_DIR)/$(PROJECT_NAME).elf; then echo; echo $(MSG_SIZE_BEFORE); $(ELF_SIZE); \
# 	2>/dev/null; echo; fi

# sizeafter:
# 	@if test -f $(OBJ_DIR)/$(PROJECT_NAME).elf; then echo; echo $(MSG_SIZE_AFTER); $(ELF_SIZE); \
# 	2>/dev/null; echo; fi
 
flash: $(OBJ_DIR)/$(PROJECT_NAME).hex # $(OBJ_DIR)/$(PROJECT_NAME).eep
	$(AVRDUDE) $(AVRDUDE_FLAGS) -U flash:w:$<:i # $(AVRDUDE_WRITE_FLASH) # $(AVRDUDE_WRITE_EEPROM)
	$(HEX_SIZE)
	$(ELF_SIZE)

# Generate avr-gdb config/init file which does the following:
#     define the reset signal, load the target file, connect to target, and set 
#     a breakpoint at main().
# gdb-config: 
# 	@$(REMOVE) $(GDBINIT_FILE)
# 	@echo define reset >> $(GDBINIT_FILE)
# 	@echo SIGNAL SIGHUP >> $(GDBINIT_FILE)
# 	@echo end >> $(GDBINIT_FILE)
# 	@echo file $(OBJ_DIR)/$(PROJECT_NAME).elf >> $(GDBINIT_FILE)
# 	@echo target remote $(DEBUG_HOST):$(DEBUG_PORT)  >> $(GDBINIT_FILE)
# ifeq ($(DEBUG_BACKEND),simulavr)
# 	@echo load  >> $(GDBINIT_FILE)
# endif	
# 	@echo break main >> $(GDBINIT_FILE)

# debug: gdb-config $(OBJ_DIR)/$(PROJECT_NAME).elf
# ifeq ($(DEBUG_BACKEND), avarice)
# 	@echo Starting AVaRICE - Press enter when "waiting to connect" message displays.
# 	@$(WINSHELL) /c start avarice --jtag $(JTAG_DEV) --erase --program --file \
# 	$(OBJ_DIR)/$(PROJECT_NAME).elf $(DEBUG_HOST):$(DEBUG_PORT)
# 	@$(WINSHELL) /c pause
# else
# 	@$(WINSHELL) /c start simulavr --gdbserver --device $(MCU) --clock-freq \
# 	$(DEBUG_MFREQ) --port $(DEBUG_PORT)
# endif
# 	@$(WINSHELL) /c start avr-$(DEBUG_UI) --command=$(GDBINIT_FILE)

# Convert ELF to COFF for use in debugging / simulating in AVR Studio or VMLAB.
# COFFCONVERT=$(OBJ_COPY) --debugging \
# --change-section-address .data-0x800000 \
# --change-section-address .bss-0x800000 \
# --change-section-address .noinit-0x800000 \
# --change-section-address .eeprom-0x810000 

# coff: $(OBJ_DIR)/$(PROJECT_NAME).elf
# 	# @echo
# 	# @echo $(MSG_COFF) $(OBJ_DIR)/$(PROJECT_NAME).cof
# 	$(COFFCONVERT) -O coff-avr $< $(OBJ_DIR)/$(PROJECT_NAME).cof


# extcoff: $(OBJ_DIR)/$(PROJECT_NAME).elf
# 	# @echo
# 	# @echo $(MSG_EXTENDED_COFF) $(OBJ_DIR)/$(PROJECT_NAME).cof
# 	$(COFFCONVERT) -O coff-ext-avr $< $(OBJ_DIR)/$(PROJECT_NAME).cof

$(OBJ_DIR)/%.hex: $(OBJ_DIR)/%.elf
# @echo
# @echo $(MSG_FLASH) $@
	$(OBJ_COPY) -j .text -j .data -O $(FORMAT) -R .eeprom $< $@

$(OBJ_DIR)/%.eep: $(OBJ_DIR)/%.elf
# @echo
# @echo $(MSG_EEPROM) $@
	-$(OBJ_COPY) -j .eeprom --set-section-flags .eeprom=alloc,load \
	--change-section-lma .eeprom=0 -O $(FORMAT) $< $@

# Create extended listing file from ELF output file.
$(OBJ_DIR)/%.lss: $(OBJ_DIR)/%.elf
# @echo
# @echo $(MSG_EXTENDED_LISTING) $@
	$(OBJ_DUMP) -h -S $< > $@

# Create a symbol table from ELF output file.
$(OBJ_DIR)/%.sym: $(OBJ_DIR)/%.elf
# @echo
# @echo $(MSG_SYMBOL_TABLE) $@
	$(NM) -n $< > $@

# Link: create ELF output file from object files.
.SECONDARY : $(OBJ_DIR)/$(PROJECT_NAME).elf
.PRECIOUS : $(OBJ)

$(OBJ_DIR)/%.elf: $(OBJ)
# @echo
# @echo $(MSG_LINKING) $@
	$(GCC) $(C_FLAGS) $^ --output $@ $(LDFLAGS)

$(OBJ_DIR)/%.o : %.c
# @echo
# @echo $(MSG_COMPILING) $<
	$(GCC) -c $(C_FLAGS) "$(abspath $<)" -o $@

$(OBJ_DIR)/%.o : %.cpp
	$(GPP) -c $(CPP_FLAGS) "$(abspath $<)" -o $@ 

$(OBJ_DIR)/%.S : %.c
	$(GCC) -S $(C_FLAGS) $< -o $@

$(OBJ_DIR)/%.S : %.cpp
	$(GPP) -S $(CPP_FLAGS) $< -o $@

$(OBJ_DIR)/%.o : %.S
# @echo
# @echo $(MSG_ASSEMBLING) $<
	$(GCC) -c $(AS_FLAGS) $< -o $@

$(OBJ_DIR)/%.i : %.c
	$(GCC) -E -mmcu=$(MCU) -I. $(C_FLAGS) $< -o $@

$(OBJ_DIR)/%.i : %.cpp
	$(GPP) -E -mmcu=$(MCU) -I. $(CPP_FLAGS) $< -o $@

install: flash

disasm:	$(FILENPROJECT_NAMEAME).elf
	$(OBJ_DUMP) -d $(PROJECT_NAME).elf

prep:
	$(GCC) $(C_FLAGS) -E $(PROJECT_NAME).c

size:
	$(HEX_SIZE)
	$(ELF_SIZE)

clean: begin clean_list end

clean_list :
# @echo
# @echo $(MSG_CLEANING)
	$(REMOVE) $(OBJ_DIR)/$(PROJECT_NAME).hex
	$(REMOVE) $(OBJ_DIR)/$(PROJECT_NAME).eep
	$(REMOVE) $(OBJ_DIR)/$(PROJECT_NAME).cof
	$(REMOVE) $(OBJ_DIR)/$(PROJECT_NAME).elf
	$(REMOVE) $(OBJ_DIR)/$(PROJECT_NAME).map
	$(REMOVE) $(OBJ_DIR)/$(PROJECT_NAME).sym
	$(REMOVE) $(OBJ_DIR)/$(PROJECT_NAME).lss
	$(REMOVE) $(OBJ)
	$(REMOVE) $(LST)
	$(REMOVE) $(OBJ_DIR)/$(C_SRC:.c=.s)
	$(REMOVE) $(OBJ_DIR)/$(C_SRC:.c=.d)
	$(REMOVE) $(OBJ_DIR)/.dep/*

.PHONY : all begin finish end sizebefore sizeafter build elf hex eep lss sym clean clean_list flash install disasm prep size #coff extcoff debug gdb-config
