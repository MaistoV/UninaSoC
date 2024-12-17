# UninaSoC Software Compilation and Usage

This repository contains the software infrastructure needed to build bare-metal applications for UninaSoC.
**Note**: For Linux-based configurations, please refer to the appropriate documentation, as this tree does not apply.

All example applications, as well as custom projects, are built upon the `examples/template` project.
Projects rely on a shared assembly file located in `startup` and a linker script in `linker`. The linker script is automatically generated during the configuration flow (see the root README).
It is expected that libraries and projects depend at least on these two files, along with a `main.c` file, which users can customize.

## Build examples

to build the `examples`, run
```
make build_examples
```
The existing examples include:
- `blinky` - Supported only on the embedded configuration.
- `echo` and `hello_world` - Supported on both embedded and HPC configurations.

`echo` and `hello_world` examples use the [tinyio](https://github.com/Granp4sso/TinyIO-library-for-printf-and-scanf-) library. 
To create a new example, use:
```
make create_example PROJECT_NAME=<example_name>
```

## Create a new project

You can create new projects similarly to how examples are created. Run:
```
make create_project PROJECT_NAME=<project_name>
```
This command creates a directory in `projects` named `project_name`, with the following structure:
```
project_name
├── ld
│   └── user.ld
├── Makefile
├── inc
└── src
    └── main.c
```

The `Makefile` assumes that the RISC-V toolchain is in your PATH. By default, it compiles 32-bit code with IMAD extensions.
To add user-defined code, place source files in the `src` directory and header files in the `inc` directory.
To compile the project, run the following command from the project directory:
```
make
```
This will generate `.bin` and `.elf` files in the newly created bin directory.
To dump the binary content of your program, run:
```
make dump
```

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