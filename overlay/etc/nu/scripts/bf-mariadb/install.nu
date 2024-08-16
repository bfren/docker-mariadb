use bf

# Install required packages for MariaDB
export def packages []: string -> nothing { bf pkg install [$"mariadb-server=1:($in)*"] }
