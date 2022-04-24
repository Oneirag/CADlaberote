(vl-load-COM)
(defun C:MENUCADLABEROTE (/	      fn	  acadobj
			  thisdoc     menus	  flag
			  currMenuGroup		  newMenu
			  newMenuItem openMacro	  MENU_NAME
			  newMenu2    newMenu3
			 )

  (setq MENU_NAME "Arquitectura")
  ;;Definición del nombre de menu

  ;; CreateMenu is a nested DEFUN that is executed if our "Menu" 

  ;; pulldown menu doesn't exist. A test for the presence of this 

  ;; pulldown menu is done in the main code 

  (defun createMenu ()

    ;; Add a new popUpMenu to currMenuGroup, i.e. to "VbaMenu" 

    (setq newMenu (vla-add (vla-get-menus currMenuGroup) MENU_NAME))

    ;;------------------------------------------------------------------ 

    ;; Puerta simple 

    (setq openMacro (strcat (chr 3) (chr 3) "Puerta" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Puerta"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Crear puertas simples en un muro: Puerta ó Pt"
    )


    ;;------------------------------------------------------------------ 

    ;; Puerta doble 

    (setq openMacro (strcat (chr 3) (chr 3) "Puertadoble" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Puerta doble"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Crear puertas dobles en un muro: Puertadoble ó Ptd"
    )


    ;;------------------------------------------------------------------ 
    ;; Separador
    (vla-AddSeparator newMenu (1+ (vla-get-count newMenu)))


    ;;------------------------------------------------------------------ 

    ;; Puerta doble 

    (setq openMacro (strcat (chr 3) (chr 3) "Ventana" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Ventana"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Crear ventanas en un muro: Ventana ó Ven"
    )

    ;;------------------------------------------------------------------ 
    ;; Separador
    (vla-AddSeparator newMenu (1+ (vla-get-count newMenu)))


    ;;------------------------------------------------------------------ 

    ;; Muro 

    (setq openMacro (strcat (chr 3) (chr 3) "Muro" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Muro"

	     openMacro

	   )

    )

    (vla-put-helpString newMenuItem "Crear muros: Muro ó mr")

    ;;Cota continua

    (setq openMacro (strcat (chr 3) (chr 3) "Continua" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Cota continua"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Crear cotas continuas: Continua"
    )



    ;;------------------------------------------------------------------ 
    ;; Separador
    (vla-AddSeparator newMenu (1+ (vla-get-count newMenu)))


    ;;------------------------------------------------------------------ 

    ;; Extiende 

    (setq openMacro (strcat (chr 3) (chr 3) "Extiende" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Extiende"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Extiende una entidad con solo seleccionarla: Extiende ó Xtend"
    )

    ;; Corta 

    (setq openMacro (strcat (chr 3) (chr 3) "Corta" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Corta"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Corta una entidad con solo seleccionarla: Corta ó Xtrim"
    )



    ;;------------------------------------------------------------------ 
    ;; Separador
    (vla-AddSeparator newMenu (1+ (vla-get-count newMenu)))


    (setq newMenu2 (vla-addSubMenu
		     newMenu
		     (1+ (vla-get-count newMenu))
		     "Personalizar"
		   )
    )


    (setq openMacro (strcat (chr 3) (chr 3) "Modifpt" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Modifica Puerta"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Cambiar los parámetros de las nuevas puertas"
    )


    (setq openMacro (strcat (chr 3) (chr 3) "Modifptd" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Modifica Puerta doble"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Cambiar los parámetros de las nuevas puertas dobles"
    )

    (setq openMacro (strcat (chr 3) (chr 3) "Modifven" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Modifica Ventana"

	     openMacro

	   )

    )






    (setq openMacro (strcat (chr 3) (chr 3) "Gic" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Gira carpintería"

	     openMacro

	   )

    )

    (vla-put-helpString newMenuItem "Girar carpinterias: Gic")


    (setq openMacro (strcat (chr 3) (chr 3) "despcarp" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Desplaza carpintería"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Desplazar carpinterias: Despcarp"
    )



    ;; Borra carpintería 

    (setq openMacro (strcat (chr 3) (chr 3) "boc" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Borra carpintería"

	     openMacro

	   )

    )

    (vla-put-helpString newMenuItem "Borra carpintería: Boc")






    ;;------------------------------------------------------------------ 
    ;; Separador
    (vla-AddSeparator newMenu (1+ (vla-get-count newMenu)))


    (setq newMenu2 (vla-addSubMenu
		     newMenu
		     (1+ (vla-get-count newMenu))
		     "Opciones de ventana"
		   )
    )



    (setq openMacro (strcat (chr 3)
			    (chr 3)
			    "(setq tipo \"Simple\")"
			    (chr 32)
		    )
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Ventana simple"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Dibujar a partir de ahora ventanas simples"
    )


    (setq openMacro (strcat (chr 3)
			    (chr 3)
			    "(setq tipo \"Doble\")"
			    (chr 32)
		    )
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Ventana doble"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Dibujar a partir de ahora ventanas dobles"
    )


    (setq openMacro
	   (strcat (chr 3) (chr 3) "(setq tipo \"3\")" (chr 32))
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Ventana 3 hojas"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Dibujar a partir de ahora ventanas de 3 hojas"
    )




    (setq openMacro
	   (strcat (chr 3) (chr 3) "(setq tipo \"4\")" (chr 32))
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu2

	     (1+ (vla-get-count newMenu2))

	     "Ventana 4 hojas"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Dibujar a partir de ahora ventanas de 4 hojas"
    )




    (setq newMenu3 (vla-addSubMenu
		     newMenu2
		     (1+ (vla-get-count newMenu2))
		     "Alfeizar"
		   )
    )



    (setq openMacro
	   (strcat (chr 3) (chr 3) "(setq alf \"Si\")" (chr 32))
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu3

	     (1+ (vla-get-count newMenu3))

	     "Con alfeizar"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Dibujar a partir de ahora ventanas con alfeizar"
    )

    (setq openMacro
	   (strcat (chr 3) (chr 3) "(setq alf \"No\")" (chr 32))
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu3

	     (1+ (vla-get-count newMenu3))

	     "Sin alfeizar"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Dibujar a partir de ahora ventanas sin alfeizar"
    )




    (setq newMenu3 (vla-addSubMenu
		     newMenu2
		     (1+ (vla-get-count newMenu2))
		     "Centrar en muro"
		   )
    )



    (setq openMacro (strcat (chr 3)
			    (chr 3)
			    "(setq centrar \"Si\")"
			    (chr 32)
		    )
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu3

	     (1+ (vla-get-count newMenu3))

	     "Centrar en muro"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Dibujar a partir de ahora ventanas centradas en el muro"
    )

    (setq openMacro (strcat (chr 3)
			    (chr 3)
			    "(setq centrar \"No\")"
			    (chr 32)
		    )
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu3

	     (1+ (vla-get-count newMenu3))

	     "En un borde"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Dibujar a partir de ahora ventanas junto al borde del muro"
    )



    ;;------------------------------------------------------------------ 
    ;; Separador
    (vla-AddSeparator newMenu (1+ (vla-get-count newMenu)))


    ;;------------------------------------------------------------------ 

    ;; Triagula 

    (setq openMacro (strcat (chr 3) (chr 3) "Triang" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Triangular"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Crea triangulos dado el lado base y la longitud de los otros dos: Triang"
    )


    ;; une 

    (setq openMacro (strcat (chr 3) (chr 3) "Une" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Unir muros"

	     openMacro

	   )

    )

    (vla-put-helpString newMenuItem "une dos muros: Une")




    ;; Metro cuadrado 

    (setq openMacro (strcat (chr 3) (chr 3) "metro2" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Simbolo del metro cuadrado"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Añade un 2 en superindice al lado de un texto dado: Metro2 o M2"
    )


    ;;------------------------------------------------------------------ 
    ;; Separador
    (vla-AddSeparator newMenu (1+ (vla-get-count newMenu)))

    ;;------------------------------------------------------------------ 

    ;; Importar dxf 

    (setq openMacro (strcat (chr 3) (chr 3) "_dxfin" (chr 32)))

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Importar dxf"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Importar fichero DXF: _dxfin"
    )


    ;; Activar barra de herramientas 

    (setq openMacro (strcat (chr 3)
			    (chr 3)
			    "_-toolbar "
			    "Arquitectura 2D"
			    " _show"
			    (chr 32)
		    )
    )

    (setq newMenuItem

	   (vla-addMenuItem

	     newMenu

	     (1+ (vla-get-count newMenu))

	     "Mostrar barra de herramientas de arquitectura"

	     openMacro

	   )

    )

    (vla-put-helpString
      newMenuItem
      "Mostrar la barra de herramientas de arquitectura (si esta cargada)"
    )






    ;;------------------------------------------------------------------ 

    ;; insert the pulldown menu into the menu bar, third from the end 

    (vla-insertInMenuBar

      newMenu

      (- (vla-get-count (vla-get-menuBar acadobj)) 0)

    )
;;;
;;;    ;; re-compile the VBAMENU menu - VBAMENU.MNC 
;;;
;;;    (vla-save currMenuGroup acMenuFileCompiled) 
;;;
;;;    ;; save it as a MNS file 
;;;
;;;    (vla-save currMenuGroup acMenuFileSource) 

  )



;;;  ;; First, check to see if our menu file "VbaMenu.mns" already 
;;;
;;;  ;; exists. If it doesn't then simply make an empty file that 
;;;
;;;  ;; we can later write our menu definition to 
;;;
;;;  (setq flag nil) 
;;;
;;;  (if (not (findfile "VbaMenu.mns")) 
;;;
;;;    (progn 
;;;
;;;      (setq fn (open "VbaMenu.mns" "w")) 
;;;
;;;      (close fn) 
;;;
;;;    ) 
;;;
;;;  ) 

  ;; Get hold of the application object - we will use it to 

  ;; retrieve the menuGroups collection, which is a child object 

  ;; of the application 

  (setq acadobj (vlax-get-acad-object))

  ;; Get the active document - also a child of the application 

  (setq thisdoc (vla-get-activeDocument acadobj))

  ;; Get all menugroups loaded into AutoCAD 

  (setq menus (vla-get-menuGroups acadobj))

  ;; Now we could use VLA-ITEM to test if "VbaMenu" exists among 

  ;; all loaded menugroups with (vla-item menus "VbaMenu"). 

  ;; Instead, as a friendly service, we want all loaded menus to 

  ;; be printed to the screen and at the same time we might as well 

  ;; use it to set a flag if "VbaMenu" is among the loaded menus 
;;;
;;;  (princ "\nLoaded menus: ") 
;;;
;;;  (vlax-for n menus 
;;;
;;;    (if (= (vla-get-name n) "VbaMenu") 
;;;
;;;      (setq flag T) 
;;;
;;;    ) 
;;;
;;;    (terpri) 
;;;
;;;    ;;;(princ (vla-get-name n)) 
;;;
;;;  ) 

;;;  ;; If VbaMenu wasn't among the loaded menus then load it 
;;;
;;;  (if (null flag) 
;;;
;;;    (vla-load menus "VbaMenu.mns") 
;;;
;;;  ) 


  (setq currMenuGroup (vla-item menus "ACAD"))

  ;; If no popUpMenus exist in VbaMenu then go create one - 

  ;; otherwise exit with grace. In this example we merely check 

  ;; if the number of popup menus in "VbaMenu" is greater than 0. 

  ;; A safer way to test for its presence would be to set up a 

  ;; test for its name, "V&BA Menu": 

  ;; (vla-item (vla-get-menus currMenuGroup) "V&BA Menu") 





  (defun rrbI:IsPopupDisplayed (popName / Found)
    (vl-Load-Com)
    (vlax-Map-Collection
      (vla-Get-MenuBar (vlax-Get-Acad-Object))
      (function
	(lambda	(objPopup)
	  (cond	((= popName (vla-Get-NameNoMnemonic objPopup))
		 (setq Found T)
		)
	  )
	)
      )
    )
    Found
  )

					;(if (<= (vla-get-count (vla-get-menus currMenuGroup)) 0) 

  (if (rrbI:IsPopupDisplayed MENU_NAME)

    (princ "\nEl menu ya estaba cargado")

    (createMenu)

  )

  (princ)

)

