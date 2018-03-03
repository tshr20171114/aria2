#!/bin/bash

set -x

date
start_date=$(date)

chmod 755 ./start_web.sh

# ***** postgresql *****

postgres_user=$(echo ${DATABASE_URL} | awk -F':' '{print $2}' | sed -e 's/\///g')
postgres_password=$(echo ${DATABASE_URL} | grep -o '/.\+@' | grep -o ':.\+' | sed -e 's/://' | sed -e 's/@//')
postgres_server=$(echo ${DATABASE_URL} | awk -F'@' '{print $2}' | awk -F':' '{print $1}')
postgres_dbname=$(echo ${DATABASE_URL} | awk -F'/' '{print $NF}')

export PGPASSWORD=${postgres_password}

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
CREATE TABLE t_files (
  file_name character varying(255) NOT NULL
 ,file_base64_text text NOT NULL
);
__HEREDOC__
cat /tmp/sql_result.txt

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
SELECT file_name
      ,length(file_base64_text)
  FROM t_files
 ORDER BY file_name
__HEREDOC__
cat /tmp/sql_result.txt

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
SELECT file_base64_text
  FROM t_files
 WHERE file_name = 'usr_aria2.tar.bz2'
__HEREDOC__

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result2.txt << __HEREDOC__
DELETE
  FROM t_files
 WHERE file_name = 'usr_aria2.tar.bz2'
__HEREDOC__

# ***** /tmp/usr *****

cd /tmp

mkdir -m 777 usr

set +x
echo $(cat /tmp/sql_result.txt | head -n 3 | tail -n 1) > /tmp/usr.tar.bz2.base64.txt
set -x
base64 -d /tmp/usr.tar.bz2.base64.txt > /tmp/usr.tar.bz2
tar xf /tmp/usr.tar.bz2 -C /tmp/usr --strip=1

ls -Rlang usr

# ***** env *****

export HOME2=${PWD}
export PATH="/tmp/usr2/bin:/tmp/usr/bin:${PATH}"
export LD_LIBRARY_PATH=/tmp/usr/lib

export CFLAGS="-march=native -O2"
export CXXFLAGS="$CFLAGS"

parallels=$(grep -c -e processor /proc/cpuinfo)

# ***** ccache *****

cd /tmp

wget https://www.samba.org/ftp/ccache/ccache-3.3.4.tar.gz
tar xf ccache-3.3.4.tar.gz
cd ccache-3.3.4
./configure --help
./configure --prefix=/tmp/usr2 --mandir=/tmp/man --docdir=/tmp/doc
make -j${parallels}
make install

cd /tmp/usr2/bin
ln -s ccache gcc
ln -s ccache g++
ln -s ccache cc
ln -s ccache c++

mkdir -m 777 /tmp/ccache
export CCACHE_DIR=/tmp/ccache

time psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
SELECT file_base64_text
  FROM t_files
 WHERE file_name = 'ccache_cache.aria2.tar.bz2'
__HEREDOC__

if [ $(cat /tmp/sql_result.txt | grep -c '(1 row)') -eq 1 ]; then
  set +x
  time echo $(cat /tmp/sql_result.txt | head -n 3 | tail -n 1) > /tmp/ccache_cache.tar.bz2.base64.txt
  set -x
  time base64 -d /tmp/ccache_cache.tar.bz2.base64.txt > /tmp/ccache_cache.tar.bz2
  tar xf /tmp/ccache_cache.tar.bz2 -C /tmp/ccache --strip=1
fi

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
DELETE
  FROM t_files
 WHERE file_name = 'ccache_cache.aria2.tar.bz2'
__HEREDOC__

ccache -s
ccache -z

# ***** aria2 *****

cd /tmp

wget https://github.com/aria2/aria2/releases/download/release-1.33.1/aria2-1.33.1.tar.bz2

tar xf aria2-1.33.1.tar.bz2

cd aria2-1.33.1

./configure --help
./configure --prefix=/tmp/usr --mandir=/tmp/man --docdir=/tmp/doc
make -j${parallels}
make install

# ***** tar *****

cd /tmp
time tar -jcf ccache_cache.tar.bz2 ccache

base64 -w 0 ccache_cache.tar.bz2 > ccache_cache.tar.bz2.base64.txt

set +x
base64_text=$(cat /tmp/ccache_cache.tar.bz2.base64.txt)

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
INSERT INTO t_files (file_name, file_base64_text) VALUES ('ccache_cache.aria2.tar.bz2', '${base64_text}');
__HEREDOC__
set -x

cd /tmp

filename=usr_aria2

time tar -jcf ${filename}.tar.bz2 usr

base64 -w 0 ${filename}.tar.bz2 > ${filename}.tar.bz2.base64.txt

set +x
base64_text=$(cat /tmp/${filename}.tar.bz2.base64.txt)

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
INSERT INTO t_files (file_name, file_base64_text) VALUES ('${filename}.tar.bz2', '${base64_text}');
__HEREDOC__
set -x

echo ${start_date}
date
