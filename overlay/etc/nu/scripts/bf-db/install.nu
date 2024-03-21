use bf

# Install required packages for MariaDB
export def packages [
    version: string
] {
    bf pkg install [$"mariadb-server=1:($version)*"]
}
