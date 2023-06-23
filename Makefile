DEVICE = MSP430FR6989

ifndef DEVICE
$(info Please specify a device, e.g. DEVICE=MSP430F5529)
$(error unspecified device)
endif

HOST_COMPILER = gcc -c
EMB_COMPILER = cl430
HOST_SOURCES := $(wildcard src/app/*.c)
EMB_SOURCES := $(wildcard src/app/*.c)

compile_host: directories
	$(HOST_COMPILER) $(HOST_SOURCES)

compile_emb: directories
	$(EMB_COMPILER) $(EMB_SOURCES)

directories:
	mkdir -p build
	mkdir -p output

docker_build:
	docker build -t test1 .

docker_run:
	docker run -it -v "c:/codebase/jjsprandel/ieeeucf/emb_skills_series/msp430:/home/app" test1:latest bash