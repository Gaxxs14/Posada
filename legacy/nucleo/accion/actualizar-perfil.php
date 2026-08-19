<?php 
    $datos=array(
        'nombre'    => $_POST['nombre'],
        'usuario'   => $_POST['usuario'],
        'correo'    => $_POST['correo'],
        'telefono'  => $_POST['telefono'],
        'tipo'      => $_POST['tipo']
    );
    Actualizar($_SESSION['usuario']['id'],$datos,'usuarios');
    foreach($datos as $clave => $valor){
        $_SESSION['usuario'][$clave] = $valor;
    }
    // contrasena

    header("Content-type: application/json");
    echo json_encode($datos);
    exit();
?>