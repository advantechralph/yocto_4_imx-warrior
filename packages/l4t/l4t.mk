
l4t_toolchain_dl_url:=http://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
# l4t_toolchain_dl_file:=$(shell basename $(l4t_toolchain_dl_url))
l4t_toolchain_dl_file:=gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
l4t_crosscompile:=$(builddir)/l4t/toolchain/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
l4t_cc:=$(l4t_crosscompile)gcc
l4t_source_dl_url:=https://developer.nvidia.com/embedded/l4t/r32_release_v5.1/r32_release_v5.1/sources/t186/public_sources.tbz2

include packages/l4t/*/*.mk

