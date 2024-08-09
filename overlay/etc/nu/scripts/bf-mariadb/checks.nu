use bf

# Returns true if the mysql version info file does not exist
export def server_is_not_installed []: nothing -> bool { bf env DB_DATA_VERSION_FILE | bf fs is_not_file }

# Returns true if the mariadbd service is not running (i.e. pid is empty)
export def server_is_offline []: nothing -> bool { { ^pidof mariadbd } | bf handle -i | is-empty }
