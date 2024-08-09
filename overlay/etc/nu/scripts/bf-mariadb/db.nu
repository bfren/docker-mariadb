use bf

# Returns true if database exists in the cluster
export def exists []: string -> bool { $in in (get_all) }

# Dump a database
export def dump [
    name: string    # The name of the database to dump
    file: string    # The path to save the dump script to
]: nothing -> nothing {
    # ensure the database exists
    if not ($name | exists) { bf write error $"Database ($name) does not exist." db/dump }

    # dump database and save to specified file
    { ^db mariadb-dump --add-drop-database --databases $name } | bf handle -s {|x| $x | save --force $file } db/dump
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
    { ^db mariadb --execute="SHOW DATABASES;" | ^tail -n+2 | ^xargs } | bf handle -d "Selecting MariaDB databases" db/get_all | split row " " | where {|x| $x not-in $ignore } | compact
}
