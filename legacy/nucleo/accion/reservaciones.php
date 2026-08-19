<?php 
if($_POST['opcion']==1){

    $datos=array(
        'habitacion_id' => $_POST['habitacion_id'],
        'cliente_id'    => $_POST['cliente_id'],
        'entrada'       => $_POST['entrada'],
        'salida'        => $_POST['salida'],
        'estatus'       => 'Aprobado'
    );
    Agregar($datos,'reservaciones',true);
    Actualizar($_POST['habitacion_id'],array('estatus'=>'Ocupada'),'habitaciones');

}else if($_POST['opcion']==2){

    $datos=array(
        'habitacion_id' => $_POST['habitacion_id'],
        'entrada'       => $_POST['entrada'],
        'salida'        => $_POST['salida']
    );
    Actualizar($_POST['id'],$datos,'reservaciones');

}else if($_POST['opcion']==3){

    Eliminar($_POST['id'],'reservaciones');

}else if($_POST['opcion']==4){

    Actualizar($_POST['id'],array('estatus'=>'Aprobado'),'reservaciones');
    Actualizar($_POST['hbt_id'],array('estatus'=>'Ocupada'),'habitaciones');

}
    
    header("Content-type: application/json");
    echo json_encode($datos);
    exit();
?>