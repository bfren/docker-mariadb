use bf

# Run default mariadb installation executable
export def install []: nothing -> nothing {
    # run server installation
    bf write debug "Running mariadb-install-db."
    let install_args = [
        "--user=dbadm"
        $"--datadir=(bf env DB_DATA)"
    ]
    { ^mariadb-install-db ...$install_args } | bf handle

    # set server config permissions
    bf write debug "Setting server config permissions."
    ["/etc/my.cnf*" "dbadm:dbadm" "0440" "0750"] | bf ch apply
}

# Generate the database initialisation script
export def generate []: nothing -> nothing {
    # create init file
    bf write debug "Generating initialisation script."
    "# bf database initialisation script" | append_to_init

    # update root user with password and ensure full access
    bf write debug " .. alter root user privileges"
    sql_alter_root_privileges | append_to_init

    # cleanup unneeded user and database
    bf write debug " .. drop dbadm user"
    sql_drop_dbadm_user | append_to_init
    bf write debug " .. drop test database"
    sql_drop_test_database | append_to_init

    # create the application database(s) and user
    bf env DB_DATABASE | split row " " | each {|db|
        bf write debug $" .. adding database ($db)"
        $db | sql_create_db | append_to_init
        $db | sql_grant_user | append_to_init
    }

    # enable super user
    if (bf env check DB_SUPER_USER) { sql_enable_super_user | append_to_init }

    # flush privileges
    sql_flush_privileges | append_to_init
}

# Append an input value to the init script file, followed by a new line
def append_to_init []: [string -> nothing, list<string> -> nothing] {
    let sql = $in
    let init_file = bf env DB_INIT_FILE
    $sql | str join "\n" | echo $"($in)\n" | save --append $init_file
}

# Ensure root password is correct and only local access is permitted
def sql_alter_root_privileges []: nothing -> list<string> {
    [
        $"ALTER USER 'root'@'localhost' IDENTIFIED BY '(bf env DB_ROOT_PASSWORD)';"
        "GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
    ]
}

# Drop dbadm user (created on startup)
def sql_drop_dbadm_user []: nothing -> string { "DROP USER IF EXISTS 'dbadm'@'localhost';" }

# Drop test database
def sql_drop_test_database []: nothing -> string { "DROP DATABASE IF EXISTS `test`;" }

# Create application database
def sql_create_db []: string -> string { $"CREATE DATABASE IF NOT EXISTS `($in)`;" }

# Grant application user all permissions for database, from any host
export def sql_grant_user []: string -> list<string> {
    let db = $in
    let user = bf env DB_USERNAME
    let pass = bf env DB_PASSWORD
    [
        $"GRANT ALL PRIVILEGES ON `($in)`.* TO '($user)'@'localhost' IDENTIFIED BY '($pass)';"
        $"GRANT ALL PRIVILEGES ON `($in)`.* TO '($user)'@'%' IDENTIFIED BY '($pass)';"
    ]
}

# Grant application user permission to:
#   access all databases (GRANT ALL PRIVILEGES ON *.*)
#   manage users (WITH GRANT OPTION)
#   from any host (TO 'user'@'%')
export def sql_enable_super_user []: nothing -> list<string> {
    let user = bf env DB_USERNAME
    [
        $"GRANT ALL PRIVILEGES ON *.* TO '(bf env DB_USERNAME)'@'localhost' WITH GRANT OPTION;"
        $"GRANT ALL PRIVILEGES ON *.* TO '(bf env DB_USERNAME)'@'%' WITH GRANT OPTION;"
    ]
}

# Always flush privileges after making changes to user / database permissions
export def sql_flush_privileges []: nothing -> string { "FLUSH PRIVILEGES;" }
