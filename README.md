# netlogo_moneda_social
Simulación de un mercado de moneda social con caja de canje con otras monedas

Este programa es una simulación que utiliza el lenguaje de programación NetLogo para recrear cómo interactúan varios participantes en un sistema económico. El objetivo es observar cómo las personas (a las que llamaremos prosumidores) compran, venden, y gestionan sus recursos utilizando dos tipos de monedas: G1 (una moneda local) y Euros.

El programa también incluye una Caja central que presta dinero a los prosumidores que lo necesitan y que, en algunas situaciones, puede donar Euros. Los prosumidores pueden entrar en frustración y ser eliminados del sistema si no tienen suficientes recursos para seguir operando.

¿Quiénes son los "Prosumidores"?
Los prosumidores son los actores principales del sistema. Son personas que pueden actuar como compradores o vendedores.

Un comprador gasta su dinero (G1 o Euros) para comprar cosas.
Un vendedor recibe dinero cuando vende algo.
Cada prosumidor tiene una cantidad de dinero en G1 y en Euros. Durante la simulación, los prosumidores intentan:

Comprar o vender productos.
Mantener un saldo positivo para no entrar en frustración.
¿Qué es la Caja?
La Caja es como un banco central que administra:

Préstamos: Si un prosumidor no tiene suficiente dinero en G1 para comprar algo, la Caja le puede prestar G1.
Donaciones de Euros: Si un prosumidor no tiene dinero en G1 ni en Euros, la Caja le puede donar Euros para que pueda seguir operando.
Principales Funciones del Programa
1. Inicialización del sistema (setup)
Cuando comienza la simulación, el programa crea:

Una cantidad definida de prosumidores (compradores y vendedores) con roles y saldos de dinero.
La Caja, que empieza con un saldo inicial de G1 y Euros.
2. Ejecución del ciclo (go)
Este es el corazón del programa. Cada vez que el programa da un paso (llamado ciclo), los prosumidores y la Caja realizan varias acciones:

Compradores: Tratan de comprar productos, pero solo lo hacen si tienen suficiente dinero.
Vendedores: Venden productos si tienen suficientes cosas para vender.
Caja: Si un comprador no tiene suficiente dinero, la Caja puede prestarle o donarle Euros.
Frustración: Si un prosumidor se queda sin dinero y no puede seguir comprando, entra en frustración y es eliminado del sistema.
3. Compras y Ventas (interact, make-sale, make-purchase)
Cuando un comprador y un vendedor se encuentran, pueden realizar una transacción. Dependiendo de las cantidades y del saldo del comprador:

Si el comprador tiene suficiente G1, realiza la compra, y el vendedor recibe el dinero.
Si no tiene suficiente, puede recibir un préstamo de la Caja o donar Euros para completar la transacción.
4. Préstamos y Donaciones (prestar-de-la-caja, realizar-donacion-euros)
Cuando un prosumidor se queda sin dinero:

Préstamos: La Caja le presta G1 al prosumidor para que pueda seguir operando.
Donaciones: Si el prosumidor no tiene ni G1 ni Euros, la Caja le dona Euros para que pueda comprar.
5. Frustración y Bajas (check-frustration)
Si un prosumidor llega a un punto en que no tiene dinero en G1 y no puede conseguir más, se marca como frustrado. Esto significa que:

Deja de operar en el sistema.
Se transfiere todo su dinero restante a la Caja, y es eliminado de la simulación.
6. Crisis Financiera (crisis-financiera)
De manera aleatoria, puede ocurrir una crisis financiera que afecta a todos los prosumidores. Durante una crisis:

Todos los prosumidores ven reducidos sus saldos de G1 y Euros.
Esto incrementa las dificultades para realizar compras y ventas, y aumenta la probabilidad de frustración.
Casuísticas Principales del Programa
Compra y Venta:

Los compradores intentan gastar su G1 para obtener productos.
Si no tienen suficiente dinero, pueden recibir un préstamo o donación.
Los vendedores ganan G1 con cada venta.
Préstamos de la Caja:

Si un comprador no puede pagar, la Caja interviene para prestarle G1.
Si la Caja tiene poco dinero en G1, puede negar el préstamo.
Frustración:

Si un prosumidor se queda sin dinero para operar, se frustra y es eliminado.
Esto ocurre cuando un prosumidor tiene un saldo negativo que no puede corregir.
Crisis Financiera:

De manera aleatoria, ocurre una crisis que afecta a todos los prosumidores, reduciendo sus recursos y aumentando la dificultad de realizar transacciones.
Visualización y Gráficos
El programa también incluye gráficos que muestran el comportamiento del sistema a lo largo del tiempo:

Saldo Total en G1 y Euros: Muestra cómo evolucionan los saldos de todos los prosumidores.
Crisis y Frustración: Registra cuántos prosumidores se frustran y cuántas crisis han ocurrido.
¿Qué puedes observar con este programa?
Este programa te permite observar cómo los prosumidores interactúan en un entorno económico con recursos limitados y desafíos como crisis financieras. Puedes ver cómo los préstamos, donaciones y frustraciones afectan el comportamiento de un sistema económico, y cómo se desenvuelven los actores en un ambiente donde los recursos son limitados.

