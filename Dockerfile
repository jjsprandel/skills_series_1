# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ENV MSP430_CGT_VERSION 21.6.1.LTS
ENV MSP430_CGT_INSTALLER_SRC ti_cgt_msp430_${MSP430_CGT_VERSION}_linux-x64_installer.bin
ENV UNIFLASH_VERSION 5.2.0.2519

# Install base packages
RUN dpkg --add-architecture i386
RUN apt-get update && \
        apt-get install -y apt-utils ssh git wget build-essential zlib1g-dev \
        ca-certificates apt-transport-https gnupg software-properties-common \
        python3 python3-pip unzip

RUN apt-get install -y libc6:i386
RUN apt-get install -y libusb-0.1-4:i386
RUN apt-get install -y libgconf-2-4:i386
RUN apt-get install -y build-essential
RUN apt-get install -y libpython2.7

# Install CMake
RUN wget -O - "https://apt.kitware.com/keys/kitware-archive-latest.asc" 2>/dev/null | apt-key add - && \
        apt-add-repository "deb https://apt.kitware.com/ubuntu/ jammy main" && \
        apt-get update && \
        apt-get install -y cmake

# Install MSP430-CGT
RUN mkdir -p /msp430_cgt_install && \
        cd /msp430_cgt_install && \
        wget "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-p4jWEYpR8n/${MSP430_CGT_VERSION}/${MSP430_CGT_INSTALLER_SRC}" && \
        chmod +x ${MSP430_CGT_INSTALLER_SRC} && \
        /msp430_cgt_install/${MSP430_CGT_INSTALLER_SRC} --prefix /home/dev --mode unattended --unattendedmodeui minimal && \
        rm -r /msp430_cgt_install

ENV PATH $PATH:/home/dev/ti-cgt-msp430_${MSP430_CGT_VERSION}/bin

ENV MSP430_C_DIR /home/dev/ti-cgt-msp430_${MSP430_CGT_VERSION}/include ; /home/dev/ti-cgt-msp430_${MSP430_CGT_VERSION}/lib

WORKDIR /ccs_install

RUN wget "https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-J1VdearkvK/12.3.0/CCS12.3.0.00005_linux-x64.tar.gz"

RUN tar -xzf CCS12.3.0.00005_linux-x64.tar.gz

WORKDIR /ccs_install/CCS12.3.0.00005_linux-x64

RUN chmod +x ccs_setup_12.3.0.00005.run

RUN ./ccs_setup_12.3.0.00005.run --enable-components PF_MSP430 --mode unattended --prefix /opt/ti


WORKDIR /

# Install packages for UniFlash
RUN apt-get update && \
        apt-get install -y libusb-0.1-4 libgconf-2-4 gdb

# Install UniFlash
RUN wget "http://software-dl.ti.com/ccs/esd/uniflash/uniflash_sl.${UNIFLASH_VERSION}.run" && \
        chmod +x uniflash_sl.${UNIFLASH_VERSION}.run && \
        ./uniflash_sl.${UNIFLASH_VERSION}.run --unattendedmodeui none --mode unattended --prefix /opt/ti/uniflash && \
        rm uniflash_sl.${UNIFLASH_VERSION}.run && \
        cd /opt/ti/uniflash/TICloudAgentHostApp/install_scripts && \
        mkdir -p /etc/udev/rules.d && \
        cp 70-mm-no-ti-emulators.rules /etc/udev/rules.d/72-mm-no-ti-emulators.rules && \
        cp 71-ti-permissions.rules /etc/udev/rules.d/73-ti-permissions.rules && \
        ln -sf /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0

WORKDIR /home/app

CMD tail -f /dev/null
