# PeRISCore32

## Estructura de directorios y ficheros del proyecto:

* constraints: para incluir ficheros de restricciones *.xdc*.
* doc: alberga documentación autogenerada con *doxygen*.
* hls: incluir archivos fuentes para síntesis de alto nivel
       (C/C++) si fuese necesario. En este momento no existen
        archivos fuente de tal tipo en el proyecto.
* ip: almacenar ficheros relacionadas con la generación de bloques IP
      que necesiten seguimiento en el sistema de control de versiones,
      si fueran necesarios.
* rtl: almacenar archivos fuente HDL de PeRISCore32, más todos los 
       scripts auxiliares necesarios y microcódigos.
        * images: almacena ficheros de programas de prueba en ensamblador *.asm*,
                  y ficheros de texto *.dat* con el código máquina de sus respectivos
                  programas en ensamblador en forma de lineas de carácteres de 0s y 1s.
                  También incluye *fill_image.py*, el script para procesar los ficheros
                  de código máquina que genera el simulador MARS y así puedan cargarse
                  en la cache de instrucciones mediante VHDL.
        * microcode: incluye ficheros *.csv*, *.dat*, ficheros de licencia,
                     script *gen_microcode.py* y un makefile.
                     Los ficheros *.csv* contienen el "microcódigo" del procesador,
                     los valores de las señales de control para cada instrucción o
                     clase de instrucciones del procesador. Mediante el script de 
                     python generamos los ficheros *.dat* que se pueden cargar 
                     mediante VHDL en las unidades de control de nuestro diseño.
                     El makefile simplifica la generación de los ficheros, pues
                     solo hay que ejecutar el comando **make** dentro del directorio
                     **rtl/microcode** para regenerarlos. Y para borrarlos **make clean**.
        * periscore32.tcl: script de vivado para regenerar el proyecto en workspace
* testbenches: almacenar testbenches para probar el código HDL del
               directorio *rtl*.
               * images: directorio que almacena ficheros *.dat* con los datos de 
                         salida de los programas ensamblador de prueba que aplican
                         algunos testbench para probar el pipeline. Estos ficheros
                         son generados por el simulador MARS y deben recortarse a
                         256 líneas de texto para que los testbenches los usen
                         como "golden data".
* workspace: directorio donde se encuentra el proyecto de vivado

## Acceder a la documentación de los ficheros fuente en html
Si el directorio *doc* se encuentra vacío, se puede generar la documentación
situandose con una terminal en el directorio raíz del proyecto yejecutando 
el comando:

doxygen Doxyfile

Entonces encontrará la documentación abriendo con un navegador el fichero:

[](doc/html/index.html)

Necesitará tener doxygen instalado en su sistema.

## Simulador de ensamblador
El simulador MARS se puede obtener de: [MARS](http://courses.missouristate.edu/kenvollmar/mars/download.htm)