Resumen
Prosumidores: Compran, venden y dependen de sus saldos de G1 y Euros.
Caja: Actúa como un banco central que otorga préstamos y donaciones.
Frustración: Si un prosumidor no tiene suficiente dinero para operar, es eliminado.
Crisis Financiera: Un evento aleatorio que reduce los recursos de todos y complica el sistema.
Este programa ofrece una vista simplificada pero interesante de cómo funcionan las interacciones económicas y los préstamos en un sistema de múltiples monedas, mostrando cómo el equilibrio puede cambiar debido a factores externos como las crisis o la falta de recursos.


README Técnico Detallado: Modelo de Prosumidores con Caja, Préstamos y Frustración en NetLogo
Descripción General
Este programa en NetLogo simula un sistema económico complejo en el que prosumidores (actores que pueden actuar como compradores y vendedores) interactúan mediante transacciones económicas. Los prosumidores utilizan dos tipos de monedas: G1 (una moneda local) y Euros (moneda fiduciaria). Las interacciones principales incluyen compras, ventas, préstamos, donaciones, y frustración cuando el saldo es insuficiente para operar.

El programa se centra en la gestión de recursos, donde la Caja actúa como el ente central que administra los préstamos y las donaciones de Euros. El modelo introduce dinámicas de frustración que dan de baja a los prosumidores cuando sus saldos llegan a niveles críticos, y puede simular eventos como crisis financieras que afectan a todo el sistema.

Estructura del Programa
1. Variables Globales
Estas variables globales son compartidas por todas las entidades en el modelo y se actualizan en cada ciclo:

Variables de contabilidad:

transacciones-totales: Número acumulado de transacciones (compras y ventas).
frustrados-historicos: Total de prosumidores que han sido frustrados y eliminados del sistema.
saldo-total-g1, saldo-total-euros: Saldos globales acumulados de G1 y Euros en el sistema.
acumulado-total-deudores-g1: Total de G1 prestado a prosumidores con saldo negativo.
usuarios-deudor, usuarios-donacion: Conteo de prosumidores que han sido deudores o han recibido donaciones de Euros.
Variables de control de simulación:

dia: Contador del número de días (ticks) que han transcurrido en la simulación.
crisis: Contador de crisis financieras ocurridas en el sistema.
desviacion-estandar-promedio: Desviación estándar promedio de los saldos de G1 entre compradores y vendedores.
2. Propiedades de los Prosumidores (turtles-own)
Cada prosumidor tiene variables que controlan su comportamiento y estado:

Variables económicas:

rol: Define si el prosumidor es un comprador o vendedor.
saldo-g1, saldo-euro: Saldos individuales en G1 y Euros de cada prosumidor.
items-comprados, items-vendidos: Cantidad de ítems que ha comprado o vendido el prosumidor.
Variables de comportamiento:

esta-frustrado: Si es verdadero, indica que el prosumidor ha sido frustrado (saldo crítico).
preferencial: Indica si el prosumidor es clasificado como preferencial, lo que puede influir en bonificaciones.
ha-comprado, ha-vendido: Flags que indican si el prosumidor ha realizado una compra o venta en el ciclo.
Variables de préstamo y donación:

ha-sido-deudor: Indica si el prosumidor ha recibido un préstamo.
ha-hecho-donacion: Indica si el prosumidor ha recibido una donación de Euros.
total-deudores-g1: Total de G1 que debe el prosumidor debido a préstamos.
3. Procedimientos Principales
setup
Descripción: Inicializa el modelo, configurando la cantidad de prosumidores y la Caja. Se establecen los valores iniciales de las variables globales y se crean los prosumidores con un rol asignado al azar (comprador o vendedor). También inicializa los gráficos y los contadores.

Casuísticas:

Se crean prosumidores con roles de compradores y vendedores asignados aleatoriamente.
Se genera una Caja con saldos iniciales en G1 y Euros, utilizada para realizar préstamos y donaciones.
go
Descripción: Procedimiento que se ejecuta en cada ciclo (tick) del modelo. Contiene la lógica principal que gobierna las interacciones de los prosumidores, actualiza sus saldos, controla la Caja y verifica las condiciones de frustración y crisis financiera.

Casuísticas:

Verificación del saldo de la Caja: Si el saldo G1 de la Caja es inferior a su saldo en Euros, se activa un mensaje de advertencia.
Interacciones de los prosumidores:
Los compradores verifican si tienen suficiente saldo en G1 para realizar una compra. Si no, intentan obtener un préstamo de la Caja o recibir una donación de Euros.
Los vendedores verifican su stock y proceden con las ventas si es posible.
Frustración: Si el saldo de un prosumidor es crítico (G1 <= -90) y no tiene Euros suficientes, se marca como frustrado y es dado de baja.
Crisis Financiera: De forma aleatoria, una crisis puede reducir los saldos G1 y Euros de todos los prosumidores.
move
Descripción: Controla el movimiento de los prosumidores dentro del espacio. Los prosumidores preferenciales se mueven más rápido que los no preferenciales.

