# netlogo_moneda_social
Simulación de un mercado de moneda social con caja de canje con otras monedas

README: Modelo NetLogo de Prosumidores con Caja, Préstamos y Frustración
Descripción General
Este programa en NetLogo simula un sistema económico basado en transacciones entre prosumidores (compradores y vendedores) que utilizan dos tipos de monedas: G1 y Euros. Los prosumidores realizan compras, ventas, pueden recibir préstamos o donaciones de una Caja central, y pueden enfrentar frustración si sus saldos son insuficientes. El modelo evalúa la dinámica del sistema a lo largo del tiempo, registrando transacciones, frustraciones, y aplicando ciertas condiciones de crisis financiera.

Estructura del Programa
1. Variables Globales
transacciones-totales: Número total de transacciones realizadas.
frustrados-historicos: Número de prosumidores que han sido frustrados históricamente.
saldo-total-g1 y saldo-total-euros: Saldos globales acumulados de la moneda G1 y Euros respectivamente.
usuarios-deudor y usuarios-donacion: Contadores de prosumidores que han sido deudores o han recibido donaciones.
dia: Día actual de la simulación.
crisis: Contador de crisis financieras.
Otros: Variables relacionadas con desviaciones estándar, acumulados de saldos, y control de usuarios nuevos.
2. Propiedades de los Prosumidores (turtles-own)
rol: Define si el prosumidor es un comprador o vendedor.
saldo-g1 y saldo-euro: Saldos individuales en G1 y Euros.
items-comprados y items-vendidos: Contador de transacciones realizadas.
esta-frustrado: Indica si el prosumidor ha sido frustrado (baja del sistema).
preferencial: Marca si el prosumidor ha sido clasificado como preferencial (bonificaciones).
3. Procedimientos Principales
setup
Propósito: Inicializa el modelo, creando prosumidores y la Caja, y estableciendo los valores iniciales de todas las variables globales.
Acciones:
Crear prosumidores (create-turtles).
Crear la Caja (create-caja), entidad central que gestiona préstamos y donaciones.
Inicializar gráficos y contadores (inicializar-plots).
go
Propósito: Es el ciclo principal del modelo, ejecutado en cada tick.
Acciones:
Incrementa el contador de días.
Verifica saldos de la Caja y decide si ocurre una crisis financiera.
Permite a los prosumidores realizar transacciones (compras y ventas) e interactuar.
Verifica si los prosumidores necesitan préstamos o donaciones y si deben devolver préstamos.
Controla las frustraciones y las bajas de prosumidores.
Actualiza los gráficos y estadísticas.
move
Propósito: Controla el movimiento de los prosumidores en el espacio.
Acciones:
Mueve los prosumidores de acuerdo a su estado (preferencial o no).
interact
Propósito: Define la lógica de interacción entre prosumidores cercanos.
Acciones:
Verifica si dos prosumidores pueden realizar una transacción de compra o venta.
make-sale y make-purchase
Propósito: Ejecutan la lógica de las ventas y compras.
Acciones:
Calculan el precio, la cantidad de ítems, y actualizan los saldos de compradores y vendedores.
La Caja recibe una comisión por cada transacción.
prestar-de-la-caja y devolver-prestamo
Propósito: Gestiona la lógica de los préstamos entre la Caja y los prosumidores.
Acciones:
La Caja otorga préstamos si un prosumidor tiene saldo negativo.
Los prosumidores devuelven los préstamos cuando tienen saldo suficiente.
realizar-donacion-euros
Propósito: Gestiona donaciones de Euros por parte de la Caja a los prosumidores con saldo negativo.
check-frustration
Propósito: Verifica si un prosumidor está frustrado (saldo crítico) y lo elimina del modelo.
calculate-totals, actualizar-saldos-g1, update-color
Propósito: Calculan totales y estadísticas como el saldo global de G1 y Euros, y actualizan los gráficos.
crisis-financiera
Propósito: Aplica una crisis financiera de forma aleatoria, reduciendo los saldos de todos los prosumidores.
4. Casuísticas Principales
Compras y Ventas: Los prosumidores realizan transacciones basadas en su saldo y la cantidad de ítems disponibles.
Préstamos: Cuando un prosumidor no tiene saldo suficiente para completar una transacción, puede recibir un préstamo de la Caja.
Canje de Euros: Los prosumidores pueden canjear Euros por G1 si sus saldos son negativos.
Frustración: Si un prosumidor alcanza un saldo crítico (G1 <= -90), es dado de baja y su saldo se transfiere a la Caja.
Crisis: De manera aleatoria, el sistema puede sufrir una crisis financiera que reduce los saldos de todos los prosumidores.
5. Gráficos y Monitores
Gráficos: El modelo incluye gráficos que muestran la evolución de los saldos G1 y Euros, además de contar las crisis financieras y frustraciones.
Monitores: Muestra valores como el saldo promedio de deudores y donantes, y el número de usuarios activos.
Uso del Programa
Configuración Inicial:

Presiona el botón setup para inicializar el modelo con los prosumidores y la Caja.
Ejecución del Modelo:

Presiona el botón go para comenzar la simulación. El modelo correrá indefinidamente, mostrando las interacciones entre los prosumidores y la Caja, hasta que ocurra una condición de parada (como un desequilibrio crítico).
Gráficos y Estadísticas:

Observa los gráficos y monitores para seguir la evolución de la simulación, como los saldos de G1, Euros, y las crisis financieras.
Parámetros Personalizables
usuarios: Número inicial de prosumidores en el sistema.
euros: Cantidad inicial de Euros que tienen los prosumidores.
saldo-g1_entrada: Saldo inicial en G1 de los prosumidores.
Posibles Extensiones
Agregar nuevos roles: Incorporar nuevos roles además de compradores y vendedores, como inversionistas o prestamistas.
Mejorar la lógica de crisis: Crear eventos de crisis más complejos que afecten de manera desigual a los prosumidores.
Interacción entre prosumidores: Introducir reglas más avanzadas de interacción social entre los prosumidores.
Consideraciones Técnicas
El modelo puede correr en ciclos indefinidos, por lo que es importante monitorear las condiciones límite (crisis financieras, frustración masiva) para detener la simulación si es necesario.
Las decisiones de préstamos y donaciones están limitadas por los recursos de la Caja, lo que puede llevar a escenarios insostenibles si no se manejan bien.
Requisitos
NetLogo 6.0 o superior.
Memoria suficiente: Para manejar simulaciones con grandes cantidades de prosumidores.
Este modelo simula interacciones económicas de un modo simplificado y puede servir para estudiar dinámicas de frustración, préstamos, y uso de distintas monedas en sistemas complejos.
