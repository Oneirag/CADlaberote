;;----------------------------------------------------------------------------------------
;;				Programa principal
;;----------------------------------------------------------------------------------------


(defun c:aplasta (/ seleccion num-sel indice entidad nombre capa tipo	
		aux
)
	(prompt "\nPrograma para poner cota Z=0 en todo el dibujo")
	(setq seleccion (ssget))
	(setq num-sel (sslength seleccion))			;;No verifico que haya selección
	(setq indice 0)	
	(repeat num-sel
	
	     (progn
		(setq nombre (ssname seleccion indice))			;;Obtener cada entidad
		(setq entidad (entget nombre ))				;;Selecciona entidad a aplastar
;;		(setvar "CLAYER" (cdr (assoc 8 entidad)))		;;Pone su capa como actual
;;		(print (cdr ( assoc 210 entidad)))			;;Imprime dirección SCO
		(setq tipo (cdr (assoc 0 entidad)))			;;Obtiene el tipo de entidad	
		(cond
			
			( (= tipo "POINT") 	(aplasta-som))		;;solucion provisional
			( (= tipo "HATCH") 	(aplasta-som))
			( (= tipo "INSERT") 	(aplasta-som))
			( (= tipo "MTEXT") 	(aplasta-txt))
			( (= tipo "TEXT") 	(aplasta-txt))
			( (= tipo "CIRCLE") 	(aplasta-arco))
			( (= tipo "ARC") 	(aplasta-arco))
			( (= tipo "POLYLINE") 	(aplasta-3dpol))
			( (= tipo "LWPOLYLINE") (aplasta-polilinea))
			( (= tipo "LINE") 	(aplasta-linea))
	   	 (T (print tipo))
		)
	     )
	(setq indice (+ indice 1))
;	(foreach aux entidad (print aux ))	
	)
	
	
) 





;;----------------------------------------------------------------------------------------
;;				Modificar línea
;;----------------------------------------------------------------------------------------

(defun aplasta-linea (/ inicio fin )
	
	(setq inicio (cdr ( assoc 10 entidad)))			;;Guardar el punto inicial
	(setq inicio (list 10 (car inicio) (cadr inicio) 0))	;;Ponerle z=0
	(setq fin (cdr ( assoc 11 entidad)))			;;Guardar el punto final
	(setq fin (list 11 (car fin) (cadr fin) 0))		;;Poner z=0
								;;Modificar pto inicial y final
	(setq entidad  (subst inicio (assoc 10 entidad) entidad))
	(setq entidad  (subst fin (assoc 11 entidad) entidad))
	(entmod entidad)					;;Guardar los cambios
)
	
;;----------------------------------------------------------------------------------------
;;				Modificar polilínea plana
;;----------------------------------------------------------------------------------------

(defun aplasta-polilinea (/ temp )
		
	(if (equal '(0 0 1) (cdr(assoc 210 entidad)))		;;Si es paralela al SCU
	(progn							;;Poner z=0
		(setq temp  (cons (car (assoc 38 entidad)) 0 ))
		(setq entidad  (subst temp (assoc 38 entidad) entidad))
	)
	(print tipo)						;;Clausula por si falla
	)
	(entmod entidad)					;;Guardar los cambios

)

;;----------------------------------------------------------------------------------------
;;				Modificar polilínea espacial
;;----------------------------------------------------------------------------------------

(defun aplasta-3dpol (/ vertice nombre-vertice pto aux1)

	(setq aux1 (cons 100 "AcDb2dPolyline"))
	(if  (member aux1 entidad)			;;Si es una polilínea plana desplazada
	(progn

		(setq pto (cdr ( assoc 10 entidad)))			;;Obtener un vértice
		(setq pto (list 10 (car pto) (cadr pto) 0))		;;Poner z=0
		(setq entidad  (subst pto (assoc 10 entidad) entidad))	;;Modificar el vértice
		(entmod entidad)					;;Escribirlo
	)
	(progn						;;Si es una 3Dpol
	(setq nombre-vertice nombre)			;;Realizar un bucle para pasar por todos los nodos
	(while (=  "VERTEX" (cdr(assoc 0 (entget(entnext nombre-vertice)))))
		(setq nombre-vertice (entnext nombre-vertice))
		(setq vertice (entget nombre-vertice))
		(setq pto (cdr ( assoc 10 vertice)))			;;Obtener el vértice
		(setq pto (list 10 (car pto) (cadr pto) 0))		;;Poner z=0
		(setq vertice  (subst pto (assoc 10 vertice) vertice))	;;Modificar el vértice
		(entmod vertice)					;;Escribirlo
		;	(foreach aux1 vertice (print aux1 ))

	))
	)
	(entupd nombre)							;;Regenerar entidad
)	

;;----------------------------------------------------------------------------------------
;;				Modificar círculo y arco
;;----------------------------------------------------------------------------------------

(defun aplasta-arco (/ centro )
	
	(if (equal '(0 0 1) (cdr(assoc 210 entidad)))		;;Si es paralela al SCU
	(progn
	 (setq centro (cdr ( assoc 10 entidad)))		;;Guardar el centro
	 (setq centro (list 10 (car centro) (cadr centro) 0))	;;Ponerle z=0
	 							;;Modificar centro
	 (setq entidad  (subst centro (assoc 10 entidad) entidad))
	 (entmod entidad)					;;Guardar los cambios
	 )
	(print tipo)						;;Clausula por si falla
	)							;;Si no es paralela no hace nada
)

;;----------------------------------------------------------------------------------------
;;				Modificar texto
;;----------------------------------------------------------------------------------------

(defun aplasta-txt (/ inicio fin )
	
	(setq inicio (cdr ( assoc 10 entidad)))			;;Guardar el punto inicial
	(setq inicio (list 10 (car inicio) (cadr inicio) 0))	;;Ponerle z=0
	(setq fin (cdr ( assoc 11 entidad)))			;;Guardar el punto final
	(setq fin (list 11 (car fin) (cadr fin) 0))		;;Poner z=0
								;;Modificar pto inicial y final
	(setq entidad  (subst inicio (assoc 10 entidad) entidad))
	(setq entidad  (subst fin (assoc 11 entidad) entidad))
	(entmod entidad)					;;Guardar los cambios
	(entupd nombre)						;;Redibujar el texto
)


;;----------------------------------------------------------------------------------------
;;				Modificar sombreado
;;----------------------------------------------------------------------------------------

(defun aplasta-som (/ inicio fin )
	
	(setq inicio (cdr ( assoc 10 entidad)))			;;Guardar el punto inicial
	(setq inicio (list 10 (car inicio) (cadr inicio) 0))	;;Ponerle z=0
	
								;;Modificar pto inicial
	(setq entidad  (subst inicio (assoc 10 entidad) entidad))
	(entmod entidad)					;;Guardar los cambios
)
