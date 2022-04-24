;;	Programilla para hacer union de dos muros




;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun prog-err (s)
  (if (/= s "Función cancelada")
      (princ (strcat "\nError: No encuetro dos muros "))	;; Debería cambiar funcion cancelada por s
  )
  (setq *error* olderr)
  (setq seleccion nil
  )
  (command "_undo" "_end" )
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
;;			Funciones para devolver el pto final e inicial de una línea
;;	-------------------------------------------------------------------------------

(defun pto-fin (cosa )
	(cdr (assoc 11 (entget cosa)))
)


(defun pto-ini (cosa )
	(cdr (assoc 10 (entget cosa)))
)








;;	-------------------------------------------------------------------------------
;; 					FUNCION PRINCIPAL
;;	-------------------------------------------------------------------------------


;; La variable anchom hay que guardarla en el dibujo y todavía no sé como

(defun   union (/   	pto1 		pto2		seleccion	indice
			nombre		aux		linea1		linea2
			linea3		linea4		muro1		muro2
			int1		int2		int3 		int4
		)				




;;-------LLamar a la nueva funcion de error)
;	(setq olderr *error* *error* prog-err)

;;	Guardar variables del sistema
	(salva-vars '("cmdecho" "blipmode" "expert" 
           "gridmode" "osmode" "thickness" "clayer"
	   "OFFSETDIST" "FILLETRAD")
	)

;;------Poner los valores que quiera en las variables del sistema------------
	(mapcar 'setvar
    		'("cmdecho" "blipmode" "expert" 
      		"thickness" "osmode" "FILLETRAD")
    		'(1 0 0 0 0 0)
 	 )


(command "_undo" "_begin" )




(if (not (tblsearch "LAYER" "MUROS"))
	(progn
	(prompt "\nEste dibujo no tiene muros..")
	(exit)						;; Causa un error
	)
)

