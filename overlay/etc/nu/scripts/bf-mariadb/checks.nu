use bf
use versions.nu

# Returns true if the mysql version info file does not exist
export def server_is_not_installed []: nothing -> bool { versions get_data_version | is-empty }

# Returns true if the mariadbd service is not running (i.e. pid is empty)
export def server_is_offline []: nothing -> bool { { ^pidof mariadbd } | bf handle -i | is-empty }
