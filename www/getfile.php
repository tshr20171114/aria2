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

$statement = $pdo->prepare($sql);
$statement->execute();

$result = $statement->fetch();

file_put_contents('/tmp/file_data', base64_decode($result['file_data']));

header('Content-Disposition: inline; filename="filedata.dat"');
header('Content-Length: ' . filesize('/tmp/file_data'));
header('Content-Type: application/octet-stream');

echo file_get_contents('/tmp/file_data');

?>
