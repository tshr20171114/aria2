<?php

$connection_info = parse_url(getenv('DATABASE_URL'));

$dsn = sprintf('pgsql:host=%s;dbname=%s', $connection_info['host'], substr($connection_info['path'], 1));

echo $dsn . "\n";

$pdo = new PDO($dsn, $connection_info['user'], $connection_info['pass']);

$sql = 'SELECT Fqdn FROM M_Appliction';

$result = $pdo->query($sql);
  
foreach ($result as $row)
{
  echo convert_enc($row['Fqdn']) . "\n";
}

$pdo = null;
?>