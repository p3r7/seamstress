#!/bin/bash

mkdir /tmp
mkdir /opt

# install zig
mkdir /opt/zig
wget https://ziglang.org/builds/zig-linux-x86_64-0.11.0.tar.xz 1> /dev/null
tar -xf zig-linux-x86_64-0.11.0.tar.xz -C /tmp
cp -R /tmp/zig-linux-x86_64-0.11.0/* /opt/zig

# fix liblo missing alias
ln -s /mingw64/bin/liblo-7.dll /mingw64/bin/lo.dll

# build
/opt/zig/zig build -Doptimize=ReleaseFast -Dcpu=x86_64 --summary all
