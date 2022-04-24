;;	Programilla para escribir el cuadrado de los metros cuadrados




;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun prog-err (s)
  (if (/= s "Función cancelada")
      (princ (strcat "\nError: No encuetro un texto "))
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
;; 					FUNCION PRINCIPAL
;;	-------------------------------------------------------------------------------



(defun   metro2 (/   	texto		altura-txt	angulo-txt	
			aux		inicio		fin
			nombre	
		)				




;;-------LLamar a la nueva funcion de error)
	(setq olderr *error* *error* prog-err)

;;	Guardar variables del sistema
	(salva-vars '("cmdecho" "blipmode" "expert" 
           "gridmode" "osmode" "thickness" "clayer"
	   "OFFSETDIST" "FILLETRAD")
	)

;;------Poner los valores que quiera en las variables del sistema------------
	(mapcar 'setvar
    		'("cmdecho" "blipmode" "expert" 
      		"thickness" "osmode" "FILLETRAD")
    		'(0 0 0 0 0 0)
 	 )


(command "_undo" "_begin" )


(setq nombre  (car (entsel "\nSeleccione el texto acabado en m para poner el cuarado: ")))
(setq texto (entget nombre))
(if (/= (cdr (assoc 0 texto)) "TEXT")		;; Si no es un texto, error!!!
	(exit)
)

(setq aux (textbox texto))
(setq fin (mapcar '+ (cdr(assoc 10 texto)) (cadr aux) ))
(setq 	altura-txt 	(cdr(assoc 40 texto))
	angulo-txt 	(cdr(assoc 50 texto))
)

(setq inicio (polar fin (- angulo-txt (/ pi 2) ) (/ altura-txt 2) ))
(setq inicio (polar inicio angulo-txt (/ altura-txt 8 )))

;; Por si falla algún día, poner esto:
;;	(setq inicio (polar inicio angulo-txt (/ altura-txt (* 5 (cdr(assoc 41 texto))))))

(setq texto  (subst (append '(10) inicio) (assoc 10 texto) texto))		;;Poner el origen
(setq texto  (subst (cons 1 "2") (assoc 1 texto) texto))			;;Poner un 2
(setq texto  (subst (cons 40 (/ altura-txt 2)) (assoc 40 texto) texto))		;;Reducir tamaño
(entmake texto)	




(command "_undo" "_end" )

(setq *error* olderr)		;;Volver a poner los errores en condiciones
(recupera-vars)
(prin1)				;Para que no salga ningun valor en la línea de comandos


)






;;	-------------------------------------------------------------------------------
;; 				MENSAJE HORTERA E INICIALIZACIONES
;;	-------------------------------------------------------------------------------



(defun c:metro2 () (metro2))
(defun c:m2   	() (metro2))				;; Alias de la orden

(princ "\nFuncion para dibujar un m^2 en condiciones")	
(princ)

