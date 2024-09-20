globals [
  transacciones-totales
  frustrados-historicos
  dia
  acumulado-total-deudores-g1
  usuarios-deudor
  saldo-total-donacion-euro
  usuarios-donacion
  saldo-total-g1-vendedores
  usuarios-ventas
  saldo-total-g1-compradores
  usuarios-compras
  crisis
  precio
  costo
  nuevos-usuarios
  cant_nuevos-usuarios
  saldo-total-g1-compradores_vendedores
  saldo-total-g1
  saldo-total-euros
  desviacion-estandar-promedio
  probabilidad-canje-euros
  frustra_>_actividad
  frustra_>_nuevos
  costo-acum
]

turtles-own [
  rol
  saldo-g1
  saldo-euro
  items-comprados
  items-vendidos
  esta-frustrado
  preferencial
  ha-sido-deudor
  ha-hecho-donacion
  ha-comprado
  ha-vendido
  total-deudores-g1
  saldo-adicional-euro
  ciclos-desde-ultima-adicion
]

to setup
  clear-all
  set frustra_>_nuevos false
  set frustra_>_actividad false
  set transacciones-totales 0
  set frustrados-historicos 0
  set dia 0
  set acumulado-total-deudores-g1 0
  set usuarios-deudor 0
  set saldo-total-donacion-euro 0
  set usuarios-donacion 0
  set saldo-total-g1-vendedores 0
  set usuarios-ventas 0
  set saldo-total-g1-compradores 0
  set saldo-total-g1-compradores_vendedores 0
  set usuarios-compras 0
  set crisis 0
  set cant_nuevos-usuarios 0
  set desviacion-estandar-promedio 0
  set costo-acum 0
  set probabilidad-canje-euros 0.6 ; probabilidad del 50% que el usuario elija pedir un préstamo en G1 que canjear euros, siendo que lo segundo es lo prioritario antes de permitir un canje
  create-turtles usuarios [
    setup-turtle
  ]
  create-caja
  inicializar-plots
  reset-ticks
end

to setup-turtle
  set ha-comprado false  ;; Inicialización correcta como booleano
  set ha-vendido false   ;; Inicialización correcta como booleano
  setxy random-xcor random-ycor
  set rol one-of ["comprador" "vendedor"]
  set saldo-g1 saldo-g1_entrada
  set saldo-euro euros
  set items-comprados 0
  set items-vendidos 0
  set esta-frustrado false
  set preferencial false
  set ha-sido-deudor false
  set ha-hecho-donacion false
  set total-deudores-g1 0
  set saldo-adicional-euro 0
  set ciclos-desde-ultima-adicion 0
  ifelse rol = "comprador" [
    set shape "triangle"
  ] [
    set shape "circle"
  ]
  set color white
  set size 1.5  ;; tamaño original
end

to create-caja
  create-turtles 1 [
    setxy 0 0
    set shape "house"
    set color yellow
    set saldo-g1 0
    set saldo-euro 0
    set rol "caja"
    set size 1.5
  ]
end

to go ;modulo principal
  if not any? turtles [ stop ]
  set dia dia + 1
  ; Verificar si el saldo G1 es menor que el saldo euro
  let caja one-of turtles with [rol = "caja"]
  let caja-saldo-g1 [saldo-g1] of caja
  let caja-saldo-euro [saldo-euro] of caja
  if caja-saldo-g1 < caja-saldo-euro  [
   ;; user-message "El saldo G1 de CAJA es menor que el saldo Euro. La simulación se detiene."
   show (word "El saldo G1 de CAJA es menor que el saldo Euro de €" caja-saldo-euro)
    ;; stop
  ]
  crisis-financiera
  ask turtles [ ;funcion principal
    if rol != "caja" [ ; solo considera a prosumidores, no a caja
      move
      interact_comercia ; en la interaccion se realiza la compra o venta si el usuario tiene saldo y puede comerciar
      update-rol
      check-frustration
      ;; Llamada a devolver-prestamo si el usuario debe dinero y recupero el saldo positivo
      devolver-prestamo caja self
      gestionar-saldo-adicional-euros ; periodicamente (30 ciclos) se le agrega euros a la billetera de vendedores y compradores (por otros salarios mensuales en FIAT)
    ]
  ]
  calculate-totals
  if preferenciales [apply-bonuses]
  update-stocks
  actualizar-saldos-g1
  update-monitors
  actualizar-plots
  verificar-saldos
  add-new-users
  ;; Si los ticks alcanzan los 1000, detener la simulación
  if ticks >= 1000 [
    stop
  ]

  ;; El resto del código continúa si no se ha alcanzado el límite de ticks
  tick
