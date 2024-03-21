use bf
bf env load

# Generate MariaDB configuration file and apply permissions
def main [] {
    # generate configuration
    bf write "Generating MariaDB configuration."
    bf esh template (bf env DB_CONF)
    bf ch apply_file "12-conf"
}
