
# Description:
#   Open XSDB and connect to RISC-V hart 0
#   The goal is to use XSDB as a backend for GDB

# Connect to hw_server
connect -host $::env(XILINX_HW_SERVER_HOST) -port $::env(XILINX_HW_SERVER_PORT)

puts "\[INFO\] Initiate connection"
connect

after 500

# Filter and set target
puts "\[INFO\] Selecting target Hart #0"
targets -set -filter {name  =~ "*Hart #0*"}

# Reset target core
puts "\[INFO\] Resetting target"
rst -processor

puts "\[INFO\] XSDB backend running, open GDB"