end

to move
  if preferencial [
    rt random 180
    fd 1.1 ; Aumentar la distancia que se mueve la tortuga preferencial
  ]
  if not preferencial [
    rt random 360
    fd 1 ; Aumentar la distancia que se mueve la tortuga no preferencial
  ]
end

to interact_comercia
  let nearby one-of other turtles in-radius 3 ; Radio de interacción (ajustado a 3)
  if nearby != nobody and [rol] of nearby != rol [
    if random-float 1 < 0.2 [ ; Establecer una probabilidad fija del 20% y elige aleatoriamente venta o compra
      let tipo-transaccion one-of ["venta" "compra"]
      if rol = "vendedor" [
        make-sale nearby ;solo si le alcanza el saldo G1 al comprador para comprar, doble comprobacion
      ]
      if rol = "comprador"  [
        make-purchase nearby ;solo si le alcanza el saldo G1 para comprar
      ]
    ]
  ]
end

to make-sale [comprador]  ; bloque para vendedores, un vendedor no tiene restricciones de saldo para vender
  if rol = "vendedor" and rol != "caja" [
    set precio random 10 + 1
    let cantidad random 7 + 1
    set costo precio * cantidad
    let comision 0.025 * costo  ;; Comisión del 2,5% de cada venta para los préstamos de la Caja

    if [saldo-g1] of comprador - costo >= -100 [  ;si le alcanza compra, sino pide prestamo o canjea e intenta comprar nuevamente, esta es una doble comprobacion que tambien se hace en el comprador
      set transacciones-totales transacciones-totales + 1
      set saldo-g1 saldo-g1 + costo
      ask comprador [
        if rol != "caja" [
          set saldo-g1 saldo-g1 - costo
          set items-comprados items-comprados + cantidad
          if not ha-comprado [
            set usuarios-compras usuarios-compras + 1
            set ha-comprado true
          ]
        ]
      ]
      set items-vendidos items-vendidos + cantidad
      set costo-acum costo-acum + costo
      if not ha-vendido [
        set usuarios-ventas usuarios-ventas + 1
        set ha-vendido true
      ]
      update-color

      ;; La caja recibe una comisión por la venta
      let caja one-of turtles with [rol = "caja"]
      ask caja [
        set saldo-g1 saldo-g1 + comision
      ]
    ]
        evita-frustracion-prestamo_o_canje ;de acuerdo al costo y si tiene saldo suficiente
  ]
end

