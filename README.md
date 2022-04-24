# CADlaberote
Utilidades sencillas en lisp para arquitectura en Autocad (hacer muros, puertas, ventanas...).

Todas utilidades funcionan por línea de comandos, algunos comandos tienen dos nombres (uno largo y uno corto).

Está pensado para dibujos en metros, ya que las medidas por defecto del ancho del muro son 30cm (0.3) y de las puertas 72cm (0.72)


## Instalación
1. Descarga los ficheros en una carpeta (y recuerda su nombre).
2. Abre autocad
3. Escribe OPTIONS, Despliega el apartado "Support File Search Path" o "Ruta de Búsqueda de Archivos de Soporte", y añade la carpeta del punto 1)
4. Escribe ahora APPLOAD, elige "Startup suite" o "Cargar al inicio" y navega hasta la carpeta del punto 1. De todos los ficheros elegir "Arquitectura.lsp"
5. Si todo es correcto en la consola aparece un mensaje que dice "Programas de arquitectura preparados"

## Funciones de dibujo
## muro o mr
Crea un muro. Se elige el punto inicial y final del muro (que definen una de las líneas paralelas) y el lado para el que va el muro (donde irá la línea paralela que define el muro). También da la opción de cerrar el muro. 

Para cambiar el ancho del muro, una vez marcado un primer punto del muro usar la opción por línea de comandos "Ancho".

El programa identifica como muro a cualquier par de líneas paralelas de la capa Muros.

### puerta o pt
Crea una puerta. Pide el punto en el que se sitúa la bisagra y hacia donde abre la puerta. Debe estar situada en un muro creado con la orden muro (o en dos lineas paralelas de la capa Muros). La puerta se crea en la capa Carpinteria
### puertadoble o ptd
Igual que puerta, pero doble.
## ventana o ven
Genera una ventana, de forma similar a cómo se crea una puerta y en su misma capa.

## Funciones para modificar puertas y ventanas
### modifipt o mop
Muestra una imágen de una puerta simple y pide los parámetros de la puerta (tamaño de la jamba y de la hoja)
### modifptd o mopd
Muestra la imagen de una puerta doble y pide los parámetros de las puerdas dobles (tamaño de las jambas y de las dos hojas)
### modifven o moven
Muestra la imagen de una ventana simple y una ventana doble y pide sus parémtros:
- Tipo de ventana: simple, doble, 3 hojas o 4 hojas
- Lleva alfeizar: si o no
- Tamaño del cristal
- Ancho del perfil
- Centrar en el muro: si o no

### gic o giracarp
Seleccionando una puerta/ventana (simple o doble) permite cambiarle la dirección en cualquiera de los dos ejes.

### despcarp o dpc
Seleccionando una puerta/ventana (simple o doble) permite desplazarla en la dirección del muro en el que está puesta.

### borracarp o boc
Borra una carpintería y restablece el muro.

## Utilidades varias
### aplasta
Le aplica cota 0 (valor z=0) a todas las entidades del dibujo actual.
### continua
Crea una cota continua: se marca una línea de inicio y una línea de fin y genera cotas de todos los elementos que se crucen con la línea dada y alineada con ella
### corta o xtrim
Marcando un punto corta el segmento marcado hasta la intersección más próxima. Útil por ejemplo si se cruzasen dos muros y no se hace correctamente la union, para borrar los cruces.
### extiende o xtend
Marcado un extremo de una entidad (por ejemplo, una línea) la extiende hasta la primera entidad con la que se cruce.
### triang
Marcando una línea base se dan las distancias respecto a cada uno de los dos extremos de la misma y la dirección ha la que se quiere dibujar el triángulo y lo dibuja.
### une
Si dos muros se cruzan y no están correctamente unidos, marcandolos con esta orden se hace el cruce correcto.
### m2 o metro2
Marcando un texto le añade un superíndice 2 al final.
