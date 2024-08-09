use bf
use db.nu

# Run the mariadb-upgrade executable
export def main []: nothing -> nothing { { ^mariadb-upgrade ...(db root) --force } | bf handle upgrade }
