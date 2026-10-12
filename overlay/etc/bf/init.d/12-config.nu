use bf
use bf-s6
bf env load

# Generate MariaDB configuration file and apply permissions
def main [] {
    # generate configuration
    bf write "Generating MariaDB configuration."
    bf-s6 esh template (bf env DB_CONF)
    bf-s6 ch apply_file "13-conf"
}
