use std/assert
use ../bf-mariadb/db.nu
use helpers.nu


#======================================================================================================================
# credentials
#======================================================================================================================

export def root__uses_root_password [] {
    assert equal ["--user=root" "--password=root-pass"] (with-env (helpers db_env) { db root })
}

export def user__uses_application_user [] {
    assert equal ["--user=app" "--password=app-pass"] (with-env (helpers db_env) { db user })
}


#======================================================================================================================
# databases
#======================================================================================================================

export def without_system__removes_system_databases_and_empty_names [] {
    let input = ["information_schema" "app" "mysql" "" "other" "performance_schema" "sys" "test"]

    assert equal ["app" "other"] ($input | db without_system)
}

export def get_all__returns_application_databases [] {
    let stubs = helpers stubs
    let result = helpers with_stubs $stubs { with-env (helpers db_env) { db get_all } }

    assert equal ["app" "other"] $result
    assert ("--user=root" in (helpers args $stubs mariadb)) "databases should be listed as root"
}

export def exists__checks_application_databases [] {
    let stubs = helpers stubs
    helpers with_stubs $stubs {
        with-env (helpers db_env) {
            assert ("app" | db exists)
            assert not ("missing" | db exists)
            assert not ("mysql" | db exists) "system databases are ignored"
        }
    }
}

export def dump__dumps_one_database_with_drop_and_create [] {
    let stubs = helpers stubs
    let file = $"(mktemp --directory)/app.sql"
    helpers with_stubs $stubs { with-env (helpers db_env) { db dump app $file } }
    let args = helpers args $stubs mariadb-dump

    assert ($file | path exists)
    for x in ["--user=root" "--add-drop-database" "--databases" "app"] { assert ($x in $args) $"($x) should be used" }
}
