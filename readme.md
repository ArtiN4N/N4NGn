# N4NG4N

Game engine written on top of odin and SDL3

## Debug instructions
Compile sdl3 from source into /usr/local/lib/
Copy .so.0 file into /bin/
odin run src -out:bin/game -extra-linker-flags:"-L/usr/local/lib/"

## Release instructions
Compile sdl3 from source into /usr/local/lib/
Copy .so.0 file into /release/lib/
odin build src -out:release/game -extra-linker-flags:"-L/usr/local/lib/ -Wl,-rpath,$ORIGIN/lib"
patchelf --remove-rpath release/game
patchelf --set-rpath '$ORIGIN/lib' release/game