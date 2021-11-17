# HDL team excercise for new candidates

## Intro

Bienvenido a este examen que nos ayudará a poder validar distintas habilidades 
que tengas. Este examen consta de 3 ejercicios que deberán resolverse en el 
plazo de 1 semana desde que hayas recibido la invitación a este repositorio. 
La solución del mismo puede enviarse por mail o podés hacer un fork en un repositorio 
personal en gitlab.com y entregar el link a tu repositorio con la solución.
Siempre podés enviar una consulta a los entrevistadores en caso que encuentre 
algún problema para el desarrollo.
La metodología propuesta para estos ejercicios sigue nuestros lineamientos de 
desarrollo con lo que con estos ejercicios podemos evaluar también como te 
desenvolvés con ellos.
Sin nada mas que agregar, éxitos!

## Metodología de desarrollo

Es probable que no dispongas de un entorno de desarrollo configurado para poder
trabajar y validar los ejercicios, pero ningún problema pensamos en ello!. Si
querés instalarte las herramientas, seguí este tutorial [link tutorial], sino 
podes hacer uso del mecanismo de Continuous Integration (CI) que ofrece Gitlab y
que ya está configurado para este proyecto. 

Estamos a tu disposición para cualquier consulta.

## Formas de uso

Para poder desarrollar los distintos ejercicios aquí propuestos podes:

* Utilizando gitlab CI para ver el resultado de las corridas en los pipelines. Este sistema corre solo por cada push que hagas al repositorio.
* Usar docker para poder correr los test de forma local.
* Instalarse todos los paquetes necesarios para correr los test de forma local.

### Docker

Para instalar Docker, ejecutar:
```bash
sudo apt-get install apt-transport-https dirmngr
sudo echo 'deb https://apt.dockerproject.org/repo debian-stretch main' >> /etc/apt/sources.list
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-get update
sudo apt-get install docker-engine
sudo usermod -a -G docker $USER
```

Luego, para descargar la imagen que posee todos los programas necesarios para
realizar los ejercicios, ejecutar el siguiente comando:

```bash
docker pull registry.gitlab.com/hdlteam/candidate-test
```

Para abrir una terminal con la imagen de docker, ejecutar el script `dockershell.sh`.

### Standalone

Para poder ejecutar las simulaciones sin la utilización de docker debe tener 
instalados los siguiente paquetes:

* python3
* ghdl: Simulador de VHDL
* iverilog: Simulador de Verilog
* gtkwave: Visualizador de waveform
* cocotb: Framework para desarrollar testbenchs en python

Para sistemas basados en debian, estos se deben instalar de la siguiente forma:

```bash
## Instala Python3, iverilog, make y gtkwave
sudo apt install python3 iverilog gtkwave make

## Instalar GHDL
sudo apt install gnat gcc
git clone https://github.com/ghdl/ghdl.git
cd ghdl
mkdir build
cd build
../configure --prefix=PREFIX
make
sudo make install

## Descargar COCOTB
git clone https://github.com/potentialventures/cocotb.git 
```

## Ejecutar los test

En las carpetas `test` de los ejercicios, se encontrará con un Makefile y los
archivos de simulación python.

Para ejecutar los test, ejecutar el comando `make` dentro de la carpeta `test`.

Recuerde de tener todo instalado, y en el caso de usar docker, haber ejecutado
previamente el script `dockershell.sh`. 

Al ejecutar los tests standalone, pueden tener el siguiente error:

```
Makefile:10: /makefiles/Makefile.sim: No such file or directory
make: *** No rule to make target '/makefiles/Makefile.sim'.  Stop.
```

Esto se debe a que no se tiene inicializada la variable de entorno de COCOTB.
Para ello ejecutar:
```bash
export COCOTB=<COCOTB-PATH> #Reemplazar <COCOTB-PATH> por lo que corresponda 
```
