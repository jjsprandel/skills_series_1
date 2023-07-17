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
	$(EMB_COMPILER) --include_path=/opt/ti/ccs/ccs_base/msp430/include/ --include_path=/home/app --include_path=/home/dev/ti_cgt_msp430_21.6.1.LTS/include --define=__MSP430FR6989__ $(EMB_SOURCES)

link_emb: directories
	$(EMB_COMPILER) --use_hw_mpy=F5 --define=__MSP430FR6989__ --define=_MPU_ENABLE --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 -z -i"/opt/ti/ccs/ccs_base/msp430/include/" -i"/opt/ti/ccs/ccs_base/msp430/lib/5xx_6xx_FRxx/" -i"/opt/ti/ccs/ccs_base/msp430/lib/FR59xx" -i"/home/dev/ti_cgt_msp430_21.6.1.LTS/lib/" -i"/home/dev/ti_cgt_msp430_21.6.1.LTS/include" --rom_model --output_file=main.out "main.obj" "/opt/ti/ccs/ccs_base/msp430/include/lnk_msp430fr6989.cmd"

directories:
	mkdir -p build
	mkdir -p output

docker_build:
	docker build -t test1 .

docker_run:
	docker run -it -v "c:/codebase/jjsprandel/ieeeucf/emb_skills_series/msp430:/home/app" test1:latest bash