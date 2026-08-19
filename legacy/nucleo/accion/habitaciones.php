<?php 
if($_POST['opcion']==1){

    $datos=array(
        'nro'  => $_POST['nro'],
        'precio' => $_POST['precio'],
        'estatus'  => 'Disponible'
    );
    Agregar($datos,'habitaciones',true);

}else if($_POST['opcion']==2){

    $datos=array(
        'nro'    => $_POST['nro'],
        'precio' => $_POST['precio']
    );
    Actualizar($_POST['id'],$datos,'habitaciones');

}else if($_POST['opcion']==3){

    Eliminar($_POST['id'],'habitaciones');

}
    
    header("Content-type: application/json");
    echo json_encode($datos);
    exit();
?>