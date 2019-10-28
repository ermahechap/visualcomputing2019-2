# Taller raster

## Propósito

Comprender algunos aspectos fundamentales del paradigma de rasterización.

## Tareas

Emplee coordenadas baricéntricas para:

1. Rasterizar un triángulo.
2. Sombrear su superficie a partir de los colores de sus vértices.
3. Implementar un [algoritmo de anti-aliasing](https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-practical-implementation) para sus aristas.

Referencias:

* [The barycentric conspiracy](https://fgiesen.wordpress.com/2013/02/06/the-barycentric-conspirac/)
* [Rasterization stage](https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage)

Implemente la función ```triangleRaster()``` del sketch adjunto para tal efecto, requiere la librería [nub](https://github.com/visualcomputing/nub/releases) (versión >= 0.2).

## Integrantes

Complete la tabla:

| Integrante | github nick |
|------------|-------------|
|Diego Said Niquefa Velásquez|niquefaDiego|
|Juan Diego Moreno|judmorenomo|
|Edwin Ricardo Mahecha Parra|ermahechap|


## Discusión

Hicimos anti-aliasing mediante la técnica de dividir el pixeles en subpixeles y asignar al pixel el color promedio de los subpixeles. Para esto usamos una función recursiva que en cada paso divide el pixel/subpixel en 4 y hace un llamado recursivo a cada uno, hasta llegar a profunidad 3. En el caso base de la recursión se determina si el centro del subpixel está en el triangulo, en caso de estarlo se determina el color del pixel mediante el uso de coordenadas baricéntricas, y en caso de no estarlo se toma el color negro (color de fondo). El color que retorna la función es el promedio de los colores en cada uno de las 4 divisiones.

A simple vista el anti-aliasing al partir el pixel en 64 se ve suficientemente bueno, así que no parece valer la pena hacer más divisiones y perder eficiencia por esto.

Referencia usada: https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage

## Entrega

* Plazo: ~~20/10/19~~ 27/10/19 a las 24h.