to make-purchase [vendedor] ;bloque para compradores
  if rol = "comprador" and rol != "caja" [  ;; Solo los compradores que no son la caja pueden realizar compras
    set precio random 10 + 1  ;; Precio aleatorio
    let cantidad random 7 + 1  ;; Cantidad aleatoria
    set costo precio * cantidad
    let comision 0.025 * costo  ;; Comisión del 2,5 de cada compra para los préstamos de la Caja
    ;; Verificar que el comprador puede pagar sin quedar con un saldo menor a -100
    if saldo-g1 - costo >= -100 [ ;doble comprobacion de que el comprador tiene saldo y le alcanza para comprar el producto
      set transacciones-totales transacciones-totales + 1
      set saldo-g1 saldo-g1 - costo  ;; Reduce saldo G1 del comprador
      ask vendedor [
        if rol != "caja" [  ;; Asegurarse de que la caja no sea vendedora
          set saldo-g1 saldo-g1 + costo  ;; Aumenta saldo G1 del vendedor
          set items-vendidos items-vendidos + cantidad
          ;; Asegúrate de que ha-vendido es un booleano
          if not ha-vendido [
            set usuarios-ventas usuarios-ventas + 1
            set ha-vendido true
          ]
        ]
      ]
      set items-comprados items-comprados + cantidad
      set costo-acum costo-acum + costo
      if not ha-comprado [
        set usuarios-compras usuarios-compras + 1
        set ha-comprado true
      ]
      update-color
       ;; La caja recibe una comisión por la compra
      let caja one-of turtles with [rol = "caja"]
      ask caja [
        set saldo-g1 saldo-g1 + comision
      ]
    ]
     evita-frustracion-prestamo_o_canje ;de acuerdo al costo y si tiene saldo suficiente
  ]
end

to gestionar-saldo-adicional-euros ; Cada 30 días permito volver a canjear euros por G1 al usuario y le sumo mas euros a su billetera (por salario mensual habitual)
  set ciclos-desde-ultima-adicion ciclos-desde-ultima-adicion + 1
  if ciclos-desde-ultima-adicion >= 30 [ ; Reducir el tiempo de espera para gestionar el saldo
;    set saldo-adicional-euro saldo-adicional-euro + euros ; Aumentar la cantidad de saldo adicional
;    set saldo-euro saldo-euro + saldo-adicional - euro
    set saldo-euro saldo-euro + euros ; segun lo que se informa en interfase input euro>0
  set ha-hecho-donacion false
    set ciclos-desde-ultima-adicion 0
  ]
end

to update-rol
  ifelse rol = "vendedor" [
    set rol "comprador"
    set shape "triangle"
  ] [
    set rol "vendedor"
    set shape "circle"
  ]
  ; Reducir la probabilidad de cambiar de rol para estabilizar la simulación
  if random-float 1 < 0.8 [ ; Aumentar la probabilidad de que cambie de rol más rápidamente
    update-rol
  ]
end

to prestar-de-la-caja [caja usuario monto-faltante]
  let saldo-caja [saldo-g1] of caja
  let prestamo-a-dar  monto-faltante   ;; Prestamos lo que seael monto faltante, dejando incluso la caja en negativo

  ;; Si la caja tiene saldo suficiente, realizar el préstamo
  ifelse prestamo-a-dar > 0 and [saldo-g1] of one-of turtles with [rol = "caja"] > prestamo-a-dar  [
    ask usuario [
      set saldo-g1 saldo-g1 + prestamo-a-dar
      set total-deudores-g1 total-deudores-g1 + prestamo-a-dar
      if not ha-sido-deudor [
        set usuarios-deudor usuarios-deudor + 1
        set ha-sido-deudor true
      ]
    ]
    set acumulado-total-deudores-g1 acumulado-total-deudores-g1 + prestamo-a-dar  ;acumulado positivo de saldos deudores
    ask caja [
      set saldo-g1 saldo-g1 - prestamo-a-dar
    ]
    show (word "Préstamo otorgado de " prestamo-a-dar " G1.")
  ] [
    show (word "No se puede prestar más dinero. La caja tiene saldo insuficiente. saldo-g1:" [saldo-g1] of one-of turtles with [rol = "caja"])
  ]
end

to devolver-prestamo [caja usuario]
  let deuda [total-deudores-g1] of usuario
  ;; El usuario debe devolver el préstamo cuando tiene saldo positivo
  if saldo-g1 > 0 and deuda > 0 [
    let cantidad-devolver deuda
    ask usuario [
      set saldo-g1 saldo-g1 - cantidad-devolver
      set total-deudores-g1 total-deudores-g1 - cantidad-devolver
    ]
    ask caja [
      set saldo-g1 saldo-g1 + cantidad-devolver
    ]
    show (word "Préstamo devuelto de " cantidad-devolver " G1.")
  ]
