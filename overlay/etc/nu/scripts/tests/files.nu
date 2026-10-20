use std/assert
use ../bf-mariadb
use helpers.nu


#======================================================================================================================
# backup
#======================================================================================================================

export def backup_dir__is_named_by_date_and_time [] {
    let env_vars = helpers db_env
    let dir = with-env $env_vars { bf-mariadb backup create_backup_dir }

    assert equal "dir" ($dir | path type)
    assert equal $env_vars.BF_DB_BACKUP ($dir | path dirname)
    assert (($dir | path basename) =~ '^\d{12}$') "backup directories should be named yyyyMMddHHmm"
}


#======================================================================================================================
# restore
#======================================================================================================================

export def check_dump_file__reports_missing_dump [] {
    assert equal {exists: false} (with-env (helpers db_env) { bf-mariadb restore check_dump_file })
}

export def check_dump_file__decompresses_bzip2_dump [] {
    let env_vars = helpers db_env
    let sql = $"($env_vars.BF_DB_DUMP_FILE_WITHOUT_EXT).sql"
    "SELECT 1;" | save $sql
    ^bzip2 $sql

    let result = with-env $env_vars { bf-mariadb restore check_dump_file }

    assert equal {exists: true, path: $sql} $result
    assert equal "SELECT 1;" (open --raw $sql)
}

export def restore__fails_when_backup_does_not_exist [] {
    assert error { with-env (helpers db_env) { bf-mariadb restore from "202601010000" } }
}

export def restore__runs_dump_as_root_and_removes_copy [] {
    let stubs = helpers stubs
    let env_vars = helpers db_env
    let backup = $"($env_vars.BF_DB_BACKUP)/202601010000"
    mkdir $backup
    "-- all databases" | save $"($backup)/dump.sql"

    helpers with_stubs $stubs { with-env $env_vars { bf-mariadb restore from "202601010000" } }

    assert ("--user=root" in (helpers args $stubs mariadb)) "restore should run as root"
    assert equal "-- all databases" (open --raw $"($stubs)/mariadb.stdin")
    assert not ($"($env_vars.BF_DB_BACKUP)/dump.sql" | path exists) "the copied dump should be removed"
    assert ($"($backup)/dump.sql" | path exists) "the backup should be kept"
}


#======================================================================================================================
# export and import
#======================================================================================================================

export def export__saves_database_to_backup_root [] {
    let stubs = helpers stubs
    let env_vars = helpers db_env

    helpers with_stubs $stubs { with-env $env_vars { "app" | bf-mariadb export-db } }

    assert ((open --raw $"($env_vars.BF_DB_BACKUP)/app.sql") starts-with "-- dump")
}

export def export__fails_when_database_does_not_exist [] {
    let stubs = helpers stubs
    assert error { helpers with_stubs $stubs { with-env (helpers db_env) { "missing" | bf-mariadb export-db } } }
}

export def import__runs_file_as_root [] {
    let stubs = helpers stubs
    let env_vars = helpers db_env
    "-- app database" | save $"($env_vars.BF_DB_BACKUP)/app.sql"

    helpers with_stubs $stubs { with-env $env_vars { "app" | bf-mariadb import } }

    assert ("--user=root" in (helpers args $stubs mariadb)) "import should run as root"
    assert equal "-- app database" (open --raw $"($stubs)/mariadb.stdin")
}

export def import__fails_when_file_does_not_exist [] {
    let stubs = helpers stubs
    assert error { helpers with_stubs $stubs { with-env (helpers db_env) { "app" | bf-mariadb import } } }
}
