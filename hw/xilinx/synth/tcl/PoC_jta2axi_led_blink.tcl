# Author: Vincenzo Maisto <vincenzo.maisto2@unina.it>
# Description: Blink leds on GPIOs out

# Utility function
proc leds_set { address value } {
    create_hw_axi_txn gpio_wr_txn [get_hw_axis hw_axi_1] -type write -force -address $address -data $value -len 4
    run_hw_axi [get_hw_axi_txns gpio_wr_txn]
}

# Local variables
set word_off 0x00000000
set word_on  0xffffffff
set base_address 0x0020000
set base_address 0x100000
set num_toggles 5

for {set i 0} {$i < $num_toggles} {incr i} {
    # Led off
    leds_set $base_address $word_off
    # Wait 1s
    after 500
    # Led on
    leds_set $base_address $word_on
    # Wait 1s
    after 500
}


