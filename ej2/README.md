# Ejercicio 2

## Intro

Como caso inverso el ejercicio numero 1, este problema requiere desarrollar una herramienta de validación, que también siga las mismas especificaciones.
Los testbenchs serán desarrollados usando python, específicamente la herramienta [CoCoTB](https://github.com/potentialventures/cocotb). Podrás basarte en el testbench del ejercicio numero 1.

Del mismo se evaluará:

* Cobertura de casos de test.
* Estructura de código desarrollada para el mismo.

## Objetivos

* Desarrollar un testbench que cubra toda la especificación del core con mensajes de failure para los casos donde esté fuera de especificación.

A partir del testbench presentado, modifique el mismo para que: 

* Realice la escritura de valores **aleatorios** en todas las posiciones de la memoria, escribiendo en el Puerto A.
* Leyendo por el Puerto B, verifique que los valores almacenados previamente sean correctos. 

## Especificaciones

Se dispone de una memoria RAM de doble puerto (Dual Port Ram), con las entradas y salidas que se muestran en la siguiente figura. 

```

          +--------------+
          |              |
  WEA+--->|              |
          |              |
  ENA+--->|              |<---+ENB
          |              |
          |   DUAL PORT  |
  DIA+--->|              |---->DOB
          |      RAM     |
ADDRA+--->|              |<---+ADDRB
          |              |
          |              |
 CLKA+--->|              |<---+CLKB
          |              |
          +--------------+
```

El código de la misma se encuentra descripto en verilog. Se presenta también un testbench en Python + COCOTB, el cual realiza una secuencia básica de escritura de dos valores en el Puerto A y lectura de estos mismos valores por el Puerto B. 

## Prueba del código

### Gitlab-CI

Al hacer `push` del código al repositorio Gitlab, correrá un Pipeline de Gitlab-CI. En el mismo podrá observar el comportamiento de la simulación. 

### Standalone

Si lo desea, puede instalar la herramienta COCOTB e IVerilog, para simular de forma local en su computadora. (Ver Referencia i) 

## Referencias

1. [COCOTB QuickStart](https://cocotb.readthedocs.io/en/latest/quickstart.html) 
