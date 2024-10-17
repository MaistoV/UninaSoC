
# Add files to project
import_files -norecurse -fileset [current_fileset] $src_file_list
update_compile_order -fileset sources_1
set_property top ${top_module} [current_fileset]

# Package the IP and update the catalog
ipx::package_project -root_dir $::env(IP_DIR)/build/$::env(IP_PRJ_NAME).srcs/sources_1/imports -vendor user.org -library user -taxonomy /UserIP
set_property name $::env(IP_PRJ_NAME) [ipx::current_core]
set_property core_revision 2 [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $::env(IP_DIR)/build/$::env(IP_PRJ_NAME).srcs/sources_1/imports [current_project]
update_ip_catalog

# Import IP into the project
create_ip -vlnv user.org:user:$::env(IP_PRJ_NAME):1.0 -module_name $::env(IP_NAME) 

#$::env(XILINX_IPS_ROOT)/