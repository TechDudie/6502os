printf "%s\n" "Compiling..."
vasm6502_oldstyle -dotdir -esc -Fbin boot.s
printf "%s\n" "Writing..."
minipro -p AT28C256 -w a.out
printf "%s\n" "Cleaning up..."
del a.out
printf "%s\n" "Done."
