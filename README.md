SymTabCreator allows you to create Symbol Table for a stripped app

only works for x86_64 and i386 apps (MH_EXECUTE file type)


What is it?

if you disassemble a stripped binary you can see the following code:

(from the included example)

	...
	   +56  00001ef8  e887000000              calll       0x00001f84                    _exit
	   +61  00001efd  f4                      hlt

	Anon1:
	    +0  00001efe  55                      pushl       %ebp
	    +1  00001eff  89e5                    movl        %esp,%ebp
	    +3  00001f01  83ec08                  subl        $0x08,%esp
	    +6  00001f04  8b4508                  movl        0x08(%ebp),%eax
	    +9  00001f07  0faf450c                imull       0x0c(%ebp),%eax
	   +13  00001f0b  c9                      leave
	   +14  00001f0c  c3                      ret

	Anon2:
	    +0  00001f0d  55                      pushl       %ebp
	    +1  00001f0e  89e5                    movl        %esp,%ebp
	    +3  00001f10  83ec08                  subl        $0x08,%esp
	    +6  00001f13  8b4508                  movl        0x08(%ebp),%eax
	...

gdb doesn't even know Anon functions.
Note down the offsets in a file (example.symbols):

	00001ec0 start
	00001efe multiply
	00001f0d add
	00001f1c main

please note that you currently need a 8 (for i386) or 16 (for x86_64) digit hex number.

this file is then processed with SymTabCreator:

SymTabCreator -s example.symbols -o example.stabs

Now you have the symbols in example.stabs and can use them in GDB:

	exec-file example
	add-symbol-file example.stabs

now you've got symbols loaded and can add a breakpoint to "main" for example:
	
	b main