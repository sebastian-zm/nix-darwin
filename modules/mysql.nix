{ pkgs, ... }:

{
  launchd.daemons.mysql = {
    path = [ pkgs.coreutils pkgs.mysql84 ];
    script = ''
      dbdir=/var/db/mysql

      if [ ! -d "$dbdir" ]; then
        mkdir -p "$dbdir"
        chown -R _mysql:_mysql "$dbdir"
      fi

      if [ ! -d "$dbdir/mysql" ]; then
        ${pkgs.mysql84}/bin/mysqld --initialize-insecure \
          --basedir=${pkgs.mysql84} \
          --datadir="$dbdir" \
          --user=_mysql
        chown -R _mysql:_mysql "$dbdir"
      fi

      if [ ! -d /run/mysqld ]; then
        mkdir -p /run/mysqld
        chown _mysql:_mysql /run/mysqld
      fi

      exec ${pkgs.mysql84}/bin/mysqld_safe \
        --basedir=${pkgs.mysql84} \
        --datadir="$dbdir" \
        --user=_mysql
    '';
    serviceConfig.KeepAlive = true;
    serviceConfig.RunAtLoad = true;
  };
}
