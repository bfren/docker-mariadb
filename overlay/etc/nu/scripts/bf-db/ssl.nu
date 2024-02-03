use bf

# Generate certificate and key files to enable MariaDB SSL access
# see https://www.cyberciti.biz/faq/how-to-setup-mariadb-ssl-and-secure-connections-from-clients/
export def generate_certs [] {
    # ensure SSL tmp dir exists
    mkdir (bf env DB_SSL_TMP)

    # generate CA key
    bf write "Generating CA key." ssl/generate_certs
    let ca_key_args = [
        (bf env DB_SSL_CA_KEY_BITS)
    ]
    { ^openssl genrsa ...$ca_key_args } | bf handle -s {|out| $out | save --force (bf env DB_SSL_CA_KEY)}

    # generate CA certificate
    bf write "Generating CA certificate." ssl/generate_certs
    let ca_cert_args = [
        -x509
        -nodes
        -days (bf env DB_SSL_EXPIRY | into duration | $in / 1day)
        -key (bf env DB_SSL_CA_KEY)
        -out (bf env DB_SSL_CA_CERT)
        -subj "\"/C=NA/ST=NA/L=NA/O=NA/OU=NA/CN=Admin\""
    ]
    { ^openssl req ...$ca_cert_args } | bf handle

    # generate client key and certificate
    bf write "Generating client key and certificate."
    generate_request "Client" (bf env DB_SSL_CLIENT_KEY_TMP) (bf env DB_SSL_CLIENT_KEY_BITS) (bf env DB_SSL_CLIENT_REQ)
    process_key (bf env DB_SSL_CLIENT_KEY_TMP) (bf env DB_SSL_CLIENT_KEY)
    sign_cert (bf env DB_SSL_CLIENT_REQ) (bf env DB_SSL_CLIENT_CERT)

    # generate server key and certificate
    bf write "Generating server key and certificate."
    generate_request "Server" (bf env DB_SSL_SERVER_KEY_TMP) (bf env DB_SSL_SERVER_KEY_BITS) (bf env DB_SSL_SERVER_REQ)
    process_key (bf env DB_SSL_SERVER_KEY_TMP) (bf env DB_SSL_SERVER_KEY)
    sign_cert (bf env DB_SSL_SERVER_REQ) (bf env DB_SSL_SERVER_CERT)

    # verify client and server certificates
    bf write "Verifying certificates."
    let verify_args = [
        -CAfile (bf env DB_SSL_CA_CERT)
        (bf env DB_SSL_SERVER_CERT)
        (bf env DB_SSL_CLIENT_CERT)
    ]
    let result = { ^openssl verify ...$verify_args } | bf handle -d "Certificate verification" -f {||
        bf write notok "Certificate verification failed, removing all generated files."
        rm --force --recursive $"(bf env SSL)/*" (bf env SSL_TMP)
    }

    # set permissions
    bf ch apply_file "11-ssl"
}

# Use openssl to make a certificate request
def generate_request [
    name: string        # Certificate name (e.g. 'Server' or 'Client')
    key_file: string    # Path to key file
    key_bits: int       # Key bits
    cert_file: string   # Path to certificate file
] {
    # write args to debug
    bf write debug $"Name=($name)" ssl/generate_request
    bf write debug $"Key File=($key_file)" ssl/generate_request
    bf write debug $"Key Bits=($key_bits)" ssl/generate_request
    bf write debug $"Certificate File=($cert_file)" ssl/generate_request

    # use openssl to generate request
    let args = [
        -nodes
        -keyout $key_file
        -newkey $"rsa:($key_bits)"
        -out $cert_file
        -subj $"\"/C=NA/ST=NA/L=NA/O=NA/OU=NA/CN=($name)\""
    ]
    bf write debug $"Requesting certificate: ($args | str join ' ')."
    { ^openssl req ...$args } | bf handle
}

# Use openssl to process an RSA key
def process_key [
    input: string   # Path to input key
    output: string  # Path to output key
] {
    # write args to debug
    bf write debug $"Input=($input)" ssl/process_key
    bf write debug $"Output=($output)" ssl/process_key

    # use openssl to process key
    let args = [
        -in $input
        -out $output
    ]
    bf write debug $"Processing key: ($args | str join ' ')."
    { ^openssl rsa ...$args } | bf handle

    # remove input key
    bf write debug $"Removing input key file ($input)." ssl/process_key
    rm --force $input
}

# Use openssl to sign a certificate
def sign_cert [
    input: string   # Path to certificate request
    output: string  # Path to certificate
] {
    # write args to debug
    bf write debug $"Input=($input)" ssl/sign_cert
    bf write debug $"Output=($output)" ssl/sign_cert

    bf fs read $input | bf dump -t $"Input ($input)"
    bf fs read (bf env DB_SSL_CA_CERT) | bf dump -t "CA Cert"
    bf fs read (bf env DB_SSL_CA_KEY) | bf dump -t "CA Key"

    # use openssl to sign the certificate
    let args = [
        -days (bf env DB_SSL_EXPIRY | into duration | $in / 1day)
        -in $input
        -CA (bf env DB_SSL_CA_CERT)
        -CAkey (bf env DB_SSL_CA_KEY)
        -set_serial "01"
        -out $output
    ]
    bf write debug $"Signing certificate: ($args | str join ' ')."
    { ^openssl x509 ...$args } | bf handle

    # remove input certificate
    bf write debug $"Removing input certificate file ($input)." ssl/sign_cert
    rm --force $input
}
