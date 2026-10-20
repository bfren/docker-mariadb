# Environment used by tests - each call uses a new temporary backup directory, so tests can run in parallel
export def db_env []: nothing -> record {
    let backup = mktemp --directory
    {
        BF_DB_ROOT_PASSWORD: "root-pass"
        BF_DB_USERNAME: "app"
        BF_DB_PASSWORD: "app-pass"
        BF_DB_DATABASE: "app"
        BF_DB_BACKUP: $backup
        BF_DB_DUMP_BASENAME: "dump"
        BF_DB_DUMP_FILE_WITHOUT_EXT: $"($backup)/dump"
    }
}

# Create stub mariadb and mariadb-dump executables in a new temporary directory, and return its path:
#   - each stub saves its arguments (one per line) to <dir>/<name>.args
#   - mariadb lists the databases for SHOW DATABASES, otherwise saves its input to <dir>/mariadb.stdin
#   - mariadb-dump outputs a line containing its arguments
export def stubs []: nothing -> string {
    let dir = mktemp --directory
    let mariadb = [
        "#!/bin/sh"
        "dir=$(dirname \"$0\")"
        "printf '%s\\n' \"$@\" > \"$dir/mariadb.args\""
        "case \"$*\" in"
        "    *'SHOW DATABASES'*) printf 'Database\\ninformation_schema\\napp\\nmysql\\nother\\nperformance_schema\\nsys\\n' ;;"
        "    *) cat > \"$dir/mariadb.stdin\" ;;"
        "esac"
    ]
    let mariadb_dump = [
        "#!/bin/sh"
        "printf '%s\\n' \"$@\" > \"$(dirname \"$0\")/mariadb-dump.args\""
        "echo \"-- dump $*\""
    ]
    $mariadb | str join "\n" | save $"($dir)/mariadb"
    $mariadb_dump | str join "\n" | save $"($dir)/mariadb-dump"
    ^chmod +x $"($dir)/mariadb" $"($dir)/mariadb-dump"
    $dir
}

# Run a closure with the stubs in $dir first on PATH (the real mariadb would need a running server)
export def with_stubs [dir: string, action: closure]: nothing -> any {
    let path = [$dir] | append ($env.PATH | [$in] | flatten | str join (char esep) | split row (char esep))
    with-env {PATH: $path} { do $action }
}

# Return the arguments a stub was called with
export def args [dir: string, name: string]: nothing -> list<string> {
    open --raw $"($dir)/($name).args" | lines
}
