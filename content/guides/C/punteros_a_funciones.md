---
tags: guides, C
---

# Punteros a funciones

## Introducción 

Un puntero a una función es una definición de una variable cuyo tipo es un
puntero que se dice que apunta a una función. En C las funciones son punteros,
es decir, es la dirección de memoria de la primera instrucción que se va a
ejecutar al llamarlo (junto con metadatos y otras cosas irrelevantes). 

## Asignación

Por tanto, para asignar una función a una variable, es indiferente usar `X =
foo;` o `X = &foo;`, siendo X una variable que apunta a una función con la misma
firma que `foo`, o `void*`.

## Definciones iniciales

Supongamos una función definida como `int foo(float);`, cuya implementación se
encuentra en algun archivo declarada como `int foo(float f){ ... }`. Vamos a
definir un puntero llamado `foo_ptr` que apunte a esta función.

## Sobre la consistencia de las declaraciones

Pasemos un momento a un puntero normal, imaginemos una variable `V` que apunta a
un tipo `T`. Resultaría en algo de la forma `T *V`. Notese en que el `*`
acompaña a la variable, pues la variable es un puntero a un espacio de memoria
del tipo `T`, no se modifica el tipo `T`. Partiendo de este conocimiento básico,
apliquemos esta regla a la definición inicial.

## Definicion de un puntero a una función

Consideremos como tipo `int (float)`, ya que una función de define como un tipo
de retorno y un numeró constante de argumentos, con un tipo fijo. Consideremos
como variable nuestro nombre del puntero `foo_ptr`. Utilizando lo visto en el
apartado anterior, aplicando `T *V`, nos quedaria `int *foo_ptr (float)` (Nótese
que la variable sigue en el medio del tipo, por conveniencia. 

## Ambiguedad y como resolverla

Hay un último problema, el `*` que acompaña al nombre de la función es ambiguo,
ya que no se sabe si es una declaración de un puntero a una función, o es una
declaración de una función que devuelve un puntero. Para arreglar este problema,
declarar un puntero a una funcion requiere que el nombre de la variable y el `*`
que indica que es un puntero sean escritos entre paréntesis. El resultado final
de nuestra variable es el siguiente: `int (* foo_ptr) (float)`, se puede ver la
similitud con la declaración `int foo (float)`.

## Como definir un puntero a una función como un nuevo tipo

Usar punteros a funciones puede no ser conveniente en algunos casos, como por
ejemplo declarar una función que devuelve un puntero a función (se deja como
ejercicio para el lector). A continuación vamos a declarar una tipo `foo_ptr_t`
y con él nuestra variable `foo_ptr`. 

Usando `typedef` es totalmente trivial, pues partiendo de la declaración de
nuestro puntero a una función, añadiendo `typedef` al principio y cambiando el
nombre de la variable por el nombre del tipo, conseguimos definir nuestro tipo
`typedef int (* foo_ptr_t) (foat)`. Con nuestro nuevo tipo `float_ptr_t` podemos
definir nuestra función `foo_ptr` como cualquier definición de un tipo estándar,
`foo_ptr_t foo_ptr = foo;`. 

## Ejemplo completo en C

```c
/* Queremos definir una variable que guarde un puntero a `int foo(float)` */


/* Definición y declaracion de foo */
int foo(float);

int foo(float f){
    ...
}

/* Definicion de una variable de tipo puntero a una funcion con la misma firma que foo. */
int (*foo_ptr) (float);
foo_ptr = foo;

/* Definicion de una tipo puntero a una funcion con la misma firma que foo. */
typedef int (*foo_ptr_t) (float);

/* Con este tipo podemos declarar y definir una variable */
foo_ptr_t foo_ptr = foo;
```
