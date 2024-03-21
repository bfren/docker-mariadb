use bf
use bf-db
bf env load

# If SSL is enabled, generate certificates
def main [] {
    # if SSL is not enabled, exit script gracefully
    if not (bf env check DB_SSL_ENABLE) {
        bf write "SSL is not enabled."
        return
    }

    # if a certificate already exists, exit script gracefully
    if (bf env DB_SSL_SERVER_CERT | path exists) {
        bf write "Using existing SSL certficates."
        return
    }

    # generate certificates
    bf-db ssl generate_certs
}
