use std/assert
use ../bf-mariadb/checks.nu
use helpers.nu


#======================================================================================================================
# server_is_not_initialised
#======================================================================================================================

# Return the version file variables, pointing to a new temporary directory
def version_files []: nothing -> record {
    let dir = mktemp --directory
    {
        BF_DB_DATA_VERSION_FILE_OLD: $"($dir)/mysql_upgrade_info"
        BF_DB_DATA_VERSION_FILE_NEW: $"($dir)/mariadb_upgrade_info"
    }
}

export def server_is_not_initialised__without_version_file [] {
    assert (with-env (version_files) { checks server_is_not_initialised })
}

export def server_is_not_initialised__is_false_with_version_file [] {
    let files = version_files
    "11.8.9-MariaDB" | save $files.BF_DB_DATA_VERSION_FILE_NEW

    assert not (with-env $files { checks server_is_not_initialised })
}


#======================================================================================================================
# server_is_online
#======================================================================================================================

# Run server_is_online with a stub mariadb that outputs $output, and return the result and arguments it was called with
def online_with [output: string]: nothing -> record {
    let dir = mktemp --directory
    $"#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$\(dirname \"$0\"\)/args\"\ncat > /dev/null\nprintf '($output)'\n" | save $"($dir)/mariadb"
    ^chmod +x $"($dir)/mariadb"
    let result = helpers with_stubs $dir { with-env (helpers db_env) { checks server_is_online } }
    {result: $result, args: (open --raw $"($dir)/args" | lines)}
}

export def server_is_online__when_query_returns_1 [] {
    let online = online_with "1\\n"

    assert $online.result
    assert ("--user=app" in $online.args) "the check should use the application user, like the health check"
}

export def server_is_online__is_false_when_query_fails [] {
    assert not (online_with "").result
    assert not (online_with "ERROR\\n").result
}
