<?php
@ini_set('session.cookie_httponly',1);
@ini_set('session.use_only_cookies',1);
@header("X-FRAME-OPTIONS: SAMEORIGIN");
if (!version_compare(PHP_VERSION, '5.5.0', '>=')){
    print "Se Requiere una version PHP mayor o igual a: 5.5.0 <br> Su version PHP actual es: ".PHP_VERSION." Por favor actualice su version de PHP para continuar 😉";
    exit();
}
date_default_timezone_set('America/Caracas');
@ini_set('gd.jpeg_ignore_warning', 1);
session_start();
$lfmc = array();
require_once('incluir/base_de_datos.php');
require_once('incluir/funciones_generales.php');
$consulta = mysqli_query($lfmc['sql'], "SELECT * FROM reservaciones WHERE estatus = 'Aprobado' AND (salida > '".date('Y-m-d')." 00:00')");
while ($dato = mysqli_fetch_assoc($consulta)){
    Actualizar($dato['habitacion_id'],array('estatus' => 'Disponible'), 'habitaciones');
}
?>