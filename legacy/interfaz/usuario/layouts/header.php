<header id="header" class="alt">
    <h1><a href="inicio">Posada ABBAPapi</a></h1>
    <nav id="nav">
        <ul>
            <li><a href="inicio">Inicio</a></li>
            <li><a class="button" style="cursor: default; background-color: chocolate;"><?php echo $_SESSION['usuario']['nombre'];?></a></li>
            <li>
                <a href="#" class="icon solid fa-angle-down">Menú</a>
                <ul>
                    <li><a href="perfil">Perfil</a></li>
                    <li><a href="configuracion">Configuración</a></li>
                    <li><a href="nucleo/accion/cerrar">Cerrar Sesión</a></li>
                </ul>
            </li>            
        </ul>
    </nav>
</header>
<!-- Bandera -->
<section id="banner">
    <h2>Posada ABBAPapi</h2>
  <?php if($lfmc['link'][0]==''||$lfmc['link'][0]=='inicio'){?>
    <p>Abre la puerta a un mundo nuevo</p>
    <ul class="actions special">
        <li><a href="reservacion" class="button">¡Haz tu reservación ahora!</a></li>
    </ul>
  <?php }?>
</section>