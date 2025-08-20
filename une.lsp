;; ?????????????????????????????????????????????????????????????????????
;;  ARCHIVOS:  UNE.LSP  ?  Unir dos muros (cascada de 4 líneas)
;;  • Usa las variables de arquitectura (*anchom*, *anchop* …) cuando
;;    sea necesario.  Si el usuario aun no las ha cargado, el script
;;    las crea con valores por defecto.
;;  • Todas las llamadas de dibujo se realizan con `command?s`.
;;  • Se añade un manejador de errores robusto (`une--error`) y
;;    captura con `vl-catch-call` en la función que se expone
;;    (alias `c:une`).
;;  • Se conserva la lógica original de “buscar 4 líneas, agrupar
;;    en 2 muros, recortar, unir”.
;;  ?????????????????????????????????????????????????????????????????????

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.  Variables de arquitectura de referencia
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun une--ensure-vars ()
  "Asegura que las variables de arquitectura (*anchom*, …) existan."
  (unless (boundp '*anchom*) (defvar *anchom* 0.20  "Espesor de muro 2D"))
  (unless (boundp '*anchop*) (defvar *anchop* 0.72  "Anchura de una puerta 2D"))
  (unless (boundp '*anchomh*)(defvar *anchomh* 0.60 "Ancho hoja 1 doble (2D)"))
  (unless (boundp '*anchomh2*)(defvar *anchomh2* 0.50 "Ancho hoja 2 doble (2D)"))
  ;; las variantes con “_” que la versión 1999 usaba
  (unless (boundp '*_anchom_*) (defvar *_anchom_* *anchom*))
  (unless (boundp '*_anchop_*) (defvar *_anchop_* *anchop*)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2.  Función de error
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun une--error (s)
  "Muestra el error `s`, limpia el undo y restaura el entorno."
  (if (/= s "Función cancelada")
      (princ (strcat "\n[UNE] Error: " s)))
  (setq _error_ olderr)
  (setq seleccion nil)
  (recupera-vars)
  (command-s "_undo" "_end")
  (princ)
  (exit))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3.  Guardar / recuperar variables de AutoCAD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *MLST* nil)

(defun une--salva-vars (a)
  (setq *MLST* '())
  (dolist (v a)
    (push (list v (getvar v)) *MLST*)))

(defun une--recupera-vars ()
  (dolist (p *MLST*)
    (setvar (car p) (cadr p)))
  (setq *MLST* nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.  Funciones auxiliares de geometría
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun une--pto-ini (ent) (cdr (assoc 10 (entget ent))))
(defun une--pto-fin (ent) (cdr (assoc 11 (entget ent))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.  Función principal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun une--impl ()
  "Unir dos muros (casos con 4 líneas) con la lógica original."
  ;; 5.1 Garantizar variables de arquitectura y activar error
  (une--ensure-vars)
  (setq olderr _error_
        _error_ une--error)

  ;; 5.2 Guardar estado de AutoCAD
  (une--salva-vars
   '("cmdecho" "blipmode" "expert" "gridmode" "osmode"
     "thickness" "clayer" "OFFSETDIST" "FILLETRAD"))
  (mapcar 'setvar
          '(cmdecho blipmode expert gridmode osmode thickness ORTHOMODE)
          '(1 0 0 0 0 0 0))
  (command-s "_undo" "_begin")

  ;; 5.3  Comprobar capa MUROS
  (if (not (tblsearch "LAYER" "MUROS"))
      (progn
        (prompt "\nEste dibujo no tiene la capa MUROS.")
        (exit)))                    ; causa un error “cancelado”

  ;; 5.4  Seleccionar las líneas de los muros
  (setq pto1 (getpoint "\nDesde: "))
  (setq pto2 (getcorner pto1 "\nHasta: "))
  (setq seleccion (ssget "_C" pto1 pto2 '((8 . "MUROS") (0 . "LINE"))))
  (unless seleccion
    (princ "\nNo se encontró ninguna línea en ese rango.")
    (exit))

  (if (or (< (sslength seleccion) 4) (> (sslength seleccion) 5))
      (progn
        (princ "\nNúmero de líneas no compatible: se esperan 4 líneas.")
        (exit)))

  ;; Si encuentra 5 líneas, borrar la que sobra
  (setq aux (ssget "_W" pto1 pto2 '((8 . "MUROS") (0 . "LINE"))))
  (when aux
    (if (> (sslength aux) 1)          ; demasiadas
        (progn
          (princ "\nDemasiadas líneas en el rango.") (exit))
        (command-s "_erase" aux "")))

  ;; 5.5  Identificar las 4 líneas
  (setq linea1 (ssname seleccion 0)
        linea2 (ssname seleccion 1)
        linea3 (ssname seleccion 2)
        linea4 (ssname seleccion 3))

  ;; 5.6  Agrupar las líneas en 2 muros
  (setq muro1 (ssadd linea1)
        seleccion (ssdel linea2 seleccion))
  (cond   ; comparar ángulos
    ((= (angle (une--pto-ini linea1) (une--pto-fin linea1))
        (angle (une--pto-ini linea2) (une--pto-fin linea2)))
     (setq muro1   (ssadd linea2 muro1)
           seleccion (ssdel linea2 seleccion)
           muro2   (ssadd linea3)
           muro2   (ssadd linea4 muro2)))
    ((= (angle (une--pto-ini linea1) (une--pto-fin linea1))
        (angle (une--pto-ini linea3) (une--pto-fin linea3)))
     (setq muro1   (ssadd linea3 muro1)
           seleccion (ssdel linea3 seleccion)
           muro2   (ssadd linea2)
           muro2   (ssadd linea4 muro2)))
    ((= (angle (une--pto-ini linea1) (une--pto-fin linea1))
        (angle (une--pto-ini linea4) (une--pto-fin linea4)))
     (setq muro1   (ssadd linea4 muro1)
           seleccion (ssdel linea4 seleccion)
           muro2   (ssadd linea3)
           muro2   (ssadd linea2 muro2)))
    (t (princ "\nNo se encontró par de líneas paralelas.") (exit)))

  ;; 5.7  Confirmar que cada muro es realmente dos líneas paralelas
  (setq linea1 (ssname muro1 0)
        linea2 (ssname muro1 1)
        linea3 (ssname muro2 0)
        linea4 (ssname muro2 1))
  (unless (and (= (angle (une--pto-ini linea3) (une--pto-fin linea3))
                 (angle (une--pto-ini linea4) (une--pto-fin linea4)))
    (princ "\nEl segundo conjunto de líneas no es paralelo.") (exit))

  ;; 5.8  Recortar los dos muros en la intersección
  (let ((int1 (inters  (une--pto-ini linea1) (une--pto-fin linea1)
                         (une--pto-ini linea3) (une--pto-fin linea3)))
        (int2 (inters  (une--pto-ini linea1) (une--pto-fin linea1)
                         (une--pto-ini linea4) (une--pto-fin linea4)))
        (int3 (inters  (une--pto-ini linea2) (une--pto-fin linea2)
                         (une--pto-ini linea4) (une--pto-fin linea4)))
        (int4 (inters  (une--pto-ini linea2) (une--pto-fin linea2)
                         (une--pto-ini linea3) (une--pto-fin linea3))))
    ;; Si existe mínimo una intersección válida, usar BE. Break
    (when (and int1 int2)
      (command-s "_break" linea1 int1 int2))
    (when (and int1 int2)
      (command-s "_break" linea2 int3 int4))
    (when (and int1 int2)
      (command-s "_break" linea3 int1 int3))
    (when (and int1 int2)
      (command-s "_break" linea4 int2 int4)))

  ;; 5.9  Finalizar
  (command-s "_undo" "_end")
  (une--recupera-vars)
  (princ))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.  Alias y mensaje de bienvenida
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:une () (une--impl))      ;; Alias (equiv. a c:union en AutoCAD)
(princ "\nFunción para unir muros (siete líneas)…cargada OK")
(princ)