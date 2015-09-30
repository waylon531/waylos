RUSTC = rustc
RLIBFLAGS = --target=x86_64-elf.json --emit link,dep-info -C linker=x86_64-elf-ld -L . --crate-type lib -C opt-level=3
RFLAGS = --target=x86_64-elf.json --emit obj,dep-info -C linker=x86_64-elf-ld -C no-redzone  -Z no-landing-pads -L . --crate-type lib --extern core=$(CORE) -C opt-level=3
RFLAGS += -C code-model=kernel
RFLAGS += -C soft-float
#RFLAGS += --cfg disable_float
NASM = nasm -felf64
SOURCES = stub.asm dependencies.asm 
RLIBS = kernel.o libcore.rlib liblib.rlib #liballoc.rlib liblibc.rlib
TARGET = waylos.bin
AR = x86_64-elf-ar
LD = x86_64-elf-ld
LINKSCRIPT := linker.ld
LINKFLAGS := -T $(LINKSCRIPT)
#LINKFLAGS += --gc-sections
LINKFLAGS += -Map map.txt
LINKFLAGS += -L ./
LINKFLAGS += -nostdlib
LINKFLAGS += -z max-page-size=0x1000
CORE := build/libcore.rlib

OBJECTS:=$(patsubst %,build/%.o,$(basename $(SOURCES)))
SOURCES:=$(patsubst %,src/%,$(SOURCES))
RLIBS:=$(patsubst %,build/%,$(RLIBS))
RLOC=target/x86_64-elf/debug

all: $(SOURCES) $(TARGET)

build: 
	mkdir -p build

$(TARGET): $(OBJECTS) $(RLIBS) linker.ld
	$(LD) -o $@ $(LINKFLAGS) $(OBJECTS) $(RLIBS)

$(OBJECTS): | build


pure64.sys:
	cd src/boot/Pure64;./build.sh;mv ./pure64.sys ../../../

libcompiler-rt:
	cp compiler-rt/multi_arch/m32/libcompiler_rt.a ./
	ln -s libcompiler_rt.a libcompiler-rt.a

build/kernel.o: src/kernel.rs build/libcore.rlib src/*.rs
	$(RUSTC) $(RFLAGS) $< -o $@ 

build/%.o: src/%.asm
	$(NASM) $< -o $@

build/%.o: src/%.S
	x86_64-elf-as $< -o $@

#%.rlib: %.rs
#	$(RUSTC) $(RLIBFLAGS) $@
#

#libkernel.rlib:
#	$(RUSTC) $(RLIBFLAGS) kernel.rs -o $@ --extern core=libcore.rlib
build/liblib.rlib: $(CORE)
	$(RUSTC) $(RLIBFLAGS) lib/rlibc/src/lib.rs -o $@ --extern core=$(CORE)

build/%.rlib: lib/%/lib.rs
	$(RUSTC) $(RLIBFLAGS) lib/libcore/lib.rs -o $@
	
build/liballoc.rlib: $(CORE) build/liblibc.rlib
	$(RUSTC) $(RLIBFLAGS) lib/liballoc/lib.rs -o $@ --extern core=$(CORE) -C target-feature='-test,-external_funcs,-external_crate' --extern libc=build/liblibc.rlib

build/liblibc.rlib: $(CORE) lib/waylibc/lib.rs
	$(RUSTC) $(RLIBFLAGS) lib/waylibc/lib.rs -o $@ --extern core=$(CORE)

print: 
	echo $(OBJECTS)

libwaylos:
	cargo rustc --target x86_64-elf.json --verbose -- -L .

clean:
	rm build/*.o

distclean:
	rm -r build
	rm *.bin


iso: $(TARGET)
	#cp $(TARGET) isodir/boot/$(TARGET)
	#cat pure64.sys waylos.bin > waylos.sys
	#dd if=waylos.sys of=waylos.img bs=512 seek=16 conv=notrunc
	#x86_64-elf-objcopy waylos.sys -F elf32-i386 isodir/boot/$(TARGET)
	#mv waylos.sys isodir/boot/$(TARGET)
	#grub-mkrescue -d /usr/lib/grub/i386-pc/ -o waylos.iso isodir
	make -C Hydrogen image KERNEL=../../$(TARGET)
	cp Hydrogen/build/boot.iso waylos.iso

-include libcore.d kernel.d
