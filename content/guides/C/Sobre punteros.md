## Introducción
El lenguaje C se caracteriza por su proximidad al hardware, permitiendo una gestión explícita de la memoria y una interacción directa con la arquitectura del sistema.

Antes de abordar los punteros, es fundamental definir con precisión qué es una variable. En C, una variable es una abstracción proporcionada por el compilador que vincula un identificador (nombre) con una dirección de memoria específica y un tipo de dato. Este último determina el tamaño del bloque de memoria (número de bytes) y la interpretación de su contenido binario.

Durante el proceso de compilación, el compilador traduce las referencias simbólicas a direcciones (relativas o absolutas). En tiempo de ejecución, la CPU no opera sobre 'nombres', sino sobre estas direcciones.

- Al asignar un valor (operación de escritura o l-value), la CPU localiza la dirección de memoria asociada y almacena la representación binaria del dato.

- Al leer el valor (operación de lectura o r-value), la CPU accede a la dirección, carga los bytes en un registro y los interpreta según el tipo de dato para realizar la operación solicitada.

## Qué es un puntero?
Un puntero es una variable que almacena un numero, que se asume que es una dirección de memoria. El compilador también almacena información sobre el tipo de dato que hay en esa dirección, y podría almacenar mas metadatos si lo requiere. Los punteros se usan para almacenar la dirección de memoria de una variable, para de esta forma poder acceder a ella desde parte del código que no tiene ese identificador visible. Como bien sabes, al pasar una variable como parámetro de una función, se copia su valor a una variable local de la función. En el caso de que queramos que las modificaciones que hagamos a un valor se vean reflejados en la variable original, no se puede pasar como una copia (pues se esta modificando la copia solo)


**continuará**