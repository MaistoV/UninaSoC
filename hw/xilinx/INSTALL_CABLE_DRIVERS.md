# Install Linux Cable Drivers

## Digilent Devices
For now, just reference (this guide)[https://digilent.com/reference/programmable-logic/guides/install-cable-drivers?srsltid=AfmBOooM1cKdqktUmDoPwlNzoN9zTsPGdju7_pBQfquQ5r9d5ZPqLZ8n] from Digilent.
(this guide)[https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Install-Cable-Drivers] from Xilinx.

In generale, each Vivado installation has the a script to run with sudo:
```console
cd <Vivado Install>/data/xicom/cable_drivers/lin64/install_script/install_drivers/
./install_drivers
```
> NOTE: most Vivado installation path, can be retrieved from XILINX_VIVADO environment variable

> TODO: what about Alveos?
