<head>
    <title>Posada | <?php echo ucfirst(str_replace('-',' ',$lfmc['link'][0]));?></title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="interfaz/usuario/assets/css/main.css" />
    <link rel="stylesheet" href="interfaz/usuario/assets/fontawesome-free/css/all.min.css" />
    <link rel="icon" href="interfaz/usuario/images/logo.ico">

	
	<script src="interfaz/usuario/assets/jquery/jquery.min.js"></script>
	<script src="interfaz/usuario/assets/jquery.form/jquery.form.min.js"></script>

	<style>	
		.form-group {
		margin-bottom: 1rem;
		}
		@media (min-width: 576px) {
		.form-group {
			display: flex;
			flex: 0 0 auto;
			flex-flow: row wrap;
			align-items: center;
			margin-bottom: 0;
		}
		}
		.form-control {
		display: block;
		width: 100%;
		height: calc(1.5em + 0.75rem + 2px);
		padding: 0.375rem 0.75rem;
		font-size: 1rem;
		font-weight: 400;
		line-height: 1.5;
		color: #6e707e;
		background-color: #fff;
		background-clip: padding-box;
		border: 1px solid #d1d3e2;
		border-radius: 0.35rem;
		transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
		}

		@media (prefers-reduced-motion: reduce) {
		.form-control {
			transition: none;
		}
		}

		.form-control::-ms-expand {
		background-color: transparent;
		border: 0;
		}

		.form-control:-moz-focusring {
		color: transparent;
		text-shadow: 0 0 0 #6e707e;
		}

		.form-control:focus {
		color: #6e707e;
		background-color: #fff;
		border-color: #bac8f3;
		outline: 0;
		box-shadow: 0 0 0 0.2rem rgba(78, 115, 223, 0.25);
		}

		.form-control::-webkit-input-placeholder {
		color: #858796;
		opacity: 1;
		}

		.form-control::-moz-placeholder {
		color: #858796;
		opacity: 1;
		}

		.form-control:-ms-input-placeholder {
		color: #858796;
		opacity: 1;
		}

		.form-control::-ms-input-placeholder {
		color: #858796;
		opacity: 1;
		}

		.form-control::placeholder {
		color: #858796;
		opacity: 1;
		}

		.form-control:disabled, .form-control[readonly] {
		background-color: #eaecf4;
		opacity: 1;
		}

		input[type="date"].form-control,
		input[type="time"].form-control,
		input[type="datetime-local"].form-control,
		input[type="month"].form-control {
		-webkit-appearance: none;
		-moz-appearance: none;
		appearance: none;
		}

		select.form-control:focus::-ms-value {
		color: #6e707e;
		background-color: #fff;
		}

		.form-control-file,
		.form-control-range {
		display: block;
		width: 100%;
		}
		.col-form-label {
		padding-top: calc(0.375rem + 1px);
		padding-bottom: calc(0.375rem + 1px);
		margin-bottom: 0;
		font-size: inherit;
		line-height: 1.5;
		
		}
	</style>
</head>