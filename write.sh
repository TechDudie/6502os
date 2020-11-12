printf "%s\n" "Preparing..."
STR=uname -a
SUB='Linux'
if [[ "$STR" == *"$SUB"* ]]; then
  SYSOS="Linux"
else
  SYSOS="MacOS"
fi
printf "%s\n" "Compiling..."
if ! [ -x "$(command -v vasm6502_oldstyle)" ]; then
  echo 'Error: vasm6502_oldstyle is not installed.' >&2
  exit 1
fi
vasm6502_oldstyle -dotdir -esc -Fbin boot.s
printf "%s\n" "Writing..."
if ! [ -x "$(command -v minipro)" ]; then
  echo 'Error: minipro is not installed.' >&2
  echo 'Installing...'
  MAC="MacOS"
  if [ SYSOS == MAC ]
    brew install minipro
  else
    sudo apt-get install build-essential pkg-config git libusb-1.0-0-dev
    git clone https://gitlab.com/DavidGriffith/minipro.git
    cd minipro
    make
    sudo make install
  echo 'Done. Writing...'
fi
minipro -p AT28C256 -w a.out
printf "%s\n" "Cleaning up..."
del a.out
printf "%s\n" "Done."
