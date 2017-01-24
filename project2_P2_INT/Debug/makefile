################################################################################
# Automatically-generated file. Do not edit!
################################################################################

SHELL = cmd.exe

CG_TOOL_ROOT := c:/ti/ccsv6/tools/compiler/gcc-arm-none-eabi-4_7-2013q3

ORDERED_OBJS += \
"./project1_P2_delay.o" \
"./project2_P2_blinkLoop.o" \
"./project2_P2_intDirector.o" \
"./project2_P2_main.o" \
"./project2_P2_toggleLED.o" \
"./startup_ARMCA8.o" \
-Wl,-T"../AM335x.lds" \
$(GEN_CMDS__FLAG) \
-Wl,--start-group \
-l"c" \
-l"gcc" \
-l"nosys" \
-Wl,--end-group \

-include ../makefile.init

RM := DEL /F
RMDIR := RMDIR /S/Q

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir_vars.mk
-include subdir_rules.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_DEPS)),)
-include $(S_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(S62_DEPS)),)
-include $(S62_DEPS)
endif
ifneq ($(strip $(C64_DEPS)),)
-include $(C64_DEPS)
endif
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(S55_DEPS)),)
-include $(S55_DEPS)
endif
ifneq ($(strip $(C67_DEPS)),)
-include $(C67_DEPS)
endif
ifneq ($(strip $(C??_DEPS)),)
-include $(C??_DEPS)
endif
ifneq ($(strip $(CLA_DEPS)),)
-include $(CLA_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(S??_DEPS)),)
-include $(S??_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(C62_DEPS)),)
-include $(C62_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(C++_DEPS)),)
-include $(C++_DEPS)
endif
ifneq ($(strip $(ASM_UPPER_DEPS)),)
-include $(ASM_UPPER_DEPS)
endif
ifneq ($(strip $(K_DEPS)),)
-include $(K_DEPS)
endif
ifneq ($(strip $(C43_DEPS)),)
-include $(C43_DEPS)
endif
ifneq ($(strip $(S67_DEPS)),)
-include $(S67_DEPS)
endif
ifneq ($(strip $(SA_DEPS)),)
-include $(SA_DEPS)
endif
ifneq ($(strip $(S43_DEPS)),)
-include $(S43_DEPS)
endif
ifneq ($(strip $(OPT_DEPS)),)
-include $(OPT_DEPS)
endif
ifneq ($(strip $(S64_DEPS)),)
-include $(S64_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(C55_DEPS)),)
-include $(C55_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXE_OUTPUTS += \
project2_P2_INT.out \

EXE_OUTPUTS__QUOTED += \
"project2_P2_INT.out" \

BIN_OUTPUTS += \
project2_P2_INT.hex \

BIN_OUTPUTS__QUOTED += \
"project2_P2_INT.hex" \


# All Target
all: project2_P2_INT.out

# Tool invocations
project2_P2_INT.out: $(OBJS) $(LDS_SRCS) $(GEN_CMDS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU Linker'
	"c:/ti/ccsv6/tools/compiler/gcc-arm-none-eabi-4_7-2013q3/bin/arm-none-eabi-gcc.exe" -Dam3359 -Xassembler -a=project2_P2_INT.lst -g -gstrict-dwarf -Wall -Wl,-Map,"project2_P2_INT.map" -nostartfiles -Wl,--defsym,STACKSIZE=0x18000 -Wl,--defsym,HEAPSIZE=0x400 -o"project2_P2_INT.out" $(ORDERED_OBJS)
	@echo 'Finished building target: $@'
	@echo ' '

project2_P2_INT.hex: $(EXE_OUTPUTS)
	@echo 'Invoking: GNU Objcopy Utility'
	"c:/ti/ccsv6/tools/compiler/gcc-arm-none-eabi-4_7-2013q3/bin/arm-none-eabi-objcopy.exe"  $(EXE_OUTPUTS__QUOTED) "project2_P2_INT.hex"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXE_OUTPUTS__QUOTED)$(BIN_OUTPUTS__QUOTED)
	-$(RM) "startup_ARMCA8.d" 
	-$(RM) "project1_P2_delay.d" "project2_P2_blinkLoop.d" "project2_P2_intDirector.d" "project2_P2_main.d" "project2_P2_toggleLED.d" 
	-$(RM) "project1_P2_delay.o" "project2_P2_blinkLoop.o" "project2_P2_intDirector.o" "project2_P2_main.o" "project2_P2_toggleLED.o" "startup_ARMCA8.o" 
	-@echo 'Finished clean'
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets

