HOST_COMPILER = gcc -c
EMB_COMPILER = cl430
HOST_SOURCES := $(wildcard src/app/*.c)
EMB_SOURCES := 

compile_host: directories
	$(HOST_COMPILER) $(HOST_SOURCES)

compile_emb: directories
	$(EMB_COMPILER) $(EMB_SOURCES)

directories:
	mkdir -p build
	mkdir -p output