;;	Programilla para hacer una ventana en un muro



;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun prog-err (s)
  (if (/= s "quit / exit abort")
      (princ (strcat "\nError: no se encuentra un muro "))	;; Debería cambiar funcion cancelada por s
  )
  (setq *error* olderr)
  (setq seleccion nil)
  (command-s "_undo" "_end")
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
;; 				FUNCION para crear las carpinterías
;;	-------------------------------------------------------------------------------

(defun carpint ()
	
	;;Dibujar un perfil
	 
	(setvar "CLAYER" "0")
	(command-s "_rectang" "0,0" (list perfil perfil))
	(setq seleccion (ssadd (entlast) seleccion))	

	;;Dibujar el otro perfil

	(command-s "_copy" (entlast) "" "0,0" (list (+ cristal perfil) 0))
	(setq seleccion (ssadd (entlast) seleccion))

	;;Dibujar la hoja  

	(command-s "_line" (list perfil 0) (list (+ perfil cristal) 0) "")
	(setq seleccion (ssadd (entlast) seleccion))
	(command-s "_line" (list perfil (/ perfil 2)) (list (+ perfil cristal) (/ perfil 2)) "")
	(setq seleccion (ssadd (entlast) seleccion))
	(command-s "_line" (list perfil perfil) (list (+ perfil cristal) perfil) "")
	(setq seleccion (ssadd (entlast) seleccion))
)




;;	-------------------------------------------------------------------------------
;; 					FUNCION PRINCIPAL
;;	-------------------------------------------------------------------------------




