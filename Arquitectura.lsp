;;Archivos de autocarga de los programas de arquitectura que 
;;estoy haciendo el verano del 99

;;Cargar el menu (necesario en autocad 2006 y superior...

;;(load "MenuCADlaberote")
;;(C:MenuCADlaberote)

;; Primero, añadir el directorio PRG al entorno de Autocad si no existía

(defun pepe (/ aux a n indice)
	(setq n (getenv "ACAD"))

	;; Vamos a buscar prg en la cadena esta
		
	;; Primero, la convierto a mayúsculas
	(setq n (strcase n))
	(setq aux (strlen n))

	(setq indice 1)

		(while (and (< indice (- aux 1)) (> indice 0))		;; Ya localiza la cadena al final
			(if (= (substr N indice 3) "PRG")
				(setq indice -1)
				(setq indice (+ indice 1))
			)
		) 

	(if (= -1 indice) (print "Entorno de arquitectura OK"))
	(if (/= indice -1)
		(progn
		(setq a (strlen n))
		(if (/= (substr n a) ";")			;; Si no acaba en ;
			(setq n (Strcat n ";"))	;;Ponerselo
		)
		(setq a (strcase (findfile "acad.exe")))
		(setq a (substr a 1 (- (strlen a) 8) ))		;;Quitarle el "acad.exe"
		(setq a (strcat a "PRG"))			;;Añadir el directorio PRG
		(setq n (strcat n a))
		(setenv "ACAD" n)
		(setq a nil)	;; Liberar memoria
		)
	)
)

;;Esta función no es necesario ejecutarla porque el instalador se ocupa ya de que 
;;el path está bien ajustado ya.

;;(pepe)				;;Ejecutar
;;(setq pepe nil)			;;Liberar memoria


;; Luego, cargar todos los comandos y sus alias

(load "util")

(autoload "aplasta" 		'("aplasta" ))
(autoload "puerta" 		'("puerta" "pt" ))
(autoload "puerta-doble"	'("puertadoble" "ptd"))
(autoload "continua" 		'("continua" ))
(autoload "corta" 		'("corta" "xtrim"))
(autoload "extiende" 		'("extiende" "xtend"))
(autoload "muro" 		'("muro" "mr" ))
(autoload "ventana" 		'("ventana" "ven" ))
(autoload "giracarp" 		'("gic" "giracarp" ))
(autoload "despcarp" 		'("despcarp" "dpc" ))
(autoload "modifpt" 		'("modifpt" "mop" ))
(autoload "modifptd" 		'("modifptd" "mopd" ))
(autoload "modifven" 		'("modifven" "moven" ))
(autoload "borracarp" 		'("borracarp" "boc" ))
(autoload "triang" 		'("triang" ))
(autoload "une" 		'("une" ))
(autoload "metro2" 		'("m2" "metro2" ))


;; Inicializar variables para las órdenes de dibujo

;; Variables 2D

;; Para la puerta 2D
(setq	anchop	0.72
	jamba	0.05
)

;; Para la puerta doble

(setq anchoh1 	0.6)				; Inicializar el ancho de una hoja de la puerta
(setq anchoh2	0.5)				; Inicializar el ancho de la otra hoja
(setq jamba 	0.05)

;; Para la ventana

(setq 	cristal	0.5				; Inicializar el ancho de la ventana
	perfil 	0.05				; Inicializar el ancho del perfil de la jamba
	alf	"Si"				; Por defecto con alfeizar y de 3 cm
	alfeiz  0.03
	tipo	"Doble"				; Ventana doble SI
	centrar "No"				; No centrar en el muro
)

;; Para el muro

(setq anchom 	0.2)


;; Para las 3D

(setq 	altop	2.3				;; Alto de puertas
	altom 	2.7)				;; Alto de muros





(prompt "\nProgramas de arquitectura preparados")