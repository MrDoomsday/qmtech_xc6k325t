# Создание block design
create_project -in_memory -part xc7k325tlffg676-2L
source top_bd.tcl
make_wrapper -files [get_files ./bd/top_bd/top_bd.bd] -top
close_project

# Создание проекта
source golden_top.tcl