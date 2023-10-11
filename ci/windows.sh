#!/bin/bash

ln -sfn / /c/msys64

# fix liblo missing alias
ln -s /mingw64/bin/liblo-7.dll /mingw64/bin/lo.dll

# install zig
mkdir /opt/zig
wget --no-verbose https://ziglang.org/builds/zig-windows-x86_64-0.11.0.zip
unzip -qq zig-windows-x86_64-0.11.0.zip
cp -R zig-windows-x86_64-0.11.0/* /opt/zig


# build
/opt/zig/zig.exe build -Doptimize=ReleaseFast -Dcpu=x86_64 --summary all
