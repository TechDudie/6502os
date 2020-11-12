printf "%s\n" "Compiling..."
if ! [ -x "$(command -v vasm6502_oldstyle)" ]; then
  echo 'Error: vasm6502_oldstyle is not installed.' >&2
  exit 1
fi
vasm6502_oldstyle -dotdir -esc -Fbin boot.s
printf "%s\n" "Writing..."
if ! [ -x "$(command -v minipro)" ]; then
  echo 'Error: minipro is not installed.' >&2
  exit 1
fi
minipro -p AT28C256 -w a.out
printf "%s\n" "Cleaning up..."
del a.out
printf "%s\n" "Done."
