# Ejercicio 1

## Intro

En nuestro trabajo diario te tocará desarrollar algún core para cumplir cierta 
función, para eso vas a tener especificaciones que te indiquen comportamientos
del mismo que debas codificar en VHDL/Verilog y luego alguien mas del equipo
desarrollará un testbench que valide el funcionamiento del core. 

Se evaluará:

* Claridad en la codificación del core.
* Cobertura de especificación.

## Objetivos

* Desarrollar un core en VHDL o Verilog que cumpla con las especificaciones.
* Lograr que pase el testbench propuesto en el repositorio.

## Especificaciones

Se dispone de un dispositivo SoC que contiene una CPU y FPGA (Programmable Logic
- PL).
Es necesario conectar un periférico SPI a través de la PL que pueda accederse
desde la CPU. Este periférico a desarrollar debe ser simple, no dispone de
inteligencia sino que expone registros para su configuración y operación.

En la siguiente figura se esquematiza como es la conexión del sistema en general
y el core que debe desarrollarse.

```
        +-----+                                             +-----+
        |     |                                             |     |
        |     |      +----------------------------+         |     |
        |     |      |       (axi_spi.v/vhdl)     |         |     |
        |     |      |                            |         |     |
        |     |<---->|                            |         |     |
        |     |<---->|                            |         |     |
        |     |<---->|AXI_INTERFACE               |   SPI   |  S  |
        |     |<---->|                            |         |  P  |
        |     |<---->|                       MISO |<--------|  I  |
        | C   |<---->|                       MOSI |-------->|     |
        | P   |      |                       SCK  |-------->|     |
        | U   |      |                       CSn  |-------->|  D  |
        |     |      |                            |         |  E  |
        |     |----->|AXI_CLK                     |         |  V  |
        |     |----->|AXI_RESETn                  |         |     |
        |     |      |                            |         |     |
        |     |<-----|IRQ                         |         |     |
        |     |      |                            |         |     |
        |     |      +----------------------------+         |     |
        |     |                                             |     |
        +-----+                                             +-----+
```
### Registros

El core se debe conectar a una interfaz AXI lite y debe tener los siguientes
registros de configuración:


| ADDRESS |   Nombre    |   Descripción                                                   |
|---------|-------------|-----------------------------------------------------------------|
|  0x00   |     TX      | Dato que se va a enviar. Escribirlo inicia la transferencia     |
|  0x04   |     RX      | Último dato recibido                                            |

Para resolver la interfaz AXI, se brinda un core que hace de wrapper
(ver [axi_lite_slave_int](hdl/axi_lit_slave_int.vhdl) ) y que ofrece a la
salida una interfaz similar a las de una ram (write enable, read enable, data y
address). Este core esta tanto en VHDL como en Verilog para  que utilice el que 
usted desee.

Los puertos del core deben ser los siguientes (respetando mayúsculas), de lo 
contrario, el test fallará:

### Puertos de entrada/salida

|      Nombre       |
|-------------------|
| CSn               |
| MOSI              |
| MISO              |
| SCK               |
| INT               |
| RX0BF             |
| RX1BF             |
| AXI_signals       |
| AXI_CLK           |
| AXI_RESETn        |

Las relaciones de clock que se deben tomar durante el diseño es: 
* AXI_CLK = 100MHz
* SCLK = 1MHz

El la trama SPI debe responder a la siguiente waveform:

```
     +-------+                                               +---------+
  CS         |                                               |
             +-----------------------------------------------+

                +--+  +--+  +--+  +--+  +--+  +--+  +--+  +--+
SCLK            |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
     +----------+  +--+  +--+  +--+  +--+  +--+  +--+  +--+  +---------+

             +-----+-----+-----+-----+-----+-----+-----+-----+
MOSI +-------+ MSB |     |     |     |     |     |     | LSB +---------+
             +-----+-----+-----+-----+-----+-----+-----+-----+

             +-----+-----+-----+-----+-----+-----+-----+-----+
MISO +-------+ MSB |     |     |     |     |     |     | LSB +---------+
             +-----+-----+-----+-----+-----+-----+-----+-----+

                                                              +--+
 INT                                                          |  |
     +--------------------------------------------------------+  +-----+

```

Los test que se proporcionan son los siguientes:

* loopback_test: Corrobora que los datos enviados sean recibidos
(loopback entre MISO y MOSI).
* tx_reg_test: Se prueba la lecto/escritura de los registros.
* spi_freq_test: Corrobora que la frecuencia de SCLK sea de 1MHz
* endianness_test: Corrobora que los datos sean enviados en orden correcto.
* sequence_test: Corrobora que se cumpla la waveform.


## Prueba del código

### Gitlab-CI

Al hacer `push` del código al repositorio Gitlab, correrá un Pipeline de
Gitlab-CI. En el mismo podrá observar el comportamiento de la simulación. 

### Standalone

Si lo desea, puede instalar la herramienta COCOTB e IVerilog, para simular de 
forma local en su computadora. (Ver Referencia i) 

## Referencias

1. [COCOTB QuickStart](https://cocotb.readthedocs.io/en/latest/quickstart.html) 
