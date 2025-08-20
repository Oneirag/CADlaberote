;; ---------------------------------------------------------
;; UTIL.LSP  – funciones auxiliares de arquitectura
;; ---------------------------------------------------------
;; •  getpoint, getdist y getangle ahora requieren un dato
;;    válido del usuario (se observa de forma interactiva).
;; •  pto‑ini / pto‑fin devuelven el punto inicial/final de
;;    cualquier entidad de tipo lienzo (línea, polilínea, arco).
;; •  paralelas: comprobación de paralelismo con tolerancia.
;; •  encuentra‑muro: búsqueda de la segunda cara de un muro.
;; ---------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.  Punto inicial y punto final de una entidad
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun pto-ini (ent)
  "Devuelve el punto inicial (código 10) de ENT."
  (when ent
    (cdr (assoc 10 (entget ent))))
)

(defun pto-fin (ent)
  "Devuelve el punto final (código 11) de ENT."
  (when ent
    (cdr (assoc 11 (entget ent))))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2.  Punto relativo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun pto-rel ()
  "Genera un punto a una distancia y ángulo desde el punto
   de referencia devuelto por `getpoint`."
  (let* ((pt0   (getpoint "\nMedido desde : "))
         (dist  (getdist  pt0        "\nDistancia: "))
         (ang   (getangle pt0        "\nÁngulo: "))
         (pt1   (polar pt0 ang dist)))
    pt1)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3.  Comprobación de paralelismo (entre dos líneas)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun paralelas (a b / ang1 ang2 diff tolera)
  "Devuelve T si las líneas A y B son paralelas dentro
   de la tolerancia TOLERANZA (0.001 rad)."
  (if (and a b)
      (progn
        (setq tolera 0.001)
        (setq ang1 (angle (pto-ini a) (pto-fin a)))
        (setq ang2 (angle (pto-ini b) (pto-fin b)))
        (setq diff (abs (- ang1 ang2)))
        (<= diff tolera))
      nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.  Buscador de muro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun encuentra-muro (cosa bis / angulo pt1 pt2 seleccion num-sel punto indice lista-dist nombre entidad distancia intersec pgr)
  "Busca la segunda cara del muro que rodea a la línea
   CUOAS.  Si no encuentra una línea paralela y
   cercana, solicita al usuario que seleccione una."
  ;; 1. Define la recta paralela en el sentido perpendicular a CUOAS
  (setq angulo (angle (pto-ini cosa) (pto-fin cosa)))
  (setq pt1 (polar bis (+ angulo (/ pi 2))  0.55))
  (setq pt2 (polar bis (+ angulo (/ pi 2)) -0.55))

  ;; 2. Seleccionamos solo líneas en la capa actual cercanas a la recta
  (setq seleccion (ssget "_f" (list pt1 pt2) '((0 . "LINE"))))
  (setq seleccion (ssdel cosa seleccion))
  (setq num-sel (sslength seleccion))
  (setq pgr nil)

  ( when seleccion
      (progn
        (setq indice 0)
        (setq lista-dist '())
        (repeat num-sel
          (setq nombre (ssname seleccion indice))
          (when (paralelas cosa nombre)
            (setq intersec (inters (pto-ini nombre) (pto-fin nombre) pt1 pt2 nil))
            (setq distancia (distance bis intersec))
            (when (and distancia (> distancia 0.02)) ; no muros de menos de 2 cm
              (setq lista-dist (append lista-dist (list distancia)))
              (if (or (null pgr) (<= distancia (apply 'min lista-dist)))
                  (setq pgr intersec))))
          (setq indice (+ indice 1))) ))

  ;; 3. Si no se halló: solicita punto al usuario e intenta crear una
  ;; línea paralela automáticamente (solo la línea será creada).
  (while (null pgr)
    (setq pgr (getpoint bis "\nNo encuentro la otra cara del muro. Indiquemela..."))
    (setq nombre (ssget pgr '((0 . "LINE"))))
    (when nombre
      (setq nombre (ssname nombre 0))
      (if (paralelas cosa nombre)
          (setq pgr (inters (pto-ini nombre) (pto-fin nombre) pt1 pt2 nil))
          (progn
            (prompt "\nLa línea seleccionada no es paralela a la primera.")
            (initget "Si No")
            (setq aux (getkword "Desea hacerla paralela (Si/<No>)" ))
            (if (and aux (not (= aux "No")))
                (progn
                  (setvar "CLAYER" (cdr (assoc 8 (entget nombre))))
                  (setq aux (distance (pto-ini nombre) (pto-fin nombre)))
                  (command
                   "_line"
                   (pto-ini nombre)
                   (polar (pto-ini nombre) angulo aux)
                   "")
                  (command
                   "_line"
                   (pto-fin nombre)
                   (polar (pto-fin nombre) angulo aux)
                   "")
                  (entdel nombre)
                  (setq nombre (entlast))
                  (setq pgr (inters (pto-ini nombre) (pto-fin nombre) pt1 pt2 nil)) )))
            )
          )))
  pgr)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.  Mensaje de carga
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(princ "\nFunciones auxiliares de arquitectura cargadas")
(princ)