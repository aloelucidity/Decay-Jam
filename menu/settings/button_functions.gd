extends Control


func open_data_folder():
	OS.shell_open(OS.get_user_data_dir())
