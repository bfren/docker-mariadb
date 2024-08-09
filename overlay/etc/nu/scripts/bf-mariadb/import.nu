use bf
use db.nu

# Import database from the root of the /backup directory
export def main []: string -> nothing {
    # capture database name
    let name = $in

    # ensure the file exists
    let import_file = $"(bf env DB_BACKUP)/($name).sql"
    if ($import_file | bf fs is_not_file) { bf write error $"Cannot find import file ($import_file)." import }

    # ensure the database exists
    bf write $"Importing database ($name) from sql file." import
    { open --raw $import_file | ^mariadb } | bf handle import

    # if we get here there have been no errors
    bf write ok "Done."
}
