use bf
bf env load

# Set environment variables
def main [] {
    # root password is required
    if (bf env empty DB_ROOT_PASSWORD) { bf write error "You must define BF_DB_ROOT_PASSWORD." }

    # application or database name / user / password is required
    let application = bf env --safe DB_APPLICATION
    bf env set DB_DATABASE (bf env DB_DATABASE $application)
    bf env set DB_USERNAME (bf env DB_USERNAME $application)
    bf env set DB_PASSWORD (bf env DB_PASSWORD $application)

    if (bf env empty DB_DATABASE) and (bf env empty DB_USERNAME) and (bf env empty DB_PASSWORD) {
        bf write error "You must define BF_DB_APPLICATION, or BF_DB_DATABASE, BF_DB_USERNAME and BF_DB_PASSWORD individually."
    }

    # data and configuration paths
    let data = "/data"
    bf env set DB_DATA $data

    let my_cnf = "/etc/my.cnf"
    let my_cnf_d = $"($my_cnf).d"
    bf env set DB_CONF $my_cnf
    bf env set DB_CONF_D $my_cnf_d

    bf env set DB_ERROR_LOG "/var/log/mariadb/error.log"

    # backup paths
    let backup = "/backup"
    let backup_basename = "dump"
    bf env set DB_BACKUP $backup
    bf env set DB_DUMP_BASENAME $backup_basename
    bf env set DB_DUMP_FILE_WITHOUT_EXT $"($backup)/($backup_basename)"

    # data and server versions
    let data_version_file = $"($data)/mysql_upgrade_info"
    bf env set DB_DATA_VERSION_FILE $data_version_file
    bf env set DB_DATA_VERSION (bf fs read --quiet $data_version_file | str replace "-MariaDB" "")
    bf env set DB_SERVER_VERSION (^mariadb -V | parse --regex '.*(?P<version>\s\d+\.\d+\.\d+)-MariaDB.*' | get version | str trim)

    # SSL certificate paths
    let ssl = "/ssl"
    let ssl_tmp = "/tmp/ssl"
    bf env set DB_SSL $ssl
    bf env set DB_SSL_TMP $ssl_tmp
    bf env set DB_SSL_CA_CERT $"($ssl_tmp)/ca-cert.pem"
    bf env set DB_SSL_CA_KEY $"($ssl_tmp)/ca-key.pem"
    bf env set DB_SSL_CLIENT_CERT $"($ssl_tmp)/client-cert.pem"
    bf env set DB_SSL_CLIENT_KEY $"($ssl_tmp)/client-key.pem"
    bf env set DB_SSL_CLIENT_KEY_TMP $"($ssl_tmp)/client-key.tmp"
    bf env set DB_SSL_CLIENT_REQ $"($ssl_tmp)/client-req.pem"
    bf env set DB_SSL_SERVER_CERT $"($ssl_tmp)/server-cert.pem"
    bf env set DB_SSL_SERVER_KEY $"($ssl_tmp)/server-key.pem"
    bf env set DB_SSL_SERVER_KEY_TMP $"($ssl_tmp)/server-key.tmp"
    bf env set DB_SSL_SERVER_REQ $"($ssl_tmp)/server-req.pem"

    # return nothing
    return
}
