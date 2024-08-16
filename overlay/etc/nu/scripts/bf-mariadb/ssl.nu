use bf

# Generate certificate and key files to enable MariaDB SSL access
# see https://www.cyberciti.biz/faq/how-to-setup-mariadb-ssl-and-secure-connections-from-clients/
export def generate_certs []: nothing -> nothing {
    # generate CA key
    bf write "Generating CA key." ssl/generate_certs
    let ca_key_args = [
        (bf env DB_SSL_CA_KEY_BITS)
    ]
    dbg_openssl "Generating CA key" genrsa $ca_key_args ssl/generate_certs
    { ^openssl genrsa ...$ca_key_args } | bf handle -s {|out| $out | save --force (bf env DB_SSL_CA_KEY)}

    # generate CA certificate
    bf write "Generating CA certificate." ssl/generate_certs
    let ca_cert_args = [
        -x509
        -nodes
        -days (bf env DB_SSL_EXPIRY | into duration | $in / 1day)
        -key (bf env DB_SSL_CA_KEY)
        -out (bf env DB_SSL_CA_CERT)
        -subj "/C=NA/ST=NA/L=NA/O=NA/OU=NA/CN=Admin"
    ]
    dbg_openssl "Generating CA certificate" req $ca_cert_args ssl/generate_certs
    { ^openssl req ...$ca_cert_args } | bf handle

    # generate server key and certificate
    bf write "Generating server key and certificate."
    generate_request "Server" (bf env DB_SSL_SERVER_KEY_TMP) (bf env DB_SSL_SERVER_KEY_BITS | into int) (bf env DB_SSL_SERVER_REQ)
    process_key (bf env DB_SSL_SERVER_KEY_TMP) (bf env DB_SSL_SERVER_KEY)
    sign_cert (bf env DB_SSL_SERVER_REQ) (bf env DB_SSL_SERVER_CERT)

    # generate client key and certificate
    bf write "Generating client key and certificate."
    generate_request "Client" (bf env DB_SSL_CLIENT_KEY_TMP) (bf env DB_SSL_CLIENT_KEY_BITS | into int) (bf env DB_SSL_CLIENT_REQ)
    process_key (bf env DB_SSL_CLIENT_KEY_TMP) (bf env DB_SSL_CLIENT_KEY)
    sign_cert (bf env DB_SSL_CLIENT_REQ) (bf env DB_SSL_CLIENT_CERT)

    # verify client and server certificates
    bf write "Verifying certificates."
    let verify_args = [
        -CAfile (bf env DB_SSL_CA_CERT)
        (bf env DB_SSL_SERVER_CERT)
        (bf env DB_SSL_CLIENT_CERT)
    ]
    let result = { ^openssl verify ...$verify_args } | bf handle -d "Certificate verification" -f {||
        bf write notok "Certificate verification failed, removing all generated files."
        bf del force $"(bf env SSL)/*" (bf env SSL_TMP)
    }

    # set permissions
    bf ch apply_file "12-ssl"
}

# Debug openssl commands
def dbg_openssl [
    text: string
    cmd: string
    args: list<any>
    script: string
]: nothing -> nothing {
    bf write debug $"($text): openssl ($cmd) ($args | into string | str join ' ')" $script
}

# Use openssl to make a certificate request
def generate_request [
    name: string        # Certificate name (e.g. 'Server' or 'Client')
    key_file: string    # Path to key file
    key_bits: int       # Key bits
    cert_file: string   # Path to certificate file
]: nothing -> nothing {
    # use openssl to generate request
    let args = [
        -nodes
        -keyout $key_file
        -newkey $"rsa:($key_bits)"
        -out $cert_file
        -subj $"/C=NA/ST=NA/L=NA/O=NA/OU=NA/CN=($name)"
    ]
    dbg_openssl "Generating certificate request" req $args ssl/generate_request
    { ^openssl req ...$args } | bf handle
}

# Use openssl to process an RSA key
def process_key [
    input: string   # Path to input key
    output: string  # Path to output key
]: nothing -> nothing {
    # use openssl to process key
    let args = [
        -in $input
        -out $output
    ]
    dbg_openssl "Processing key" rsa $args ssl/process_key
    { ^openssl rsa ...$args } | bf handle

    # remove input key
    bf write debug $"Removing input key file ($input)." ssl/process_key
    bf del force $input
}

# Use openssl to sign a certificate
def sign_cert [
    input: string   # Path to certificate request
    output: string  # Path to certificate
]: nothing -> nothing {
    # use openssl to sign the certificate
    let args = [
        -req
        -days (bf env DB_SSL_EXPIRY | into duration | $in / 1day)
        -in $input
        -CA (bf env DB_SSL_CA_CERT)
        -CAkey (bf env DB_SSL_CA_KEY)
        -set_serial "01"
        -out $output
    ]
    dbg_openssl "Signing certificate" x509 $args ssl/sign_cert
    { ^openssl x509 ...$args } | bf handle

    # remove input certificate
    bf write debug $"Removing input certificate file ($input)." ssl/sign_cert
    bf del force $input
}