end

to realizar-donacion-euros [caja usuario costo-compra]
  let donacion-euro  costo-compra  ;; Canje solo por el costo necesario y si hay saldo positivo de G1 en caja, para canjear

  ;; Si se realiza la donación
  ifelse donacion-euro > 0 and [saldo-g1] of one-of turtles with [rol = "caja"] > donacion-euro [

    ask usuario [
      set saldo-euro saldo-euro - donacion-euro  ;; Canjea los euros del usuario
      set usuarios-donacion usuarios-donacion + 1
      set ha-hecho-donacion true
    ]
      set saldo-total-donacion-euro saldo-total-donacion-euro + donacion-euro
      ask caja [
      set saldo-euro saldo-euro - donacion-euro  ;; Restar euros de la caja
    ]
    show (word "Canje de " donacion-euro " euros realizado.")
  ]
  [
    show (word "No se puede realizar el canje de euros. donacion-euro: " donacion-euro)
  ]
end

to evita-frustracion-prestamo_o_canje ;prioriza con cierta probabilidad, que primero pida prestamo G1 (si puede) en lugar de canjear euros
  let caja one-of turtles with [rol = "caja"]
  ;; Primero, intentar prestar G1 si el saldo es insuficiente
  ifelse saldo-g1 <= -90 and prestamos_G1 = true [
    if  random-float 1 < probabilidad-canje-euros [ ; ya decidido a prestar G1, decide aleatoriamente si hacerlo o canjear Euros
      prestar-de-la-caja caja self costo
    ]
    ; else canjea euros
    if saldo-g1 <= -90 and saldo-euro > 0 and euros > 0 [
      realizar-donacion-euros caja self costo
    ]
   ]
  [
    if saldo-g1 <= -90 and saldo-euro > 0 and euros > 0 [
      realizar-donacion-euros caja self costo
    ]
  ]
end

to actualizar-saldos-g1 ;totales

  let saldo-compradores sum [saldo-g1] of turtles with [rol = "comprador"]
  let saldo-euros-compradores sum [saldo-euro] of turtles with [rol = "comprador"]
  let saldo-vendedores sum [saldo-g1] of turtles with [rol = "vendedor"]
  let saldo-euros-vendedores sum [saldo-euro] of turtles with [rol = "vendedor"]

  ; Mostrar los saldos totales por rol
  show (word "Saldo total G1 de Compradores: " saldo-compradores)
  show (word "Saldo total € de Compradores: " saldo-euros-compradores)
  show (word "Saldo total G1 de Vendedores: " saldo-vendedores)
  show (word "Saldo total € de Vendedores: " saldo-euros-vendedores)
end

to check-frustration ;por cada prosumidor
  if saldo-g1 <= -90 and saldo-euro < costo and rol != "caja"[ ; Aumentar el umbral de frustración. Se frustra si no tiene saldo en G1 ni el que tiene en euros le alcanza para comprar (costo=precio*cantidad) un producto
    set esta-frustrado true
    set frustrados-historicos frustrados-historicos + 1
    show (word "El usuario " who " se ha frustrado y deja de operar.")
    let caja one-of turtles with [rol = "caja"]
    if caja != nobody [
      ask caja [
        set saldo-g1 saldo-g1 + [saldo-g1] of myself
        set saldo-euro saldo-euro + [saldo-euro] of myself ;revisar
      ]
    ]
    die
    ]
end

to update-color
  if rol = "caja" [set color yellow]

