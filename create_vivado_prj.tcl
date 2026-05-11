# Создание block design (без создания проекта)
create_project -in_memory -force -part xc7k325tlffg676-2L

# подключаем папку с самописными ip_cores
set script_path [file dirname [file normalize [info script]]]
set dir_ip_cores "$script_path/ip_cores [get_property ip_repo_paths [current_project]]"
set_property ip_repo_paths $dir_ip_cores [current_project]
update_ip_catalog

# запускаем сборку BD
source top_bd.tcl

# делаем обертку ранее сгенерированного BD
make_wrapper -files [get_files ./bd/top_bd/top_bd.bd] -top
close_project

# Создание проекта
source golden_top.tcl