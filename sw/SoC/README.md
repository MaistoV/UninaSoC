# UninaSoC Software Compilation and Usage

This repository contains the software infrastructure needed to build bare-metal applications for UninaSoC.
All example applications, as well as custom projects, are built upon the `projects/template` project.
Projects rely on a common set of files in the `common` directory.

* The `startup.s` that implements the very basic initialization operations
* The `UninaSoC.ld`, automatically generated during the configuration flow (see the root [README](../../README.md)).
* The `Makefile`, that implements all basic targets for building, shared among bare-metal applications.

It is expected that libraries and projects depend at least on the common files, along with a `main.c` file, which users can customize.

**Notes**
* For Linux-based configurations, please refer to the appropriate documentation, as this tree does not apply.
* We assume that the RISC-V toolchain is in your PATH.

## Build examples

to build the `examples`, run
```
make build_examples
```
The existing examples include:
- `blinky` - Supported only on the embedded configuration.
- `echo` and `hello_world` - Supported on both embedded and HPC configurations.

`echo` and `hello_world` examples use the [tinyio](https://github.com/Granp4sso/TinyIO-library-for-printf-and-scanf-) library to support `printf()` and `scanf()` on UART. 

## Create a new project

To create a new application project, make a copy of the `template` directory and rename it accordingly to your application name.

The tree must have the following structure:
```
project_name
├── ld
│   └── user.ld
├── Makefile
├── inc
└── src
    └── main.c
```

To add user-defined code, place source files in the `src` directory and header files in the `inc` directory.

### User-defined Makefile

The `Makefile` in the project folder is a user-defined Makefile, that imports the common `Makefile`.
In this Makefile the user can customize its project structure, compilation flags alongside toolchain selection and also the external libraries dependencies.

Default targets allow for code building and cleaning.
To compile the project, run the following command from the project directory:
```
make
```
This will generate `.bin` and `.elf` files in the newly created bin directory.
To clean all artifacts, just run:
```
make clean
```
To dump the binary content of your program, run:
```
make dump
```
A user can add new target rules in the user-defined Makefile.

### User-defined linker script

The shared linker script is automatically generated during the configuration phase of the UninaSoC project, based on the specified SoC configuration.
By default, only a few symbols and sections are defined:

- **Symbols**: Include the vector table base address, stack pointer value, and peripheral symbols (which can be imported into user code).
- **Sections**: Only the text section is defined. The vector table must be placed at the boot address, where entry 0 corresponds to a jump to the reset handler.

Users can define custom linker script sections and symbols by editing the `ld/user.ld` file in the project directory.

### Importing new libraries

Libraries, whether external or internal, are stored in the `lib` directory. To include libraries in your custom project, update the Makefile by specifying them in the libraries section.
Each library must provide:

- A static library object file (`.a`).
- Any necessary header files for integration.

For a practical example of integrating libraries into a project, refer to the `examples/hello_world` example.
