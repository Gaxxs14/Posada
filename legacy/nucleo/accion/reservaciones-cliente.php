<?php 
    $datos=array(
        'habitacion_id' => $_POST['habitacion_id'],
        'cliente_id'    => $_SESSION['usuario']['id'],
        'entrada'       => $_POST['entrada'],
        'salida'        => $_POST['salida'],
        'estatus'       => 'Pendiente'
    );
    Agregar($datos,'reservaciones');

    header("Content-type: application/json");
    echo json_encode($datos);
    exit();
?>