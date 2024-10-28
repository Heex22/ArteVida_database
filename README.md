### Realizado por Alex He

# Introducción

Este repositorio contiene una base de datos diseñada para la gestión de eventos culturales, los requisitos pedidos son los siguientes: 

* Gestionar la gran variedad de eventos y detalles, así como las ganancias obtenidas. Para ello, es necesario llevar un registro adecuado de cada evento, de las actividades que se organizan en el evento, de los artistas que los protagonizan, las ubicaciones donde tienen lugar, la venta de entradas y, por supuesto, el entusiasmo de los visitantes que asisten, si les ha gustado o no, para ello el usuario valorará cada evento con un número del 0 al 5.

* En esta base de datos deben haber una serie de actividades que tienen un nombre, un tipo: concierto de distintos tipos de música (clásica, pop, blues, soul, rock and roll, jazz, reggaeton, góspel, country, …), exposiciones, obras de teatro y conferencias, aunque en un futuro estamos dispuestos a organizar otras actividades. Además, en cada actividad participa uno o varios artistas y tiene un coste (suma del caché de los artistas).

* El artista tiene un nombre, no tiene un caché fijo, éste depende de la actividad en la que participe, además se tiene una breve biografía suya. Un artista puede participar en muchas actividades.

* La ubicación tendrá un nombre (Teatro Maria Guerrero, Estadio Santiago Bernabeu, …), dirección, ciudad o pueblo, aforo, precio del alquiler y características.

* De cada evento hay que saber el nombre del evento (p.e. “VI festival de música clásica de Alcobendas”), la ubicación, el precio de la entrada, la fecha y la hora, así como una breve descripción de este. En un evento sólo se realiza una actividad.

* También tendremos en cuenta los asistentes a los eventos, de los que sabemos su nombre completo, sus teléfonos de contacto y su email. Una persona puede asistir a más de un evento y a un evento pueden asistir varias personas, hay que controlar que al evento no asistan más personas que el aforo del que dispone la ubicación.

# Estructura

## Modelo Entidad-Relación
![Diagrama-ER](https://github.com/user-attachments/assets/1a8d4022-3086-4a5d-b0f2-c52ef5e02e0f)

En el diseño conceptual las entidades usadas son: Eventos, Asistentes, Ubicación, Actividades y Artistas. Todas ellas son entidades fuertes puesto que poseen atributos diferentes entre ellas y no existe una dependencia que indique que alguna sea una entidad débil. 
Los dominios de los atributos serán los siguientes:
    • Id_lugar, Id_artista, Id_actividad, Id_asistente, Nombre_E: Código único de 4 caracteres ya sea letras o números y es key sensitive (diferencia entre mayúsculas y minúsculas).
    
    • Nombre_C, Nombre_U, Nombre, Tipo: Se componen de únicamente letras y sus tamaños son variables.
    
    • Mail, Descripción, Dirección, Características, Biografía: Están compuestos por números y letras, su longitud de caracteres es variable.
    
    • Teléfonos: Es un atributo multivalorado, se compone de listas de números de hasta 20 cifras.
    
    • Coste: Atributo derivado del caché, se computa como la suma del caché de todos los artistas que participen en la misma actividad, es un número de valor variable y puede contener decimales.
    
    • Caché: Su dominio se compone de números con decimales y como máximo establezco que llegue a 8 cifras (El caché mas alto actual es de 17 millones)
    
    • Aforo: Dominio compuesto por números enteros positivos.
    
    • Ciu_puebl: Es un booleano para el cual 1 equivale a que es una Ciudad y 0 a Pueblo.
    
    • Hora: Su dominio está compuesto por horas en la notación por defecto de SQL
    
    • Fecha: Su dominio consiste en fechas en la notación por defecto de SQL
    
    • Precio: El precio de las entradas está compuesto por números con decimales que llegan hasta las 3 cifras.
    
    • Valoración: Consiste en 1 cifra que llega hasta un máximo de 5 y un mínimo de 0.
    
Las cardinalidades están expresadas tal que:
    • En un Evento se puede realizar como máximo una Actividad y como mínimo al menos una. Una Actividad puede ser realizada en al menos un Evento y como máximo N Eventos.
    
    • Un Evento puede ocurrir en al menos una Ubicación y como máximo en una (Estoy asumiendo que un evento puede tener sólo una ubicación porque no se indica que las actividades pueden ocurrir en ubicaciones diferentes). En una Ubicación puede ocurrir al menos algún Evento y como máximo puede un Evento en una Ubicación (Asumo que no puede repetir ubicación por cuestiones de logística).
    •  En un Evento puede no venir ningún Asistente y como máximo venir N Asistentes. Un Asistente tiene que venir al menos a un Evento (sino dejaría de ser un asistente) y puede ir como máximo a N Eventos.

    • En una Actividad pueden no participar ningún Artista y como máximo N Artistas. Un Artista debe participar en al menos 1 Actividad (Si no participa en ninguna no tiene sentido agregarlo a la base de datos) y como máximo en N Actividades.
       
En los requisitos hay dos elementos que no son modelables en el diseño, en primer lugar sería el dominio de Coste el cual debe de computarse a través de la suma de los Caché y en segundo lugar tenemos la limitación de asistentes por el aforo del sitio.

## Modelo Relacional
![Modelo_relacional](https://github.com/user-attachments/assets/45d7e66a-1351-4856-9184-cbb8b454974c)

Aplicando las técnicas de paso a tablas tengo que las tablas entidad son Ubicación, Eventos, Actividades, Asistentes y Artistas. Las relaciones entre estas tablas se representaron de la siguiente forma: Las tablas Participa y Vienen al ser relaciones varios a varios poseen las claves primarias de las dos entidades que relacionan más los atributos que dicha relación tenga, la relación Realiza al tratarse de ser uno a varios y total del lado unitario (Puesto que no tendría sentido en esta base de datos agregar actividades si no van asociadas a un evento) vendrá representada mediante una clave ajena (Foreign Key) en el lado de varios, por otra parte la relación Ocurre al ser uno a uno debe elegir un lado de varios (En este caso elijo Eventos) dónde se usará una clave ajena para representarla.
