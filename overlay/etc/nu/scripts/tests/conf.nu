use std/assert


#======================================================================================================================
# helpers
#======================================================================================================================

# Generate my.cnf from the template in a temporary directory, with $vars added to (and overriding) the defaults set in
# the Dockerfile, and return its lines
def render [vars: record = {}]: nothing -> list<string> {
    let file = $"(mktemp --directory)/my.cnf"
    let defaults = {
        BF_DB_DATA: "/data"
        BF_DB_ERROR_LOG: "/var/log/mariadb/error.log"
        BF_DB_LOG_WARNINGS: "3"
        BF_DB_CHARACTER_SET: "utf8"
        BF_DB_COLLATION: "utf8_general_ci"
        BF_DB_SSL_ENABLE: "0"
        BF_DB_SSL_CA_CERT: "/ssl/ca-cert.pem"
        BF_DB_SSL_SERVER_CERT: "/ssl/server-cert.pem"
        BF_DB_SSL_SERVER_KEY: "/ssl/server-key.pem"
        BF_DB_QUERY_CACHE_ENABLE: "0"
        BF_DB_QUERY_CACHE_SIZE_BYTES: "268435456"
        BF_DB_QUERY_CACHE_LIMIT_BYTES: "1048576"
        BF_DB_CONF_D: "/etc/my.cnf.d"
    }
    with-env ($defaults | merge $vars) { ^esh -o $file /etc/bf/templates/my.cnf.esh }
    open --raw $file | lines
}


#======================================================================================================================
# my.cnf
#======================================================================================================================

export def template__sets_server_variables [] {
    let conf = render {BF_DB_CHARACTER_SET: "utf8mb4", BF_DB_COLLATION: "utf8mb4_unicode_ci", BF_DB_LOG_WARNINGS: "2"}

    for x in ["datadir=/data" "log_error=/var/log/mariadb/error.log" "log_warnings=2" "character_set_server=utf8mb4" "collation_server=utf8mb4_unicode_ci"] {
        assert ($x in $conf) $"($x) should be set"
    }
}

export def template__includes_custom_configuration [] {
    assert equal "!includedir /etc/my.cnf.d" (render | where {|x| $x != "" } | last)
}

export def template__adds_ssl_only_when_enabled [] {
    let ssl = ["ssl-ca=/ssl/ca-cert.pem" "ssl-cert=/ssl/server-cert.pem" "ssl-key=/ssl/server-key.pem" "tls_version=TLSv1.2,TLSv1.3"]
    let disabled = render
    let enabled = render {BF_DB_SSL_ENABLE: "1"}

    for x in $ssl {
        assert not ($x in $disabled) $"($x) should not be set when SSL is disabled"
        assert ($x in $enabled) $"($x) should be set when SSL is enabled"
    }
}

export def template__adds_query_cache_only_when_enabled [] {
    let cache = ["query_cache_type=1" "query_cache_size=1024" "query_cache_limit=16"]
    let disabled = render {BF_DB_QUERY_CACHE_SIZE_BYTES: "1024", BF_DB_QUERY_CACHE_LIMIT_BYTES: "16"}
    let enabled = render {BF_DB_QUERY_CACHE_ENABLE: "1", BF_DB_QUERY_CACHE_SIZE_BYTES: "1024", BF_DB_QUERY_CACHE_LIMIT_BYTES: "16"}

    for x in $cache {
        assert not ($x in $disabled) $"($x) should not be set when the query cache is disabled"
        assert ($x in $enabled) $"($x) should be set when the query cache is enabled"
    }
}
