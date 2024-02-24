use bf
use init.nu
use restore.nu

# Run preflight checks before executing process
export def preflight [] {
    # load environment
    bf env load

    # manually set executing script
    bf env x_set --override run mariadb

    # exit if we are restoring
    if (restore is_restoring) {
        let for = 5sec
        bf write $"A backup is being restored so sleep for ($for)."
        sleep $for
        exit 0
    }

    # if the mysql database directory does not exist, the server is not yet initialised
    if ($"(bf env DB_DATA)/mysql" | bf fs is_not_dir) {
        bf write debug "Server not initialised."
        init install
        init generate
    }

    # if we get here we are ready to start MariaDB
    bf write "Starting MariaDB."
}
