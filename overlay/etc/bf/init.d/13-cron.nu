use bf
use bf-s6
bf env load

# Append backup task to crontab
def main [] { bf-s6 crontab append --min (random int 1..59 | into string) --hour "*/8" "db-dump" }
