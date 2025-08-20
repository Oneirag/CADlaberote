;; ==============================================================
;;  ventana.lsp – crea una ventana en un muro (2D/3D)
;;  •  Ahora usa las variables globales de `arquitectura_v2026.lsp`
;;  •  Manejado con `command?s` y con manejo de errores “try”/`vl?catch?call`
;;  •  Los bloques de carpintería se generan de forma consistente
;; ==============================================================

;; ------------------------------------------------------------------
;; 1.  Aseguramos que las variables globales existan
;; ------------------------------------------------------------------
(defun ventana--ensure-vars ()
  "Crea las variables de arquitectura (*cristal*, *perfil*, …) si no existen."
  (unless (boundp '*cristal*) (defvar *cristal* 0.5  "Espesor del cristal 2D"))
  (unless (boundp '*perfil*)  (defvar *perfil* 0.05 "Espesor del perfil 2D"))
  (unless (boundp '*alf*)     (defvar *alf* "Si"      "Alfeizar (Si/No)"))
  (unless (boundp '*alfeiz*)(defvar *alfeiz* 0.03 "Alfeizar 0.03"))
  (unless (boundp '*tipo*)(defvar *tipo* "Doble"      "Simple, Doble, Triple…"))
  (unless (boundp '*centrar*)(defvar *centrar* "No" "Centra en muro?")))

;; ------------------------------------------------------------------
;; 2.  Manejo de errores – captura con `vl?catch?call`
;; ------------------------------------------------------------------
(defun ventana--error (msg)
  "Muestra un mensaje de error y restaura el entorno."
  (princ (strcat "\n[VENTANA] Error: " msg))
  (command-s "_undo" "_end")              ; cancelar cualquier acción
  (ventana--recupera-vars)
  (setq _error_ olderr)                   ; restaura el controlador original
  (princ)                                 ; no devuelve nada
  (exit))

;; ------------------------------------------------------------------
;; 3.  Guardar / recuperar variables de AutoCAD
;; ------------------------------------------------------------------
(defvar *MLST* nil)

(defun ventana--salva-vars (vars)
  "Guarda el estado de las variables `vars` en `*MLST*`."
  (setq *MLST* (mapcar (lambda (v)
                         (list v (getvar v)))
                       vars)))

(defun ventana--recupera-vars ()
  "Restaura las variables guardadas en `*MLST*`."
  (when *MLST*
    (mapcar (lambda (p)
              (setvar (car p) (cadr p)))
            *MLST*)
    (setq *MLST* nil)))

;; ------------------------------------------------------------------
;; 4.  Carpintería (perfil + hoja + alfeizar)
;; ------------------------------------------------------------------
(defun ventana--carpint ()
  "Dibuja la carpintería (perfil + hoja) en la capa 0."
  (setvar "CLAYER" "0")

  ;; 1. Perfil (izquierda)
  (command-s "_rectang" "0,0" (list *perfil* *perfil*))
  (setq seleccion (ssadd (entlast) seleccion))

  ;; 2. Hoja (mediana)
  (command-s "_copy" (entlast) "" "0,0" (list (+ *cristal* *perfil*) 0))
  (setq seleccion (ssadd (entlast) seleccion))

  ;; 3. Líneas de la hoja (3 lineas)
  (command-s "_line" (list *perfil* 0) (list (+ *perfil* *cristal*) 0) "")
  (setq seleccion (ssadd (entlast) seleccion))

  (command-s "_line" (list (* 0.5 *perfil*) (* 0.5 *perfil*)) 
                (list (+ *perfil* *cristal* 0.5) (* 0.5 *perfil*)) "")
  (setq seleccion (ssadd (entlast) seleccion))

  (command-s "_line" (list *perfil* *perfil*) 
                (list (+ *perfil* *cristal*) *perfil*) "")
  (setq seleccion (ssadd (entlast) seleccion)))

;; ------------------------------------------------------------------
;; 5.  Función principal – `ventana--impl`
;; ------------------------------------------------------------------
(defun ventana--impl ()
  "Crea una ventana sobre un muro."
  ;; 5.1  Establecer manejo de errores
  (setq olderr _error_ _error_ ventana--error)

  ;; 5.2  Guardar configuración de AutoCAD
  (ventana--salva-vars
   '("cmdecho" "blipmode" "expert" "gridmode"
     "osmode" "thickness" "clayer" "OFFSETDIST" "ORTHOMODE"))

  (mapcar 'setvar
          '(cmdecho blipmode expert gridmode osmode thickness ORTHOMODE)
          '(0 0 0 0 0 0 0))

  (command-s "_undo" "_begin")

  ;; 5.3  Algunas variables locales
  (setq hueco (+ *perfil* *cristal* *perfil*))   ; útil para offset
  (setq aux nil)

  ;; 5.4  Punto de la bisagra
  (setq bisagra (getpoint "\nPunto en el que irá una bisagra <Relativo>: "))
  (unless bisagra (setq bisagra (pto-rel)))
  (setq bisagra (osnap bisagra "_nearest"))
  (setq cosamuro (ssname (ssget bisagra) 0))
  (setq datosmuro (entget cosamuro))
  (setq capamuro (cdr (assoc 8 datosmuro)))    ; capa actual
  (setq pgrosor (encuentra-muro cosamuro bisagra))

  (unless pgrosor
    (princ "\nNo encuentro otra línea paralela") (exit))

  ;; 5.5  Lado del hueco
  (setq aux (getpoint bisagra "\nHacia que lado de la bisagra irá el hueco: "))

  ;; 5.6  Dimensiones del bloque
  (setq distancia (distance bisagra pgrosor))
  (setq distancia (distof (rtos distancia 2 2) 2))   ; redondeo a cm

  (setq nombre (strcat "V"
                       (substr *tipo* 1 1) (substr *alf* 1 1) (substr *centrar* 1 1)
                       (rtos (* 100 *cristal*) 2 0) "-P"
                       (rtos (* 100 *perfil*) 2 0)
                       "Muro"
                       (rtos (* 100 distancia) 2 0)))

  ;; 5.7  Crear bloque de ventana si no existe
  (unless (tblsearch "BLOCK" nombre)
    ;; Construir el bloque
    (prompt "\nCreando un nuevo bloque de ventana…")
    (setq seleccion nil)
    (setq seleccion (ssadd))

    ;; Jamba izquierda
    (setvar "CLAYER" "0")
    (command-s "_rectang" "0,0" (list *perfil* *perfil*))
    (setq seleccion (ssadd (entlast) seleccion))

    ;; Jamba derecha
    (command-s "_copy" seleccion "" "0,0"
               (list (+ *cristal* *perfil*) 0))
    (setq seleccion (ssadd (entlast) seleccion))

    ;; Hoja
    (command-s "_line" (list *perfil* 0) (list (+ *perfil* *cristal*) 0) "")
    (setq seleccion (ssadd (entlast) seleccion))
    (command-s "_line" (list (* 0.5 *perfil*) (* 0.5 *perfil*)) 
              (list (+ *perfil* *cristal* 0.5) (* 0.5 *perfil*)) "")
    (setq seleccion (ssadd (entlast) seleccion))
    (command-s "_line" (list *perfil* *perfil*) 
              (list (+ *perfil* *cristal*) *perfil*) "")
    (setq seleccion (ssadd (entlast) seleccion))

    ;; Tipo de ventana: doble, triple, ...
    (cond
      ((string= *tipo* "Doble")
       (command-s "_move" seleccion "" (list (+ *cristal* *perfil* *perfil*) 0) "0,0")
       (ventana--carpint)               ; dibuja la segunda carpintería
       (command-s "_line" "0,-.05" "0,.1" "")
       (setq seleccion (ssadd (entlast) seleccion))
       (command-s "_move" seleccion "" "0,0" 
                  (list (+ *cristal* *perfil* *perfil*) 0)))
      ((not (string= *tipo* "Simple"))
       (repeat (- (atoi *tipo*) 1)            ; 3?4…etc.
         (command-s "_move" seleccion "" "0,0" 
                    (list (+ *cristal* *perfil* *perfil*) 0))
         (ventana--carpint)
         (command-s "_line" (list hueco -0.05) 
                   (list hueco (+ 0.05 *perfil*)) "")
         (setq seleccion (ssadd (entlast) seleccion)))))
    ;; Alfeizar
    (setq hueco (+ *perfil* *cristal* *perfil*))  ; base
    (cond
      ((string= *tipo* "Doble") (setq hueco (* 2 hueco)))
      ((string= *tipo* "Simple") nil)   ; deja hueco tal cual
      (T (setq hueco (* (atof *tipo*) hueco))))

    (when (string= *centrar* "Si")
      (command-s "_move" seleccion "" "0,0"
               (list 0 (/ (- distancia *perfil*) 2)))
      (command-s "_line" "0,0" (list hueco 0) "")
      (setq seleccion (ssadd (entlast) seleccion)))

    (if (string= *alf* "No")
        (command-s "_line" (list 0 distancia) (list hueco distancia) "")
      (command-s "_pline"
              (list (- 0 *alfeiz*) distancia)
              (list (- 0 *alfeiz*) (+ distancia *alfeiz*))
              (list (+ hueco *alfeiz*) (+ distancia *alfeiz*))
              (list (+ hueco *alfeiz*) distancia)
              ""))

    (setq seleccion (ssadd (entlast) seleccion))
    (command-s "_block" nombre "0,0" seleccion "")
    (prompt "Nueva ventana creada OK"))

  ;; 5.8  Dibujar ventana sobre el muro
  (setvar "CLAYER" capamuro)
  (command-s "_line" bisagra pgrosor "")
  (setq linea1 (entlast))

  ;; Offset con el ancho de la ventana
  (setq hueco (+ *perfil* *cristal* *perfil*))  ; base
  (cond
    ((string= *tipo* "Doble") (setq hueco (* 2 hueco)))
    ((string= *tipo* "Simple") nil)
    (T (setq hueco (* (atof *tipo*) hueco))))

  (command-s "_offset" hueco linea1 aux "")
  (setq aux (entlast))
  (setq linea2 (entget aux))

  ;; Puntos de corte
  (setq p4 (cdr (assoc 10 linea2)))
  (setq p5 (cdr (assoc 11 linea2)))

  (entdel linea1)                             ; quita la línea mientras recortamos
  (command-s "_break"
             (polar bisagra (angle bisagra p4) (/ *anchop* 2)) "_f"
             bisagra p4)
  (command-s "_break"
             (polar pgrosor (angle pgrosor p5) (/ *anchop* 2)) "_f"
             pgrosor p5)
  (entdel linea1)                             ; vuelve a dibujarla

  ;; --- Capa Carpintería y posibles ajustes ---
  (unless (tblsearch "LAYER" "Carpinteria")
    (command-s "_LAYER" "_New" "Carpinteria" "_color" "_cyan"
              "Carpinteria" ""))
  (setvar "CLAYER" "Carpinteria")

  ;; Escala y rotación al insertar
  (setq angulo (angle bisagra p4))
  (if (or
       (= (abs (- angulo (/ pi 2))) 0.001)
       (= (abs (- angulo (* 3 pi/2))) 0.001))
      (setq escala 1)
    (setq escala -1))

  (command-s "_insert" nombre bisagra "" escala
             (* 180.0 (/ angulo pi)))

  ;; Finalizar
  (command-s "_undo" "_end")
  (setq _error_ olderr)
  (ventana--recupera-vars)
  (princ))                                         ; no devuelve nada

;; ------------------------------------------------------------------
;; 6.  Alias y mensaje de bienvenida
;; ------------------------------------------------------------------
(defun c:ventana () (ventana--impl))
(defun c:ven () (ventana--impl))     ; alias

(princ "\nFunción para insertar ventanas en un muro (2D) cargada OK")
(princ)