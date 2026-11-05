use bf
use db.nu

# Database will be exported as a sql file to the root backup directory
export def main []: string -> nothing {
    # capture database name
    let name = $in

    # the dump file in the backup root is restored on the next start
    if $name == (bf env DB_DUMP_BASENAME) { bf write error $"A database called ($name) cannot be exported." export }

    # create path to export file
    let export_file = $"(bf env DB_BACKUP)/($name).sql"

    # dump database to file
    bf write $"Dumping ($name) to ($export_file)." export
    db dump $name $export_file

    # if we get here there have been no errors
    bf write ok "Done." export
}
