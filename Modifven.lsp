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


(defun modificaven (/ mensaje  nuevovalor
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


(command "_vslide" "VENTANA")

;; Ventana simple o doble?


(setq mensaje (strcat "\nTipo de ventana (Simple/Doble/3 hojas/4 hojas) <" tipo ">: "))

(Initget "Simple Doble 3 4")
(if (setq nuevovalor (getkword mensaje)) (setq tipo nuevovalor))


;; Alfeizar si o no


(setq mensaje (strcat "\nLLeva ALFEIZAR (Si/No) <" alf ">: "))

(Initget "Si No")
(if (setq nuevovalor (getkword mensaje)) (setq alf nuevovalor))


;solicita el ancho de las hojas 

 (setq mensaje (strcat "\nAncho de cada CRISTAL <" (rtos cristal) ">: "))


 (if (setq nuevovalor (getdist mensaje)) (setq cristal nuevovalor))

	;;Redondeo a un número entero de centímetros
 
 (setq cristal (distof (rtos cristal 2 2) 2 ) )

 

 (setq mensaje (strcat "\nAncho del PERFIL <" (rtos perfil) ">: "))

 (if (setq nuevovalor (getdist mensaje)) (setq  perfil nuevovalor))

	;;Redondeo a un número entero de centímetros
 
 (setq perfil (distof (rtos perfil 2 2) 2 ) )



;; Centrar en el muro Si o No


(setq mensaje (strcat "\nCentrar en el muro (Si/No) <" Centrar ">: "))

(Initget "Si No")
(if (setq nuevovalor (getkword mensaje)) (setq Centrar nuevovalor))



(redraw)





(setq *error* olderr)		;;Volver a poner los errores en condiciones
(recupera-vars)
(princ)				;Para que no salga ningun valor en la línea de comandos


)






;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------

(defun c:modifven 	() (modificaven))
(defun c:mopven		() (modificaven))


(princ "\nModificar parámetros de la ventana")	
(princ)

