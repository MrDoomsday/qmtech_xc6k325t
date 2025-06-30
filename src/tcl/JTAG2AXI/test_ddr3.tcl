reset_hw_axi [get_hw_axis hw_axi_1]

set b 0x12345678
set b_extend 0
for {set i 0} {$i < 8} {incr i} {
    set b_extend [expr ($b_extend << 32) + ($i*0x77777777)&0xFFFFFFFF]
    puts "B_ext=$b_extend"
}


for {set i 0} {$i < 16} {incr i} {
    create_hw_axi_txn wr_txn{$i} [get_hw_axis hw_axi_1] -address 80004000 -data 0x12345678_12345678_12345678_12345678 -len 4 -size 32 -type write -force
    run_hw_axi wr_txn{$i}
}

create_hw_axi_txn rdn [get_hw_axis hw_axi_1] -address 80004000 -len 8 -size 32 -type read -force
for {set i 0} {$i < 16} {incr i} {
    run_hw_axi rdn
}



create_hw_axi_txn wr [get_hw_axis hw_axi_1] -len 4 -address 42100000 -data FFFFFFFF_22222222_33333333_44444444 -type write
run_hw_axi wr
delete_hw_axi_txn wr

create_hw_axi_txn rd [get_hw_axis hw_axi_1] -len 4 -address 42100000 -type read
run_hw_axi rd
delete_hw_axi_txn rd

# lite
create_hw_axi_txn rd [get_hw_axis hw_axi_1] -address 40000000 -type read
run_hw_axi rd
delete_hw_axi_txn rd

create_hw_axi_txn wr [get_hw_axis hw_axi_1] -address 40000000 -data FFFFFFFF -type write
run_hw_axi wr
delete_hw_axi_txn wr


