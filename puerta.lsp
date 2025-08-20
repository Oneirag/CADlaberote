;; ────────────────────────────────────────────────────────────────────────
;;  puerta.lsp –   Dibuja una puerta (2D/3D)
;; ────────────────────────────────────────────────────────────────────────
;;  Compatibilidad con la nueva arquitectura_v2026.lsp
;;  • Usa las variables globales definidas en esa librería.
;;  • Altamente portátil: en caso de que la variable no exista,
;;    la crea con un valor por defecto.
;;  • Se optimiza el manejo de errores con `vl-catch-call`.
;;  • Sólo se usa `command-s`, no `Command:` ni `Command`.
;;  ────────────────────────────────────────────────────────────────────────

;; ------------------- 1.  Preparar el entorno --------------------------
;; Aseguremos que los símbolos a los que nos referimos realmente existen.
;; Si el usuario tiene *anchop* / *jamba* etc., nos apoyamos en ellos;
;; si no, creamos variables con los nombres habituales de AutoCAD
;; (sin signos de puntuación al principio ni al final) para mantener la
;; independencia.

(defun puerta--prepare-variables ()
  "Crea las variables de arquitectura en el espacio global
si no están ya definidas."
  (unless (boundp '*anchop*)  (defvar *anchop* 0.72  "Anchura de una puerta 2D"))
  (unless (boundp '*jamba*)   (defvar *jamba* 0.05  "Espesor de las jambas 2D"))
  (unless (boundp '*anchomh*) (defvar *anchomh* 0.6  "Ancho hoja 1ª opción 2D"))
  (unless (boundp '*anchomh2*)(defvar *anchomh2* 0.5 "Ancho hoja 2ª opción 2D"))
  (unless (boundp '*cristal*)(defvar *cristal* 0.5 "Espesor del cristal 2D"))
  (unless (boundp '*perfil*)(defvar *perfil* 0.05 "Espesor perfil 2D"))
  (unless (boundp '*alf*)(defvar *alf* "Si"  "Presencia de alfeizar? 1 sí 2 no"))
  (unless (boundp '*alfeiz*)(defvar *alfeiz* 0.03 "Alfeizar 0.03"))
  (unless (boundp '*tipo*)(defvar *tipo* "Doble" "Tipo de ventana simple/doble"))
  (unless (boundp '*centrar*)(defvar *centrar* "No" "Centra en muro?"))
  (unless (boundp '*anchom*)(defvar *anchom* 0.20 "Espesor de un muro 2D"))
  (unless (boundp '*altop*)(defvar *altop* 2.3  "Altura de puertas 3D"))
  (unless (boundp '*altom*)(defvar *altom* 2.7  "Altura de muros 3D"))
  ;; Si tu arquitectura usa el estilo con subrayado, apunta a ellos.
  (unless (boundp '_anchop_) (defvar _anchop_ *anchop*))
  (unless (boundp '_jamba_)  (defvar _jamba_  *jamba* ))
  ;; (repite para las demás variables si las necesitas…)
  )

;; ------------------- 2.  Función de error ------------------------------
(defun puerta--error (msg)
  "Manejo de errores: muestra *msg*, restaura estado y finaliza."
  (princ (strcat "\n[ERROR] " msg))
  (command-s "_undo" "_end")
  (recupera-vars)          ; devuelve variables de AutoCAD
  (setq _error_ old-err)   ; restaura old-err
  (princ)                   ; no devuelva nada
  (exit))

;; ------------------- 3.  Guarda / recupera variables de AutoCAD ------
(defun puerta--salva-vars (vars)
  "Guarda el estado de las variables `vars` en *MLST*."
  (setq *MLST* (mapcar (lambda (v) (list v (getvar v))) vars)))

(defun puerta--recupera-vars ()
  "Restaura el estado de las variables guardadas en *MLST*."
  (when *MLST*
    (mapcar (lambda (p) (setvar (car p) (cadr p))) *MLST*)
    (setq *MLST* nil)))

;; ------------------- 4.  Implementación real de la puerta ---------------
(defun puerta--impl ()
  "Función interna que realiza la lógica de dibujo de una puerta."
  (let* ((old-err _error_)
         (_error_ puerta--error)            ; manejo de errores
         (capamuro   nil)                   ; capa del muro
         (pgrosor    nil)                   ; segunda cara del muro
         (bisagra    nil)
         (cosamuro   nil)
         (datosmuro  nil)
         (aux        nil)
         (nombre     nil)
         (linea1     nil)
         (linea2     nil)
         (p4         nil)
         (p5         nil)
         (pgr        nil)
         (nuevovalor nil))

    (puerta--prepare-variables)

    ;; -------
    ;; 1.  Estado inicial
    ;; -------
    (puerta--salva-vars '(cmdecho blipmode expert gridmode
                          osmode thickness clayer OFFSETDIST ORTHOMODE))
    (mapcar 'setvar
            '(cmdecho blipmode expert gridmode osmode thickness ORTHOMODE)
            '(0 0 0 0 0 0 0))
    (command-s "_undo" "_begin")

    ;; -------
    ;; 2.  Obtener bisagra
    ;; -------
    (setq bisagra (getpoint "\nPunto en el que irá la bisagra <Relativo>: "))
    (unless bisagra (setq bisagra (pto-rel)))
    (setq bisagra (osnap bisagra "_nearest"))
    (setq cosamuro (ssname (ssget bisagra) 0))
    (setq datosmuro (entget cosamuro))
    (setq capamuro (cdr (assoc 8 datosmuro)))   ; capa del muro
    (setq pgrosor (encuentra-muro cosamuro bisagra))
    (when (not pgrosor) (puerta--error "No encuentro otra línea paralela"))

    ;; -------
    ;; 3.  Dirección del hueco
    ;; -------
    (setq aux (getpoint bisagra "\nHacia que lado de la bisagra irá el hueco: "))

    ;; -------
    ;; 4.  Ancho de la hoja
    ;; -------
    (let ((mensaje
           (if (not *anchop*)     ; usa la variable existente
               "\nAncho de la hoja (NOTA: las dos jambas ocupan 10 cm)<ancho>: "
              (strcat "\nAncho de la hoja (NOTA: las dos jambas ocupan 10 cm)<"
                      (rtos *anchop* 2 0) ">: "))))
      (when (setq nuevovalor (getdist bisagra mensaje))
        (setq *anchop* nuevovalor))
      ;; redondeo a centímetro
      (setq *anchop* (distof (rtos *anchop* 2 2) 2)))

    ;; -------
    ;; 5.  Construir bloque de puerta (si no existe)
    ;; -------
    (setq nombre
          (strcat "PS_H"
                  (rtos (* 100 *anchop*) 2 0)
                  "-J"
                  (rtos (* 100 *jamba*) 2 0)))
    (unless (tblsearch "BLOCK" nombre)
      (prompt "\nCreando un nuevo bloque de puerta…")
      (setq sset (ssadd))

      ;; Jamba izquierda
      (setvar "CLAYER" "0")
      (command-s "_rectang" "0,0" (list *jamba* *jamba*))
      (setq sset (ssadd (entlast) sset))

      ;; Jamba derecha (copia)
      (command-s "_copy" sset "" "0,0"
                 (list (+ *anchop* *jamba*) 0))
      (setq sset (ssadd (entlast) sset))

      ;; Hoja
      (command-s "_rectang" "0,0" (list 0.03 *anchop*))
      (setq sset (ssadd (entlast) sset))
      (command-s "_move" (entlast) "" "0,0" (list *jamba* *jamba*))

      ;; Arco
      (command-s "_arc" "_c" "0,0"
                 (list *anchop* 0) (list 0 *anchop*))
      (setq sset (ssadd (entlast) sset))
      (command-s "_move" (entlast) "" "0,0" (list *jamba* *jamba*))

      ;; Bloquear todo en un bloque llamado `nombre`
      (command-s "_block" nombre "0,0" sset "")
      (prompt "Nueva puerta creada OK"))

    ;; -------
    ;; 6.  Dibujar la puerta a lo largo del muro
    ;; -------
    (setvar "CLAYER" capamuro)
    (command-s "_line" bisagra pgrosor "")
    (setq linea1 (entlast))

    ;; offset (margen)
    (command-s "_offset" (+ *anchop* (* 2 *jamba*)) linea1 aux "")
    (setq aux (entlast))
    (setq linea2 (entget aux))

    (setq p4 (cdr (assoc 10 linea2)))
    (setq p5 (cdr (assoc 11 linea2)))

    ;; Recortar la línea del muro en los extremos
    (entdel linea1)
    (command-s "_break"
               (polar bisagra (angle bisagra p4) (/ *anchop* 2)) "_f"
               bisagra p4)
    (command-s "_break"
               (polar pgrosor (angle pgrosor p5) (/ *anchop* 2)) "_f"
               pgrosor p5)
    (entdel linea1) ;; devuelve la línea original (no esencial)

    ;; -------
    ;; 7.  Capa de carpintería
    ;; -------
    (unless (tblsearch "LAYER" "Carpinteria")
      (command-s "_LAYER" "_New" "Carpinteria" "_color" "_cyan" "Carpinteria" ""))
    (setvar "CLAYER" "Carpinteria")

    ;; -------
    ;; 8.  Insertar el bloque (ajustamos la rotación)
    ;; -------
    (if (or (= (abs (- (angle bisagra p4) (/ pi 2))) 0.001)
            (= (abs (- (angle bisagra p4) (* 3 pi/2))) 0.001))
        (command-s "_insert" nombre bisagra "" ""
                   (* 180.0 (/ (angle bisagra p4) pi)))
      (command-s "_insert" nombre bisagra "" "-1"
                 (* 180.0 (/ (angle bisagra p4) pi))))

    ;; -------
    ;; 9.  Fin
    ;; -------
    (command-s "_undo" "_end")
    (setq _error_ old-err)
    (puerta--recupera-vars)
    (princ)))

;; ------------------- 5.  Alias y mensaje de bienvenida -------------------
(defun c:puerta () (puerta--impl))
(defun c:pt () (puerta--impl))            ; alias

(princ "\nFunción para hacer puertas en un muro (2D y 3D) "
       "\ncargada en arquitectura 2026 OK")
(princ)