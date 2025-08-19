;;Archivos de autocarga de los programas de arquitectura que
;;estoy haciendo el verano del 99
;; Y modificados varias veces, ultima agosto 2025
;;Cargar el menu (necesario en autocad 2006 y superior...
;; Luego, cargar todos los comandos y sus alias
(load "util")
(autoload "aplasta" '("aplasta"))
(autoload "puerta" '("puerta" "pt"))
(autoload "puerta-doble" '("puertadoble" "ptd"))
(autoload "continua" '("continua"))
(autoload "corta" '("corta" "xtrim"))
(autoload "extiende" '("extiende" "xtend"))
(autoload "muro" '("muro" "mr"))
(autoload "ventana" '("ventana" "ven"))
(autoload "giracarp" '("gic" "giracarp"))
(autoload "despcarp" '("despcarp" "dpc"))
(autoload "modifpt" '("modifpt" "mop"))
(autoload "modifptd" '("modifptd" "mopd"))
(autoload "modifven" '("modifven" "moven"))
(autoload "borracarp" '("borracarp" "boc"))
(autoload "triang" '("triang"))
(autoload "une" '("une"))
(autoload "metro2" '("m2" "metro2"))

;; Inicializar variables para las �rdenes de dibujo
;; Variables 2D
;; Para la puerta 2D
(setq *anchop* 0.72
      jamba 0.05
)

;; Para la puerta doble
(setq anchoh1 0.6) ; Inicializar el ancho de una hoja de la puerta
(setq anchoh2 0.5) ; Inicializar el ancho de la otra hoja
(setq jamba 0.05)

;; Para la ventana
(setq cristal 0.5 ; Inicializar el ancho de la ventana
      perfil 0.05 ; Inicializar el ancho del perfil de la jamba
      alf "Si" ; Por defecto con alfeizar y de 3 cm
      alfeiz  0.03
      tipo "Doble" ; Ventana doble SI
      centrar "No" ; No centrar en el muro
)

;; Para el muro
(setq anchom 0.2)

;; Para las 3D
(setq altop 2.3 ;; Alto de puertas
      altom 2.7) ;; Alto de muros

(prompt "\nProgramas de arquitectura preparados")