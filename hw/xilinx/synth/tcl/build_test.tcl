set project_name "picorv32"
set ip_name "picorv32_core"

# Create new project (no force)
create_project $project_name . -force -part  $::env(XILINX_PART_NUMBER)

# Import IP
create_ip -name $ip_name -version 1.0;

# Define a list of all the source files
set src_file_list [ list \
    $::env(XILINX_ROOT)/rtl/core/picorv32.v 
]

# Add files to project
add_files -norecurse -fileset [current_fileset] $src_file_list

# Create out-of-context synthesis for the IP
set_property ip_out_of_context true [get_ips $ip_name]
set_property synthesis_type out_of_context [get_ips $ip_name]

# Run synthesis for the IP
launch_run -jobs 8 picorv32_synth_1

# Wait for synthesis to complete
wait_on_run picorv32_synth_1