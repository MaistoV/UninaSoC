#!/bin/python3.10
import sys
import os

# Check for correct number of arguments
if len(sys.argv) != 3:
    print("Usage: '<CONFIG_PERIPHERALS_CSV>' <OUTPUT_HAL_CONF_FILE>")
    sys.exit(1)

peripheral_csv_path = sys.argv[1]
output_hal_conf_file = sys.argv[2]

if peripheral_csv_path is None:
    print("Error: config_peripheral_bus.csv not found in CONFIG_BUS_CSVS")
    sys.exit(1)

# Open the file whose path is stored in peripheral_csv_path
devices = set()

with open(peripheral_csv_path, 'r') as file:
    for line in file:
        if line.startswith('RANGE_NAMES'):
            # Split line by comma, then take the right-hand side (after first comma)
            names_str = line.strip().split(',', 1)[1]
            names = names_str.split()
            for name in names:
                if name.startswith('TIM'):
                    devices.add('TIM')
                else:
                    devices.add(name)
            break  # No need to process further lines

devices = list(devices)

# Extract base name and make it a valid macro name for the include guard
base_filename = os.path.basename(output_hal_conf_file).replace('.', '_').upper()
include_guard = f"__{base_filename}__"

# Prepare the lines to write
lines = [
    f"#ifndef {include_guard}",
    f"#define {include_guard}",
    "",
]

for device in devices:
    macro_name = f"{device.upper()}_IS_ENABLED"
    lines.append(f"#define {macro_name} 1")

lines.append("")
lines.append(f"#endif // {include_guard}")

# Write to file (overwriting if it exists)
with open(output_hal_conf_file, 'w') as f:
    f.write("\n".join(lines))
