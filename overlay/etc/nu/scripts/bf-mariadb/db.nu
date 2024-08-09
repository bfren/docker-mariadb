use bf

# Returns true if database exists in the cluster
export def exists []: string -> bool { $in in (get_all) }

# Dump a database
export def dump [
    name: string    # The name of the database to dump
    file: string    # The path to save the dump script to
] {
    # ensure the database exists
    if not ($name | exists) { bf write error $"Database ($name) does not exist." db/dump }

    # dump database and save to specified file
    let args = [
        "--add-drop-database"
        "--user=root"
        $"--password=(bf env DB_ROOT_PASSWORD)"
        $name
    ]
    { ^mariadb-dump ...$args } | bf handle -s {|x| $x | save --force $file } db/dump
}

# Get a list of databases, ignoring system databases
export def get_all []: nothing -> list<string> {
    # ignore these databases
    let ignore = [
        "mysql"
        "information_schema"
        "performance_schema"
        "sys"
    ]

    # execute SQL and process response
    let args = [
        "--user=root"
        $"--password=(bf env DB_ROOT_PASSWORD)"
        "--execute=SHOW DATABASES;"
    ]
    { ^mariadb ...$args | ^tail -n+2 | ^xargs } | bf handle -d "Selecting MariaDB databases" db/get_all | split row " " | where {|x| $x not-in $ignore } | compact
}