;; Aqui usa colores y agrega el simbolo del uso de moneda G1
  if saldo-g1 = 0 [
    set color white
    set label "N"
  ]
  if saldo-g1 > 0  [
    set color green
    set label "+Ĝ"
  ]
  if  saldo-g1 < 0 [
    set color orange
    set label "X"
  ]
  if  preferencial = true [
    set color blue
    set label "P"
  ]
  ;; Aqui mantiene colores pero agrega a lo anterior el simbolo de euro si han usado euros y por tanto tienen saldo en euros, para poder visualizar a este grupo de personas
  if saldo-euro > 0 and saldo-g1 = 0 [
    set color white
    set label "€"
  ]
  if saldo-euro > 0 and saldo-g1 > 0 [
    set color green
    set label "+Ĝ€"
  ]
  if saldo-euro < 0 and saldo-g1 < 0 [
    set color orange
    set label "X€"
  ]
  if  preferencial = true [
    set color blue
    set label "P€"
  ]
end

to update-stocks
  ask turtles with [rol = "vendedor"] [
    if items-vendidos >= 5 [ set items-vendidos 5 ]
  ]
end

to add-new-users
  let caja one-of turtles with [rol = "caja"]
  let caja-saldo-g1 [saldo-g1] of caja
  let total-usuarios count turtles - 1 ;menos la CAJA
  ; Verificar si la cantidad de Frustrados es mayor a la cantidad de nuevos usuarios , en caso afirmativo paro la simulacion
  if frustrados-historicos > cant_nuevos-usuarios [
      if frustra_>_nuevos = false [
        user-message "ALERTA: La cantidad de Frustrados es mayor a la cantidad de usuarios Nuevos."
      set frustra_>_nuevos true
      plot_vertical
      ]
  ]
  ; Verificar si la cantidad de Frustrados es mayor a la cantidad de usuarios en Actividad, en caso afirmativo paro la simulacion
  if total-usuarios <= frustrados-historicos [
      if frustra_>_actividad = false [
        user-message "ALERTA: La cantidad de Frustrados es mayor a la cantidad de usuarios en Actividad, continuar?."
      set frustra_>_actividad true
      plot_vertical
      ]

  ]
  ; Verificar si la cantidad de Deudores es mayor a la cantidad de usuarios nuevos, en caso afirmativo paro la simulacion
  if count turtles with [rol != "caja" and saldo-g1 < 0 and saldo-g1 > -90 ] > cant_nuevos-usuarios [
    ; Mostrar el mensaje y detener la simulación
    ;stop
     show (word "ALERTA: La cantidad de Deudores es mayor a la cantidad de usuarios Nuevos.")
    ; plot_vertical
  ]

  ; Se genera un número al azar menor a 0.30 (probabilidad del 30%), pero se considera que un usuario nuevo incrementa la deuda por prestamos inicial de la caja.
  if (random-float 1 < probabilidad_nuevos) [
    set nuevos-usuarios 1  ; Crear un solo nuevo usuario
    set cant_nuevos-usuarios cant_nuevos-usuarios + 1
    create-turtles nuevos-usuarios [
      setup-turtle
    ]
    show (word "Nuevo usuario creado. Total usuarios: " count turtles)
  ]
end

to plot_vertical
      ; Dibujar una línea vertical en el plot "Total tipos usuario"
    set-current-plot "Total tipos usuario"
    let x ticks  ; Posición en el eje X (número de ticks)
    ;; Usar un bucle while para dibujar la línea vertical
    let y 0
    while [y <= 10] [
      plotxy x y
      set y y + 1
    ]
end
to update-monitors
  ; Aquí se puede agregar lógica para actualizar monitores si es necesario
end

to inicializar-plots
  set-current-plot "Saldo en G1 del usuario CAJA"
  set-current-plot-pen "G1"
  plot-pen-reset
  set-current-plot-pen "€"
  plot-pen-reset
  set-current-plot "Saldo G1 promedio Préstamos a Deudores"
  set-current-plot-pen "Promedio G1 Deudores"
  plot-pen-reset
  set-current-plot "Crisis Financieras"
  set-current-plot-pen "Crisis_financieras"
  plot-pen-reset
end

