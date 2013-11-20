Building a Simple Sinatra Tic-Tac-Toe game 
==================================================

App currently contains:

* app.rb - the application code
* Gemfile - specifies the gems this app relies on
* Gemfile.lock - automatically generated dependancy file
* views/ - this is the default folder for erb views
* layout.erb - this is the default layout to be used for all erb files
* public/ - this is the default folder for serving static assets
* Procfile - this tells Heroku or Foreman how to run the application
* Rakefile- installs the gems and run the server

1. Objetivo
-----------
	
	1.1. Añadir una base de datos a la práctica del TicTacToe para guardar a los usuarios y sus puntuaciones. 
	1.2. Las celdas pares e impares seran de distintos colores. 
	1.3. Deberá tener una lista de jugadores con sus registros.
	1.4. Desplegar la aplicación en Heroku. 


2. Instalar:
------------

	sudo apt-get install libecpg-dev
	sudo apt-get install postgresql-client
	sudo apt-get install postgresql

3. Ejecucción
-------------

	rake css --> Si se modifica el fichero .scss
	rake --> Arracar la app

4. Mostrar aplicación
---------------------

	Local: htpp://localhost:4567

	Heroku: http://stw-tresenraya.herokuapp.com/
