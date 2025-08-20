;; ------------------------------------------------------------
;;  ARCHITECTURA.V2026.LSP   (versión para AutoCAD 2026)
;; ------------------------------------------------------------
;;  • Carga de extensiones y funciones de apoyo
;;  • Definición de comandos de arquitectura (puerta, ventana, muro, etc.)
;;  • Variables globales de dibujo (ajustada a 2026, con ?double?floats)
;;  • Comentarios actualizados y compatibilidad con los motores LISP modernos
;; ------------------------------------------------------------

;; ------------------------------------------------------------------
;; 1.  Carga de archivos auxiliar
;; ------------------------------------------------------------------
;; Los archivos util.lsp y cualquier otro módulo deberán estar presentes
;; en el mismo directorio que este script o en una ruta de búsqueda 
;; de AutoCAD.
(when (not (file-exists-p "util.lsp")) ; simple comprobación
  (prompt "\n**** ATENCIÓN: No se encontró 'util.lsp' ****"))

(load "util")

;; ------------------------------------------------------------------
;; 2.  AUTOLIST PARA LOS COMANDOS
;; ------------------------------------------------------------------
;; La sintaxis de AUTOLIST sigue siendo válida en 2026.
;; Se ha añadido la cadena de descripción – puede quedar vacía.
(autoload "aplasta"    "aplasta" "")
(autoload "puerta"     "puerta" "PT")
(autoload "puerta-doble" "puertadoble" "PTD")
(autoload "continua"   "continua" "")
(autoload "corta"      "corta" "xtrim")
(autoload "extiende"   "extiende" "xtend")
(autoload "muro"       "muro" "MR")
(autoload "ventana"    "ventana" "VEN")
(autoload "giracarp"   "giracarp" "GIC")
(autoload "despcarp"   "despcarp" "DPC")
(autoload "modifpt"    "modifpt" "MOP")
(autoload "modifptd"   "modifptd" "MOPD")
(autoload "modifven"   "modifven" "MOVEN")
(autoload "borracarp"  "borracarp" "BOC")
(autoload "triang"     "triang" "")
(autoload "une"        "une" "")
(autoload "metro2"     "metro2" "M2")

;; ------------------------------------------------------------------
;; 3.  VARIABLES DE ENTORNO
;; ------------------------------------------------------------------
;; Se usan con `defvar` para que AutoCAD 2026 oscile entre
;; variables locales y globales cuando se cambia de sesión

;; ========== 2D ==========
(defvar *anchop* 0.72 "Anchura de una puerta 2D")
(defvar *jamba* 0.05 "Espesor de la jamba de una puerta 2D")

(defvar *anchoh1* 0.6  "Primer panel de la puerta doble  (2D)")
(defvar *anchoh2* 0.5  "Segundo panel de la puerta doble  (2D)")

(defvar *cristal* 0.5    "Espesor del cristal de la ventana  (2D)")
(defvar *perfil* 0.05    "Espesor del perfil de la jamba  (2D)")
(defvar *alf* "Si"       "Presencia de alfeizar (Sí/No)")
(defvar *alfeiz* 0.03    "Alfeizar de la ventana  (m)")
(defvar *tipo* "Doble"   "Tipo de ventana (Simple/Doble)")
(defvar *centrar* "No"   "Centro automático en muro")

(defvar *anchom* 0.20 "Espesor de un muro  (2D)")

;; ========== 3D ==========
(defvar *altop* 2.3 "Altura de las puertas en 3D (m)")
(defvar *altom* 2.7 "Altura de los muros en 3D (m)")

;; ------------------------------------------------------------------
;; 4.  Mensaje de bienvenida
;; ------------------------------------------------------------------
(prompt "\n[Arquitectura V2026] ¡Los programas de arquitectura están listos!\n")

;; ------------------------------------------------------------------
;; 5.  ACCESO A MENUCADLABEROTE (opcional)
;; ------------------------------------------------------------------
;; Si cuentas con el menú de CAD?laberote y lo quieres leer
;; en 2026 debes disponer del archivo MenuCADlaberote.lsp
;; y descomentar las líneas siguientes.
;;
;; (when (file-exists-p "MenuCADlaberote.lsp")
;;   (load "MenuCADlaberote")
;;   (command "C:MenuCADlaberote"))

;; ------------------------------------------------------------------
;; Fin del script
;; ------------------------------------------------------------------