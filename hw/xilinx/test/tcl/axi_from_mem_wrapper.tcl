
set project_name "axi_from_mem_wrapper"
set ip_name ${project_name}_ip
set top_name $project_name

create_project $project_name . -force -part  $::env(XILINX_PART_NUMBER)

# Define a list of all the source files
set src_file_list [ list \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/axi_pkg.sv \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/typedef.svh \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/registers.svh \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/assertions.svh \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/uninasoc_axi.svh \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/fifo_v3.sv \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/axi_lite_from_mem.sv \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/axi_lite_to_axi.sv \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/axi_from_mem.sv \
    $::env(XILINX_ROOT)/test/rtl/${top_name}/axi_from_mem_wrapper.sv \

]

# Add files to project
add_files -norecurse -fileset [current_fileset] $src_file_list

update_compile_order -fileset sources_1
set_property top $top_name [current_fileset]

ipx::package_project -root_dir $::env(XILINX_ROOT)/test/build/$project_name/${project_name}.srcs/sources_1/imports -vendor user.org -library user -taxonomy /UserIP
set_property core_revision 2 [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $::env(XILINX_ROOT)/test/build/$project_name/${project_name}.srcs/sources_1/imports [current_project]
update_ip_catalog

# Import IP
create_ip -vlnv user.org:user:${top_name}:1.0 -module_name $ip_name

# Generate
generate_target {instantiation_template} [get_files ${ip_name}.xci]
generate_target all [get_files ${ip_name}.xci]

# Synthesize
create_ip_run [get_files -of_objects [get_fileset sources_1] ${ip_name}.xci]
launch_run -jobs 8 ${ip_name}_synth_1
wait_on_run ${ip_name}_synth_1