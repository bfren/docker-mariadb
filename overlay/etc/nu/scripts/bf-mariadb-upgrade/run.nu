use bf
use bf-mariadb
use bf-s6

# Run preflight checks before starting process
export def preflight []: nothing -> nothing {
    # load environment
    bf env load

    # manually set executing script
    bf env x_set --override run mariadb-upgrade

    # sleep duration if not ready
    let sleep_for = 2sec

    # exit if any of the checks fail - S6 will automatically restart the service
    if (bf-mariadb checks server_is_not_initialised) {
        "MariaDB server is not initialised" | bf-s6 svc exit_preflight --sleep $sleep_for mariadb-upgrade
    }
    else if (bf-mariadb checks service_is_not_running) {
        "MariaDB service is not running" | bf-s6 svc exit_preflight --sleep $sleep_for mariadb-upgrade
    }
    else if not (bf-mariadb checks server_is_online) {
        "MariaDB server is not online" | bf-s6 svc exit_preflight --sleep $sleep_for mariadb-upgrade
    }

    # get versions
    let data_version = bf-mariadb versions get_data_version
    let server_version = bf-mariadb versions get_server_version
    bf write debug $"Data: ($data_version); Server: ($server_version)."

    # disable service if versions match
    if $data_version == $server_version {
        bf-s6 svc down mariadb-upgrade
        "Data and Server versions match, upgrade not necessary" | bf-s6 svc exit_preflight mariadb-upgrade
    }

    # if we get here we are ready to run the upgrade
    bf write "Executing upgrade."
}
