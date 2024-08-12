use bf
use db.nu
use versions.nu

# Returns true if the mysql version info file does not exist
export def server_is_not_initialised []: nothing -> bool { versions get_data_version | is-empty }

# Returns true if the mariadbd service is not running (i.e. pid is empty)
export def service_is_not_running []: nothing -> bool { { ^pidof mariadbd } | bf handle -i | is-empty }

# Returns true if the server is online
export def server_is_online []: nothing -> bool { { echo "SELECT 1;" | ^mariadb ...(db user) | ^head -n1 } | bf handle -i | $in == "1" }
