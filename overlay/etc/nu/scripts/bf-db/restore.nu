use bf

# the name of the restoring environment variable
const restoring = "DB_RESTORING"

# Returns true if we are restoring a database backup
export def is_restoring [] { bf env check $restoring }

# Restore the data from a dump file
export def main [] { }
