;; Funcion para generar triángulos con un lado base y las longitudes
;; de los otros dos lados


(defun c:triang (/ nombre lin inicio fin a b c pt1 pt2 x y angulo)

	(setq nombre (entsel "\nSeleccione la línea base: "))
	(setq nombre (car nombre))
	(setq lin (entget nombre))

	(if (/= "LINE" (cdr(assoc 0 lin)) )
		(/ 0 0)
	)		;; Provocar error

	(setq 	inicio 	(cdr(assoc 10 lin))
		fin	(cdr(assoc 11 lin))
		a	(distance inicio fin)
	)

	(setvar "CLAYER" (cdr (assoc 8 lin)))
	(setq b (getdist inicio "\nTamaño del primer lado: "))
	(setq c (getdist fin "\nTamaño del segundo lado: "))


	;; comprobación de errores :

	(if (or 
		(> a (+ b c))		
		(< (+ a b) c)
		(< (+ a c) b)
		)
		(prompt "\nNo se puede hacer ese triángulo")


		(progn		

		(setq x (+ (* b b ) (* a a) ) )
		(setq x (- x (* c c)) )
		(setq x (/ x (+ a a)) )
		(setq y (sqrt (- (* b b) (* x x) )))

		(setq pt1 (list x y))
		(setq pt2 (list x (- 0 y)))
		(setq angulo (angle '(0 0) pt1 ))
		(setq aux (getpoint "\nDireccion hacia la que va el triángulo:"))
		(setq pt1 (polar inicio (+ (angle inicio fin) angulo) b))
		(setq pt2 (polar inicio (- (angle inicio fin) angulo) b))

		(if (< (distance aux pt1) (distance aux pt2))
			(command "_line" inicio pt1 fin "")
			(command "_line" inicio pt2 fin "")
		)
	
		)   ;Progn
	)


(prin1)


)