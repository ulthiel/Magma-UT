<?php
/*
   Copyright (C) 2020 Ulrich Thiel
   https://github.com/ulthiel/magma-ut
   thiel@mathematik.uni-kl.de, https://ulthiel.com/math

   PHP script to add selfcheck report for Magma-UT.
   Copy this script to your server.
*/

// Set MySQL database variables here
$servername = "localhost";
$username = "";
$password = "";
$dbname = "";
$token = "";

// Check token
if ($_GET["Token"] != $token) {
    exit();
}
unset($_GET["Token"]);

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$columns = implode(", ",array_keys($_GET));
$count = count($_GET);
$escaped_values = array_map('mysqli_real_escape_string', array_fill(1,$count,$conn), array_values($_GET));
$values  = "\"" . implode("\", \"", $escaped_values) . "\"";
$sql = "INSERT INTO selfchecks ($columns) VALUES ($values)";
$result = $conn->query($sql);

$conn->close();
echo $sql;
?>
