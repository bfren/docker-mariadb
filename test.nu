#!/usr/bin/env -S nu -n

use ../index/test.nu

const mariadb_branches = [
    "10.11"
    "11.4"
    "11.8"
    "12.3"
    "13.0"
]

# Run test suite for image
def main [
    mariadb: string = "13.0"  # define which MariaDB version to use
    --all (-a)                # test all registered versions of MariaDB (overrides $mariadb)
] {
    let branches = if $all { $mariadb_branches } else { [$mariadb] }
    test "mariadb" $branches
}
