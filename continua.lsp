;;	Programilla para hacer un acotado continuo
::	Lo que hace es una recta que la usa para seleccionar entidades con un borde
;;	de esas entidades se queda con todas las rectas y les calcula la interseccion
;;	con la primera recta.
;;	Las intersecciones salen desordenadas, así que para ordenarlas hago una lista
;;	de distancias al origen de cotas y ordeno las distancias



;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun cont-err (s)
  (if (/= s "Función cancelada")
      (princ (strcat "\nError: funcion cancelada "))	;; Debería cambiar funcion cancelada por s
  )
  (setq *error* olderr)
  (setq seleccion nil
  )
  (recupera-vars)
  (princ)
)

;;	-------------------------------------------------------------------------------
;;			Funcion para salvar las variables del sistema
;;	-------------------------------------------------------------------------------

(defun salva-vars (a)
  (setq MLST '())
  (repeat (length a)
    (setq MLST (append MLST (list (list (car a) (getvar (car a))))))
    (setq a (cdr a))
  )
)


;;	-------------------------------------------------------------------------------
;;			Funcion para recuperar las variables salvadas del sistema
;;	-------------------------------------------------------------------------------

(defun recupera-vars ()
  (repeat (length MLST)
    (setvar (caar MLST) (cadar MLST))
    (setq MLST (cdr MLST))
  )
)




;;	-------------------------------------------------------------------------------
;; 					FUNCION PRINCIPAL
;;	-------------------------------------------------------------------------------


(defun c:continua (/ inicio fin nombre vertical	
	entidad	seleccion num-sel indice
	ini-cota fin-cota aux aux2 mayor intersec
	lista-dist angulo lista-vars olderr
		)				


;;-------LLamar a la nueva funcion de error)
	(setq olderr *error* *error* cont-err)

;;	Guardar variables del sistema
	(salva-vars '("cmdecho" "blipmode" "expert" 
           "gridmode" "osmode" "thickness" "clayer")
	)

;;------Poner los valores que quiera en las variables del sistema------------
	(mapcar 'setvar
    		'("cmdecho" "blipmode" "expert" "gridmode"
      		"osmode" "thickness")
    		'(0 0 0 0 0 0)
 	 )



;;	Dibujar la recta y obtener la seleccion de los puntos

	(setq inicio (getpoint "\nPrimer punto de la cota continua: "))
	(setq fin (getpoint inicio "\nSegundo punto de la cota continua: "))	;Obtener el pto final
	(setq angulo (angle inicio fin))
	(setq seleccion (ssget "_f" (list inicio fin )))	

;;	Poner la capa cotas como la actual

	(if (not (tblsearch "LAYER" "COTAS"))		;crear la capa cotas si no existe
		(command "_LAYER" "_New" "Cotas" "_color" "_red" "cotas" "")
	)
	(setvar "CLAYER" "cotas")				;Poner la capa cotas como actual


	
	(if seleccion
    		(progn
		(setq num-sel (sslength seleccion))			;;verifico que haya selección
		(setq indice 0)	
		(setq lista-dist '())					;;Lista de distancias al inicio
		(repeat num-sel
	
		     (progn
			(setq nombre (ssname seleccion indice))			;;Obtener cada entidad
			(setq entidad (entget nombre ))				;;Selecciona entidad a aplastar
			(setq tipo (cdr (assoc 0 entidad)))			;;Obtiene el tipo de entidad	
			(if  (= tipo "LINE") 	
			     (progn
			     (setq intersec (inters (cdr ( assoc 10 entidad)) (cdr ( assoc 11 entidad)) inicio fin))
			     (setq lista-dist (append lista-dist (list (distance inicio intersec))))
			     )	
		   	
			
		     	)
		       	(setq indice (+ indice 1))
		     )
		) 	

	;;Verificar si la cota a colocar será vertical

		(setq vertical (if (< (abs(- (car inicio) (car fin))) 
				(abs(- (cadr inicio) (cadr fin))))
		T 
		nil
		))	


	;; Pedir el emplazamiento de las cotas

	(setq fin (getpoint "Emplazamiento de las líneas de cota: "))

	;; Hay que ordenar los puntos que se obtienen. La ordenación no es muy eficaz, pero funciona

		(setq ini-cota (apply 'min lista-dist))
		(setq mayor (apply 'max lista-dist))
		(setq lista-dist (subst mayor ini-cota lista-dist))
		(repeat (- (length lista-dist) 1)
			(progn
				(setq fin-cota (apply 'min lista-dist))
				(setq lista-dist (subst mayor fin-cota lista-dist))		
				(setq aux (polar inicio angulo ini-cota))
				(setq aux2 (polar inicio angulo fin-cota))
				(if vertical
					(command "_dimlinear" aux aux2 "_V" fin)
					(command "_dimlinear" aux aux2 fin)
				)
				(setq ini-cota fin-cota)

			)	;;progn

		)		;;repeat

		)  		;;Progn del "if seleccion.."

	)	   		;;if seleccion...


(setq *error* olderr)		;;Volver a poner los errores en condiciones
(recupera-vars)
(princ)				;Para que no salga ningun valor en la línea de comandos


)






;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------

(princ "\nCota continua cargada.Hace cotas continuas horizontales y verticales")	
(princ)

