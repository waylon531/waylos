RUSTC = rustc
RLIBFLAGS = --target=x86_64-elf.json --emit link,dep-info -C linker=x86_64-elf-ld -L . --crate-type lib -C opt-level=3
RFLAGS = --target=x86_64-elf.json --emit obj,dep-info -C linker=x86_64-elf-ld -C no-redzone  -Z no-landing-pads -L . --crate-type lib --extern core=$(CORE) -C opt-level=3 --extern alloc=build/liballoc.rlib --extern collections=build/libcollections.rlib --extern rustc_unicode=build/librustc_unicode.rlib
RFLAGS += -C code-model=kernel
RFLAGS += -C soft-float
#RFLAGS += --cfg disable_float
NASM = nasm -felf64
SOURCES = stub.asm thread.asm dependencies.asm
RLIBS = kernel.o libcore.rlib liblib.rlib liballoc.rlib libcollections.rlib #liblibc.rlib
TARGET = waylos.bin
AR = x86_64-elf-ar
LD = x86_64-elf-ld
RUSTC_JOBS = -j4
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

build/kernel.o: src/kernel.rs build/libcore.rlib src/*.rs build/liballoc.rlib build/libcollections.rlib
	$(RUSTC) $(RFLAGS) $< -o $@ 

test: src/kernel.rs build/libcore.rlib src/*.rs
	$(RUSTC) --cfg feature=\"test\" $(RFLAGS) $< -o build/kernel.o

build/%.o: src/%.asm
	$(NASM) $< -o $@

build/%.o: src/%.S
	x86_64-elf-as $< -o $@

lib/%:
	cp -r lib/rust/src/$(notdir $@) $@

#%.rlib: %.rs
#	$(RUSTC) $(RLIBFLAGS) $@
#

#libkernel.rlib:
#	$(RUSTC) $(RLIBFLAGS) kernel.rs -o $@ --extern core=libcore.rlib
build/librustc_unicode.rlib: $(CORE) lib/librustc_unicode
	$(RUSTC) $(RLIBFLAGS) lib/librustc_unicode/lib.rs -o $@ --extern core=$(CORE)

build/liblib.rlib: $(CORE) 
	$(RUSTC) $(RLIBFLAGS) lib/rlibc/src/lib.rs -o $@ --extern core=$(CORE)

build/libcore.rlib: lib/libcore
	$(RUSTC) $(RLIBFLAGS) lib/libcore/lib.rs -o $@
	
build/liballoc.rlib: $(CORE) build/librustc_unicode.rlib lib/liballoc
	$(RUSTC) $(RLIBFLAGS) lib/liballoc/lib.rs -o $@ --extern core=$(CORE) #--extern libc=build/liblibc.rlib 

build/libcollections.rlib: $(CORE) build/liballoc.rlib build/librustc_unicode.rlib lib/libcollections
	$(RUSTC) $(RLIBFLAGS) lib/libcollections/lib.rs -o $@ --extern core=$(CORE) --extern alloc=build/liballoc.rlib --extern rustc_unicode=build/librustc_unicode.rlib

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
	rm -r lib/liballoc lib/libcollections lib/libcore lib/liblibc lib/librustc_unicode


iso: $(TARGET)
	make -C Hydrogen image KERNEL=../../$(TARGET)
	cp Hydrogen/build/boot.iso waylos.iso

run: iso
	qemu-system-x86_64 -cdrom waylos.iso -serial stdio -m 512MB

-include libcore.d kernel.d
