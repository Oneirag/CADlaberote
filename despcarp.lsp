;;	Programilla para desplazar una carpintería



;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun prog-err (s)
  (if (/= s "Función cancelada")
      (princ (strcat "\nError: no se encuentra una carpintería o un muro "))	
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


;; La variable anchop hay que guardarla en el dibujo y todavía no sé como

(defun muevecar 	(/ nombre 	entidad
		   )				




;;-------LLamar a la nueva funcion de error)
	(setq olderr *error* *error* prog-err)

;;	Guardar variables del sistema
	(salva-vars '("cmdecho" "blipmode" "expert" 
           "gridmode" "osmode" "thickness" "clayer"
	   "OFFSETDIST" "ORTHOMODE" "SNAPANG")
	)

;;------Poner los valores que quiera en las variables del sistema------------
	(mapcar 'setvar
    		'("cmdecho" "blipmode" "expert" "gridmode"
      		"osmode" "thickness" "ORTHOMODE" )
    		'(0 0 0 0 0 0 0)			
 	 )




(setvar "CLAYER" "carpinteria")		;; Si da error, es que no hay capa carpintería



(setq nombre (entsel "\nSelecciona la carpintería a girar: "))
	
(setq nombre (car nombre))
(setq entidad (entget nombre))
(if (or (/= (cdr(assoc 0 entidad)) "INSERT") 
	(/= (strcase (cdr(Assoc 8 entidad))) "CARPINTERIA")
    )
(/ 0 0)			;;Provoco un error si no es una carpintería
)




(setvar "SNAPANG" 	(cdr(assoc 50 entidad)))
(setvar "orthomode" 1)
(command "_move" nombre "" (cdr(assoc 10 entidad)) pause )


(recupera-vars)
(setq  *error* olderr)
(prin1)

)



;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------


(defun c:despcarp () 	(muevecar))
(defun c:dpc ()		(muevecar))		;Alias de la orden

(princ "\nFuncion para mover carpinterías en un muro en 2D...cargada OK")	
(princ)

