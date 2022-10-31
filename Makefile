DEFS = \
	-DHAVE_INTTYPES_H=1 \
	-DHAVE_LIMITS_H=1 \
	-DHAVE_MEMORY_H=1 \
	-DHAVE_STDINT_H=1 \
	-DHAVE_STDLIB_H=1 \
	-DHAVE_STRINGS_H=1 \
	-DHAVE_STRING_H=1 \
	-DHAVE_SYS_PARAM_H=1 \
	-DHAVE_SYS_STAT_H=1 \
	-DHAVE_SYS_TYPES_H=1 \
	-DHAVE_UNISTD_H=1 \
	-DNO_VALUES_H=1 \
	-DSTDC_HEADERS=1 \
	-D_REENTRANT=1 \
	-DUSE_THREAD_ALLOC=1 \
	-D_THREAD_SAFE=1 \
	-DMODULE_SCOPE=__private_extern__ \
	-DTCL_THREADS=1 \
	-DTCL_WIDE_INT_IS_LONG=1 \
	-DUSE_TCL_STUBS=1 \
	-DUSE_TK_STUBS=1 \
	-DMAC_OSX_TK=1 \
	-D_TKPORT

FRAMEWORKS = \
	-framework Cocoa \
	-framework Foundation \
	-framework Quartz

INCLUDES = \
	-I/usr/local/opt/tcl-tk/include

LIBS = \
	-L/usr/local/opt/tcl-tk/lib \
	-ltclstub8.6 \
	-ltkstub8.6

OPTS = \
	-shared \
	-Os \
	-Wall


Idared.dylib: src/Idared.m
	mkdir -p pkg
	gcc src/Idared.m $(OPTS) $(FRAMEWORKS) $(INCLUDES) $(LIBS) $(DEFS) -o Idared.dylib
