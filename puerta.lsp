;;	Programilla para hacer una puerta en un muro



;;	-------------------------------------------------------------------------------
;;					FUNCION DE ERROR
;;	-------------------------------------------------------------------------------

(defun prog-err (s)
  (if (/= s "quit / exit abort")
      (princ (strcat "\nError: no se encuentra un muro "))	
  )
  (setq *error* olderr)
  (setq seleccion nil
  )
  (command "_undo" "_end")
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

(defun puerta 	(/ bisagra 	cosamuro 	datosmuro 	angulo 
		   pt1 		pt2 		seleccion	num-sel
		   fallo	indice		lista-dist	nombre
		   entidad	angulo-aux	distancia	intersec		
		   pgrosor	p4		p5		mensaje
		   linea1	linea2		aux		nuevovalor
		   hueco	capamuro
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





 (command "_undo" "_begin")	
 (setq bisagra (getpoint "\nPunto en el que irá la bisagra <Relativo>: "))
 (if (not bisagra) 
	(setq bisagra (pto-rel))
	)	
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

; ;solicita el ancho del hueco 
; (if (not anchop)
;  (setq mensaje "\nAncho de la hoja (NOTA: las dos jambas ocupan 10 cm)<ancho>: ")
;  (setq mensaje (strcat "\nAncho de la hoja (NOTA: las dos jambas ocupan 10 cm)<" (rtos anchop) ">: "))
; )

; (if (setq nuevovalor (getdist bisagra mensaje)) (setq anchop nuevovalor))

	;;Redondeo a un número entero de centímetros
 
; (setq anchop (distof (rtos anchop 2 2) 2 ) )





;;----------------------Vamos a crear (si hace falta) un bloque puerta nuevo-------------------

(setq nombre (strcat "PS_H" (rtos (* 100 anchop) 2 0) "-J" (rtos (* 100 jamba) 2 0)))	


(if (not (tblsearch "BLOCK" nombre ))			

;; Si no existe esa puerta, a dibujarla y a crear el bloque correspondiente
	
	     (progn	

		(prompt "\nCreando un nuevo bloque de puerta...")		
		(setq seleccion nil )
		
		(setq seleccion (ssadd))

		;;Dibujar una jamba
 
		(setvar "CLAYER" "0")
		(Command "_rectang" "0,0" (list jamba jamba))
		(setq seleccion (ssadd (entlast) seleccion))	

		;;Dibujar la otra jamba
		
		(command "_copy" seleccion "" "0,0" (list (+ anchop jamba) 0))
		(setq seleccion (ssadd (entlast) seleccion))


		;;Dibujar la hoja

		(command "_rectang" "0,0" (list 0.03 anchop) )
		(setq seleccion (ssadd (entlast) seleccion))
		(command "_move" (entlast) "" "0,0" (list jamba jamba))

		;;Dibujar el arco

		(command "_arc" "_c" "0,0" (list anchop 0) (list 0 anchop) )
		(setq seleccion (ssadd (entlast) seleccion))
		(command "_move" (entlast) "" "0,0" (list jamba jamba))

		(command "_block" nombre "0,0" seleccion "")
		
		(prompt "Nueva puerta creada OK")		
	     )

)




 (setvar "CLAYER" capamuro)
 (command "_line" bisagra pgrosor "")

 (setq linea1 (entlast))
 (command "_offset" (+ anchop jamba jamba) linea1 aux "")	

 (setq aux (entlast))
 (setq linea2 (entget (entlast)))


 ;calcula los puntos p4 y p5

 (setq p4 (cdr ( assoc 10 linea2)))
 (setq p5 (cdr ( assoc 11 linea2)))


 ;recorta las lineas del muro entre los puntos ya sabidos

(entdel linea1)		;; La quito para ver lo que hay debajo

(command "_break" (polar bisagra (angle bisagra p4) (/ anchop 2 )) "_f" bisagra p4)
(command "_break" (polar pgrosor (angle pgrosor p5) (/ anchop 2 )) "_f" pgrosor p5)

(entdel linea1)		;; La vuelvo a poner


;; Ahora, a dibujar la puerta


	;crear la capa carpinteria si no existe

(if (not (tblsearch "LAYER" "Carpinteria"))		
		(command "_LAYER" "_New" "Carpinteria" "_color" "_cyan" "carpinteria" "")
	)
	(setvar "CLAYER" "Carpinteria")

		 
		;;Ojo al paso de radianes a grados que hay en el INSERT		


(if (or
	(equal (+ (angle bisagra p4) (/ pi 2)) (angle bisagra pgrosor) 0.001)
	(equal (- (angle bisagra p4) (/(* 3 pi) 2)) (angle bisagra pgrosor) 0.001)
    )		
           (command "_insert" nombre bisagra "" "" (* 180.0 (/ (angle bisagra p4) pi)) )

 	   (command "_insert" nombre bisagra "" "-1" (* 180.0 (/ (angle bisagra p4) pi)) )
)








(command "_undo" "_end")
(setq *error* olderr)		;;Volver a poner los errores en condiciones
(recupera-vars)
(prin1)				;Para que no salga ningun valor en la línea de comandos


)






;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------



(defun c:puerta () 	(puerta))
(defun c:pt ()		(puerta))		;Alias de la orden

(princ "\nFuncion para hacer puertas en un muro en 2D y 3D...cargada OK")	
(princ)

