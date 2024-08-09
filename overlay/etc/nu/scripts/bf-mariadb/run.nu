use bf
use bf-s6
use checks.nu
use init.nu
use restore.nu
use versions.nu

# Run preflight checks before starting process
export def preflight []: nothing -> nothing {
    # load environment
    bf env load

    # manually set executing script
    bf env x_set --override run mariadb

    # exit if we are restoring
    if (restore is_restoring) { "A backup is being restored" | bf-s6 svc exit_preflight --sleep 5sec mariadb }

    # if the mysql database directory does not exist, the server is not yet initialised
    if (checks server_is_not_installed) {
        bf write debug "Server not initialised."
        init install
        init generate
    }

    # if we get here we are ready to start MariaDB
    bf write $"Starting MariaDB (versions get_server_version)."
}
