# nds-gnu-toolchain
GNU toolchain for AndesCore

###  Getting the sources

    $ git clone https://github.com/andestech/nds-gnu-toolchain.git -b <branch_name>
    $ git submodule update --init --recursive

### Prerequisites

Several standard packages are needed to build the toolchain.

On Ubuntu, executing the following command should suffice:

    $ sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

On Fedora/CentOS/RHEL OS, executing the following command should suffice:

    $ sudo yum install autoconf automake python3 libmpc-devel mpfr-devel gmp-devel gawk bison flex texinfo patchutils gcc gcc-c++ zlib-devel expat-devel

### Installation (Newlib)
First, you must define the variables in script "build_elf_toolchain.sh" as shown in the table.
Then, you can execute the script to build and install toolchain.
The default setting is "nds32le-elf-newlib-v5".

Toolchain              | ARCH                            | ABI    | CPU                | TARGET
-----------------------|:-------------------------------:|-------:| ------------------:|----------------
nds32le-elf-newlib-v5e | rv32emc_zicsr_zifencei_xandes   | ilp32e | andes-25-series    | riscv32-elf
nds32le-elf-newlib-v5  | rv32imc_zicsr_zifencei_xandes   | ilp32  | andes-25-series    | riscv32-elf
nds32le-elf-newlib-v5f | rv32imfc_zicsr_zifencei_xandes  | ilp32f | andes-25-series    | riscv32-elf
nds32le-elf-newlib-v5d | rv32imfdc_zicsr_zifencei_xandes | ilp32d | andes-25-series    | riscv32-elf
nds64le-elf-newlib-v5  | rv64imc_zicsr_zifencei_xandes   | lp64   | andes-25-series    | riscv64-elf
nds64le-elf-newlib-v5f | rv64imfc_zicsr_zifencei_xandes  | lp64f  | andes-25-series    | riscv64-elf
nds64le-elf-newlib-v5d | rv64imfdc_zicsr_zifencei_xandes | lp64d  | andes-25-series    | riscv64-elf


### Installation (Linux)
First, you must define the variables in script "build_linux_toolchain.sh" as shown in the table.
Then, you can execute the script to build and install toolchain.
The default setting is "nds32le-linux-glibc-v5d".

Toolchain               | ARCH                                 | ABI    | CPU              | TARGET
------------------------|:------------------------------------:|-------:| ----------------:|----------------
nds32le-linux-glibc-v5  | rv32ima_zicsr_zifencei_zca_xandes    | ilp32  | andes-25-series  | riscv32-linux
nds32le-linux-glibc-v5d | rv32imafd_zicsr_zifencei_zca_xandes  | ilp32d | andes-25-series  | riscv32-linux
nds64le-linux-glibc-v5  | rv64ima_zicsr_zifencei_zca_xandes    | lp64   | andes-25-series  | riscv64-linux
nds64le-linux-glibc-v5d | rv64imafd_zicsr_zifencei_zca_xandes  | lp64d  | andes-25-series  | riscv64-linux
