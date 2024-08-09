use bf

# Return the MariaDB version of the data directory
export def get_data_version []: nothing -> string {
    # handle change in version filename
    let old = bf env DB_DATA_VERSION_FILE_OLD
    let new = bf env DB_DATA_VERSION_FILE_NEW

    # check new file first
    match ($new | path exists) {
        true => (read_version $new),
        false => (read_version $old)
    }
}

# Read the version of a data directory, stripping unnecessary data
def read_version [
    path: string    # Absolute path to data version file
]: nothing -> string {
    bf fs read --quiet $path | str replace "-MariaDB" "" | str trim
}

# Return the MariaDB version of the installed server
export def get_server_version []: nothing -> string {
    ^mariadb -V | parse --regex '.*(?P<version>\s\d+\.\d+\.\d+)-MariaDB.*' | get version | str trim | first
}
