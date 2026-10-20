use std/assert

const commands = [
    db-backup db-disable-super-user db-enable-super-user db-export db-import db-restore db-root db-upgrade db-user
]


#======================================================================================================================
# installation
#======================================================================================================================

export def install__dbadm_user_has_uid_1000 [] {
    assert equal "1000" (^id -u dbadm | str trim)
    assert equal "1000" (^id -g dbadm | str trim)
}

export def install__mariadb_executables_are_installed [] {
    for x in [mariadb mariadb-dump mariadb-install-db mariadb-upgrade mariadbd-safe openssl bzip2] {
        assert (which $x | is-not-empty) $"($x) should be installed"
    }
}

export def install__error_log_is_owned_by_dbadm [] {
    assert equal "dbadm" (^stat -c "%U" /var/log/mariadb/error.log | str trim)
}


#======================================================================================================================
# commands
#======================================================================================================================

export def commands__are_executable_and_parse [] {
    for x in $commands {
        let path = $"/usr/bin/bf/($x)"
        assert ($path | path exists) $"($x) should exist"
        assert ((^stat -c "%A" $path | str trim) =~ 'x') $"($x) should be executable"

        # check the script with whichever language its first line names
        let shebang = open --raw $path | lines | first
        if ($shebang =~ '(^#!|[/ ])nu( |$)') {
            let result = ^$nu.current-exe --no-config-file --commands $"nu-check ($path)" | complete
            assert equal "true" ($result.stdout | str trim) $"($x) does not parse: ($result.stderr)"
        } else {
            let result = ^sh -n $path | complete
            assert equal 0 $result.exit_code $"($x) is not valid shell: ($result.stderr)"
        }
    }
}

export def commands__monthly_upgrade_check_is_scheduled [] {
    let path = "/etc/periodic/monthly/force-upgrade"

    assert ($path | path exists)
    assert ((open --raw $path) =~ '(?m)^db-upgrade$') "the monthly job should run db-upgrade"
}
