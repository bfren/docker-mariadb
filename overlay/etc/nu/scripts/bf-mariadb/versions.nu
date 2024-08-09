use bf

# Return the MariaDB version of the data directory
export def get_data_version []: nothing -> string { bf fs read --quiet (bf env DB_DATA_VERSION_FILE) | str replace "-MariaDB" "" | str trim }

# Return the MariaDB version of the installed server
export def get_server_version []: nothing -> string { ^mariadb -V | parse --regex '.*(?P<version>\s\d+\.\d+\.\d+)-MariaDB.*' | get version | str trim | first }
