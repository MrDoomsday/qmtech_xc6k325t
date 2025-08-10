# procedure
proc write {address data} {
    #remove 0x...
    set address_prefix [string range $address 0 1]
    if {$address_prefix == "0x"} {
        set address [string range $address 2 [expr {[string length $address]-1}]]
        puts "Prefix address in 0x..."
    }

    set data_prefix [string range $data 0 1]
    if {$data_prefix == "0x"} {
        set data [string range $data 2 [expr {[string length $data]-1}]]
        puts "Prefix data in 0x..."
    }

    #align data - добиваем нулями слева, т.к. в противном случае будут проблемы
    set data_align [string repeat "0" [expr 8-[string length $data]]]
    set data $data_align$data

    create_hw_axi_txn -quiet -force wr_tx [get_hw_axis hw_axi_1] -address $address -data $data -len 1 -size 32 -type write
    run_hw_axi -quiet wr_tx
    puts "Transaction complete. Address = $address, data = $data"

}
proc read {address} {
    #remove 0x...
    set address_prefix [string range $address 0 1]
    if {$address_prefix == "0x"} {
        set address [string range $address 2 [expr {[string length $address]-1}]]
        puts "Prefix address in 0x..."
    }
    create_hw_axi_txn -quiet -force rd_tx [get_hw_axis hw_axi_1] -address $address -len 1 -size 32 -type read
    run_hw_axi -quiet rd_tx
    return 0x[get_property DATA [get_hw_axi_txn rd_tx]]
}

# -------------------------------------------------------------------------------
set offset_adc 0x44A00000

# enable adc
write [format %x [expr $offset_adc + 0x0]] 0x1

# set minimal amplitude
write [format %x [expr $offset_adc + 0x4]] 0xFF

# get counter overflow
set counter_overflow [read [format %x [expr $offset_adc + 0x8]]]
puts "Counter overflow = $counter_overflow"

# get amount drop
set amount_drop [read [format %x [expr $offset_adc + 0xC]]]
puts "Amount drop = $amount_drop"
