;;	Programilla para recortar una entidad señalando solo un punto



;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun prog-err (s)
  (if (/= s "Función cancelada")
      (princ (strcat "\nError: nada que recortar "))	;; Debería cambiar funcion cancelada por s
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




(defun corta (/  pt1 		seleccion	punto		dist
		   X		Y		sel
		)				




;;-------LLamar a la nueva funcion de error)
	(setq olderr *error* *error* prog-err)

;;	Guardar variables del sistema
	(salva-vars '("cmdecho" "blipmode" "expert" 
           "gridmode" "osmode" "thickness" "clayer"
	   "OFFSETDIST" )
	)

;;------Poner los valores que quiera en las variables del sistema------------
	(mapcar 'setvar
    		'("cmdecho" "blipmode" "expert" "gridmode"
      		"osmode" "thickness")
    		'(0 0 0 0 0 0)			
 	 )



	;;Forma retorcida de obtener la entidad y el punto a la vez. 
	;;Obtengo la entidad para ver que si señalo algo que no sea en una
	;;Entidad, no encuentre el punto

	(setq sel (entsel  "\nSeleccione punto a recortar"))
	
	(setq pt1 	(cadr sel))

;	(setq nombre 	(car sel))	ESTA LINEA QUEDA PARA OTRA VEZ POR SI LO NECESITO



;; Y ahora, bucle
	(While sel
		(progn

		;; Obtengo las coordenadas X e Y del tamaño en pixels de la pantalla

		(setq X (getvar "SCREENSIZE"))
		(setq Y	(cadr X) X (car X))

		;; Veo cual es el tamaño real de la pantalla en unidades de dibujo

		(setq X (* X (/ (getvar "VIEWSIZE") Y)))
		(setq Y (getvar "VIEWSIZE"))

		;; Y ahora, no hay más que centrarlo

		(setq punto (list X Y))
		(setq angulo (angle '(0 0) punto))
		(setq dist (/ (distance '(0 0) punto) 2 ))
		(setq X (polar (getvar "VIEWCTR") angulo dist))
		(setq Y (polar (getvar "VIEWCTR") (+ pi angulo) dist))  

		(setq pt1 	(cadr sel))
		(setq seleccion (ssget "_c" X Y))
		(command "_trim" seleccion "" pt1 "")

		(setq sel (entsel  "\nSeleccione punto a recortar"))
		)
	)


(setq *error* olderr)		;;Volver a poner los errores en condiciones
(recupera-vars)
(prin1)				;Para que no salga ningun valor en la línea de comandos


)






;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------

(defun c:corta () (corta))
(defun c:xtrim () (corta))		;; Alias de la orden


(princ "\nFuncion para recortar cosas seleccionando solo un punto...cargada OK")	
(princ)

