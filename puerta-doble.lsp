;; ==============================================================
;;  puerta-doble.lsp  (AutoCAD 2026 + arquitectura_v2026.lsp)
;;  •  Uso de variables globales *anchop*, *anchoh1*, *anchoh2*, *jamba*.
;;  •  Manejo de errores con `vl‑catch‑call` y función `puerta-doble--error`.
;;  •  Toda la lógica se basa en `command-s`; no se usan comandos
;;      anteriores («Command», «_»…).
;;  •  La función real se llama `puerta-doble--impl`; se expone
;;      con los alias `c:puertadoble` y `c:ptd`.
;; ==============================================================
;;; -------------------------------------------------------------------
;;; 1.  Asegurar que las variables globales se encuentran (de
;;;     arquitectura_v2026.lsp)
;;; -------------------------------------------------------------------
(defun puerta-doble--ensure-vars ()
  "Crea las variables que el módulo necesita si no existen."
  (unless (boundp '*anchop*)  (defvar *anchop* 0.72  "Anchura de la puerta 2D"))
  (unless (boundp '*anchoh1*)(defvar *anchoh1* 0.6 "Ancho hoja 1 (2D)"))
  (unless (boundp '*anchoh2*)(defvar *anchoh2* 0.5 "Ancho hoja 2 (2D)"))
  (unless (boundp '*jamba* ) (defvar *jamba* 0.05 "Espesor de jambas"))
  (unless (boundp '*anchom*)(defvar *anchom* 0.20 "Espesor de muro 2D"))
  (unless (boundp '*altop* )(defvar *altop* 2.3  "Altura de puertas 3D"))
  (unless (boundp '*altom* )(defvar *altom* 2.7  "Altura de muros 3D"))
  ;; la arquitectura también define *_anchop_, *_jamba_*, …
  (unless (boundp '*_anchop_*) (defvar *_anchop_* *anchop*))
  (unless (boundp '*_jamba_*)  (defvar *_jamba_* *jamba*)))
;;; -------------------------------------------------------------------
;;; 2.  Manejo de errores
;;; -------------------------------------------------------------------
(defun puerta-doble--error (msg)
  "Muestra `msg`, libera el undo y restaura variables."
  (princ (strcat "\n[PUERTA‑DOBLE] Error: " msg))
  (command-s "_undo" "_end")
  (puerta-doble--recupera-vars)
  (setq _error_ olderr)
  (princ)
  (exit))

;;; -------------------------------------------------------------------
;;; 3.  Guardar / Recuperar variables de AutoCAD
;;; -------------------------------------------------------------------
(defvar *MD* nil)                                 ; <- equivalente a MLST en el antiguo código

(defun puerta-doble--salva-vars (vars)
  (setq *MD* (mapcar (lambda (v) (list v (getvar v))) vars)))

(defun puerta-doble--recupera-vars ()
  (when *MD*
    (mapcar (lambda (p)
              (setvar (car p) (cadr p)))
            *MD*)
    (setq *MD* nil)))

;;; -------------------------------------------------------------------
;;; 4.  Función principal (implementación real)
;;; -------------------------------------------------------------------
(defun puerta-doble--impl ()
  "Crea una puerta doble en un muro."
  ;--- 4.1  Guardar estado y activar el controlador de error
  (setq olderr _error_ _error_ puerta-doble--error)

  ;--- 4.2  Variables globales de arquitectura deben existir
  (puerta-doble--ensure-vars)

  ;--- 4.3  Guardar estado de AutoCAD
  (puerta-doble--salva-vars
   '("cmdecho" "blipmode" "expert" "gridmode" "osmode"
     "thickness" "clayer" "OFFSETDIST" "ORTHOMODE"))
  (mapcar 'setvar
          '(cmdecho blipmode expert gridmode osmode thickness ORTHOMODE)
          '(0 0 0 0 0 0 0))
  (command-s "_undo" "_begin")

  ;--- 4.4  Selección de la bisagra
  (setq bisagra (getpoint "\nPunto en el que irá la bisagra <Relativo>: "))
  (unless bisagra (setq bisagra (pto-rel)))
  (setq bisagra (osnap bisagra "_nearest"))
  (setq cosamuro (ssname (ssget bisagra) 0))
  (setq datosmuro (entget cosamuro))
  (setq capamuro (cdr (assoc 8 datosmuro)))   ; capa del muro
  (setq pgrosor (encuentra-muro cosamuro bisagra))
  (unless pgrosor
    (princ "\nNo encuentro otra línea paralela")
    (exit))

  ;--- 4.5  Lado de la bisagra
  (setq aux (getpoint bisagra "\nHacia que lado de la bisagra irá el hueco: "))

  ;--- 4.6  Ancho de cada hoja
  (let ((mensaje
         (if (not *anchoh1*)
             "\nAncho de la hoja 1 <ancho>: "
           (strcat "\nAncho de la hoja 1 <" (rtos *anchoh1*) 2 1) "> ")))
    (when (setq nuevovalor (getdist bisagra mensaje))
      (setq *anchoh1* nuevovalor))
    (setq *anchoh1* (distof (rtos *anchoh1* 2 2) 2)))
  (let ((mensaje
         (if (not *anchoh2*)
             "\nAncho de la hoja 2 <ancho>: "
           (strcat "\nAncho de la hoja 2 <" (rtos *anchoh2*) 2 1) "> ")))
    (when (setq nuevovalor (getdist bisagra mensaje))
      (setq *anchoh2* nuevovalor))
    (setq *anchoh2* (distof (rtos *anchoh2* 2 2) 2)))

  ;--- 4.7  Crear el bloque de la puerta doble si no existe
  (setq nombre (strcat "PD_H"
                       (rtos (* 100 *anchoh1*) 2 0) "-H"
                       (rtos (* 100 *anchoh2*) 2 0) "-J"
                       (rtos (* 100 *jamba*) 2 0)))

  (unless (tblsearch "BLOCK" nombre)
    (prompt "\nCreando un nuevo bloque de puerta doble…")
    (setq seleccion (ssadd))

    (setvar "CLAYER" "0")
    ;; jamba izquierda
    (command-s "_rectang" "0,0" (list *jamba* *jamba*))
    (setq seleccion (ssadd (entlast) seleccion))

    ;; otra jamba (copia)
    (command-s "_copy" seleccion "" "0,0"
               (list (+ *anchoh1* *anchoh2* *jamba*) 0))
    (setq seleccion (ssadd (entlast) seleccion))

    ;; hoja 1
    (command-s "_rectang" "0,0" (list 0.03 *anchoh1*))
    (setq seleccion (ssadd (entlast) seleccion))
    (command-s "_move" (entlast) "" "0,0"
               (list *jamba* *jamba*))

    ;; hoja 2
    (command-s "_rectang" "0,0" (list 0.03 *anchoh2*))
    (setq seleccion (ssadd (entlast) seleccion))
    (command-s "_move" (entlast) "" "0,0"
               (list (+ *jamba* *anchoh1* *anchoh2* -0.03) *jamba*))

    ;; arco 1
    (command-s "_arc" "_c" "0,0"
               (list *anchoh1* 0) (list 0 *anchoh1*))
    (setq seleccion (ssadd (entlast) seleccion))
    (command-s "_move" (entlast) "" "0,0" (list *jamba* *jamba*))

    ;; arco 2
    (command-s "_arc" "_c" "0,0"
               (list 0 *anchoh2*) (list (* *anchoh2* -1) 0))
    (setq seleccion (ssadd (entlast) seleccion))
    (command-s "_move" (entlast) "" "0,0"
               (list (+ *jamba* *anchoh1* *anchoh2*) *jamba*))

    (command-s "_block" nombre "0,0" seleccion "")
    (prompt "Nueva puerta doble creada OK"))

  ;--- 4.8  Dibujar la puerta sobre el muro
  (setvar "CLAYER" capamuro)
  (command-s "_line" bisagra pgrosor "")
  (setq linea1 (entlast))

  ;; offset (ancho completo + dos jambas)
  (command-s "_offset"
             (+ *anchoh1* *anchoh2* (* 2 *jamba*)) linea1 aux "")
  (setq aux (entlast))
  (setq linea2 (entget aux))

  ;; puntos de corte
  (setq p4 (cdr (assoc 10 linea2)))
  (setq p5 (cdr (assoc 11 linea2)))

  ;; recortar las líneas del muro
  (entdel linea1)
  (command-s "_break"
             (polar bisagra (angle bisagra p4) (/ *anchop* 2)) "_f"
             bisagra p4)
  (command-s "_break"
             (polar pgrosor (angle pgrosor p5) (/ *anchop* 2)) "_f"
             pgrosor p5)
  (entdel linea1)  ; vuelve a dibujarla (opcional, basta con el `break`)

  ;; Capa Carpintería → si no existe, crearla
  (unless (tblsearch "LAYER" "Carpinteria")
    (command-s "_LAYER" "_New" "Carpinteria" "_color" "_cyan" "Carpinteria" ""))
  (setvar "CLAYER" "Carpinteria")

  ;; Insertar el bloque con rotación correcta
  (setq angulo (angle bisagra p4))
  (if (or
       (= (abs (- angulo (/ pi 2))) 0.001)
       (= (abs (- angulo (* 3 pi/2))) 0.001))
      (command-s "_insert" nombre bisagra "" "" (* 180.0 (/ angulo pi)))
    (command-s "_insert" nombre bisagra "" "-1" (* 180.0 (/ angulo pi))))

  ;--- 4.9  Limpiar y restaurar
  (command-s "_undo" "_end")
  (setq _error_ olderr)
  (puerta-doble--recupera-vars)
  (princ))

;;; -------------------------------------------------------------------
;;; 5.  Alias y mensaje de bienvenida
;;; -------------------------------------------------------------------
(defun c:puertadoble () (puerta-doble--impl))
(defun c:ptd () (puerta-doble--impl))      ; alias

(princ "\nFunción para hacer puertas dobles en un muro (2D) cargada OK")
(princ)