<?php

$connection_info = parse_url(getenv('DATABASE_URL'));
$pdo = new PDO(
  "pgsql:host=${connection_info['host']};dbname=" . substr($connection_info['path'], 1),
  $connection_info['user'],
  $connection_info['pass']);
$sql = <<< __HEREDOC__
SELECT file_data
  FROM t_files
 WHERE file_name = 'filedata.dat'
__HEREDOC__;

?>
