<?php
error_reporting(0);
@ini_set('max_execution_time', 0);
require_once('nucleo/config.php');

// Conectar al servidor SQL
$lfmc['sql'] = mysqli_connect($sql_host, $sql_usuario, $sql_clave, $sql_nombre, $sql_puerto);
// Manejo de errores de servidor
if(mysqli_connect_errno()){ 
    print "Error al conectarse a MySQL: " . mysqli_connect_error();
    exit();
}

define('CARPETA', $carpeta);

define('T_USUARIO', 'usuarios');

?>