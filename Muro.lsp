;;	Programilla para hacer un muro




;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun prog-err	(s)
  (if (/= s "Función cancelada")
    (princ (strcat "\nError: Fallo al crear un muro "))
    ;; Debería cambiar funcion cancelada por s
  )
  (setq *error* olderr)
  (setq	seleccion nil
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
;; 				Función para unir dos tramos de muro
;;	-------------------------------------------------------------------------------

(defun une-lin (l1 l2 l3 l4 / angulo_muro1 angulo_muro2) ;;;pto-ini pto-fin)


 ;;Obtener los angulos de las dos rectas
(setq angulo_muro1	(angle (cdr (assoc 10 (entget l1)))
		       (cdr (assoc 11 (entget l1)))
		)
)

(setq angulo_muro2	(angle (cdr (assoc 10 (entget l3)))
		       (cdr (assoc 11 (entget l3)))
		)
)


  (if (or ;; Comprobar si son paralelos
	  (= angulo_muro1 angulo_muro2)
	  (= (+ angulo_muro1 pi) angulo_muro2)
	  (= (- angulo_muro1 pi) angulo_muro2)
      )
					;si son paralelos, unirlas con una línea
    (command "_line"
	     (cdr (assoc 10 (entget l4)))
	     (cdr (assoc 11 (entget l2)))
	     ""
    )


					;Si no son paralelos, empalma los bordes				
    (progn
      (command "_fillet" l2 l4)
      (setq int1 (inters (cdr (assoc 10 (entget l2)))
			 (cdr (assoc 11 (entget l2)))
			 (cdr (assoc 10 (entget l3)))
			 (cdr (assoc 11 (entget l3)))
		 )
      )
      (setq int2 (inters (cdr (assoc 10 (entget l1)))
			 (cdr (assoc 11 (entget l1)))
			 (cdr (assoc 10 (entget l4)))
			 (cdr (assoc 11 (entget l4)))
		 )
      )
      (if (or int1 int2)
	(progn
	  (command "_fillet" l1 l4)
	  (command "_fillet" l2 l3)
	)
      )					;If int1 o int2...	

    )
    ;;Progn del verifica paralela
  )
  ;; If or angle...	

)



;;	-------------------------------------------------------------------------------
;; 					FUNCION PRINCIPAL
;;	-------------------------------------------------------------------------------


;; La variable anchom hay que guardarla en el dibujo y todavía no sé como

(defun muro (/	       punto	 cosaini   datosini  int1
	     int2      aux	 pto-sig   continuar linea1
	     linea2    linea3	 linea4	   lista-lin grupo
	     cosafin
	    )




  ;;-------LLamar a la nueva funcion de error)
  (setq	olderr	*error*
	*error*	prog-err
  )

  ;;	Guardar variables del sistema
  (salva-vars
    '("cmdecho"	     "blipmode"	    "expert"	   "gridmode"
      "osmode"	     "thickness"    "clayer"	   "OFFSETDIST"
      "FILLETRAD"
     )
  )

