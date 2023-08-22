# Sprinter

## How to run:
1. Compile the code like this in a terminal: `gcc -m32 test-sprinter.c sprinter.s`
2. A new file will be created called "a.out", execute it by typing: `./a.out`

## Program description
This program was created for a university assignment in which we were supposed to write a function called
Sprinter in x86-assembly language. Sprinter is meant to be a simplified version of C's sprintf function (https://www.tutorialspoint.com/c_standard_library/c_function_sprintf.html) with following signature: 

int sprinter(unsigned char *res, unsigned char *format, ...);

The simplifications are: 
- The only % specifiers that can occur are %c, %d, %s, %u, %x, %#x, and %%.
- There is no width specification (such as %12d) nor any modifications to the % specifiers (such as +, -, 0 or l (for "long")).

The a.out function that gets created, is used to test out if the sprinter function works correctly.
