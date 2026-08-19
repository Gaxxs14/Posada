<?php
	$Nombre = $_POST['Nombre'];
	$Usuario = $_POST['Usuario'];
	$Correo = $_POST['Correo'];
	$Contrasena = $_POST['Contrasena'];

	
	

	$query = "INSERT INTO usuarios (nombre, usuario, correo, contrasena) 
			  VALUES ('$Nombre', '$Usuario', '$Correo', '$Contrasena')";

//Verificar que los correo no se repitan
	$Verificar_correo = mysqli_query($lfmc['sql'], "SELECT * FROM usuarios WHERE correo='$Correo' ");

		if(mysqli_num_rows($Verificar_correo) > 0){
			echo '
				<script>
					alert("Intentenlo de nuevo, correo ya usado");
					window.location = "'.URL.'registro";
				</script>
			';
			exit();
		}

//Verificar que los usuarios no se petitan
	$Verificar_usuario = mysqli_query($lfmc['sql'], "SELECT * FROM usuarios WHERE usuario='$Usuario' ");

		if(mysqli_num_rows($Verificar_usuario) > 0){
			echo '
				<script>
					alert("Intentenlo de nuevo, usuario ya usado");
					window.location = "'.URL.'registro";
				</script>
			';
			exit();
		}		


// Verifiacion para registrar usuarios 

	$ejecutar = mysqli_query($lfmc['sql'], $query);

	if ($ejecutar) {
	echo '	
		<script>
			alert("Usuario registrado correctamente");
			window.location = "'.URL.'iniciar-sesion";
		</script>
		
		';
	}else{
		echo '	
		<script>
			alert("Intentenlo de nuevo, usuario no registrado");
			window.location = "'.URL.'registro";
		</script>
		
		';
	}
	mysqli_close($lfmc['sql']);
?>