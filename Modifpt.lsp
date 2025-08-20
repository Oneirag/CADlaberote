;; --------------------------------------------------------------------
;;  modifpt.lsp  (Autocad 2026, compatible con arquitectura_v2026.lsp)
;;  •  Cambia el ancho y la jamb  de una puerta ya dibujada.
;;  •  Emplea `command-s`, funciones robustas de guardado/recuperación
;;      de variables y de error mejorado (`vl?catch?call`).
;;  •  Consigue las variables globables (*anchop*, *jamba*, …) que ya están
;;      definidas en `arquitectura_v2026.lsp`. Si no se han cargado,
;;      las crea con valores por defecto.
;; --------------------------------------------------------------------

;;; --------------------------------------------------------------------
;;; 1.  Garantía de que las variables de arquitectura existan
;;; --------------------------------------------------------------------
(defun modifpt--ensure-vars ()
  "Crea las variables que el programa necesita si no están definidas."
  (unless (boundp '*anchop*)   (defvar *anchop* 0.72  "Anchura de una puerta 2D"))
  (unless (boundp '*jamba* )   (defvar *jamba* 0.05 "Espesor de la jamba"))
  (unless (boundp '*anchom*)   (defvar *anchom* 0.20  "Espesor muro 2D"))
  (unless (boundp '*anchomh*)(defvar *anchomh* 0.6 "Ancho hoja 1 doble"))
  (unless (boundp '*anchomh2*)(defvar *anchomh2* 0.5 "Ancho hoja 2 doble"))
  (unless (boundp '*cristal*)(defvar *cristal* 0.5 "Ancho cristal ventana"))
  (unless (boundp '*perfil*)(defvar *perfil* 0.05 "Ancho perfil ventana"))
  (unless (boundp '*tipo*)(defvar *tipo* "Doble" "Tipo de ventana"))
  (unless (boundp '*alf*)(defvar *alf* "Si"       "Alfeizar"))
  (unless (boundp '*alfeiz*)(defvar *alfeiz* 0.03 "Alfeizar 3?cm"))
  (unless (boundp '*centrar*)(defvar *centrar* "No" "Centra en muro"))
  ;;  Además, la versión original usaba prefijo “_”. Si sigue ahí,
  ;;  recordemos la relación para evitar confusiones:
  (unless (boundp '*_anchop_*) (defvar *_anchop_* *anchop*))
  (unless (boundp '*_jamba_*)  (defvar *_jamba_* *jamba*)))

;;; --------------------------------------------------------------------
;;; 2.  Manejo de errores
;;; --------------------------------------------------------------------
(defun modifpt--error (msg)
  "Muestra `msg`, restaura estado guardado y termina."
  (princ (strcat "\n[MOD?FPT] Error: " msg))
  (redraw)                          ; garantizamos la actualización de pantalla
  (command-s "_undo" "_end")
  (modifpt--recupera-vars)
  (setq _error_ olderr)
  (princ)
  (exit))

;;; --------------------------------------------------------------------
;;; 3.  Guardar / Recuperar variables de AutoCAD
;;; --------------------------------------------------------------------
(defvar *MLST* nil)                               ; guardado de variables

(defun modifpt--salva-vars (vars)
  (setq *MLST*
        (mapcar (lambda (v) (list v (getvar v))) vars)))

(defun modifpt--recupera-vars ()
  (when *MLST*
    (mapcar (lambda (p) (setvar (car p) (cadr p))) *MLST*)
    (setq *MLST* nil)))

;;; --------------------------------------------------------------------
;;; 4.  Función principal (implementación real)
;;; --------------------------------------------------------------------
(defun modifpt--impl ()
  "Prompt a usuario para cambiar el ancho (anchop) y
   la jamb (jamba) de una puerta ya dibujada."
  ;; 4.1  Guardar estado y activar manejador de error
  (setq olderr _error_ _error_ modifpt--error)

  ;; 4.2  Asegurar variables de arquitectura
  (modifpt--ensure-vars)

  ;; 4.3  Guardar configuración de AutoCAD
  (modifpt--salva-vars
    '("cmdecho" "blipmode" "expert" "gridmode" "osmode"
      "thickness" "clayer" "OFFSETDIST" "ORTHOMODE"))
  (mapcar 'setvar          ; modo sin eco, sin ruidos…
          '(cmdecho blipmode expert gridmode osmode thickness ORTHOMODE)
          '(0 0 0 0 0 0 0))
  (command-s "_undo" "_begin")

  ;; 4.4  Activar ventana de “puerta” (ver documentación)
  (command-s "_vslide" "puerta")

  ;; 4.5  Pedir nuevo ancho / jamba
  (let ((mensaje (strcat "\nAncho de la hoja <" (rtos *anchop* 2 1) ">: "))
        (nuevovalor nil))
    (when (setq nuevovalor (getdist mensaje))
      (setq *anchop* nuevovalor))
    (setq *anchop* (distof (rtos *anchop* 2 2) 2)))  ; redondeo a centímetro

  (let ((mensaje (strcat "\nAncho de la jamba <" (rtos *jamba* 2 1) ">: "))
        (nuevovalor nil))
    (when (setq nuevovalor (getdist mensaje))
      (setq *jamba* nuevovalor))
    (setq *jamba* (distof (rtos *jamba* 2 2) 2)))    ; redondeo a centímetro

  (redraw)

  ;; 4.6  Restaurar estado
  (setq _error_ olderr)
  (modifpt--recupera-vars)
  (princ))

;;; --------------------------------------------------------------------
;;; 5.  Alias y mensaje de bienvenida
;;; --------------------------------------------------------------------
(defun c:modifpt () (modifpt--impl))
(defun c:mop () (modifpt--impl))      ; alias

(princ "\nFunción para modificar parámetros de la puerta cargada OK")
(princ)