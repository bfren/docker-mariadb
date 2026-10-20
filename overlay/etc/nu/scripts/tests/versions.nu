use std/assert
use bf
use ../bf-mariadb/versions.nu


#======================================================================================================================
# get_data_version
#======================================================================================================================

# Return the version file variables, pointing to a new temporary directory
def version_files []: nothing -> record {
    let dir = mktemp --directory
    {
        BF_DB_DATA_VERSION_FILE_OLD: $"($dir)/mysql_upgrade_info"
        BF_DB_DATA_VERSION_FILE_NEW: $"($dir)/mariadb_upgrade_info"
    }
}

export def get_data_version__is_empty_before_initialisation [] {
    assert equal "" (with-env (version_files) { versions get_data_version })
}

export def get_data_version__prefers_new_file [] {
    let files = version_files
    "10.6.16-MariaDB" | save $files.BF_DB_DATA_VERSION_FILE_OLD
    "11.8.9-MariaDB" | save $files.BF_DB_DATA_VERSION_FILE_NEW

    assert equal "11.8.9" (with-env $files { versions get_data_version })
}

export def get_data_version__falls_back_to_old_file [] {
    let files = version_files
    "10.6.16-MariaDB" | save $files.BF_DB_DATA_VERSION_FILE_OLD

    assert equal "10.6.16" (with-env $files { versions get_data_version })
}

export def get_data_version__ignores_build_suffix [] {
    let files = version_files
    "11.8.9-MariaDB-deb12\n" | save $files.BF_DB_DATA_VERSION_FILE_NEW

    assert equal "11.8.9" (with-env $files { versions get_data_version })
}


#======================================================================================================================
# get_server_version
#======================================================================================================================

export def get_server_version__matches_installed_build [] {
    let server = versions get_server_version
    let build = with-env {BF_ETC: "/etc/bf"} { bf build | get MariaDB }

    assert ($server =~ '^\d+\.\d+\.\d+$') $"($server) should be X.Y.Z"
    assert ($build | str starts-with $server) $"server version ($server) should match the build ($build)"
}
