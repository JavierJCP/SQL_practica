use DBAlmacenes

/* configurar el formato de las fechas para este script */
set DateFormat dmy

/* insertar datos  */
INSERT INTO Almacen (CodAlmacen, NombreAlmacen, Direccion, Responsable)
			values ('AP', 'Almacen Pricipal', 'Av. Perú 345', 'Jaun Paz');
INSERT INTO Almacen (CodAlmacen, NombreAlmacen, Direccion, Responsable)
			values ('A1','Almacén sucursal Cusco', 'Av. de la Cultura 1723', 'Luis Guerra');
INSERT INTO Almacen (CodAlmacen, NombreAlmacen, Direccion, Responsable)
			values ('A2','Almacén sucursal Tacna', 'Av. Jorge Basadre 926', 'Melina Meza');

/* insertar datos sin poner los atributos */
INSERT INTO Articulo
			values ('C001','Computador desktop', 'UNI', 0.0);
INSERT INTO Articulo
			values ('C002','Lap Top', 'UNI', 0.0);
INSERT INTO Articulo
			values ('I001','Impresora', 'UNI', 0.0);
INSERT INTO Articulo
			values ('CD01','Discos compactos', 'CJA', 0.0);
INSERT INTO Articulo
			values ('USB1','Memoria USB de 4 GB', 'UNI', 0.0);

/* insertar datos con atributos en cualquier orden */
INSERT INTO Proveedor (CodProveedor, Ciudad, RazonSocial, RUC)
			values ('P01', 'LIMA','Distribuidora Alfa', '12334455667');
INSERT INTO Proveedor (CodProveedor, RazonSocial, Ciudad, RUC)
			values ('P02','Omega S.A.', 'LIMA', '21993452861');
INSERT INTO Proveedor (RUC, CodProveedor, RazonSocial, Ciudad)
			values ('82114859617', 'P03','Solución Total', 'CUSCO');
INSERT INTO Proveedor (CodProveedor, RazonSocial, RUC, Ciudad)
			values ('P04','Delta Servicios S.A.', '41983156831', 'TACNA');

/* datos de entrada */
-- FC-1005
INSERT INTO Entrada
values ('FC-1005','01/02/2008','P01','AP','COMPRA');
INSERT INTO Entrada_Detalle
values ('FC-1005','C001',20, 1500);
INSERT INTO Entrada_Detalle
values ('FC-1005','CD01',40, 100);
-- FC-1006
INSERT INTO Entrada
values ('FC-1006','04/02/2008','P02','A1','COMPRA');
INSERT INTO Entrada_Detalle
values ('FC-1006','I001',30, 650);
INSERT INTO Entrada_Detalle
values ('FC-1006','USB1',100, 40);
INSERT INTO Entrada_Detalle
values ('FC-1006','C002',10, 1040);

select * from Entrada