(setq pto1 (getpoint "\nDesde: "))
(setq pto2 (getcorner pto1 "\nHasta: "))
(setq seleccion (ssget "_C" pto1 pto2 '((8 . "MUROS") (0 . "LINE")) ) )	

(if (not seleccion)					;; Si no encuentra nada 
	(exit)						;; error
	(if (or (< (sslength seleccion) 4)			;; Si no encuentra lo suficiente	
		(> (sslength seleccion) 5)			;; O encuentra demasiado ...
	    )	
		(exit)					;; Error tambien
	)
)

;; Por si encuentra 5, lo primero es borrar la que sobra

(setq aux (ssget "_W" pto1 pto2 '((8 . "MUROS") (0 . "LINE")) ) )	
(if aux
	(if (> (sslength aux) 1)			;; Si encuentra demasiado
		(exit)					;; error
		(command "_erase" aux "")		;; Si no, a borrar	
	)
)

;; Bueno, ya tengo en teoría cuatro líneas que se cruzan y que quiero recortar

;; ahora, a encontrar líneas paralelas dos a dos
(setq 	linea1	(ssname seleccion 0)
	linea2	(ssname seleccion 1)
	linea3	(ssname seleccion 2)
	linea4	(ssname seleccion 3)
)

(setq 	muro1 		(ssadd linea1)
	seleccion 	(ssdel linea2 seleccion) 
)


(if (equal (angle (pto-ini linea1) (pto-fin linea1)) (angle (pto-ini linea2) (pto-fin linea2)) 0.001)
	(setq 	muro1 		(ssadd linea2 muro1)
		seleccion 	(ssdel linea2 seleccion) 
		muro2		(ssadd linea3)
		muro2		(ssadd linea4 muro2)
	) 
	(if (equal (angle (pto-ini linea1) (pto-fin linea1)) (angle (pto-ini linea3) (pto-fin linea3))0.001 )
		(setq 	muro1 (ssadd linea3 muro1)
			seleccion 	(ssdel linea3 seleccion) 
			muro2		(ssadd linea2)
			muro2		(ssadd linea4 muro2)
			) 
		(if (equal (angle (pto-ini linea1) (pto-fin linea1)) (angle (pto-ini linea4) (pto-fin linea4)) 0.001)
			(setq 	muro1 (ssadd linea4 muro1) 
				seleccion 	(ssdel linea4 seleccion) 
				muro2		(ssadd linea3)
				muro2		(ssadd linea2 muro2)
				) 
 
			(exit)		;; Si no encuetro paralela, error
		)
	)
)


;; Comprobar que lo que queda sea un muro

(setq 	linea1	(ssname muro1 0)
	linea2	(ssname muro1 1)
	linea3	(ssname muro2 0)
	linea4	(ssname muro2 1)
)

(if (not (equal (angle (pto-ini linea3) (pto-fin linea3)) (angle (pto-ini linea4) (pto-fin linea4)) 0.001))
	(exit)
)

(setq seleccion nil)			;; Liberar memoria

;; Ya están agrupados por muros.

;; Esto está bien
;(command "_move" linea1 "" "0,0" pause)
;(command "_move" linea2 "" "0,0" pause)
;(command "_move" linea3 "" "0,0" pause)
;(command "_move" linea4 "" "0,0" pause)

;; Empiezo a recortar las cosas
(setq 	int1 (inters 	(pto-ini linea1)
			(pto-fin linea1)
			(pto-ini linea3)
			(pto-fin linea3)
		)
	int2 (inters 	(pto-ini linea1)
			(pto-fin linea1)
			(pto-ini linea4)
			(pto-fin linea4)
		)
	int3 (inters 	(pto-ini linea2)
			(pto-fin linea2)
			(pto-ini linea4)
			(pto-fin linea4)
		)
	int4 (inters 	(pto-ini linea2)
			(pto-fin linea2)
			(pto-ini linea3)
			(pto-fin linea3)
		)


)

(if (not (or (not int1) (not int2)))
	(command "_break" linea1 
			(inters 	(pto-ini linea1)
			(pto-fin linea1)
			(pto-ini linea3)
			(pto-fin linea3)
			nil
		)
			(inters 	(pto-ini linea1)
			(pto-fin linea1)
			(pto-ini linea4)
			(pto-fin linea4)
			nil
		)


	)
)

(if (not (or (not int1) (not int2)))
	(command "_break" linea2 

	(inters 	(pto-ini linea2)
			(pto-fin linea2)
			(pto-ini linea4)
			(pto-fin linea4)
			nil
		)
	(inters 	(pto-ini linea2)
			(pto-fin linea2)
			(pto-ini linea3)
			(pto-fin linea3)
			nil
		)
	)


)
(if (not (or (not int1) (not int2)))
	(command "_break" linea3 
		(inters 	(pto-ini linea1)
			(pto-fin linea1)
			(pto-ini linea3)
			(pto-fin linea3)
			nil
		)
		(inters 	(pto-ini linea2)
			(pto-fin linea2)
			(pto-ini linea3)
			(pto-fin linea3)
			nil
		)
	)



)
(if (not (or (not int1) (not int2)))
	(command "_break" linea4 
	(inters 	(pto-ini linea1)
			(pto-fin linea1)
			(pto-ini linea4)
			(pto-fin linea4)
			nil
		)
	(inters 	(pto-ini linea2)
			(pto-fin linea2)
			(pto-ini linea4)
			(pto-fin linea4)
			nil
		)

	)



)





(command "_undo" "_end" )

;(setq *error* olderr)		;;Volver a poner los errores en condiciones
(recupera-vars)
(prin1)				;Para que no salga ningun valor en la línea de comandos


)






;;	-------------------------------------------------------------------------------
;; 				MENSAJE HORTERA E INICIALIZACIONES
;;	-------------------------------------------------------------------------------



;; La orden UNION ya existe!!, es para unir sólidos (defun c:union () (union))
(defun c:une   () (union))				;; Alias de la orden

(princ "\nFuncion para unir muros...cargada OK")	
(princ)

