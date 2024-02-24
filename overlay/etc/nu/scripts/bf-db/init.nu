use bf

# Run default mariadb installation executable
export def install [] {
    # run server installation
    bf write debug "Running mariadb-install-db."
    let install_args = [
        "--user=dbadm"
        $"--datadir=(bf env DB_DATA)"
    ]
    { ^mariadb-install-db ...$install_args } | bf handle

    # set server config permissions
    bf write debug "Setting server config permissions."
    ["/etc/my.cnf*" "dbadm:dbadm" 0440 0750] | bf ch apply
}

# Generate the database initialisation script
export def generate [] {
    # get variables
    let root_password = bf env DB_ROOT_PASSWORD
    let database = bf env DB_DATABASE
    let user = bf env DB_USERNAME
    let pass = bf env DB_PASSWORD

    # create init file
    bf write debug "Generating initialisation script."
    "# bf database initialisation script" | append_to_init

    # update root user with password and ensure full access
    bf write debug " .. alter root user privileges"
    $"ALTER USER 'root'@'localhost' IDENTIFIED BY '($root_password)';" | append_to_init
    "GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;" | append_to_init
    "FLUSH PRIVILEGES;" | append_to_init

    # delete dbadm user (no need to use the space)
    bf write debug " .. delete dbadm user"
    "DROP USER IF EXISTS dbadm@localhost;" | append_to_init

    # delete test database (no need to use the space)
    bf write debug " .. delete test database"
    "DROP DATABASE IF EXISTS test;" | append_to_init

    # create the database(s) specified for creation
    $database | split row " " | each {|name|
        bf write debug $" .. adding database ($name)"
        $"CREATE DATABASE IF NOT EXISTS `($name)`;" | append_to_init
        $"GRANT ALL PRIVILEGES ON `($name)`.* TO '($user)'@'localhost' IDENTIFIED BY '($pass)'';" | append_to_init
        $"GRANT ALL PRIVILEGES ON `($name)`.* TO '($user)'@'%' IDENTIFIED BY '($pass)';" | append_to_init
    }

    # flush privileges
    "FLUSH PRIVILEGES;" | append_to_init
}

# Append an input value to the init script file
def append_to_init [] {
    let init_file = bf env DB_INIT_FILE
    echo $in | save --append $init_file
}
