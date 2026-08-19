<?php
	$Usuario = $_POST['Usuario'];
	$Contrasena = $_POST['Contrasena'];

	$validar_login = mysqli_query($lfmc['sql'], "SELECT * FROM usuarios WHERE usuario= '$Usuario'
		AND contrasena= '$Contrasena'");


	if(mysqli_num_rows($validar_login) >0){
		$_SESSION['usuario'] = mysqli_fetch_assoc($validar_login);
		
		header("location: ".URL);
		exit();


	}else{
		echo '
			<script>
				alert("Intentelo de nuevo, usuario no existente")
				window.location = "'.URL.'iniciar-sesion";
			</script>
		';
		exit();
	}
?>