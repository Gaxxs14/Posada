<?php

function IniciarSesion($usuario, $clave){
    global $lfmc;
    if(empty($usuario) || empty($clave)){ return false; }
    $consulta = mysqli_fetch_assoc(mysqli_query($lfmc['sql'], "SELECT clave FROM ".T_USUARIO." WHERE (nombre_usuario = '$usuario' OR correo = '$usuario' OR nro_tlf = '$usuario')"));
    $hash        = 'md5';
    if(preg_match('/^[a-f0-9]{32}$/', $consulta['clave'])){
        $hash = 'md5';
    }else if(preg_match('/^[0-9a-f]{40}$/i', $consulta['clave'])){
        $hash = 'sha1';
    }else if(strlen($consulta['clave'])==60){
        $hash = 'password_hash';
    }
    if($hash=='password_hash'){
        if(password_verify($clave, $consulta['clave'])){ return true; }
    }else{ $iniciar_sesion_clave = $hash($clave); }
    
    $consulta = mysqli_fetch_row(mysqli_query($lfmc['sql'], "SELECT COUNT(id) FROM ".T_USUARIO." WHERE (nombre_usuario = '$usuario' OR correo = '$usuario' OR nro_tlf = '$usuario') AND clave = '$iniciar_sesion_clave'"));
    if($consulta[0]==1){
        if($hash=='sha1' || $hash=='md5'){
            $nueva_clave = password_hash($clave, PASSWORD_DEFAULT);
            mysqli_query($lfmc['sql'], "UPDATE ".T_USUARIO." SET clave = '$nueva_clave' WHERE (nombre_usuario = '$usuario' OR correo = '$usuario' OR nro_tlf = '$usuario')");
        }
        return true;
    }
    return false;
}

function CargarPagina($pagina_url,$tipo='usuario'){
    global $lfmc;
    $pagina = "./interfaz/$tipo/$pagina_url.phtml";
    if(file_exists($pagina)){
        $contenido_pagina = '';
        ob_start();
        require($pagina);
        $contenido_pagina = ob_get_contents();
        ob_end_clean();
        return $contenido_pagina;
    }else{
        return false;
    }
}

function Agregar($registrar_datos=array(),$tabla,$regresar_id=false){
    global $lfmc;
    if(empty($registrar_datos)){ return false; }
    $claves   = implode(', ', array_keys($registrar_datos));
    $valores  = '\''.implode('\', \'', $registrar_datos).'\'';
    $consulta = mysqli_query($lfmc['sql'], "INSERT INTO ".$tabla." ($claves) VALUES ($valores)");
    if($consulta){
        if($regresar_id==true){ return mysqli_insert_id($lfmc['sql']); }else{ return true; }
    }else{ return false; }
}
function Actualizar($id, $datos_array=array(),$tabla_nombre,$columna_id='id'){
    global $lfmc;
    if(empty($datos_array)){ return false; }
    foreach($datos_array as $clave => $valor){
        $datos[] = "$clave = '$valor'";
    }
    $datos = implode(', ', $datos);
    $consulta = mysqli_query($lfmc['sql'], "UPDATE ".$tabla_nombre." SET $datos WHERE $columna_id = '$id' ");
    if($consulta){ return true; } return false;
}
function Eliminar($id,$tabla,$where='id'){
    global $lfmc;
    if(mysqli_query($lfmc['sql'], "DELETE FROM $tabla WHERE $where = '$id'")){
        return true;
    }else{
        return false;
    }
}
function Obtener($id,$tabla, $where='id'){
    global $lfmc;
    return mysqli_fetch_assoc(mysqli_query($lfmc['sql'], "SELECT * FROM $tabla WHERE $where ='$id'"));
}
function ObtenerTodos($tabla,$id='',$where='',$id2='',$where2='',$ordenar_por='id',$ordenar_tipo='DESC'){
    global $lfmc;
    if($id!=''&&$where!=''){ $where="AND $where = '$id'";}
    if($id2!=''&&$where2!=''){ $where2="AND $where2 = '$id2'";}
    $consulta = mysqli_query($lfmc['sql'], "SELECT * FROM $tabla WHERE id != '' $where $where2 ORDER BY $ordenar_por $ordenar_tipo");
    while ($dato = mysqli_fetch_assoc($consulta)){
        $datos[] = $dato;
    }
    return $datos;
}
function Total($tabla,$id='',$where='',$id2='',$where2=''){
   global $lfmc;
   if($id!=''&&$where!=''){ $where="WHERE $where = '$id'";}
   if($id2!=''&&$where2!=''){ $where2="AND $where2 = '$id2'";}
   return mysqli_fetch_assoc(mysqli_query($lfmc['sql'], "SELECT COUNT(id) as contar FROM $tabla $where $where2"))['contar'];
}
function Existe($id,$tabla,$where="id"){
    global $lfmc;
    $consulta = mysqli_fetch_row(mysqli_query($lfmc['sql'], "SELECT COUNT(id) FROM $tabla WHERE $where = '$id'"));
    return ($consulta[0]>=1)?true:false;
}
?>