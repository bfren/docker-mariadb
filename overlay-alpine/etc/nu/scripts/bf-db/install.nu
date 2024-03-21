use bf

export def packages [
    version: string
] {
    bf pkg install [
        $"mariadb=($version)"
        $"mariadb-client=($version)"
        $"mariadb-server-utils=($version)"
        openssl
    ]
}