to actualizar-plots

  ;; Seguir trazando el saldo G1 del usuario caja
  set-current-plot "Saldo en G1 del usuario CAJA"
  set-current-plot-pen "G1"
  plotxy ticks ([saldo-g1] of one-of turtles with [rol = "caja"])
  set-current-plot-pen "€"
  plotxy ticks (saldo-total-donacion-euro)

  set-current-plot "Saldo G1 promedio Préstamos a Deudores"
  set-current-plot-pen "Promedio G1 Deudores"
  plotxy ticks saldo-promedio-deudores-g1
  set-current-plot "Crisis Financieras"
  set-current-plot-pen "Crisis_financieras"
  plotxy ticks crisis

 ;; Desviación estándar de los saldos G1 para compradores y vendedores
  let compradores-saldos [saldo-g1] of turtles with [rol = "comprador"]
  let vendedores-saldos [saldo-g1] of turtles with [rol = "vendedor"]

  ;; Calcular la desviación estándar
  let desviacion-compradores desviacion-estandar compradores-saldos
  let desviacion-vendedores desviacion-estandar vendedores-saldos
  set desviacion-estandar-promedio (desviacion-compradores + desviacion-vendedores) / 2

  ;; Dibujar en el gráfico
  set-current-plot "Desviación Estándar de Saldos"
  set-current-plot-pen "Compradores"
  plot desviacion-compradores
  set-current-plot-pen "Vendedores"
  plot desviacion-vendedores
end

to verificar-saldos
  ; Mostrar los saldos de los compradores individualmente
  show "Saldos de Compradores: "
  ask turtles with [rol = "comprador"] [
    show (word "Comprador: " who " Saldo G1: " saldo-g1)
    show (word "Comprador: " who " Saldo €: " saldo-euro)
  ]
  ; Mostrar los saldos de los vendedores individualmente
  show "Saldos de Vendedores: "
  ask turtles with [rol = "vendedor"] [
    show (word "Vendedor: " who " Saldo G1: " saldo-g1)
    show (word "Vendedor: " who " Saldo €: " saldo-euro)
  ]
  ;; Mostrar los valores de los reportes en la consola

  show "Verificación de saldos y usuarios:"
  show (word "Saldo Promedio Deudores G1: " saldo-promedio-deudores-g1)
  show (word "Saldo Promedio Donación Euro: " saldo-promedio-donacion-euro)
  show (word "Saldo Promedio Caja Frustrados: " saldo-promedio-caja-frustrados)
  show (word "Saldo de la Caja G1: " [saldo-g1] of one-of turtles with [rol = "caja"])
  show (word "Saldo de la Caja €: " [saldo-euro] of one-of turtles with [rol = "caja"])
  show (word "Saldo total  G1 Prosumidores: " saldo-total-g1-compradores_vendedores)
  show (word "Usuarios Deudores activos: " count turtles with [rol != "caja" and saldo-g1 < 0 and saldo-g1 > -90 ]) ;usuarios-deudor toma el mismo valor que los usuarios frustrados, por eso uso la formula que tambien se muestra en interfase
  show (word "Usuarios Frustrados históricos: " usuarios-deudor)
end

to apply-bonuses
  let total-tortugas count turtles
  let numero-preferenciales count turtles with [preferencial = true]

  ;; Seleccionar los usuarios con más operaciones (compras + ventas)
  let top-operaciones sort-by [[?1 ?2] -> ([items-comprados + items-vendidos] of ?1) > ([items-comprados + items-vendidos] of ?2)] turtles
  let top-percent floor (total-tortugas * 0.20)  ;; Seleccionar el 20% superior

  ;; Crear un agentset a partir del sublist
  let top-turtles turtle-set (sublist top-operaciones 0 top-percent)

  ;; Marcar como preferenciales a los que están en el top 20%
  ask top-turtles [
    set preferencial true
    set size  2.5
    set color blue
    set label "P"
  ]

  ;; Remover el estatus preferencial si ya no están en el top 20%
  ask turtles with [preferencial = true and not member? self top-turtles] [
    set preferencial false
    set size 1.5  ;; Volver al tamaño original
    set color white
    set label ""
  ]
