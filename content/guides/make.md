# Make(file)

## Introducción

[[https://www.gnu.org/software/make/manual/make.html|make]] es una herramienta de GNU diseñada para facilitar la compilación y linkeo de un programa. Únicamente necesita dos cosas, el ejecutable y un archivo `makefile`.

## Make como ejecutable
Este programa suele venir instalado en la mayoría de distros Linux. Pertenece al
paquete base de desarrollador, que puede instalarse en arch como 
```sh
sudo pacman -S base-devel
```
En el resto de distribuciones puede tener otro nombre, pero en todas estará
disponible de manera predeterminada. Una vez instalado ya se puede empezar a
usar. Hay que tener en cuenta que es un ejecutable diseñado para usarse en una
terminal.

## Por qué usar un Makefile
La ventaja de usar un Makefile es que automáticamente, a partir de reglas
preestablecidas, decide que parte del código recompilar para volver a construir
en ejecutable final, teniendo en cuenta la fecha de modificación de todos los
archivos y como dependen entre sí. De esta manera, todos los archivos que no
hayan sido modificados desde que fueron compilados por última vez, no serán
recompilados.

## Makefile
Este archivo contiene las reglas mediante las cuales queremos compilar y linkear
una serie de archivos fuente. Para que `make` encuentre este archivo, debe tener
el nombre `makefile` sin importar si son mayúsculas o minúsculas, y encontrarse
en el mismo directorio en el que se ejecuta `make`.

### Estructura
La estructura básica de un Makefile son una serie de reglas, definidas de la siguiente manera:

```make
objetivo: dependencia1 dependencia2
	comando1
	comando2
```

Objetivo, al igual que las dependencias, pueden ser tanto un nombre de otra regla, o el nombre de un archivo. Si no hay una regla con este nombre, se asume que es un archivo. Los comandos se ejecutan si el archivo **objetivo** fue modificado o si alguna regla o archivo dependencia fue actualizada.

Los comandos son cualquier comando que se pueda ejecutar en una terminal.

Hay que tener en cuenta que empezara a ejecutar la primera regla, y el resto solo se ejecutaran si son dependencias de alguna que se vaya a ejecutar.

#### Ejemplo
Imaginemos que tenemos un archivo `main.c`. Vamos a crear una regla para compilar este programa.

```make
main: main.c
	gcc main.c -o main
```

Esta regla tiene por objetivo un archivo llamado `main` que depende de `main.c`. Así, si `main` no existe o `main.c` fue modificado más tarde que `main`, se ejecuta el comando `gcc main.c -o main` que compila `main.c` con el nombre final `main`. Si se vuelve a ejecutar **make** sin que se haya modificado `main.c` nos dirá que ya está actualizado.

#### Variables

Otra cosa básica que nos va a hacer falta es poder almacenar información en variables. Una variable se declara como 

```make
VAR = contenido
```

Para llamar a esta variable desde otra parte del código, escribimos
```make
$(VAR)
```

Hay varios comandos en **make** como `$(wildcard)` y `$(shell)` que pueden resultar muy útiles, pero no vamos a tratarlos aquí.

#### Guía práctica

Ahora voy a narrar un supuesto paso a paso de la inicialización de un proyecto, digamos personal, por la falta de estructuración previa.

Vamos a crear un programa `main.c` y su regla correspondiente. Pero vamos a adelantarnos compilando todos los archivos fuente a código objeto, antes de enlazarlos. 

```make
main: main.o
	gcc main.o -c main

main: main.o
	gcc main.o -c main
main.o: main.c
	gcc main.c -o main.o -c
```

Ahora vamos a crear dos archivos que nos hacen falta, `array.c` y `array.h`. Tanto `main.c` como `array.c` dependen de la información de `array.h`, por lo que este último archivo será dependencia de ambos.

```make
main: main.o array.o
	gcc main.o -c main
	
main.o: main.c array.h
	gcc main.c -o main.o -c

array.o: array.c array.h
	gcc array.c -o array.o -c
```

Nuestro `main.c` está creciendo demasiado, por lo que valoramos separarlo en varios archivos. Supongamos que creamos los archivos `reader.c`, `reader.h`, `writer.c` y `writer.h`. El archivo de cabecera únicamente es dependencia de ellos mismos y del `main.c`, ya que es este último el que lleva a cabo toda la funcionalidad, usando los procedimientos definidos y declarados en el resto de archivos.

```make
main: main.o array.o writer.o reader.o
	gcc main.o -c main
	
main.o: main.c array.h
	gcc main.c -o main.o -c

array.o: array.c array.h
	gcc array.c -o array.o -c

reader.o: reader.c reader.h
	gcc reader.c -o reader.o -c

writer.o: writer.c writer.h
	gcc writer.c -o writer.o -c
```

Asegúrate de entender por qué las reglas funcionan, y porque es más beneficioso hacer esto que únicamente ejecutar `gcc *.c`, teniendo en mente que un proyecto puede tener más de un par de archivos.

Vamos a añadir una regla más, `clean`, que nunca se llamará automáticamente, únicamente cuando ejecutemos `make clean`. Esta regla borrará todos los archivos que generamos en la compilación.

```make
clean:
	rm -f main main.o array.o reader.o writer.o
```

#### Automatización del Makefile

Una práctica común es definir el nombre de cosas importantes que pueden variar como variables

```make
OUT = main
CC = gcc
OBJ_DIR = obj
FLAGS = -Wall -Wextra -ggdb
LIBS = -lm
INCLUDES = -I. -Isrc 
```

Se deja como ejercicio para el lector reescribir el Makefile anterior usando estas variables.

También se pueden definir reglas para obtener los archivos fuente y objeto. Esta regla no se explicará aquí, pues no es el objetivo de esta entrada ahondar tanto. Con poder intuir que **SRC** es una variable que contiene todos los archivos **.c** de la carpeta **src**, y que **OBJ** es una variable que contiene todos los archivos objeto que queremos, cambiando su extensión a **.o** y añadiendo la ruta para archivos objeto que definimos antes.
```make
SRC = $(wildcard src/*.c)
OBJ = $(patsubst src/%.c,$(OBJ_DIR)/src/%.o,$(SRC))
HEADERS = $(wildcard src/*.h)
```

Después podemos definir las siguientes reglas:
```make
$(OUT): $(OBJ)
	$(CC) $(FLAGS) $^ -o $@ $(LIBS)

$(OBJ_DIR)/src/%.o: src/%.c makefile $(HEADERS)
	@mkdir -p $(dir $@)
	$(CC) $(FLAGS) $(INCLUDES) -c $< -o $@
```

La primera genera el ejecutable y depende de todos los códigos objeto. Las variables `$^` y `$@`, las define make, la primera hace referencia a todas las dependencias, y la segunda al objetivo de la regla. La segunda regla se ejecuta para cada archivo objeto, depende del **.c** con el mismo nombre que el **.o** que se está generando, del Makefile y de todos los headers. Tiene el problema de que al cambiar un archivo de cabecera se recompilan todos los códigos objeto, pero nos ahorra de problemas al incluir un **.h** y nunca actualizar el Makefile.

## Tutorial bastante bueno

Para saber más este tutorial parece que está bien, siempre es mejor que leer una manual de GNU.

https://makefiletutorial.com/
