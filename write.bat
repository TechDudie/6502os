@ECHO OFF
for %%X in (vasm6502.exe) do (set FOUND=%%~$PATH:X)
if defined FOUND goto :compile
ECHO vasm6502 not in PATH, aborting...
EXIT
:compile
ECHO Compiling...
vasm6502 -oldstyle -dotdir -esc -Fbin boot.s
ECHO Writing...
for %%X in (minipro.exe) do (set FOUND=%%~$PATH:X)
if defined FOUND goto :write
ECHO minipro not in PATH, aborting...
EXIT
:write
minipro -p AT28C256 -w a.out
ECHO Cleaning up...
del a.out
ECHO Done.
PAUSE
