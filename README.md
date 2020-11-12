# 6502os
A simple OS that can compute mathematical expressions. This needs the original version of Ben Eater's computer without any modifications, additions, or address changes. Incompatible (for now) with Ben Eater's VGA video card.

# Compilation and writing

I have prepared a batch file. Simply enter

    write.bat

into Windows CMD or click on Run.

The script will automatcally compile and write it for you, but vasm and minipro must be added to the PATH system variable.

There is also a .sh file if you need it.

    sh write.sh

on MacOS.

# ADDRESSES
R0-R15 = $0000-$000f

Line entered = $0010-$001f

Message to print = $0020

General Purpose Register = $0030

Parameters = $0031-$0036

Calculation Result = $0037

Last Key Entered = $0038

Line entered pointer = $0039

Keyboard Input = $00ff

Port A = $6001

Port B = $6000

Data Direction A = $6003

Data Direction B = $6002

# DISCLAIMER:
I do not have a computer to test this out so please report all issues no matter how big or small.
