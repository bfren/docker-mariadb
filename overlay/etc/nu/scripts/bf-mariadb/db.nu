use bf

# Returns true if database exists in the cluster
export def exists []: string -> bool { $in in (get_all) }

# Returns root login arguments
export def root []: nothing -> list<string> { ["--user=root" $"--password=(bf env DB_ROOT_PASSWORD)"] }

# Returns user login arguments
export def user []: nothing -> list<string> { [$"--user=(bf env DB_USERNAME)" $"--password=(bf env DB_PASSWORD)"] }

# Dump a database
export def dump [
    name: string    # The name of the database to dump
    file: string    # The path to save the dump script to
]: nothing -> nothing {
    # ensure the database exists
    if not ($name | exists) { bf write error $"Database ($name) does not exist." db/dump }

    # dump database and save to specified file
    { ^mariadb-dump ...(root) --add-drop-database --databases $name } | bf handle -s {|x| $x | save --force $file } db/dump
}

# System databases - these are not backed up individually
export const system_databases = ["mysql" "information_schema" "performance_schema" "sys" "test"]

# Get a list of databases, ignoring system databases
export def get_all []: nothing -> list<string> {
    { ^mariadb ...(root) --execute="SHOW DATABASES;" | ^tail -n+2 | ^xargs }
        | bf handle -d "Selecting MariaDB databases" db/get_all
        | split row " "
        | without_system
}

# Remove system databases and empty values from a list of database names
export def without_system []: list<string> -> list<string> {
    where {|x| $x != "" and $x not-in $system_databases }
}
