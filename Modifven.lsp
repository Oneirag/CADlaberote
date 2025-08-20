;; ==============================================================
;;  modifven.lsp   –  Modificar parámetros de una ventana
;;  AutoCAD?2026, compatible con arquitectura_v2026.lsp
;;  •  Usa las variables globales (*cristal*, *perfil*, *alf*, *tipo*,
;;     *centrar*) que ya están definidas en arquitectura_v2026.lsp.
;;  •  Se emplea `command-s` en todas partes.
;;  •  Manejo de errores con una función de error dedicada.
;;  •  Guardado / recuperación de variables de AutoCAD.
;;  •  Mensaje de bienvenida y alias de la orden.
;; ==============================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.  Asegurar que todas las variables de arquitectura existan  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun modifven--ensure-vars ()
  "Crea las variables que el programa necesita si no están definidas."
  (unless (boundp '*cristal*)  (defvar *cristal* 0.5  "Espesor del cristal 2D"))
  (unless (boundp '*perfil* )  (defvar *perfil*  0.05 "Espesor del perfil 2D"))
  (unless (boundp '*alf*   )  (defvar *alf*    "Si"  "Alfeizar (Si/No)"))
  (unless (boundp '*tipo*  )  (defvar *tipo*   "Doble" "Tipo de ventana"))
  (unless (boundp '*centrar*) (defvar *centrar* "No" "Centrar en muro"))
  ;; en la versión original también había variables sin asterisco;
  ;; si todavía las necesitas, simplemente haz referencia a ellas
  ;; (por ejemplo: (if (boundp 'tipo) (setq *tipo* tipo))))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2.  Manejo de errores                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun modifven--error (msg)
  "Muestra `msg`, restaura el entorno guardado y finaliza."
  (princ (strcat "\n[MODIFVEN] Error: " msg))
  (redraw)                ; asegura que la pantalla esté actualizada
  (command-s "_undo" "_end")
  (modifven--recupera-vars)
  (setq _error_ olderr)
  (princ)
  (exit))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3.  Guardar / Recuperar variables de AutoCAD                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar *MLST* nil)   ; lista donde se guardan las variables

(defun modifven--salva-vars (vars)
  "Guarda en *MLST* las variables `vars`."
  (setq *MLST* (mapcar (lambda (v) (list v (getvar v))) vars)))

(defun modifven--recupera-vars ()
  "Restaura las variables guardadas en *MLST*."
  (when *MLST*
    (mapcar (lambda (p) (setvar (car p) (cadr p))) *MLST*)
    (setq *MLST* nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.  Función principal (implementación real)                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun modifven--impl ()
  "Solicita al usuario los nuevos valores de una ventana."
  ;; 4.1  Guardar estado y activar control de errores
  (setq olderr _error_ _error_ modifven--error)

  ;; 4.2  Asegurar variables de arquitectura
  (modifven--ensure-vars)

  ;; 4.3  Guardar configuración de AutoCAD
  (modifven--salva-vars
    '("cmdecho" "blipmode" "expert" "gridmode" "osmode"
      "thickness" "clayer" "OFFSETDIST" "ORTHOMODE"))
  (mapcar 'setvar
          '(cmdecho blipmode expert gridmode osmode thickness ORTHOMODE)
          '(0 0 0 0 0 0 0))
  (command-s "_undo" "_begin")

  ;; 4.4  Abrir el “slide” de la ventana
  (command-s "_vslide" "VENTANA")

  ;; 4.5  Tipo de ventana
  (let ((mensaje (strcat "\nTipo de ventana (Simple/Doble/3/4) <"
                         *tipo* ">: "))
        (valor nil))
    (initget "Simple Doble 3 4")
    (when (setq valor (getkword mensaje))
      (setq *tipo* valor)))

  ;; 4.6  Alfeizar
  (let ((mensaje (strcat "\nLleva alfeizar (Si/No) <"
                         *alf* ">: "))
        (valor nil))
    (initget "Si No")
    (when (setq valor (getkword mensaje))
      (setq *alf* valor)))

  ;; 4.7  Ancho del cristal
  (let ((mensaje (strcat "\nAncho del cristal <" (rtos *cristal*) "> : "))
        (valor nil))
    (when (setq valor (getdist mensaje))
      (setq *cristal* valor))
    (setq *cristal* (distof (rtos *cristal* 2 2) 2)))  ; redondea a cm

  ;; 4.8  Espesor del perfil
  (let ((mensaje (strcat "\nAncho del perfil <" (rtos *perfil*) "> : "))
        (valor nil))
    (when (setq valor (getdist mensaje))
      (setq *perfil* valor))
    (setq *perfil* (distof (rtos *perfil* 2 2) 2)))

  ;; 4.9  Centrar en el muro
  (let ((mensaje (strcat "\nCentrar en el muro (Si/No) <"
                         *centrar* ">: "))
        (valor nil))
    (initget "Si No")
    (when (setq valor (getkword mensaje))
      (setq *centrar* valor)))

  ;; 4.10  Refrescar pantalla
  (redraw)

  ;; 4.11  Restaurar el entorno y terminar
  (setq _error_ olderr)
  (modifven--recupera-vars)
  (princ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.  Alias y mensaje de bienvenida                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:modifven () (modifven--impl))
(defun c:mopven () (modifven--impl))   ; alias

(princ "\nFunción para modificar parámetros de la ventana cargada OK")
(princ)