module la_tiendita::la_tiendita{ // Declaración de módulo (la_tiendita),la_tienda es el nombre del paquete y la_tienda  es el nombre del módulo
   // Su importación de dependencias necesarias
    use std::string::{String, utf8};//libreriaspara poder usar strings
    use sui::vec_map::{VecMap, Self};//libreria para usar mapa de vectores
    use sui::tx_context::{TxContext};   // libreria para el Contexto de transacción
    use sui::object;                   // libreria para crear objetos con UID
    use sui::transfer;   // libreria para transferir ownership de objetos

 
     /// --- La estructura principal de la_tiendita ---
     ///  /// Tiene una clave única (UID), un nombre y un conjunto de productos.
    public struct La_tiendita has key, store {//Declarar una estructura publica (que siurve para almacenar datos, que puedes eliminar o descartar)

        id:UID, // Variable para  identificador único del objeto
        nombre:String,  //variable para el nombre de la tienda
        productos: VecMap<u8, Productos>,  //variable para la lista de productos, usando ID como clave

    }
 
     /// --- Estructura secundaria: Producto
    /// Representa un artículo dentro de la tiendita
    public struct Productos has store, drop {
        nombre:String,  // variable para el nombre del producto
        precio: u64,  // vaariable para su precio del producto
        cantidad: u8,// variable para la cantidad disponible
        id_produ:u8,    // variable pare el ID del producto
    }
  // Constantes de error para manejo elegante de errores

    #[error]
    const PRODUCTO_EXISTENTE: vector<u8> = b"El ID del producto ya exist";// Error cuando se intenta agregar un producto con ID existente
    #[error]
    const PRODUCTO_NO_ENCONTRADO: vector<u8> = b"Producto no encontrado";// Error cuando no se encuentra un producto
    #[error]
   const SIN_STOCK: vector<u8> = b"No hay suficiente stock"; // Error cuando no hay suficiente stock para vender
// Función para crear una nueva tiendita 
  // Crea una nueva instancia de la tiendita
 
    public fun crear_tiendita(nombre: String, ctx: &mut TxContext) {
 
        let la_tiendita = La_tiendita {  
            id: object::new(ctx),   // Genera un nuevo UID único usando el contexto  
            nombre, // Usa el nombre pasado como parámetro
            productos: vec_map::empty() // Inicializa el mapa de productos vacío
        };
 
        // Transfiere la propiedad de la tiendita al sender de la transacción
      transfer::transfer(la_tiendita, tx_context::sender(ctx));
    }
  // Función para agregar un nuevo producto a la tiendita
    public fun agregar_producto( la_tiendita: &mut La_tiendita, nombre: String,  precio: u64, cantidad: u8, id_produ: u8) {
 // Verifica que el ID del producto no exista ya en la tiendita
        // Si existe, revierte la transacción con error PRODUCTO_EXISTENTE
        assert!(!la_tiendita.productos.contains(&id_produ), PRODUCTO_EXISTENTE);
          // Crea una nueva instancia de Producto
     let producto = Productos {
            nombre,// llamando a nombre del producto
            precio,   // llamando a el precio del producto
            cantidad,    //llamando a la cantidad inicial en stock
            id_produ,       // llamando al ID único del producto
        };
          la_tiendita.productos.insert(id_produ, producto); // Inserta el producto en el mapa usando el ID como clave
 
    }
 
  public fun vender_producto( la_tiendita: &mut La_tiendita, id_produ: u8, cantidad: u8) {  // Función para vender una cantidad específica de un producto
          // Verifica que el producto exista en la tiendita
      assert!( la_tiendita.productos.contains(&id_produ), PRODUCTO_NO_ENCONTRADO);
  // Obtiene una referencia mutable al producto para modificarlo
         let producto =  la_tiendita.productos.get_mut(&id_produ);
// Verifica que haya suficiente stock para la venta
        assert!(producto.cantidad >= cantidad, SIN_STOCK);
 // Reduce la cantidad disponible (resta el stock vendido)
        producto.cantidad = producto.cantidad - cantidad;
    }
 // Función para reabastecer (aumentar stock) de un producto existente
    public fun reabastecer_producto( la_tiendita: &mut  La_tiendita, id_produ: u8, cantidad: u8) {
        // Verificamos que el producto exista
        assert!( la_tiendita.productos.contains(&id_produ), PRODUCTO_NO_ENCONTRADO);
 
        // Obtenemos una referencia mutable al producto
        let producto =  la_tiendita.productos.get_mut(&id_produ);
 
        // Aumentamos el stock
        producto.cantidad = producto.cantidad + cantidad;
    }
 
   public fun eliminar_producto( la_tiendita: &mut La_tiendita, id_produ: u8) {
        // Verificamos que el producto exista
        assert!( la_tiendita.productos.contains(&id_produ), PRODUCTO_NO_ENCONTRADO);
 
        // Lo eliminamos del mapa
         la_tiendita.productos.remove(&id_produ);
    }
 
 
}