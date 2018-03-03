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

echo ${postgres_user}
echo ${postgres_password}
echo ${postgres_server}
echo ${postgres_dbname}

export PGPASSWORD=${postgres_password}

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
CREATE TABLE t_file (
 file_id int primary key
,file_name character varying(255) NOT NULL
,file_data text
);
__HEREDOC__
cat /tmp/sql_result.txt

# ***** aria2 *****

cd /tmp

wget https://github.com/aria2/aria2/releases/download/release-1.33.1/aria2-1.33.1.tar.bz2

tar xvf aria2-1.33.1.tar.bz2

cd aria2-1.33.1

./configure --help
./configure --prefix=/tmp/usr
make -j2
make install

# ***** tar *****

cd /tmp
time tar -jcf usr_aria2.tar.bz2 usr

base64 -w 0 usr_aria2.tar.bz2 > usr_aria2.tar.bz2.base64.txt

ls -lang

set +x
base64_text=$(cat /tmp/usr_gettext.tar.bz2.base64.txt)

psql -U ${postgres_user} -d ${postgres_dbname} -h ${postgres_server} > /tmp/sql_result.txt << __HEREDOC__
INSERT INTO t_files (file_name, file_base64_text) VALUES ('usr_aria2.tar.bz2', '${base64_text}');
__HEREDOC__
set -x

echo ${start_date}
date
