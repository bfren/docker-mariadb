use bf

# Install required packages for MariaDB
export def packages []: string -> nothing {
    bf pkg install [
        $"mariadb=($in)"
        $"mariadb-client=($in)"
        $"mariadb-server-utils=($in)"
        openssl
    ]
}
