#!/bin/sh

cp ./lib/libSDL3.so.0 ./debug/
cp ./lib/libSDL3_image.so.0 ./debug/
odin run $1 -out:debug/$1.bin -extra-linker-flags:"-L/usr/local/lib/"