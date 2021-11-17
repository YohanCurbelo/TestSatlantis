from python:3.6

RUN apt update && apt install -y iverilog gtkwave make clang llvm \
                                 build-essential zlib1g-dev git gnat

WORKDIR /root

RUN git clone https://github.com/tgingold/ghdl.git ghdl_src/ \
    && cd ghdl_src \
    && ./configure --prefix=/usr/local --with-llvm-config \
    && make \
    && make install \
    && make clean \
    && cd .. \
    && rm -r ./ghdl_src --force


RUN git clone https://github.com/potentialventures/cocotb.git && \
    TOPLEVEL_LANG=vhdl SIM=ghdl make -C /root/cocotb/examples/endian_swapper/tests/ && \
    make -C /root/cocotb/examples/endian_swapper/tests/ && \
    rm -rf /root/cocotb/examples/

RUN find /root/ -type d -exec chmod 777 {} \;
RUN find /root/ -type f -exec chmod 666 {} \;

ENV COCOTB /root/cocotb
