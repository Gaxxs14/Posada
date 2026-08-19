$(document).ready(function(){
	tablausuarios = $("#tablausuarios").DataTable({
		"columnDefs":[{
        "targets": -1,
        "data":null,
        "defaultContent": "<div class='text-center'><div class='btn-group'><button class='btn btn-primary btnEditar'>Editar</button><button class='btn btn-danger btnBorrar'>Borrar</button></div></div>"  
       }],
       //Para cambiar el lenguaje a español
    "language": {
            "lengthMenu": "Mostrar _MENU_ registros",
            "zeroRecords": "No se encontraron resultados",
            "info": "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
            "infoEmpty": "Mostrando registros del 0 al 0 de un total de 0 registros",
            "infoFiltered": "(filtrado de un total de _MAX_ registros)",
            "sSearch": "Buscar:",
            "oPaginate": {
                "sFirst": "Primero",
                "sLast":"Último",
                "sNext":"Siguiente",
                "sPrevious": "Anterior"
             },
             "sProcessing":"Procesando...",
        } 
	});

	$("#btnNuevo").click(function(){
    $("#formusuarios").trigger("reset");
    $(".modal-header").css("background-color", "#28a745");
    $(".modal-header").css("color", "white");
    $(".modal-title").text("Nuevo Usuario");            
    $("#modalCRUD").modal("show");        
    id=null;
    opcion = 1; //alta
});

var fila; //capturar la fila para editar o borrar el registro

$("#formusuarios").submit(function(e){
    e.preventDefault();    
    nombre = $.trim($("#nombre").val());
    usuario = $.trim($("#usuario").val());
    contraseña = $.trim($("#contraseña").val()); 
    level = $.trim($("#level").val());    
    $.ajax({
        url: "bd/crud.php",
        type: "POST",
        dataType: "json",
        data: {nombre:nombre, usuario:usuario, contraseña:contraseña, level:level, id:id, opcion:opcion},
        success: function(data){  
            console.log(data);
            id = data[0].id;            
            nombre = data[0].nombre;
            usuario = data[0].usuario;
            contraseña = data[0].contraseña;
            level = data[0].level;
            if(opcion == 1){tablausuarios.row.add([id,nombre,usuario,contraseña,level]).draw();}
            else{tablausuarios.row(fila).data([id,nombre,usuario,contraseña,level]).draw();}            
        }        
    });
    $("#modalCRUD").modal("hide");    
    
}); 


//botón EDITAR    
$(document).on("click", ".btnEditar", function(){
    fila = $(this).closest("tr");
    id = parseInt(fila.find('td:eq(0)').text());
    nombre = fila.find('td:eq(1)').text();
    pais = fila.find('td:eq(2)').text();
    edad = parseInt(fila.find('td:eq(3)').text());
    
    $("#nombre").val(nombre);
    $("#usuario").val(usuario);
    $("#contraseña").val(contraseña);
    $("#level").val(level);
    opcion = 2; //editar
    
    $(".modal-header").css("background-color", "#007bff");
    $(".modal-header").css("color", "white");
    $(".modal-title").text("Editar Usuario");            
    $("#modalCRUD").modal("show");  
    
});


//botón BORRAR

$(document).on("click", ".btnBorrar", function(){    
    fila = $(this);
    id = parseInt($(this).closest("tr").find('td:eq(0)').text());
    opcion = 3 //borrar
    var respuesta = confirm("¿Está seguro de eliminar el registro: "+id+"?");
    if(respuesta){
        $.ajax({
            url: "bd/crud.php",
            type: "POST",
            dataType: "json",
            data: {opcion:opcion, id:id},
            success: function(){
                tablausuarios.row(fila.parents('tr')).remove().draw();
            }
        });
    }   
});



});