end

to calculate-totals
  ;; Calcula los saldos G1 de compradores y vendedores por separado
  set saldo-total-g1-compradores sum [saldo-g1] of turtles with [rol = "comprador" and not esta-frustrado]
  set saldo-total-g1-vendedores sum [saldo-g1] of turtles with [rol = "vendedor" and not esta-frustrado]
  set saldo-total-g1-compradores_vendedores saldo-total-g1-compradores + saldo-total-g1-vendedores

end

to-report saldo-promedio-deudores-g1
  if usuarios-deudor > 0 [
    report acumulado-total-deudores-g1 / usuarios-deudor
  ]
  report 0
end

to-report reporte_acumulado-total-deudores-g1
  if usuarios-deudor > 0 [
    report acumulado-total-deudores-g1
  ]
  report 0
end

to-report saldo-promedio-donacion-euro
  if usuarios-donacion > 0 [
    report saldo-total-donacion-euro / usuarios-donacion
  ]
  report 0
end

to-report saldo-promedio-ventas
  if usuarios-ventas > 0 [
    report saldo-total-g1-vendedores / usuarios-ventas
  ]
  report 0
end

to-report saldo-promedio-compras
  if usuarios-compras > 0 [
    report saldo-total-g1-compradores / usuarios-compras
  ]
  report 0
end

to-report saldo-promedio-caja-frustrados
  if frustrados-historicos > 0 [
    report acumulado-total-deudores-g1 / frustrados-historicos
  ]
  report 0
end

to-report desviacion-estandar [lst]
  if empty? lst [report 0]  ;; Si la lista está vacía, retorna 0
  let media (mean lst)      ;; Calcular la media de la lista
  let suma-diferencias-cuadradas sum map [valor -> (valor - media) ^ 2 ] lst
  let n length lst
  report sqrt (suma-diferencias-cuadradas / n)  ;; Devolver la desviación estándar
end

