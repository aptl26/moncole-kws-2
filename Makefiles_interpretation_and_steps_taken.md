Brilliant Labs' original, non-edited Makefile

26: include the definitions from micropythons makefile (will take a look later)
29: if the variable `MICROPY_ROM_TEXT_COMPRESSION` isn't already defined, give it the value `1`
32: `FROZEN_MANIFEST` a variable to store the directory containing the files to "freeze into the firmware" (need to understand what that means)
38: `CROSS_COMPILE` a prefix to use the compilers suitable for the monocle
41: `BUILD_VERSION` creates a variable for the build version based on the date and the time.
44: `WARN` a variable to define flags that tell the compiler to generate warning when facing specific code formats.
47-59: `OPT` defines flags to optimize the compilation and here we're adding more flags to the variable. The adding happens with a space 
62: `CSUPEROPT` is a variable that refrences a flag that optimizes the size of the code to be minimal instead of optimizing the speed of the compilation
65-69: adds flags to the variable `DEFS` (need to understand what this variable does)
72-75: `LDFLAGS` defines a bunch of flags to setup the linker of the compiler in a specific way.
77-95: `INC` defines a bunch of directories with `.h` files to include during compilation, each directory being preceeded by a `-I` to tell the compiler that it's to be included for the header files in the compilation process
98: `CFLAGS` combines all the flags that need to be passed to the compiler
100-191: `SRC-C` is a variable with all the C files that need to be compiled.
193: `SRC_QSTR` same as the `SRC-C` variable. (mb check if the included makefiles add some stuff to these)
195: `OBJ` I speculate this includes the object files to be created by the compilers. Here they copy `PY_O` which I assume is the object files from the micropython makefile
196: adds to `OBJ` every file in `SRC-C` replacing the extension for one of an object file, and adding the prefix of `build/` to each of them. I assume this means that the object files are going to be stored in the `build` folder, with a copy of their original directories.
199: `LIB` defines the libraries needed the compiler needs to add to the compiled files to be used by the files to be compiled

Rules:
204: `OBJCOPY` is the objcopy shell command preceeded with the `CROSS_COMPILE` prefix. The purpose of this line is to transform the `build/application.elf` file to .hex format

208-209: the `Q` is used to add a `@` if verbose == 1, `@` makes the compiler not print the commands

-----------------------------------------------------------------------------------------------


Micropythons mkenv.mk:

12: `THIS_MAKEFILE` stores the directory of the current make file (Print it)
13: `TOP` stores the directory of the root of micropython
19-30: Makes the build verbose if it's set to 1 when running make
34: `PY_SRC` stores the directory of the `py` folder inside the `micropython` folder
35: `BUILD` stores `build` which is probably a rule or the name of the folder
37-44: `RM` = rm `ECHO` = @echo `CP` = cp `MKDIR` = mkdir `SED` = sed `CAT` = cat `TOUCH` = touch `PYTHON` = python3 `AS` = as `CC` = gcc `CPP`= gcc - E `CXX` = g++ `GDB` = gdb `LD` = ld `OBJCOPY` = objcopy `SIZE` = size `STRIP` = strip `AR` = ar
57: `MAKE_MANIFEST` runs the Python file `/tools/makemanifest.py`
58: `MAKE_FROZEN` runs the Python file `/tools/make-frozen.py`
59: `MPY_TOOL` runs the Python file `/tools/mpy-tool.py`
61: `MPY_LIB_SUBMODULE_DIR` stores the directory `/lib/micropython-lib`
62: `MPY_LIB_DIR` stores the directory `/lib/micropython-lib`
64-67: `MICROPY_MPYCROSS` and `MICROPY_MPYCROSS_DEPENDENCY` store the path `/mpy-cross/build/mpy-cross`

-----------------------------------------------------------------------------------------------


Micropythons py.k:

2: `PY_BUILD` stores the directory `build/py` where the python object files should be stored after compilation
4: `HEADER_BUILD` stores the directory `build/genhdr` which is where autogenerated header files are stored (need to understand what autogenerates header files and why)
8: `PY_QSTR_DEFS` stores the directory of the file `/py/qstrdefs.h` which are a bunch of strings stored in a an effecient way. One could use these strings using `MP_QSTR_....`
(Stopped bc felt not very relevant)

-----------------------------------------------------------------------------------------------


Micropythons mkrules.mk
36-41: the object files will maintain the same directory structure but inside the build file

47-50: Creates a requested object file out of a `.S` file
52-55: Creats a requested object file out of a `.s` file
57-67: defines how the C files should be compiled
69-79: defines how the C++ files should be compiled
81-83: compiles a C file into an object file when this object file is needed
85-87: compiles a C++ file into an object file when this object file is needed

-----------------------------------------------------------------------------------------------

Harrison's Makefile_monocle
1-3: requires version 3.82 of make or later
6: (when running from the root of Harrison's repo)`TENSORFLOW_ROOT` = "" `RELATIVE_MAKEFILE_DIR` = "tensorflow/lite/micro/tools/make" `MAKEFILE_DIR` = "tensorflow/lite/micro/tools/make" `DOWNLOADS_DIR` = "tensorflow/lite/micro/tools/make/downloads"
15-27: Define `HOST_OS` on my laptop, equals "osx"





Things to try:
 - Change the `TARGET` and `TARGET_ARCH` variables to be the nrf's



 Steps taken:
  - Fixed the arm-none-eabi-gcc problem. It was causing some libraries to not be included althought they should work. Verified it works using the brilliant labs' original repo make all
  - Added a new rule to `/py/mkrules.mk` to compile `.cc` files
  - Had to manualy clone the repos of `gemmlowp` and `pigweed` into `/tensorflow/lite/micro/tools/make`