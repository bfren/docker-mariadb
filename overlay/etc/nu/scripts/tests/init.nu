use std/assert
use ../bf-mariadb/init.nu
use helpers.nu


#======================================================================================================================
# helpers
#======================================================================================================================

# Generate the initialisation script in a temporary directory, with $vars added to the test environment, and return
# its lines
def generate_with [vars: record = {}]: nothing -> list<string> {
    let file = $"(mktemp --directory)/init.sql"
    with-env (helpers db_env | merge {BF_DB_INIT_FILE: $file} | merge $vars) { init generate }
    open --raw $file | lines
}


#======================================================================================================================
# generate
#======================================================================================================================

export def generate__sets_root_password_for_localhost_only [] {
    let sql = generate_with

    assert ("ALTER USER 'root'@'localhost' IDENTIFIED BY 'root-pass';" in $sql)
    assert ($sql | where {|x| $x =~ "'root'@'%'" } | is-empty) "root should not be able to connect from other hosts"
}

export def generate__creates_each_database_and_grants_user_access [] {
    let sql = generate_with {BF_DB_DATABASE: "one two"}

    for db in [one two] {
        assert ($"CREATE DATABASE IF NOT EXISTS `($db)`;" in $sql) $"($db) should be created"
        for host in [localhost "%"] {
            let grant = $"GRANT ALL PRIVILEGES ON `($db)`.* TO 'app'@'($host)' IDENTIFIED BY 'app-pass';"
            assert ($grant in $sql) $"app@($host) should have access to ($db)"
        }
    }
}

export def generate__removes_test_database_and_dbadm_user [] {
    let sql = generate_with

    assert ("DROP DATABASE IF EXISTS `test`;" in $sql)
    assert ("DROP USER IF EXISTS 'dbadm'@'localhost';" in $sql)
}

export def generate__grants_super_user_only_when_enabled [] {
    let super = "GRANT ALL PRIVILEGES ON *.* TO 'app'@'%' WITH GRANT OPTION;"

    assert not ($super in (generate_with)) "super user should be disabled by default"
    assert not ($super in (generate_with {BF_DB_SUPER_USER: "0"}))
    assert ($super in (generate_with {BF_DB_SUPER_USER: "1"}))
}

export def generate__ends_by_flushing_privileges [] {
    assert equal "FLUSH PRIVILEGES;" (generate_with | last)
}


#======================================================================================================================
# sql
#======================================================================================================================

export def sql_enable_super_user__grants_all_privileges_from_any_host [] {
    let sql = with-env (helpers db_env) { init sql_enable_super_user }

    assert equal [
        "GRANT ALL PRIVILEGES ON *.* TO 'app'@'localhost' WITH GRANT OPTION;"
        "GRANT ALL PRIVILEGES ON *.* TO 'app'@'%' WITH GRANT OPTION;"
    ] $sql
}
