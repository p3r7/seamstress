#!/bin/bash

mkdir /tmp
mkdir /opt

# install zig
mkdir /opt/zig
wget https://ziglang.org/builds/zig-windows-x86_64-0.11.0.tar.xz 1> /dev/null
tar -xf zig-windows-x86_64-0.11.0.tar.xz -C /tmp
cp -R /tmp/zig-windows-x86_64-0.11.0/* /opt/zig

# fix liblo missing alias
ln -s /mingw64/bin/liblo-7.dll /mingw64/bin/lo.dll

# build
ls /opt/zig/
# /opt/zig/zig build -Doptimize=ReleaseFast -Dcpu=x86_64 --summary all
