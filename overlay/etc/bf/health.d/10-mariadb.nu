use bf
use bf-mariadb
bf env load -x

# Healthcheck will fail if the server is not online
def main [] { if not (bf-mariadb checks server_is_online) { exit 1 } }
