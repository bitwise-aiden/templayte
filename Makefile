HEAP_SIZE      = 8388208
STACK_SIZE     = 61800

PRODUCT = Templayte.pdx
PDCFLAGS=

SDK = ${PLAYDATE_SDK_PATH}
ifeq ($(SDK),)
	SDK = $(shell egrep '^\s*SDKRoot' ~/.Playdate/config | head -n 1 | cut -c9-)
endif
ifeq ($(SDK),)
	$(error SDK path not found; set ENV value PLAYDATE_SDK_PATH)
endif

VPATH += src
VPATH += $(SDK)/C_API/buildsupport

SRC = $(wildcard src/*.c)

GCC = /usr/local/bin/arm-none-eabi-gcc
CC  = $(GCC) -g3

OPT = -O2 -falign-functions=16 -fomit-frame-pointer

LDSCRIPT = $(patsubst ~%,$(HOME)%,$(SDK)/C_API/buildsupport/link_map.ld)

INCDIR = $(patsubst %,-I %,. $(SDK)/C_API)
OBJDIR = build
DEPDIR = $(OBJDIR)/dep
TMPDIR = temp
ASTDIR = assets

SRC += $(SDK)/C_API/buildsupport/setup.c

OBJS = $(addprefix $(OBJDIR)/, $(SRC:.c=.o))

MCFLAGS  = -mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-sp-d16 -D__FPU_USED=1
ASFLAGS  = $(MCFLAGS) $(OPT) -g3 -gdwarf-2 -Wa,-amhls=$(<:.s=.lst) -D__HEAP_SIZE=$(HEAP_SIZE) -D__STACK_SIZE=$(STACK_SIZE)
CPFLAGS  = $(MCFLAGS) $(OPT) -gdwarf-2 -Wall -Wno-unused -Wstrict-prototypes -Wno-unknown-pragmas -fverbose-asm -Wdouble-promotion -mword-relocations -fno-common
CPFLAGS += -ffunction-sections -fdata-sections -Wa,-ahlms=$(OBJDIR)/$(notdir $(<:.c=.lst)) -DTARGET_PLAYDATE=1 -DTARGET_EXTENSION=1
CPFLAGS += -MD -MP -MF $(DEPDIR)/$(@F).d
LDFLAGS  = -nostartfiles $(MCFLAGS) -T$(LDSCRIPT) -Wl,-Map=$(OBJDIR)/pdex.map,--cref,--gc-sections,--no-warn-mismatch,--emit-relocs

all: device_bin simulator_bin assets
	$(SDK)/bin/pdc $(PDCFLAGS) $(TMPDIR) $(PRODUCT)
	-rm -rf $(OBJDIR) $(TMPDIR)

debug: OPT = -O0
debug: all

MKBUILDDIRS:
	mkdir -p $(OBJDIR) $(DEPDIR) $(TMPDIR)

MKASSETSDIR:
	mkdir -p $(ASTDIR)

device_bin: $(OBJDIR)/pdex.elf
	cp $(OBJDIR)/pdex.elf $(TMPDIR)

simulator_bin: $(OBJDIR)/pdex.dylib
	cp $(OBJDIR)/pdex.dylib $(TMPDIR)

assets: MKASSETSDIR
	cp -r $(ASTDIR)/* $(TMPDIR)

$(OBJDIR)/%.o : %.c | MKBUILDDIRS
	mkdir -p `dirname $@`
	$(CC) -c $(CPFLAGS) -I . $(INCDIR) $< -o $@

$(OBJDIR)/%.o : %.s | MKBUILDDIRS
	$(GCC) -x assembler-with-cpp -c $(ASFLAGS) $< -o $@

.PRECIOUS: $(OBJDIR)/%elf
$(OBJDIR)/pdex.elf: $(OBJS) $(LDSCRIPT)
	$(CC) $(OBJS) $(LDFLAGS) $(DLIBS) $(ULIBS) -o $@

$(OBJDIR)/pdex.dylib: $(SRC) | MKBUILDDIRS
	clang -g -dynamiclib -rdynamic -lm -DTARGET_SIMULATOR=1 -DTARGET_EXTENSION=1 $(INCDIR) -o $(OBJDIR)/pdex.dylib $(SRC)

clean:
	-rm -rf $(OBJDIR) $(PRODUCT) $(TMPDIR)