;;------Poner los valores que quiera en las variables del sistema------------
;;;	ONG 20100919 - Cambiar esto para que no me quite las ayudas al sistema de antes de dibujar
;;;	(mapcar 'setvar
;;;    		'("cmdecho" "blipmode" "expert" 
;;;      		"thickness" "osmode" "FILLETRAD")
;;;    		'(0 0 0 0 0 0)
;;; 	 )


  (mapcar 'setvar
	  '(
	    "thickness"
	    "FILLETRAD"
	   )
	  '(0 0)
  )


  ;;------Crear la capa muros si no existe

  (if (not (tblsearch "LAYER" "Muros"))
    (command "_LAYER" "_New" "Muros" "_color" "_blue" "Muros" "")
  )
  (setvar "CLAYER" "Muros")



  ;; Inicializar la lista de puntos

  (setq lista-lin nil)
  (setq grupo nil)



  ;;-----Empezar la orden muro

  (If (not anchom)
    (progn
      (setq anchom (getdist "\nAncho del muro <0.3>: "))
      (if (not anchom)
	(setq anchom 0.3)
      )					;valor inicial
    )
  )



  (setq punto (getpoint "\nPrimer punto del muro <Relativo>: "))
  (if (not punto)
    (setq punto (pto-rel))
  )

  (if (osnap punto "_nearest")
    (setq punto (osnap punto "_nearest"))
    ;; Si hay algo cerca, detectarlo
  )



					; Verificar si hay algo cerca del punto que se ha selecionado

  (setq cosaini (ssget punto '((8 . "MUROS") (0 . "LINE"))))

  (setq pto-sig nil)

  (while (null pto-sig)
    (progn
      (Initget "Ancho")
      (setq pto-sig (getpoint punto "\nAl punto (Ancho/Relativo): "))
      (cond
	((= pto-sig "Relativo") (setq pto-sig (pto-rel)))
	((= pto-sig "Ancho")
	 (progn
	   (setq pto-sig anchom)
	   (setq anchom
		  (getdist
		    (strcat "\nAncho del muro <" (rtos anchom) ">: ")
		  )
	   )
	   (if (not anchom)
	     (setq anchom pto-sig)
	   )
	   (setq pto-sig nil)
	 )
	)
	((not pto-sig) (setq punto (/ 0 0)))
					;Provoca un error para salir
      )					;cond
    )					;Progn
  )					;While


  (command "_Line" punto pto-sig "")
  (setq grupo (append (list (entlast)) grupo))
  (setq linea3 (entlast))
  (initget 1)
  ;; No permitir entrada nula
  (setq aux (getpoint "\nDireccion de la otra cara del muro: "))
  (command "_offset" anchom (entlast) aux "")
  (setq grupo (append (list (entlast)) grupo))
  (setq linea4 (entlast))
  (setq lista-lin (append grupo lista-lin))
  (setq grupo nil)


  (setq continuar T)

  (while continuar
    (progn

      (setq punto  (cdr (assoc 11 (entget (cadr lista-lin))))
	    linea1 (cadr lista-lin)
	    linea2 (car lista-lin)
      )

      (initget "Ancho Revoca Cierra")

      (setq pto-sig
	     (getpoint punto
		       "\nAl punto (Ancho/Revoca/Cierra/<Relativo>): "
	     )
      )
      (if (= pto-sig "Relativo")
	(setq pto-sig (pto-rel))
      )

      (cond
	((null pto-sig) (setq continuar nil))
	((= pto-sig "Cierra")
	 (if (> (length lista-lin) 2)
	   (setq continuar nil)
	   (prompt "\nTodavía no puedo cerrar")
	 )
	)
	((= pto-sig "Revoca")
	 (progn
	   (print "hola hola")
	   (if (> (length lista-lin) 2)
	     (progn
	       (command "_undo" "_back")
	       (setq lista-lin (cddr lista-lin))
	     )
	     ;; Else..
	     (prompt "\nNo se puede revocar más")
	   )
	 )
	)

	((= pto-sig "Ancho")
	 (progn
	   (setq continuar anchom)
	   (setq anchom
		  (getdist
		    (strcat "\nAncho del muro <" (rtos anchom) ">: ")
		  )
	   )
	   (if (not anchom)
	     (setq anchom continuar)
	   )
	   (setq continuar T)
	 )

	)
	(T
	 (progn

	   (command "_undo" "_mark")
	   (if (osnap pto-sig "_nearest")
	     (setq pto-sig (osnap pto-sig "_nearest"))
	     ;; Si hay algo cerca, detectarlo
	   )

	   (command "_Line" punto pto-sig "")
	   (setq linea3 (entlast))
	   (setq grupo (append (list (entlast)) grupo))
	   (initget 1)
	   ;; No permitir entrada nula
	   (setq
	     aux (getpoint "\nDireccion de la otra cara del muro: ")
	   )
	   (command "_offset" anchom (entlast) aux "")
	   (setq linea4 (entlast))
	   (setq grupo (append (list (entlast)) grupo))
	   (setq lista-lin (append grupo lista-lin))
	   (setq grupo nil)

	   (une-lin linea1 linea2 linea3 linea4)

					;NO HACE FALTA			(command "_undo" "_end")

	 )				;Progn del "else" del cond ...

	)
      )					;Cond



    )
    ;;Progn
  )
  ;;While


  (if cosaini				; Si hay algo al ppio no cierra
    (if	(= pto-sig "Cierra")
      (setq pto-sig nil)
    )
  )


  (setq	linea1 (last lista-lin)
	linea2 (entnext linea1)
	       ;; Son las dos líneas del principio
  )




  (if (= pto-sig "Cierra")
    (progn
      ;; Hacer un empalme normal entre la línea 1 y la línea 2

      (setq pto-sig (cdr (assoc 11 (entget linea4))))
      (command "_Line" punto (cdr (assoc 10 (entget linea1))) "")
      (setq linea3 (entlast))
      (setq grupo (append (list (entlast)) grupo))
      (setq aux (cdr (Assoc 10 (entget linea2))))
      (command "_offset" anchom (entlast) aux "")
      (setq linea4 (entlast))
      (setq grupo (append (list (entlast)) grupo))
      (setq lista-lin (append grupo lista-lin))
      (setq grupo nil)



      ;; Unir principio y final
      (une-lin linea1 linea2 linea3 linea4)

      ;; Unir la penúltima línea con la antepenúltima
      (une-lin (cadddr lista-lin)
	       (caddr lista-lin)
	       (cadr lista-lin)
	       (car lista-lin)
      )


    )

    (progn ;; No cerrar el muro

	   ;; Cerrar la línea inicial


	   (if cosaini			;si había algo en el ppio, recortarlo
	     (progn
	       (setq cosaini (ssname cosaini 0))
	       (setq datosini (entget linea2))
	       (setq inicio (inters (cdr (assoc 10 (entget linea2)))
				    (cdr (assoc 11 (entget linea2)))
				    (cdr (assoc 10 (entget cosaini)))
				    (cdr (assoc 11 (entget cosaini)))
				    nil
			    )
	       )


	       ;;Modificar pto inicial y final
	       (if inicio
		 ;;Por si las líneas son paralelas
		 (setq datosini	(subst (append '(10) inicio)
				       (assoc 10 datosini)
				       datosini
				)
		 )
	       )
	       (entmod datosini)
	       ;;Guardar los cambios
	       (command	"_break"
			cosaini
			inicio
			(cdr (assoc 10 (entget linea1)))
	       )

	     )
	     ;;Si no había nada, hacer el final

	     (command "_line"
		      (cdr (assoc 10 (entget linea2)))
		      (cdr (assoc 10 (entget linea1)))
		      ""
	     )

	   )



	   ;; Y ahora, algo parecido a lo del principio, pero con los puntos finales


	   (entdel linea3)
	   ;;quito la línea para ver qué hay debajo
	   (setq cosafin (ssget punto '((8 . "MUROS") (0 . "LINE"))))
	   (entdel linea3)
	   ;;Vuelvo a poner la línea

	   (if cosafin			;si había algo en el ppio, recortarlo
	     (progn
	       (setq cosafin (ssname cosafin 0))
	       (setq datosini (entget linea4))
	       (setq inicio (inters (cdr (assoc 10 (entget linea4)))
				    (cdr (assoc 11 (entget linea4)))
				    (cdr (assoc 10 (entget cosafin)))
				    (cdr (assoc 11 (entget cosafin)))
				    nil
			    )
	       )


	       ;;Modificar pto inicial y final
	       (if inicio
		 ;;Por si las líneas son paralelas
		 (setq datosini	(subst (append '(11) inicio)
				       (assoc 11 datosini)
				       datosini
				)
		 )
	       )
	       (entmod datosini)
	       ;;Guardar los cambios
	       (command	"_break"
			cosafin
			inicio
			(cdr (assoc 11 (entget linea3)))
	       )

	     )
	     ;;Si no había nada, hacer el final

	     (command "_line"
		      (cdr (assoc 11 (entget linea4)))
		      (cdr (assoc 11 (entget linea3)))
		      ""
	     )

	   )

    )
    ;; Progn del if cierra...

  )
  ;; If cierra....





  ;; Para hacer el muro 3d no habría más que coger todas las líneas de lista-lin y 
  ;; Dibujar 3D caras encima de ellas


  (setq *error* olderr)
  ;;Volver a poner los errores en condiciones
  (recupera-vars)
  (prin1)				;Para que no salga ningun valor en la línea de comandos


)






;;	-------------------------------------------------------------------------------
;; 				MENSAJE HORTERA E INICIALIZACIONES
;;	-------------------------------------------------------------------------------



(defun c:muro () (muro))
(defun c:mr () (muro))
;; Alias de la orden

(princ "\nFuncion para hacer un muro...cargada OK")
(princ)

