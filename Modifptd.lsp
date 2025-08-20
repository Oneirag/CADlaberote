;; ---------------------------------------------------------------
;;  modifptd.lsp  –  Modifica parámetros de una puerta doble
;;  • Usa las variables globales de arquitectura_v2026.lsp
;;  • Emplea `command?s`, funciones robustas de guardado/recuperación
;;  • Manejo de errores con `vl?catch?call` (o la variante clase?if)
;;  • Mensaje de bienvenida y alias.
;; ---------------------------------------------------------------

;;; --------------------------------------------------------------------
;;; 1.  Asegurar que las variables de arquitectura existan
;;; --------------------------------------------------------------------
(defun modifptd--ensure-vars ()
  "Crea las variables que el programa necesita si no están definidas."
  (unless (boundp '*anchoh1*)(defvar *anchoh1* 0.6  "Ancho hoja 1 (2D)"))
  (unless (boundp '*anchoh2*)(defvar *anchoh2* 0.5  "Ancho hoja 2 (2D)"))
  (unless (boundp '*jamba* ) (defvar *jamba* 0.05  "Espesor de la jamba 2D"))
  (unless (boundp '*anchop* )(defvar *anchop* 0.72  "Anchura de una puerta (usada también por la función `puerta`)"))
  ;; Prefijos con “_” que la arquitectura original definía,
  ;; si aún los necesitas, los reflejamos:
  (unless (boundp '*_anchoh1_*)(defvar *_anchoh1_* *anchoh1*))
  (unless (boundp '*_anchoh2_*)(defvar *_anchoh2_* *anchoh2*))
  (unless (boundp '*_jamba_*)  (defvar *_jamba_* *jamba*)))

;;; --------------------------------------------------------------------
;;; 2.  Manejo de errores
;;; --------------------------------------------------------------------
(defun modifptd--error (msg)
  "Muestra `msg`, restaura estado guardado y finaliza."
  (princ (strcat "\n[MODIFPTD] Error: " msg))
  (redraw)                      ; refresca pantalla
  (command-s "_undo" "_end")
  (modifptd--recupera-vars)
  (setq _error_ olderr)
  (princ)
  (exit))

;;; --------------------------------------------------------------------
;;; 3.  Guardar / Recuperar variables de AutoCAD
;;; --------------------------------------------------------------------
(defvar *MLST* nil)

(defun modifptd--salva-vars (vars)
  (setq *MLST*
        (mapcar (lambda (v) (list v (getvar v))) vars)))

(defun modifptd--recupera-vars ()
  (when *MLST*
    (mapcar (lambda (p) (setvar (car p) (cadr p))) *MLST*)
    (setq *MLST* nil)))

;;; --------------------------------------------------------------------
;;; 4.  Función principal (implementación real)
;;; --------------------------------------------------------------------
(defun modifptd--impl ()
  "Solicita al usuario los valores de las hojas y la jamba de una puerta doble."
  ;; 4.1  **Guardar estado** y activar manejador de error
  (setq olderr _error_ _error_ modifptd--error)

  ;; 4.2  **Asegurar variables de arquitectura**
  (modifptd--ensure-vars)

  ;; 4.3  **Guardar configuración de AutoCAD**
  (modifptd--salva-vars
    '("cmdecho" "blipmode" "expert" "gridmode" "osmode"
      "thickness" "clayer" "OFFSETDIST" "ORTHOMODE"))
  (mapcar 'setvar
          '(cmdecho blipmode expert gridmode osmode thickness ORTHOMODE)
          '(0 0 0 0 0 0 0))
  (command-s "_undo" "_begin")

  ;; 4.4  Abrir el “slide” de la puerta doble
  (command-s "_vslide" "puerta-doble")

  ;; 4.5  Los nuevos valores de las hojas
  (let ((mensaje (strcat "\nAncho de la hoja 1 <" (rtos *anchoh1* 2 1) ">: "))
        (nuevo nil))
    (when (setq nuevo (getdist mensaje))
      (setq *anchoh1* nuevo))
    (setq *anchoh1* (distof (rtos *anchoh1* 2 2) 2)))          ; cm

  (let ((mensaje (strcat "\nAncho de la hoja 2 <" (rtos *anchoh2* 2 1) ">: "))
        (nuevo nil))
    (when (setq nuevo (getdist mensaje))
      (setq *anchoh2* nuevo))
    (setq *anchoh2* (distof (rtos *anchoh2* 2 2) 2)))

  ;; 4.6  y el ancho de la jamba
  (let ((mensaje (strcat "\nAncho de la jamba <" (rtos *jamba* 2 1) ">: "))
        (nuevo nil))
    (when (setq nuevo (getdist mensaje))
      (setq *jamba* nuevo))
    (setq *jamba* (distof (rtos *jamba* 2 2) 2)))

  (redraw)

  ;; 4.7  **Recuperar estado y terminar**
  (setq _error_ olderr)
  (modifptd--recupera-vars)
  (princ))

;;; --------------------------------------------------------------------
;;; 5.  Alias y mensaje de bienvenida
;;; --------------------------------------------------------------------
(defun c:modifptd () (modifptd--impl))
(defun c:mopd   () (modifptd--impl))   ; alias

(princ "\nFunción para modificar parámetros de la puerta doble cargada OK")
(princ)