; Implementación de la crisis financiera
to crisis-financiera
  if random 100 < 2 [ ;  probabilidad de crisis en cada ciclo 2%
    ask turtles [
      set saldo-g1 saldo-g1 - (precio - random precio) ; Reducir más saldo durante la crisis, en un valor aleatorio de precio para G1 y de saldo inicial euros para €
      set saldo-euro saldo-euro - (euros - random euros)
    ]
    set crisis crisis + 1 ; Aumentar el contador de crisis
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
286
10
718
443
-1
-1
12.85
1
10
1
1
1
0
1
1
1
-16
16
-16
16
1
1
1
ticks
30.0

MONITOR
737
60
945
105
Cantidad de Compradores (en actividad)
count turtles with [rol = \"comprador\"]
17
1
11

MONITOR
1086
60
1290
105
Cantidad de Vendedores (en actividad)
count turtles with [rol = \"vendedor\"]
17
1
11

MONITOR
738
151
975
196
Cantidad de usuarios Frustrados (baja)
frustrados-historicos
17
1
11

MONITOR
1032
151
1284
196
Cantidad de usuarios Preferenciales
count turtles with [preferencial = true]
17
1
11

BUTTON
20
10
84
43
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
93
10
153
43
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1300
16
1468
61
Saldo G1 Compradores
saldo-total-g1-compradores
1
1
11

MONITOR
1649
16
1817
61
Saldo G1 Vendedores
saldo-total-g1-vendedores
1
1
11

MONITOR
739
307
1033
352
Acumulado G1 total préstamos a Deudores 
acumulado-total-deudores-g1
1
1
11

MONITOR
739
351
1033
396
Saldo G1 de CAJA (- frustrados - préstamos + comisiones)
[saldo-g1] of one-of turtles with [rol = \"caja\"]
2
1
11

PLOT
1301
115
1819
266
Saldo en G1 del usuario CAJA
Días (mercadillos)
Monto
0.0
10.0
-150.0
150.0
true
true
"" ""
PENS
"G1" 1.0 0 -13840069 true "" ""
"€" 1.0 0 -14070903 true "" ""

MONITOR
739
263
1033
308
Saldo G1 promedio préstamos a Deudores
saldo-promedio-deudores-g1
1
1
11

MONITOR
1057
264
1290
309
Saldo € promedio canje  
saldo-promedio-donacion-euro
1
1
11

MONITOR
1648
62
1819
107
Uso G1 promedio en Ventas
saldo-promedio-ventas
1
1
11

MONITOR
1299
60
1469
105
Uso G1 promedio en Compras
saldo-promedio-compras
1
1
11

PLOT
1301
265
1818
394
Saldo G1 promedio Préstamos a Deudores
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Promedio G1 Deudores" 1.0 0 -16777216 true "" ""

PLOT
9
333
286
453
Crisis Financieras
Días (mercadillos)
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Crisis_financieras" 1.0 0 -16777216 true "" ""

SLIDER
17
276
190
309
usuarios
usuarios
0
500
101.0
1
1
NIL
HORIZONTAL

SLIDER
18
61
190
94
euros
euros
0
200
10.0
1
1
NIL
HORIZONTAL

SLIDER
17
241
190
274
saldo-g1_entrada
saldo-g1_entrada
0
100
100.0
1
1
NIL
HORIZONTAL

MONITOR
916
10
1125
55
Total usuarios Prosumidores en actividad
count turtles with [rol != \"caja\"]
17
1
11

MONITOR
1056
350
1289
395
Acumulado € total canje (Saldo € CAJA)
saldo-total-donacion-euro
2
1
11

MONITOR
739
196
975
241
Cantidad de usuarios Nuevos  
cant_nuevos-usuarios
17
1
11

MONITOR
1482
16
1637
61
Saldo actual G1 Prosumidores
saldo-total-g1-compradores_vendedores
1
1
11

PLOT
9
473
724
791
Desviación Estándar de Saldos
Días (mercadillos)
Diferencia
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Compradores" 1.0 0 -5825686 true "" ""
"Vendedores" 1.0 0 -11221820 true "" ""

SWITCH
17
147
190
180
preferenciales
preferenciales
0
1
-1000

SWITCH
17
114
190
147
prestamos_G1
prestamos_G1
0
1
-1000

MONITOR
490
690
723
735
Desviacion estandar promedio
desviacion-estandar-promedio
1
1
11

MONITOR
1033
196
1284
241
Cantidad de usuarios saldo Deudor (en actividad)
count turtles with [rol != \"caja\" and saldo-g1 < 0 and saldo-g1 > -90 ]
17
1
11

PLOT
740
399
1816
792
Total tipos usuario
Días (mercadillos)
Cantidad
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Activos " 1.0 0 -16777216 true "" "plot count turtles with [rol != \"caja\"]"
"Deudores activos" 1.0 0 -817084 true "" "plot count turtles with [rol != \"caja\" and saldo-g1 < 0 and saldo-g1 > -90 ]"
"Nuevos totales" 1.0 0 -3026479 true "" "plot cant_nuevos-usuarios"
"Frustrados e inactivos" 1.0 0 -2674135 true "" "plot frustrados-historicos"
"Preferenciales" 1.0 0 -13791810 true "" "plot count turtles with [preferencial = true]"

SLIDER
18
209
190
242
probabilidad_nuevos
probabilidad_nuevos
0
0.50
0.15
0.01
1
NIL
HORIZONTAL

TEXTBOX
193
64
298
119
€ disponibles para canje por mes
11
0.0
1

MONITOR
1483
62
1638
107
Monto Operaciones (acumulado)
costo-acum
2
1
11

TEXTBOX
466
445
888
463
REF: Compradores: triangulos, Vendedores: círculos
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