(defun ventana (/ bisagra cosamuro datosmuro angulo 
		 seleccion nombre entidad distancia
		 pgrosor p4 p5 mensaje
		 linea1 linea2 aux nuevovalor
		 hueco capamuro escala olderr
		 ;perfil cristal tipo alf centrar alfeiz anchop
                )

	;;-------LLamar a la nueva funcion de error)
	(setq olderr *error* *error* prog-err)

	;;	Guardar variables del sistema
	(salva-vars '("cmdecho" "blipmode" "expert" 
		   "gridmode" "osmode" "thickness" "clayer"
		   "OFFSETDIST" "ORTHOMODE"))

	;;------Poner los valores que quiera en las variables del sistema------------
	(mapcar 'setvar
		'("cmdecho" "blipmode" "expert" "gridmode"
		  "osmode" "thickness" "ORTHOMODE")
		'(0 0 0 0 0 0 0))

	;; Inicializar variables por defecto si no existen
	;(if (not perfil) (setq perfil 0.05))     ; 5 cm por defecto
	;(if (not cristal) (setq cristal 0.50))   ; 50 cm por defecto
	;(if (not tipo) (setq tipo "Doble"))      ; Simple por defecto
	;(if (not alf) (setq alf "Si"))           ; Con alfeizar por defecto
	;(if (not centrar) (setq centrar "No"))   ; No centrado por defecto
	;(if (not alfeiz) (setq alfeiz 0.03))     ; 3 cm de alfeizar por defecto
	;(if (not anchop) (setq anchop 0.70))     ; Para compatibilidad

	(command-s "_undo" "_begin")

	;; Inicializo esto antes de que me haga falta
	(setq hueco (+ perfil cristal perfil))

	(setq bisagra (getpoint "\nPunto en el que irá una bisagra <Relativo>: "))
	(if (not bisagra) 
		(setq bisagra (pto-rel)))	
	(setq bisagra (osnap bisagra "_nearest"))	;;Ajustar el punto. Si da error se que no había muro		

	(setq cosamuro (ssname (ssget bisagra) 0))
	(setq datosmuro (entget cosamuro))
	(setq capamuro (cdr(assoc 8 datosmuro)))	;;Poner la capa de lo que sea como capa actual

	(setq pgrosor (encuentra-muro cosamuro bisagra))
	(if (not pgrosor)
		(progn
			(prompt "\nNo encuentro otra línea paralela")
			(exit)		;; Provocar fallo
		)
	)

	;hacia qué lado?
	(initget 1)	
	(setq aux (getpoint bisagra "\nHacia que lado de la bisagra irá el hueco: ")) 	

	;;----------------------Vamos a crear (si hace falta) un bloque ventana nuevo-------------------

	(setq distancia (distance bisagra pgrosor))
	(setq distancia (distof (rtos distancia 2 2) 2))		;; Redondeo el ancho del muro a cm

	(setq nombre (strcat "V" (substr tipo 1 1) (substr alf 1 1) (substr centrar 1 1)
			(rtos (* 100 cristal) 2 0) "-P" (rtos (* 100 perfil) 2 0) 
			"Muro" (rtos (* 100 distancia) 2 0)))	

	(print nombre)

	(if (not (tblsearch "BLOCK" nombre))			

		;; Si no existe esa ventana, a dibujarla y a crear el bloque correspondiente
		
		(progn	
			(prompt "\nCreando un nuevo bloque de ventana...")		
			(setq seleccion nil)
			
			(setq seleccion (ssadd))

			;;Dibujar una jamba
			
			(setvar "CLAYER" "0")
			(command-s "_rectang" "0,0" (list perfil perfil))
			(setq seleccion (ssadd (entlast) seleccion))	

			;;Dibujar la otra jamba
			
			(command-s "_copy" seleccion "" "0,0" (list (+ cristal perfil) 0))
			(setq seleccion (ssadd (entlast) seleccion))

			;;Dibujar una hoja  

			(command-s "_line" (list perfil 0) (list (+ perfil cristal) 0) "")
			(setq seleccion (ssadd (entlast) seleccion))
			(command-s "_line" (list perfil (/ perfil 2)) (list (+ perfil cristal) (/ perfil 2)) "")
			(setq seleccion (ssadd (entlast) seleccion))
			(command-s "_line" (list perfil perfil) (list (+ perfil cristal) perfil) "")
			(setq seleccion (ssadd (entlast) seleccion))

			;; Si la ventana es doble

			(if (= tipo "Doble")
				(progn
				    (command-s "_move" seleccion ""  (list (+ cristal perfil perfil) 0) "0,0")
		
					(carpint)				
					;; Por último, la línea de en medio de la ventana
				
					(command-s "_line" "0,-.05" "0,.1" "")
					(setq seleccion (ssadd (entlast) seleccion))

				    (command-s "_move" seleccion "" "0,0" (list (+ cristal perfil perfil) 0))
				)

				; Si la ventana no es doble pero tampoco simple, hacerla triple, cuadruple, etc...
				(if (/= tipo "Simple") 
					(repeat (- (atoi tipo) 1)
					    (command-s "_move" seleccion ""  "0,0" (list (+ cristal perfil perfil) 0))
						
						(carpint)				
						;; Por último, la línea de en medio de la ventana
					
						(command-s "_line" (list hueco -0.05) (list hueco (+ 0.05 perfil)) "")
						(setq seleccion (ssadd (entlast) seleccion))
					)	;fin repeat
				)		;fin /= tipo simple....
			)	;; Fin = tipo doble...

		    ;; Ponerle alfeizar si lo necesita	

			; Esto lo inicialicé al principio	   (setq hueco (+ perfil cristal perfil))
			(cond 
				((eq tipo "Doble")	(setq hueco (+ hueco hueco)))
				((eq tipo "Simple")	(setq hueco  hueco))
				(T			(setq hueco (* (atof tipo) hueco)))
			)

			;; Si quiero centrar la carpintería en el en el muro:

			(if (= centrar "Si")
				(progn
					(command-s "_move" seleccion "" "0,0" (list 0  (/ (- distancia perfil) 2)))
					(command-s "_line" "0,0" (list hueco 0) "")
					(setq seleccion (ssadd (entlast) seleccion))
				)
			)

		    (if (eq alf "No")	 		;;Si no lleva alfeizar, dibujar una línea	
			(command-s "_line" (list 0 distancia) (list hueco distancia) "")	

			;; Si lleva alfeizar, dibujarlo
			
			(command-s "_pline" (list (- 0 alfeiz) distancia) 
					  (list (- 0 alfeiz) (+ distancia alfeiz)) 
					  (list (+ hueco alfeiz) (+ distancia alfeiz))
					  (list (+ hueco alfeiz) distancia)
					"")
		     )	

			(setq seleccion (ssadd (entlast) seleccion))

			(command-s "_block" nombre "0,0" seleccion "")

			(prompt "Nueva ventana creada OK")		
		)
	)

	(setvar "CLAYER" capamuro)
	(command-s "_line" bisagra pgrosor "")

	(setq linea1 (entlast))

	;; dibujar la otra línea del cerco en el muro

	;; Como falla y no se pq lo pongo a lo bruto
	;(if (eq tipo "Doble") (setq hueco (* 2.0  (+ perfil cristal perfil)  )))
	(setq hueco (+ perfil cristal perfil))
	(cond 
		((eq tipo "Doble")	(setq hueco (+ hueco hueco)))
		((eq tipo "Simple")	(setq hueco  hueco))
		(T			(setq hueco (* (atof tipo) hueco)))
	)

	(command-s "_offset" hueco linea1 aux "")	

	(setq aux (entlast))
	(setq linea2 (entget (entlast)))

	;calcula los puntos p4 y p5

	(setq p4 (cdr (assoc 10 linea2)))
	(setq p5 (cdr (assoc 11 linea2)))

	;recorta las lineas del muro entre los puntos ya sabidos

	(entdel linea1)		;; La quito para ver lo que hay debajo

	(command-s "_break" (polar bisagra (angle bisagra p4) (/ hueco 2)) "_f" bisagra p4)
	(command-s "_break" (polar pgrosor (angle pgrosor p5) (/ hueco 2)) "_f" pgrosor p5)

	(entdel linea1)		;; La vuelvo a poner

	;; Ahora, a dibujar la ventana

	;crear la capa carpinteria si no existe

	(if (not (tblsearch "LAYER" "Carpinteria"))		
		(command-s "_LAYER" "_New" "Carpinteria" "_color" "_cyan" "carpinteria" ""))
	(setvar "CLAYER" "Carpinteria")

	;;Ojo al paso de radianes a grados que hay en el INSERT		

	(setq angulo (angle bisagra p4))

	(if (or
		(equal (+ angulo (/ pi 2)) (angle bisagra pgrosor) 0.001)
		(equal (- angulo (/(* 3 pi) 2)) (angle bisagra pgrosor) 0.001))		
		(setq escala 1)	
		(setq escala -1)
	)
	(command-s "_insert" nombre bisagra "" escala (* 180.0 (/ angulo pi)))

	(command-s "_undo" "_end")
	(setq *error* olderr)		;;Volver a poner los errores en condiciones
	(recupera-vars)
	(prin1)				;Para que no salga ningun valor en la línea de comandos
)






;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------




(defun c:ventana () 	(ventana))
(defun c:ven ()		(ventana))		;Alias de la orden

(princ "\nFuncion para hacer ventanas en un muro en 2D...cargada OK")	
(princ)