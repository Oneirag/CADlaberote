;; ---------------------------------------------------------------
;;  muro.lsp   –  Programa para dibujar un muro en AutoCAD 2026
;; ---------------------------------------------------------------
;;  • Crea la capa “Muros” (si no existe)
;;  • Usa las variables de arquitectura (*anchom*, *anchop*, …) cuando sea
;;  • Maneja errores con `prog-err` y restaura el estado de AutoCAD
;;  • Cambia todas las llamadas de dibujo a `command-s`
;;  • Se mantiene la lógica antigua (puertas, líneas, empalmes, cierre)
;; ---------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 1.  Asegurarse de que las variables de arquitectura existen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun muro--ensure-vars ()
  "Crea las variables que el módulo necesita si no están definidas."
  (unless (boundp '*anchom*) (defvar *anchom* 0.20  "Espesor de un muro 2D"))
  (unless (boundp '*anchop*) (defvar *anchop* 0.72  "Anchura de una puerta (2D)"))
  (unless (boundp '*anchomh*)(defvar *anchomh* 0.60 "Ancho hoja 1 doble (2D)"))
  (unless (boundp '*anchomh2*)(defvar *anchomh2* 0.50 "Ancho hoja 2 doble (2D)")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 2.  Función de error
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun prog-err (s)
  "Muestra un mensaje de error, limpia la banda de Undo y restaura variables."
  (if (/= s "Función cancelada")
      (princ (strcat "\nError: " s)))
  (setq _error_ olderr)
  (setq seleccion nil)
  (recupera-vars)
  (command-s "_undo" "_end")
  (princ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3.  Guardar / Recuperar variables de AutoCAD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar MLST nil)

(defun salva-vars (a)
  (setq MLST '())
  (repeat (length a)
    (setq MLST (append MLST (list (list (car a) (getvar (car a))))))
    (setq a (cdr a))))

(defun recupera-vars ()
  (repeat (length MLST)
    (setvar (caar MLST) (cadar MLST))
    (setq MLST (cdr MLST))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.  Función `une-lin` – unir dos tramos de muro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun une-lin (l1 l2 l3 l4 / angulo1 angulo2)
  "Unir tramos de muro.  Si son paralelos se une con `command-s`.  Si no, se empalma."
  ;; Obtener los ángulos de las dos rectas
  (setq angulo1 (angle (cdr (assoc 10 (entget l1)))
                       (cdr (assoc 11 (entget l1))))
  (setq angulo2 (angle (cdr (assoc 10 (entget l3)))
                       (cdr (assoc 11 (entget l3)))))

  (if (or (= angulo1 angulo2)
           (= (+ angulo1 pi) angulo2)
           (= (- angulo1 pi) angulo2))
      ;; paralelos -> línea sencilla
      (command-s "_line"
         (cdr (assoc 10 (entget l4)))
         (cdr (assoc 11 (entget l2)))
         "")
    ;; no paralelos -> empalmes
    (progn
      (command-s "_fillet" l2 l4)
      (setq int1 (inters (cdr (assoc 10 (entget l2)))
                          (cdr (assoc 11 (entget l2)))
                          (cdr (assoc 10 (entget l3)))
                          (cdr (assoc 11 (entget l3)))))
      (setq int2 (inters (cdr (assoc 10 (entget l1)))
                          (cdr (assoc 11 (entget l1)))
                          (cdr (assoc 10 (entget l4)))
                          (cdr (assoc 11 (entget l4)))))
      (if (or int1 int2)
          (progn
            (command-s "_fillet" l1 l4)
            (command-s "_fillet" l2 l3))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.  Función principal `muro--impl`
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun muro--impl ()
  "Dibuja un muro siguiendo la lógica original pero con mejoras de error y AUTOLISP 2026."
  ;; Garantizar variables de arquitectura
  (muro--ensure-vars)

  ;; Guardar estado de AutoCAD y activar manejador de errores
  (setq olderr _error_
        _error_  prog-err)
  (salva-vars
   '("cmdecho" "blipmode" "expert" "gridmode" "osmode"
     "thickness" "clayer" "OFFSETDIST" "FILLETRAD"))
  (mapcar 'setvar
          '(thickness FILLETRAD)
          '(0 0))

  ;; Crear capa Muros si no existe
  (unless (tblsearch "LAYER" "Muros")
    (command-s "_LAYER" "_New" "Muros" "_color" "_blue" "Muros" ""))
  (setvar "CLAYER" "Muros")

  ;; 1ª parte: Primer punto, ancho inicial
  (when (not anchom)
    (setq anchom (getdist "\nAncho del muro <0.3>: "))
    (when (not anchom) (setq anchom 0.3)))

  (setq punto (getpoint "\nPrimer punto del muro <Relativo>: "))
  (unless punto (setq punto (pto-rel)))
  (when (osnap punto "_nearest")
    (setq punto (osnap punto "_nearest")))

  ;; Verificar si hay línea de muro cercana
  (setq cosaini (ssget punto '((8 . "MUROS") (0 . "LINE"))))
  (setq pto-sig nil)

  ;;; Bucle de “Ancho / Relativo”
  (while (null pto-sig)
    (progn
      (initget "Ancho")
      (setq pto-sig (getpoint punto "\nAl punto (Ancho/Relativo): "))
      (cond
        ((= pto-sig "Relativo") (setq pto-sig (pto-rel)))
        ((= pto-sig "Ancho")
         (progn
           (setq pto-sig anchom)
           (setq anchom
                 (getdist
                  (strcat "\nAncho del muro <" (rtos anchom) ">: ")))
           (unless anchom (setq anchom pto-sig))
           (setq pto-sig nil)))
        ((not pto-sig) (setq punto (/ 0 0))))))

  ;; Dibuja la primera línea y crea el grupo de líneas del muro
  (command-s "_Line" punto pto-sig "")
  (setq grupo (append (list (entlast)) grupo))
  (setq linea3 (entlast))
  (initget 1)
  (setq aux (getpoint "\nDireccion de la otra cara del muro: "))
  (command-s "_offset" anchom (entlast) aux "")
  (setq grupo (append (list (entlast)) grupo))
  (setq linea4 (entlast))
  (setq lista-lin (append grupo lista-lin))
  (setq grupo nil)

  ;; Bucle principal: relaciones, revoca, cierre
  (setq continuar T)
  (while continuar
    (progn
      ;; Obtener últimos dos tramos
      (setq punto  (cdr (assoc 11 (entget (cadr lista-lin))))
            linea1 (cadr lista-lin)
            linea2 (car lista-lin))

      (initget "Ancho Revoca Cierra")
      (setq pto-sig
            (getpoint punto
                       "\nAl punto (Ancho/Revoca/Cierra/<Relativo>): "))

      (when (= pto-sig "Relativo")
        (setq pto-sig (pto-rel)))

      (cond
        ((null pto-sig) (setq continuar nil))

        ((= pto-sig "Cierra")
         (if (> (length lista-lin) 2)
             (setq continuar nil)
             (prompt "\nTodavía no puedo cerrar")))

        ((= pto-sig "Revoca")
         (progn
           (prompt "Revocando…")
           (if (> (length lista-lin) 2)
               (progn
                 (command-s "_undo" "_back")
                 (setq lista-lin (cddr lista-lin)))
               (prompt "\nNo se puede revocar más"))))

        ((= pto-sig "Ancho")
         (progn
           (setq continuar anchom)
           (setq anchom
                 (getdist
                  (strcat "\nAncho del muro <" (rtos anchom) ">: ")))
           (unless anchom (setq anchom continuar))
           (setq continuar T)))

        (T  ; caso “normal”
         (progn
           (command-s "_undo" "_mark")
           (when (osnap pto-sig "_nearest")
             (setq pto-sig (osnap pto-sig "_nearest")))
           (command-s "_Line" punto pto-sig "")
           (setq linea3 (entlast))
           (setq grupo (append (list (entlast)) grupo))
           (initget 1)
           (setq aux (getpoint "\nDireccion de la otra cara del muro: "))
           (command-s "_offset" anchom (entlast) aux "")
           (setq grupo (append (list (entlast)) grupo))
           (setq linea4 (entlast))
           (setq grupo (append (list (entlast)) grupo))
           (setq lista-lin (append grupo lista-lin))
           (setq grupo nil)
           (une-lin linea1 linea2 linea3 linea4))))))

  ;; ----  Cierre/Finalización  -------------------------------------
  (if cosaini
      (when (= pto-sig "Cierra")
        (setq pto-sig nil)))

  (setq linea1 (last lista-lin)
        linea2 (entnext linea1))

  (if (= pto-sig "Cierra")
      (progn
        (setq pto-sig (cdr (assoc 11 (entget linea4))))
        (command-s "_Line" punto (cdr (assoc 10 (entget linea1))) "")
        (setq linea3 (entlast))
        (setq grupo (append (list (entlast)) grupo))
        (setq aux (cdr (assoc 10 (entget linea2))))
        (command-s "_offset" anchom (entlast) aux "")
        (setq linea4 (entlast))
        (setq grupo (append (list (entlast)) grupo))
        (setq lista-lin (append grupo lista-lin))
        (setq grupo nil)
        (une-lin linea1 linea2 linea3 linea4)
        (une-lin (cadddr lista-lin)
                 (caddr lista-lin)
                 (cadr lista-lin)
                 (car lista-lin)))
      (progn  ; No cerrar
        (if cosaini
            (progn
              (setq cosaini (ssname cosaini 0))
              (setq datosini (entget linea2))
              (setq inicio (inters (cdr (assoc 10 (entget linea2)))
                                   (cdr (assoc 11 (entget linea2)))
                                   (cdr (assoc 10 (entget cosaini)))
                                   (cdr (assoc 11 (entget cosaini))) nil))
              (when inicio
                (setq datosini (subst (append '(10) inicio)
                                      (assoc 10 datosini)
                                      datosini)))
              (entmod datosini)
              (command-s "_break"
                         cosaini inicio (cdr (assoc 10 (entget linea1)))))
            (command-s "_line"
              (cdr (assoc 10 (entget linea2)))
              (cdr (assoc 10 (entget linea1)))
              ""))

        (entdel linea3)
        (setq cosafin (ssget punto '((8 . "MUROS") (0 . "LINE"))))
        (entdel linea3)
        (when cosafin
          (setq cosafin (ssname cosafin 0))
          (setq datosini (entget linea4))
          (setq inicio (inters (cdr (assoc 10 (entget linea4)))
                               (cdr (assoc 11 (entget linea4)))
                               (cdr (assoc 10 (entget cosafin)))
                               (cdr (assoc 11 (entget cosafin))) nil))
          (when inicio
            (setq datosini (subst (append '(11) inicio)
                                  (assoc 11 datosini)
                                  datosini)))
          (entmod datosini)
          (command-s "_break"
                     cosafin inicio (cdr (assoc 11 (entget linea3)))) )
        (when (not cosafin)
          (command-s "_line"
                     (cdr (assoc 11 (entget linea4)))
                     (cdr (assoc 11 (entget linea3)))
                     ""))))

  ;; Reiniciar variables de AutoCAD y entregar
  (setq _error_ olderr)
  (recupera-vars)
  (princ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.  Alias y mensaje de bienvenida
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun c:muro () (muro--impl))
(defun c:mr () (muro--impl))   ; alias

(princ "\nFunción para hacer un muro...cargada OK")
(princ)