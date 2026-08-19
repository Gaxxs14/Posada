<?php require_once('nucleo/iniciar_app.php');

if(!empty($_GET['lf8'])){
    if(isset($_GET['lf8'])){ $lf8 = $_GET['lf8']; }
    if(isset($_GET['mc8'])){ $mc8 = $_GET['mc8']; }
    $dato = array('estado' => 400,'mensaje' => array( 'Algo salio mal' ), 'html' => "<small>😅 <h4>Algo salio mal</small></h1>" );
    if(file_exists("nucleo/ajax/$lf8/vzl.php")){
        include_once "nucleo/ajax/$lf8/vzl.php";
        header("Content-type: application/json");
        echo json_encode($dato);
        exit();
    }
}else{
    $enlace = explode('/', str_replace('/'.CARPETA.'/', '', $_SERVER['REQUEST_URI']));
    foreach($enlace as $clave => $valor){
        $lfmc['link'][$clave] = $valor;
    }
    require_once('interfaz/index.phtml');
}
mysqli_close($lfmc['sql']);
unset($lfmc);
?>