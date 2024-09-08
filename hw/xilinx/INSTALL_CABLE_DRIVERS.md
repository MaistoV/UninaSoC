# Install Linux Cable Drivers
Installing Vivado on Linux by regular installer does not install device cable drivers, since it would require root access. Therefore, this step must be performed manually.

## Digilent Devices
Refer to [this guide](https://digilent.com/reference/programmable-logic/guides/install-cable-drivers?srsltid=AfmBOooM1cKdqktUmDoPwlNzoN9zTsPGdju7_pBQfquQ5r9d5ZPqLZ8n) from Digilent and
[this guide](https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Install-Cable-Drivers) from Xilinx.

In general, each Linux Vivado installation comes with an installation script, to be run with sudo:
```console
cd <Vivado Install>/data/xicom/cable_drivers/lin64/install_script/install_drivers/
sudo ./install_drivers
```
> NOTE: for regualar Vivado installations, `<Vivado Install>` path can be retrieved from `XILINX_VIVADO` environment variable.

> TODO: what about Alveos?
