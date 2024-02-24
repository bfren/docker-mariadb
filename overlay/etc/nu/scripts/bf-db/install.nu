use bf

export def packages [
    version: string
] {
    bf pkg install [$"mariadb-server=1:($version)*"]
}
