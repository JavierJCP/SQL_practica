DROP DATABASE IF EXISTS DBAlmacenes;
CREATE DATABASE DBAlmacenes;



/* Crear lo tipos */
CREATE TYPE TCodAlmacen FROM varchar(12) NOT NULL;
go
CREATE TYPE TCodArticulo FROM varchar(12) NOT NULL ;
go
CREATE TYPE TCodProveedor FROM varchar(12);
go
CREATE TYPE TDocEntrada FROM varchar(12) NOT NULL ;
go
CREATE TYPE TDocSalida FROM varchar(12) NOT NULL ;
go
CREATE TYPE TDocPedido FROM varchar(12) NOT NULL ;
go

/* Activar la base de datos */
use DBAlmacenes
go

/*Crear las tablas */
CREATE TABLE Almacen (
	CodAlmacen		TCodAlmacen NOT NULL,
	NombreAlmacen	varchar(40) NOT NULL,
	Direccion		varchar(40),
	Responsable		varchar(40),
	PRIMARY KEY		(CodAlmacen)
)
go

create table Articulo(
CodArticulo			TCodArticulo NOT NULL,
Descripcion			varchar(40) NOT NULL,
UnidadMed			varchar(3),
Stock				numeric(15,6),
PRIMARY KEY			(CodArticulo)
)
go

create table Proveedor(
	CodProveedor	TCodProveedor NOT NULL,
	RazonSocial		varchar(40) NOT NULL,
	RUC				varchar(11),
	Ciudad			varchar(25),
	PRIMARY KEY		(CodProveedor)
)
go

create table Entrada(
	DocEntrada		TDocEntrada NOT NULL,
	Fecha			DateTime,
	CodProveedor	TCodProveedor,
	CodAlmacen		TCodAlmacen,
	Concepto		varchar(10) check(Concepto in ('COMPRA', 'DEVOLUCION', 'AJUSTE')),
	PRIMARY KEY		(DocEntrada),
	FOREIGN KEY		(CodProveedor) REFERENCES Proveedor(CodProveedor)
)
go

create table Salida(
	DocSalida		TDocSalida NOT NULL,
	Fecha			DateTime,
	Cliente			varchar(40),
	CodAlmacen		TCodAlmacen,
	Concepto		varchar(10) check(Concepto in ('VENTA', 'DEVOLUCION', 'AJUSTE'))
	PRIMARY KEY		(DocSalida),
	FOREIGN KEY		(CodAlmacen) REFERENCES Almacen(CodAlmacen)
)
go 

create table Salida_Detalle(
DocSalida			TDocSalida NOT NULL,
CodArticulo			TCodArticulo,
Cantidad			numeric(15,2) check(Cantidad > 0),
PrecioUnitario		numeric(15,2) check(PrecioUnitario > 0),
PRIMARY KEY			(DocSalida, CodArticulo),
FOREIGN KEY			(DocSalida) REFERENCES Salida(DocSalida),
FOREIGN KEY			(CodArticulo) REFERENCES Articulo(CodArticulo)
)
go

create table Pedido(
DocPedido		TDocPedido NOT NULL,
Fecha			DateTime,
CodProveedor	TCodProveedor,
FechaEntrega	DateTime,
PRIMARY KEY		(DocPedido),
FOREIGN KEY		(CodProveedor) REFERENCES Proveedor(CodProveedor),
)
go

create table Pedido_Detalle(
DocPedido			TDocPedido NOT NULL,
CodArticulo			TCodArticulo,
Cantidad			numeric(15,2) check(Cantidad > 0),
CostoUnitario		numeric(15,2) check(CostoUnitario > 0),
PRIMARY KEY			(DocPedido, CodArticulo),
FOREIGN KEY			(DocPedido) REFERENCES Pedido(DocPedido),
FOREIGN KEY			(CodArticulo) REFERENCES Articulo(CodArticulo)
)
go

/* MODIFICAR TABLAS */
ALTER TABLE Proveedor
ADD Email	varchar(80)
go

select * from Proveedor