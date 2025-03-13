# Program Loading

Once the target board has been programmed with a valid bitstream, it is possible to load a program into the soc memory in various ways,
depending on the selected RISC-V CPU specified with `CORE_SELECTOR`. Example programs can be compiled and built in the `sw/SoC` directory using `make`. It is also possible
to use programs compiled externally. Beware to use supported comoilation flags for the selected CPU.

We offer two loading options:
- *Binary Loading*: load the flat .bin file starting from a memory address
- *ELF Loading*: load the .elf file using sections

For both flows, the default application loaded is `sw/SoC/examples/blinky`

## Load an ELF file

To load a .elf file a backend supporting the target platform and the target CPU deployed a valid backend is required.
In the current configuration, we support two backends: [PROGRAM_LOADING.md](OpenOCD) and XSDB (coming with Vivado).
Both connects to port 3004 that is used for RISC-V 32 bits (as of now, 64-bit is not yet supported).
As for the loader, we use the GDB debugger, though using XSDB is a viable option.

If the `CORE_SELECTOR` is `CORE_MICROBLAZE` it is possible to load the .elf in memory and run the program using
```
make xsdb_run
```
Instead, if the `CORE_SELECTOR` is `CORE_CV32E40P` use openocd (be sure to have closed connections with Xilinx HW server before)
```
make openocd_run
```
Once the backend is enabled, load the .elf file using
```
make debug_run ELF_PATH=<path-to-elf>
```

## Load a binary file

Since not all `CORE_SELECTOR` valid CPUs support a backend and load infrastructure, it is also possible to program
the memory with a flat binary using the Xilinx jtag2axi or Xilinx DMA IPs, both integrated in our `rtl/sys_master` component. 
The binary loading process is quite naive and just writes bytes in memory; hence be careful in placing code contiguously at linking time.
```
make load_binary bin_path=<path-to-bin> base_address=<value> JTAG_READBACK=<false|true>
```
Expect this approach to be slower than loading an elf file.