Casuística: Se utiliza para simular el comportamiento aleatorio de los prosumidores dentro del espacio de la simulación, haciendo que se muevan de forma aleatoria o con mayor velocidad si son preferenciales.

interact
Descripción: Controla las interacciones entre prosumidores cercanos, verificando si pueden realizar una transacción de compra o venta.

Casuística: Si un comprador y un vendedor están dentro de un radio de interacción definido, se intenta realizar una transacción con una probabilidad del 20%.

make-sale y make-purchase
Descripción: Estas funciones controlan la lógica detrás de las ventas y compras. Calculan los precios, cantidades y actualizan los saldos de los prosumidores involucrados.

Casuísticas:

Si un vendedor realiza una venta, su saldo G1 aumenta según el precio del ítem, y el comprador reduce su saldo G1.
La Caja recibe una comisión del 10% por cada transacción exitosa.
Si un comprador no tiene suficiente saldo, puede intentar canjear Euros o solicitar un préstamo a la Caja.
prestar-de-la-caja y devolver-prestamo
Descripción: Controla la lógica de préstamos y devoluciones entre los prosumidores y la Caja.

Casuísticas:

Si un prosumidor no tiene saldo suficiente para realizar una compra, puede solicitar un préstamo de la Caja si la Caja tiene suficiente saldo disponible.
Si un prosumidor tiene un préstamo pendiente y saldo positivo, devuelve parte o la totalidad del préstamo.
realizar-donacion-euros
Descripción: Gestiona las donaciones de Euros desde la Caja a los prosumidores que tienen saldo negativo.

Casuística: Si un prosumidor no tiene saldo suficiente para realizar una compra, la Caja puede donarle Euros para cubrir el costo del ítem.

check-frustration
Descripción: Verifica si el saldo de un prosumidor ha alcanzado un nivel crítico (G1 <= -90) y si no tiene suficientes Euros para cubrir sus compras. Si se cumplen estas condiciones, el prosumidor es marcado como frustrado y dado de baja.

Casuística: La frustración es un mecanismo que regula la sostenibilidad del sistema. Los prosumidores frustrados transfieren sus saldos a la Caja y se eliminan del modelo.

crisis-financiera
Descripción: Introduce un elemento aleatorio de crisis financiera que reduce los saldos G1 y Euros de todos los prosumidores.

Casuística: Se ejecuta con una probabilidad baja en cada ciclo (0.1%), y su impacto es una reducción general de los recursos de todos los prosumidores, aumentando la dificultad del sistema.

4. Cálculos y Estadísticas
calculate-totals
Descripción: Calcula los saldos totales de los compradores y vendedores en G1 y Euros. También calcula los promedios y otras estadísticas clave.

Casuística: Sirve para monitorear la evolución de los saldos globales del sistema, tanto en G1 como en Euros, y detectar si los saldos están convergiendo o divergiendo.

actualizar-saldos-g1
Descripción: Actualiza los gráficos y los monitores que muestran los saldos totales de G1 y Euros, desglosados por compradores y vendedores.

Casuística: Proporciona una visualización continua del estado del sistema y sus actores.

Flujo de Decisiones y Casuísticas
Compras y Ventas: Los prosumidores realizan transacciones dependiendo de sus roles (compradores o vendedores) y sus saldos.
Préstamos y Canjes: Si un comprador no tiene saldo suficiente, intenta obtener un préstamo o realizar un canje de Euros.
Frustración: Si los prosumidores alcanzan un saldo crítico sin posibilidad de operar, son frustrados y eliminados del sistema.
Crisis Financiera: En un evento aleatorio, la crisis reduce los saldos globales y dificulta las transacciones.
Devoluciones: Los prosumidores devuelven sus préstamos cuando su saldo es positivo.
Uso del Programa
Configuración:

Al presionar el botón setup, se inicializa la simulación con el número de prosumidores y la Caja.
El sistema genera aleatoriamente compradores y vendedores con saldos iniciales predefinidos.
Ejecución:

Presiona el botón go para ejecutar el modelo. El ciclo go continuará indefinidamente hasta que se pare manualmente o se cumplan ciertas condiciones de insostenibilidad (como el colapso financiero o la frustración masiva).
Visualización:

Los gráficos de saldo total, frustración y crisis financiera permiten analizar el comportamiento del sistema a lo largo del tiempo.
Posibles Extensiones
Monedas adicionales: Agregar más tipos de monedas para simular un entorno más complejo.
Diversificación de roles: Añadir más roles como intermediarios o especuladores para ver cómo influye en el equilibrio económico.
Lógica de interacción social: Implementar interacciones más avanzadas entre los prosumidores, como redes sociales o jerarquías.
Requisitos
NetLogo 6.0 o superior.
Recursos: Se recomienda tener al menos 1 GB de memoria disponible para simulaciones complejas con muchos prosumidores.
Este programa simula un entorno económico dinámico y ofrece una plataforma flexible para estudiar las interacciones entre diferentes agentes económicos bajo diversas condiciones.

