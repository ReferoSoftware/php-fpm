<?php
/*
 * Example readiness probe...
 * Try connecting to the database $max times and sleep $sleep seconds between attempts
 * When successful return code '0'; otherwise return '1'
 *
 * Disclaimer: this is intended as a rough example, and is not tested
 */

function connect() {
	return mysqli_connect(env('DB_HOST'), env('DB_USER'), env('DB_PASSWORD'), env('DB_NAME'));
}

$max = 3;
$sleep = 3;
$tries = 0;
$dbConnectionSuccess = false;

while (! $dbConnectionSuccess && $tries < $max) {
	echo 'Attempting DB connection...';

	$conn = connect();

	if (! $conn) {
		echo 'Connection attempt failed...sleeping for ' . $sleep;
		$tries++;
		sleep($sleep);
		continue;
	}

	echo 'Successfully connected';
	$dbConnectionSuccess = true;
}

return $dbConnectionSuccess ? '0' : '1';