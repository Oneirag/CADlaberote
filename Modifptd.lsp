;;	Programilla para modificar los valores de una puerta



;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun prog-err (s)
  (if (/= s "Función cancelada")
      (princ (strcat "\nError: funcion cancelada "))	;; Debería camniar funcion cancelada por s
  )
  (redraw)	
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


(defun modificapuertad (/ mensaje  nuevovalor
		)				

;;-------LLamar a la nueva funcion de error)
	(setq olderr *error* *error* prog-err)

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


(command "_vslide" "puerta-doble")


 ;solicita el ancho de las hojas

  (setq mensaje (strcat "\nAncho de la hoja 1 <" (rtos anchoh1) ">: "))
  (if (setq nuevovalor (getdist mensaje)) (setq anchoh1 nuevovalor))

	;;Redondeo a un número entero de centímetros
 
 (setq anchoh1 (distof (rtos anchoh1 2 2) 2 ) )

  (setq mensaje (strcat "\nAncho de la hoja 2 <" (rtos anchoh2) ">: "))
  (if (setq nuevovalor (getdist mensaje)) (setq anchoh2 nuevovalor))

	;;Redondeo a un número entero de centímetros
 
 (setq anchoh2 (distof (rtos anchoh2 2 2) 2 ) )



 ;solicita el ancho de la jamba 

 (setq mensaje (strcat "\nAncho de la jamba <" (rtos jamba) ">: "))

 (if (setq nuevovalor (getdist mensaje)) (setq  jamba nuevovalor))

	;;Redondeo a un número entero de centímetros
 
 (setq jamba (distof (rtos jamba 2 2) 2 ) )


(redraw)





(setq *error* olderr)		;;Volver a poner los errores en condiciones
(recupera-vars)
(princ)				;Para que no salga ningun valor en la línea de comandos


)






;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------

(defun c:modifptd () (modificapuertad))
(defun c:mopd	() (modificapuertad))


(princ "\nModificar parámetros de la puerta")	
(princ)

