@ECHO OFF
ECHO Compiling...
vasm6502 -oldstyle -dotdir -esc -Fbin boot.s
ECHO Writing...
minipro -p AT28C256 -w a.out
ECHO Cleaning up...
del a.out
ECHO Done.
PAUSE
