# A RISC-V nostd library for scanf and printf implementation
TinyIO provides the C standard input/output operations (printf and scanf) to communicate over a serial phyisical device. The library is made of two open-source projects, 
the [printf](https://github.com/mpaland/printf/tree/master) repo from Marco Paland, and the [mini-scanf](https://github.com/MuratovAS/mini-scanf) from MuratovAS.
The core of this project is the implementation of standard input/output operations (printf and scanf) tailored for embedded systems. It includes:
- Implementation of standard printf and scanf functionalities from established libraries.
- Customization of _putchar() to handle output operations efficiently.
- Customization of _getchar() to manage input operations effectively.
It's crucial to customize these implementations to seamlessly integrate with the specific serial communication interfaces.

## File Structure
The project directory is structured as follows:
```plaintext
├── inc             # Folder for header files
│   ├── print.h     # Header file for printf functions
│   ├── scan.h      # Header file for scanf functions
│   ├── tinyIO.h    # Header file for tinyIO functions
│   └── uart.h      # uart_send_char and uart_get_char functions 
├── lib
│   └── tinyio.a    # Static library tinyIO.a
├── Makefile
├── README.md
└── src
    ├── print.c     # printf implementation from mpaland/printf and _putchar function
    ├── scan.c      # scanf implementation from MuratovAS/mini-scanf and _getchar function
    ├── tinyIO.c    # Main functions for initialization and interfacing
    └── uart.c      # uart_send_char and uart_get_char functions
``` 
# Dependencies
The project requires a development environment capable of compiling C/C++ code and targeting the specific architecture (edefault is riscv 32bit).
Ensure that the necessary toolchain and libraries for your target platform are properly installed and configured.
The files `src/uart.c` and `inc/uart.h` are hardware-dependant and must be provided for the specific UART device. Current version implements
a Xilinx AXI4-lite UART device driver, with a blocking scanf. 

# Usage
By default, the project is configured to work with risc-v architecture and requires M-extension to be enabled.
To build the tiniyio static library, modify the Makefile and redefine the `RV_PREFIX` variable with your risc-v toolchain path.
The run:
```
make
```
This version of tinyio does not require external dependencies when linked against an application, and it provides almost all format support. 
Tt does not include  long long (128 bits) or float representations. Such a choice is meant to reduce the code footprint on 32-bit architectures,
where linking libgcc.a is required. However, It is possible to compile the library to include `%llu`, `%f` and more by passing proper parameters to make.

| Parameter         | Format Support    | Notes                                                                                                 |
| ----------------- | ----------------- | ---------------------------------------------------------------------------------------------------   |
| LONG_SUPPORT=Y    | `%llu`, `%lld`    | Linking with libgcc.a is required, unless a 64 or 128 bit divider is supported by the architecture    |
| FLOAT_SUPPORT=Y   | `%f`              | Linking with libgcc.a is required, unless the F-extension is enabled                                  |
| EXP_SUPPORT=Y     | `%e`              | Requires the float support enabled                                                                    |
| PTR_SUPPORT=Y     | `%t`              | Requires the long support enabled                                                                     |


It is also possible to optionally include the compressed extension and/or the floating point extension in the compilation flow.
To do so, pass to make `C_EXTENSION=Y` and/or `F_EXTENSION=Y`. As an instance, to compile tinyio with compressed extension enabled and support
to the floating point format:
```
make C_EXTENSION=Y F_EXTENSION=Y FLOAT_SUPPORT=Y

```

# Contribution
Contributions to enhance and optimize the project are welcome. Please follow the guidelines:
1. Fork the repository and create a feature branch.
2. Make your changes, test thoroughly, and ensure compatibility.
3. Submit a pull request detailing the changes made and the rationale behind them.

This project demonstrates a robust implementation of standard I/O operations tailored for embedded systems, emphasizing the need to adapt these operations to specific serial communication interfaces for seamless integration and functionality.






 
