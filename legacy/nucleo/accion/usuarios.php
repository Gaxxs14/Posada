<?php 
if($_POST['opcion']==1){

    $datos=array(
        'nombre'  => $_POST['nombre'],
        'usuario' => $_POST['usuario'],
        'contrasena' => $_POST['contrasena'],
        'correo'  => $_POST['correo'],
        'telefono'  => $_POST['telefono'],
        'tipo'    => $_POST['tipo']
    );
    Agregar($datos,'usuarios',true);

}else if($_POST['opcion']==2){

    $datos=array(
        'nombre'  => $_POST['nombre'],
        'usuario' => $_POST['usuario'],
        'correo'  => $_POST['correo'],
        'telefono'  => $_POST['telefono'],
        'tipo'    => $_POST['tipo']
    );
    Actualizar($_POST['id'],$datos,'usuarios');

    if($_SESSION['usuario']['id']==$_POST['id']){
        foreach($datos as $clave => $valor){
            $_SESSION['usuario'][$clave] = $valor;
        }
    }

}else if($_POST['opcion']==3){

    Eliminar($_POST['id'],'usuarios');

}
    
    header("Content-type: application/json");
    echo json_encode($datos);
    exit();
?>