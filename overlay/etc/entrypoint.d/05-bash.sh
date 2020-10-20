#!/usr/bin/env bash

declare -x BACKUP_KEEP_FOR_DAYS
[[ -z "${BACKUP_KEEP_FOR_DAYS}" ]] && BACKUP_KEEP_FOR_DAYS="14"

declare -x MARIADB_DEFAULT_CHARACTER_SET
[[ -z "${MARIADB_DEFAULT_CHARACTER_SET}" ]] && MARIADB_DEFAULT_CHARACTER_SET="utf8"

declare -x MARIADB_CHARACTER_SET_SERVER
[[ -z "${MARIADB_CHARACTER_SET_SERVER}" ]] && MARIADB_CHARACTER_SET_SERVER="utf8"

declare -x MARIADB_COLLATION_SERVER
[[ -z "${MARIADB_COLLATION_SERVER}" ]] && MARIADB_COLLATION_SERVER="utf8_general_ci"

declare -x MARIADB_KEY_BUFFER_SIZE
[[ -z "${MARIADB_KEY_BUFFER_SIZE}" ]] && MARIADB_KEY_BUFFER_SIZE="16M"

declare -x MARIADB_MAX_ALLOWED_PACKET
[[ -z "${MARIADB_MAX_ALLOWED_PACKET}" ]] && MARIADB_MAX_ALLOWED_PACKET="1M"

declare -x MARIADB_TABLE_OPEN_CACHE
[[ -z "${MARIADB_TABLE_OPEN_CACHE}" ]] && MARIADB_TABLE_OPEN_CACHE="64"

declare -x MARIADB_SORT_BUFFER_SIZE
[[ -z "${MARIADB_SORT_BUFFER_SIZE}" ]] && MARIADB_SORT_BUFFER_SIZE="512K"

declare -x MARIADB_NET_BUFFER_SIZE
[[ -z "${MARIADB_NET_BUFFER_SIZE}" ]] && MARIADB_NET_BUFFER_SIZE="8K"

declare -x MARIADB_READ_BUFFER_SIZE
[[ -z "${MARIADB_READ_BUFFER_SIZE}" ]] && MARIADB_READ_BUFFER_SIZE="256K"

declare -x MARIADB_READ_RND_BUFFER_SIZE
[[ -z "${MARIADB_READ_RND_BUFFER_SIZE}" ]] && MARIADB_READ_RND_BUFFER_SIZE="512K"

declare -x MARIADB_MYISAM_SORT_BUFFER_SIZE
[[ -z "${MARIADB_MYISAM_SORT_BUFFER_SIZE}" ]] && MARIADB_MYISAM_SORT_BUFFER_SIZE="8M"

declare -x MARIADB_LOG_BIN
[[ -z "${MARIADB_LOG_BIN}" ]] && MARIADB_LOG_BIN="mysql-bin"

declare -x MARIADB_BINLOG_FORMAT
[[ -z "${MARIADB_BINLOG_FORMAT}" ]] && MARIADB_BINLOG_FORMAT="mixed"

declare -x MARIADB_SERVER_ID
[[ -z "${MARIADB_SERVER_ID}" ]] && MARIADB_SERVER_ID="1"

declare -x MARIADB_INNODB_DATA_FILE_PATH
[[ -z "${MARIADB_INNODB_DATA_FILE_PATH}" ]] && MARIADB_INNODB_DATA_FILE_PATH="ibdata1:10M:autoextend"

declare -x MARIADB_INNODB_BUFFER_POOL_SIZE
[[ -z "${MARIADB_INNODB_BUFFER_POOL_SIZE}" ]] && MARIADB_INNODB_BUFFER_POOL_SIZE="16M"

declare -x MARIADB_INNODB_LOG_FILE_SIZE
[[ -z "${MARIADB_INNODB_LOG_FILE_SIZE}" ]] && MARIADB_INNODB_LOG_FILE_SIZE="5M"

declare -x MARIADB_INNODB_LOG_BUFFER_SIZE
[[ -z "${MARIADB_INNODB_LOG_BUFFER_SIZE}" ]] && MARIADB_INNODB_LOG_BUFFER_SIZE="8M"

declare -x MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT
[[ -z "${MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT}" ]] && MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT="1"

declare -x MARIADB_INNODB_LOCK_WAIT_TIMEOUT
[[ -z "${MARIADB_INNODB_LOCK_WAIT_TIMEOUT}" ]] && MARIADB_INNODB_LOCK_WAIT_TIMEOUT="50"

declare -x MARIADB_INNODB_USE_NATIVE_AIO
[[ -z "${MARIADB_INNODB_USE_NATIVE_AIO}" ]] && MARIADB_INNODB_USE_NATIVE_AIO="1"

declare -x MARIADB_INNODB_FILE_PER_TABLE
[[ -z "${MARIADB_INNODB_FILE_PER_TABLE}" ]] && MARIADB_INNODB_FILE_PER_TABLE="ON"

declare -x MARIADB_MAX_ALLOWED_PACKET
[[ -z "${MARIADB_MAX_ALLOWED_PACKET}" ]] && MARIADB_MAX_ALLOWED_PACKET="16M"

declare -x MARIADB_KEY_BUFFER_SIZE
[[ -z "${MARIADB_KEY_BUFFER_SIZE}" ]] && MARIADB_KEY_BUFFER_SIZE="20M"

declare -x MARIADB_SORT_BUFFER_SIZE
[[ -z "${MARIADB_SORT_BUFFER_SIZE}" ]] && MARIADB_SORT_BUFFER_SIZE="20M"

declare -x MARIADB_READ_BUFFER
[[ -z "${MARIADB_READ_BUFFER}" ]] && MARIADB_READ_BUFFER="2M"

declare -x MARIADB_WRITE_BUFFER
[[ -z "${MARIADB_WRITE_BUFFER}" ]] && MARIADB_WRITE_BUFFER="2M"

declare -x MARIADB_MAX_CONNECTIONS
[[ -z "${MARIADB_MAX_CONNECTIONS}" ]] && MARIADB_MAX_CONNECTIONS="151"

declare -x MARIADB_SKIP_CHOWN
[[ -z "${MARIADB_SKIP_CHOWN}" ]] && MARIADB_SKIP_CHOWN="false"