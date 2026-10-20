use std/assert
use ../bf-mariadb/ssl.nu


#======================================================================================================================
# helpers
#======================================================================================================================

# Create certificates in a new temporary directory (with smaller keys, so tests are quicker), and return its path
def create []: nothing -> string {
    let dir = mktemp --directory
    let files = [CA_CERT CA_KEY CLIENT_CERT CLIENT_KEY CLIENT_KEY_TMP CLIENT_REQ SERVER_CERT SERVER_KEY SERVER_KEY_TMP SERVER_REQ]
        | reduce --fold {} {|x, acc| $acc | insert $"BF_DB_SSL_($x)" $"($dir)/($x | str lowercase | str replace --all '_' '-').pem" }
    let settings = {
        BF_DB_SSL: $dir
        BF_DB_SSL_EXPIRY: "30day"
        BF_DB_SSL_CA_KEY_BITS: "2048"
        BF_DB_SSL_SERVER_KEY_BITS: "2048"
        BF_DB_SSL_CLIENT_KEY_BITS: "2048"
    }
    with-env ($files | merge $settings) { ssl create_certs }
    $dir
}

# Return a certificate field using openssl x509, e.g. 'serial' or 'enddate'
def field [cert: string, name: string]: nothing -> string {
    ^openssl x509 -noout $"-($name)" -in $cert | str trim | split row "=" | last
}


#======================================================================================================================
# create_certs
#======================================================================================================================

export def create_certs__creates_certificates_signed_by_ca [] {
    let dir = create
    let result = ^openssl verify -CAfile $"($dir)/ca-cert.pem" $"($dir)/server-cert.pem" $"($dir)/client-cert.pem" | complete

    assert equal 0 $result.exit_code $result.stderr
}

export def create_certs__gives_each_certificate_a_unique_serial [] {
    let dir = create

    assert not equal (field $"($dir)/server-cert.pem" serial) (field $"($dir)/client-cert.pem" serial)
}

export def create_certs__removes_requests_and_temporary_keys [] {
    let files = ls (create) | get name | path basename | sort

    assert equal [ca-cert.pem ca-key.pem client-cert.pem client-key.pem server-cert.pem server-key.pem] $files
}

export def create_certs__uses_expiry [] {
    let dir = create
    # openssl shows dates like 'Nov  6 12:00:00 2026 GMT'
    let expires = field $"($dir)/server-cert.pem" enddate | str replace --regex ' +' ' ' | into datetime --format "%b %d %H:%M:%S %Y GMT"
    let days = ($expires - (date now)) / 1day | math round

    assert equal 30 $days
}
