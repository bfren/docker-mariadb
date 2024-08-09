use bf
use db.nu

# Backup the cluster to a dump file, compressing if required
export def main [] {
    # create backup directories
    let backup_dir = create_backup_dir
    let temp_dir = bf fs make_temp_dir

    # dump all databases and save to dump file
    bf write $"Dumping all databases." dump
    let dump_file = $"($temp_dir)/(bf env DB_DUMP_BASENAME).sql"
    bf write debug $" .. to ($dump_file)" dump
    let args = [
        "--user=root"
        $"--password=(bf env DB_ROOT_PASSWORD)"
        "--add-drop-database"
        "--all-databases"
    ]
    { ^mariadb-dump ...$args } | bf handle -s {|x| $x | save --force $dump_file } dump

    # compress dump file
    if (bf env check DB_BACKUP_COMPRESS_FILES) {
        bf write debug " .. compressing dump file" dump
        { ^bzip2 $dump_file } | bf handle dump
    }

    # get list of individual databases and back them up
    db get_all | each {|x|
        # dump database to backup file
        bf write debug $" .. backing up database ($x)" dump
        let backup_file = $"($temp_dir)/($x).sql"
        db dump $x $backup_file

        # compress backup file
        if (bf env check DB_BACKUP_COMPRESS_FILES) {
            bf write debug "    compressing backup file" dump
            { ^bzip2 $backup_file } | bf handle dump
        }
    }

    # move files to backup directory
    bf write debug $" .. moving files to ($backup_dir)" dump
    echo $"($temp_dir)/*" | into glob | mv $in $backup_dir

    # set correct permissions
    bf write debug $" .. applying correct permissions" dump
    bf ch apply_file "10-backup"

    # delete temporary directory
    bf write debug $" .. deleting ($temp_dir)" dump
    bf del force $temp_dir

    # cleanup old backup files
    bf write debug " .. removing expired backup files" dump
    bf del old --type d (bf env DB_BACKUP) (bf env DB_BACKUP_KEEP_FOR | into duration)

    # if we get here there have been no errors
    bf write ok "Done." dump
}

# Create a backup directory
def create_backup_dir [] {
    # create temporary directory
    let date = date now | format date "%Y%m%d%H%M"
    let dir = $"(bf env DB_BACKUP)/($date)"
    mkdir $dir

    # return if directory exists
    if ($dir | bf fs is_not_dir) { bf write error "Unable to create backup directory." dump/create_backup_dir }
    $dir
}
