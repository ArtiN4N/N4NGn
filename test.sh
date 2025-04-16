#!/bin/sh

cp ./lib/libSDL3.so.0 ./debug/
cp ./lib/libSDL3_image.so.0 ./debug/
odin test $1 -out:debug/test.bin -extra-linker-flags:"-L/usr/local/lib/" -define:ODIN_TEST_LOG_LEVEL=warning