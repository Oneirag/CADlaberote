;;	Programilla para GIRAR una carpintería



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




(defun girac 	(/ bisagra 	cosamuro 	datosmuro 	angulo 
		   pt1 		pt2 		seleccion	num-sel
		   fallo	indice		lista-dist	nombre
		   entidad	angulo-aux	distancia	intersec		
		   pgrosor	p4		p5		mensaje
		   linea1	linea2		aux		nuevovalor
		   hueco	
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


(setq sel (ssadd))

(setq nombre (entsel "\nSelecciona la carpintería a girar: "))
	
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

;; Esto es necesario para cuando le haya dado la vuelta a la carp, que no salga mal
;(if (= (cdr(assoc 41 entidad)) -1) (setq angulo (+ angulo pi)))


(setq seleccion	(ssget "_c" bisagra bisagra '((0 . "LINE")) )) 		

(setq      aux 	seleccion)
(setvar	"SNAPANG"  angulo )						;; Snapang va en radianes


;;Ahora, hay que quitar de la selección la línea del muros

		(setq num-sel (sslength seleccion))			
		(setq indice 0)	
		(print num-sel)
		(repeat (- num-sel 1)
		     (progn
			(print indice)
			(print (ssname seleccion indice))
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

(setq pt1 (polar pgrosor (angle pgrosor p4) 
	(/ (distance pgrosor p4) 2) ))

(setvar "orthomode" 1)
(command "_mirror" sel "" pt1 pause "_y")


(recupera-vars)
(setq  *error* olderr)
(prin1)

)








;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------


(defun c:giracarp () 	(girac))
(defun c:gic ()		(girac))		;Alias de la orden

(princ "\nFuncion para girar carpinterías en un muro en 2D...cargada OK")	
(princ)

