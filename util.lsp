;;	Programillas auxiliares de arquitectura


;;	-------------------------------------------------------------------------------
;;		Funciones para dar el punto inicial y final de una línea 
;;	-------------------------------------------------------------------------------

(defun pto-ini (algo)
	(cdr(assoc 10 (entget algo)))
)

(defun pto-fin (algo)
	(cdr(assoc 11 (entget algo)))
)



;;	-------------------------------------------------------------------------------
;;				FUNCION DE PUNTO RELATIVO
;;	-------------------------------------------------------------------------------

(defun pto-rel (/ pto angul dis
		)

	(setq pto 	(getpoint 		"\nMedido desde :"	))
	(setq dis 	(getdist 	pto 	"\nDistancia: "		))
	(setq angul 	(getangle 	pto 	"\nAngulo: "		))
	(setq pto 	(polar 		pto 	angul 	   	     dis))

)








;;	-------------------------------------------------------------------------------
;;			Función auxiliar que dice si dos líneas son paralelas
;;	-------------------------------------------------------------------------------

(defun paralelas (a b / c d tolera)


(setq tolera 0.001)		;Valor de la tolerancia, un desnivel relativo del 0.1 %

;(setq a (entsel "\nSeñala algo.."))
;(setq b (entsel "\nSeñala algo.."))
;(setq a (car a))
;(setq b (car b))

;; ESTA ERA LA COMPROBACION QUE HACIA ANTES

;	(if (or (equal (angle (pto-ini a) (pto-fin a)) (angle (pto-ini b) (pto-fin b)) tolerancia)
;		(equal (angle (pto-ini a) (pto-fin a)) (angle (pto-ini b) (pto-fin b)) tolerancia)
;		(equal (angle (pto-ini a) (pto-fin a)) (angle (pto-ini b) (pto-fin b)) tolerancia)
;		(equal (angle (pto-ini a) (pto-fin a)) (angle (pto-ini b) (pto-fin b)) tolerancia)
;			     )


	(setq d (polar (pto-ini a) (+ (angle (pto-ini a) (pto-fin a)) (/ pi 2)) 1))
	(setq d (inters (pto-ini a) d (pto-fin b) (pto-ini b) nil))	
	(setq c (distance (pto-ini a) d))
	(setq d (polar (pto-fin a) (+ (angle (pto-ini a) (pto-fin a)) (/ pi 2) ) 1))
	(setq d (inters (pto-fin a) d (pto-fin b) (pto-ini b) nil))
	(print (- c (distance d (pto-fin a))) )
	(print (/ (- c (distance d (pto-fin a))) (distance (pto-ini cosa) (pto-fin cosa))) )

;; Debería dividirla por la longitud del segmento "cosa" para hacerla relativa en %
;; Vamos a hacerlo así


;; Así lo hacía antes 
;;	(if (equal c (distance d (pto-fin a)) tolera)
;; Y ahora lo hago así
	(if (equal 0 (/ (- c (distance d (pto-fin a))) (distance (pto-ini cosa) (pto-fin cosa)))  tolera)
		(setq c T)
		(setq c nil)
	)
	
	(setq c c)
	
)



;;	-------------------------------------------------------------------------------
;;				Función Para encontrar un muro
;;	-------------------------------------------------------------------------------




(defun encuentra-muro 	(  cosa		bis		/  		angulo 
			   pt1 		pt2 		seleccion	num-sel
			   punto	indice		lista-dist	nombre
			   entidad	distancia	intersec	pgr	
			   tolerancia		
			)				



 ;El segundo punto lo encuentra buscando la recta paralela más próxima a él

	(setq angulo (angle (pto-ini cosa) (pto-fin cosa)))	;Obtengo el ángulo que forma la recta

	; NO hay muros de más de 55 cm (digo yo):

	(setq pt1 (polar bis (+ angulo (/ pi 2))  0.55))			
	(setq pt2 (polar bis (+ angulo (/ pi 2)) -0.55))	

	;Sólo partirá objetos hechos con líneas

	(setq seleccion (ssget "_f" (list pt1 pt2) '(  (0 . "LINE") ) ))	;coger sólo lo que haya en la capa muros
	(setq seleccion (ssdel cosa seleccion))
	(setq num-sel (sslength seleccion))
	(setq pgr nil)
	(if seleccion							;; Si ha encontrado algo
	    	(progn
		(setq num-sel (sslength seleccion))			
		(setq indice 0)	
		(setq lista-dist '())					;;Lista de distancias a la bisagra
		(repeat num-sel
		     (progn
			(setq nombre (ssname seleccion indice))			;;Obtener cada entidad

			;;Verifica paralelismo con la tolerancia anteriormente dicha
			(if (paralelas cosa nombre)
			     (progn
			     (setq intersec (inters (pto-ini nombre) (pto-fin nombre) pt1 pt2))
			     (setq distancia (distance bis intersec)) 
     		        (if (not (equal 0 distancia 0.02))	;;Muros de menos de 2 cm tampoco hay
				(progn	
			     	(setq lista-dist (append lista-dist (list distancia)))
			     	(if (<= distancia (apply 'min lista-dist))
						(setq pgr intersec)
						(setq pgr pgr)
				    )		;if
				)
			     )	

			     )		;progn
			    			;; Si no son paralelas, fallo			   	
		     	)
		       	(setq indice (+ indice 1))
		     )		

		)


		);Progn
	)		;If seleccion...			


;; Ahora habría que ver si pgr es nil, pedir que el usuario seleccione un muro
	(While (null pgr)
		(progn
			(setq pgr (getpoint bis "\nNo encuentro la otra cara del muro. Indiquemela..."))
			
			(setq nombre (ssget pgr '((0 . "LINE")) ))
			(if (null nombre)
				(setq pgr nil)
				;;Verifica paralelismo con la tolerancia anteriormente dicha
				(progn
				(setq nombre (ssname nombre 0))
					(if (paralelas cosa nombre)
						(setq pgr (inters (pto-ini nombre) (pto-fin nombre) pt1 pt2 nil))
						(progn
							(prompt "\nLa línea seleccionada no es paralela a la primera.")
							(initget "Si No")
							(setq aux (getkword "Desea hacerla paralela (Si/<No>)" ))
							(if (not aux)
								(setq pgr nil)
								(if (= aux "No")
								  (setq pgr nil)
								  (progn		;;Hacerlas paralelas
									(setvar "CLAYER" (cdr (assoc 8 (entget nombre))))
									(setq aux (distance (pto-ini nombre) (pto-fin nombre) ))
									(if (< (distance (pto-ini cosa) (pto-ini nombre)) (distance (pto-ini cosa) (pto-ini nombre)))
										(command "_line" (pto-ini nombre) (polar (pto-ini nombre) angulo aux) "")
										(command "_line" (pto-fin nombre) (polar (pto-fin nombre) angulo aux) "")
									)
									(entdel nombre)
									(setq nombre (entlast))
									(setq pgr (inters (pto-ini nombre) (pto-fin nombre) pt1 pt2 nil)))
								  )	
							)
						)
					)
				)
			)
		)
	)


(setq pgr pgr)

)






;;	-------------------------------------------------------------------------------
;; 					MENSAJE HORTERA
;;	-------------------------------------------------------------------------------




(princ "\nFunciones auxiliares de arquitectura cargadas")	
(princ)

