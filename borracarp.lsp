;;	Programilla para borrar una carpintería



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

(defun borrac 	(/ bisagra 	cosamuro 	datosmuro 	angulo 
		   pt1 		pt2 		seleccion	num-sel
		   indice	nombre	        entidad		pgrosor	
		   p4		p5		mensaje         aux		
		   nuevovalor
		)				




;;-------LLamar a la nueva funcion de error)
	(setq olderr *error* *error* prog-err)

;;	Guardar variables del sistema
	(salva-vars '("cmdecho" "blipmode" "expert" 
           "gridmode" "osmode" "thickness" "clayer"
	   "OFFSETDIST" "ORTHOMODE")
	)

;;------Poner los valores que quiera en las variables del sistema------------
	(mapcar 'setvar
    		'("cmdecho" "blipmode" "expert" "gridmode"
      		"osmode" "thickness" "ORTHOMODE")
    		'(0 0 0 0 0 0 0)			
 	 )



(setvar "CLAYER" "carpinteria")		;; Si da error, es que no hay capa carpintería


(setq sel (ssadd))

(setq nombre (entsel "\nSelecciona la carpintería a borrar: "))
	
(setq nombre (car nombre))
(setq sel (ssadd nombre sel))
(setq entidad (entget nombre))
(if (or (/= (cdr(assoc 0 entidad)) "INSERT") 
	(/= (strcase (cdr(Assoc 8 entidad))) "CARPINTERIA")
    )
(/ 0 0)			;;Provoco un error si no es una carpintería
)




;; Ahora, voy a seleccionar los trazos que me dan el ancho del muro y del hueco

(setq bisagra (cdr(assoc 10 entidad)))

;; Coger las dos líneas del ancho de la carpintería

(setq angulo 	(cdr(assoc 50 entidad)))

(setq seleccion	(ssget "_c" bisagra bisagra '((0 . "LINE")) )) 		

(setq      aux 	seleccion)


;;Ahora, hay que quitar de la selección la línea del muros

		(setq num-sel (sslength seleccion))			
		(setq indice 0)	
		
		(repeat (- num-sel 1)
		     (progn
			
			
			(setq nombre (ssname seleccion indice))			;;Obtener cada entidad
			(setq 	entidad 	(entget nombre)
				pt1		(cdr(assoc 10 entidad))				
				pt2		(cdr(assoc 11 entidad))
				)

  		   	(if 	(or
	 			(equal angulo (angle pt1 pt2) 0.001)	 
	 			(equal angulo (angle pt2 pt1) 0.001)	 
	 			)
				(setq aux (ssdel nombre aux))
			)

		       	(setq indice (+ indice 1))
		     )		

		)

(setq seleccion aux)
(setq nombre (ssname seleccion 0) )
(setq sel (ssadd nombre sel))
(setq sel (ssadd (entnext nombre) sel))


(setq bisagra (cdr (assoc 10 (entget nombre) ) ))
(setq pgrosor (cdr (assoc 11 (entget nombre) ) ))
(setq p4      (cdr (assoc 10 (entget (entnext nombre)) ) ))
(setq p5      (cdr (assoc 11 (entget (entnext nombre)) ) ))	

;; Me cargo lo 2D
(command "_erase" sel "")

(setq nombre (ssname (ssget "_c" bisagra bisagra '((0 . "LINE") ) )  0) )
(setq entidad (entget nombre) )
(setq pt1 
	(if (equal 0 (distance bisagra (cdr(Assoc 10 entidad))) 0.00001 )
		(cdr(Assoc 11 entidad))
		(cdr(Assoc 10 entidad))
	)
)
(entdel nombre)



(setq entidad (entget (ssname (ssget "_c" p4 p4 '((0 . "LINE") ) ) 0) ) )
(setq entidad 
	(if (equal 0 (distance p4 (cdr(Assoc 10 entidad))) 0.001)
		(subst (append '(10) pt1) (assoc 10 entidad) entidad)
		(subst (append '(11) pt1) (assoc 11 entidad) entidad)
	)
)
(entmod entidad)


(setq nombre (ssname (ssget "_c" pgrosor pgrosor '((0 . "LINE")) )  0) )

(setq entidad (entget nombre ))
(setq pt1 
	(if (equal 0 (distance pgrosor (cdr(assoc 10 entidad))) 0.001)
		(cdr(assoc 11 entidad))
		(cdr(assoc 10 entidad))
	)
)
(entdel nombre)


(setq entidad (entget (ssname (ssget "_c" p5 p5 '((0 . "LINE") ) ) 0) ) )
(setq entidad 	   
	(if (equal 0 (distance p5 (cdr(assoc 10 entidad))) 0.0000000001)
		(subst (append '(10) pt1) (assoc 10 entidad) entidad)
		(subst (append '(11) pt1) (assoc 11 entidad) entidad)
	)
)
(entmod entidad)




(setq *error* olderr)		;;Volver a poner los errores en condiciones
(recupera-vars)
(prin1)

)



;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------


(defun c:borracarp () 	(borrac))
(defun c:boc ()		(borrac))		;Alias de la orden

(princ "\nFuncion para borrar carpinterías en un muro en 2D...cargada OK")	
(princ)

