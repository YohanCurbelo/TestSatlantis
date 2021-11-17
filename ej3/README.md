## Ejercicio 3

### Intro

Este problema es más bien conceptual, requiere que propongas una solución a un
problema especifico, ideando una solución integral al mismo. La presentación de
la solución puede ser un diagrama en bloques con un resumen explicado, una
presentación, una descripción en VHDL/Verilog, lo que te sea mas útil para
contarnos tu idea.

Se evaluará:

* Creatividad en la idea propuesta.
* Cobertura de especificación.
* Claridad en la explicación.
* Recursos utilizados.

### Descripción del problema

Se dispone de un System on Chip (SoC) que contiene:

* Una zona de lógica programable (PL)
* Un controlador de memoria DDR4
* 4 Interfaces AXI3 de tamaño de burst máximo 256 transacciones y 128 bits de
ancho máximo por palabra.
* Una CPU que puede acceder a la memoria DDR4 y la zona de la PL.

Todo esto se esquematiza en la siguiente figura.

```
                         SOC
+-----------------------------------------------------+
|                                                     |
|                                                     |      +-------------+
|                                                     |      |             |
|  +------------------+            +---------------+  |      |             |
|  |                  |   AXIx4    |               |  |      |             |
|  |                  <------------>               |  |      |             |
|  |                  |            |               |  |      |             |
|  |                  <------------>    MEMORY     |  |      |             |
|  |        PL        |            |               <--------->     DDR4    |
|  |                  <------------>  CONTROLLER   |  |      |             |
|  |                  |            |               |  |      |             |
|  |                  <------------>               |  |      |             |
|  |                  |            |               |  |      |             |
|  +--------^---------+            +-------^-------+  |      |             |
|           |                              |          |      |             |
|           |                              |          |      |             |
|  +--------+------------------------------+-------+  |      +-------------+
|  |                                               |  |
|  |                    CPU                        |  |
|  |                                               |  |
|  |                                               |  |
|  +-----------------------------------------------+  |
+-----------------------------------------------------+
```

Se requiere diseñar un core en la PL lo mas simple posible que permita medir el
ancho de banda hacia la DDR4.

Se debe explicar como es el método para hacer esta medición, en qué consiste, 
que recursos cree que necesitará y como se puede garantizar que lo medido es 
realmente el ancho de banda máximo de la memoria. A su vez indicar las 
limitaciones del método elegido.
