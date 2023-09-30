/* Obtener la relación de prestatarios de la comunidad de código C001, con los siguientes atributos:
R(CodPrestatario, Nombres, DocIdentidad) */

select CodPrestatario, Nombres, DocIdentidad
from Prestatario
where CodComunidad = 'C001'

/* Obtener la relación de préstamos efectuados en los meses de Enero y febrero del 2004 */
SELECT *
FROM PRESTAMO
WHERE FechaPrestamo BETWEEN '01/01/2004' AND '02/29/2004'

/* Obtener el número de prestatarios */
select count(CodPrestatario) as NroPrestatarios
from Prestatario

/* Obtener el número de prestatarios de la comunidad de código C001 */
select count(CodPrestatario) as NroPrestatarios
from Prestatario
where CodComunidad = 'C001'

/* Obtener la relación de comunidades con su respectivo número de prestatarios, con los siguientes atributos 
	R(CodComunidad, NroPrestatarios)
*/
select CodComunidad, count(CodPrestatario) as NroPrestatarios
from Prestatario
group by CodComunidad

/* Obtener la relación de prestatarios que tengan más de 3 préstamos en el año 2003. La relación resultante debe estar
ordenado por el número de préstamos y tener los siguientes atributos:
R(CodPrestatario, NroPrestamos)  */
SELECT CodPrestatario, count(DocPrestamo) as NroPrestamos
FROM PRESTAMO
-- WHERE (FechaPrestamo BETWEEN '01/01/2007' AND '12/31/2007')
GROUP BY CodPrestatario
HAVING count(DocPrestamo) > 3
ORDER BY NroPrestamos


/* Obtener la relación de préstamos efectuados por el oficial de crédito de código OC0001, con los siguientes atributos:
R(DocPrestamo, FechaPrestamo, Importe, CodPrestatario, Nombres) */
select	 DocPrestamo, FechaPrestamo, Importe, CodPrestatario, Nombres
from	 Prestamo P inner join Oficial_Credito O
on		 P.CodOficial = O.CodOficial
where	 P.CodOficial = 'OC0001'

/* Obtener la relación de comunidades con el número de prestatarios, con los siguientes atributos:
R(CodComunidad, Nombre, NroPrestatarios) */
select	P.CodComunidad, Nombre,count(CodPrestatario) as NroPrestatario
from	Prestatario P inner join Comunidad C
on P.CodComunidad = C.CodComunidad
group by P.CodComunidad, Nombre	


/* Obtener la relación de Prestatarios con el número de préstamos y el total de los importes obtenidos, con los siguientes
atributos:
R(CodPrestatario, Nombres, DocIdentidad, NroPrestamos, TotalImporte) */
select	A.CodPrestatario, B.Nombres, B.DocIdentidad ,count(DocPrestamo) as NroPrestamos, SUM(Importe) as TotalImporte
from	Prestamo A inner join Prestatario B
on		A.CodPrestatario = B.CodPrestatario
group by A.CodPrestatario, B.Nombres, B.DocIdentidad

/* Obtener la relación de comunidades con los importes totales prestados a cada comunidad:
R(CodComunidad, Nombre, TotalImporte) */
select C.CodComunidad, C.Nombre, SUM(Importe) as TotalImport
from Comunidad C inner join Prestatario P 
on C.CodComunidad = P.CodComunidad 
inner join Prestamo A
on P.CodPrestatario = A.CodPrestatario
group by C.CodComunidad, C.Nombre

/* Obtener la relación de las 10 primeras comunidades que tienen el menor número de prestatarios:
R(CodComunidad, Nombre, NroPrestatarios) */

select top 10 C.CodComunidad, C.Nombre, count(CodPrestatario) as NroPrestatarios
from Prestatario P inner join Comunidad C
on P.CodComunidad = C.CodComunidad
group by C.CodComunidad, C.Nombre
order by NroPrestatarios  

/* Obtener la comunidad a la que se le prestó la mayor cantidad de dinero:
R(CodComunidad, Nombre, TotalImporte) */

select	top 1 C.CodComunidad, C.Nombre, SUM(A.Importe) as ImporteTotal
from	Prestamo A inner join Prestatario B
on		A.CodPrestatario = B.CodPrestatario
inner join Comunidad C
on		B.CodComunidad = C.CodComunidad
group by C.CodComunidad, C.Nombre
order by ImporteTotal desc

/*
============================================ 
			Composición externa. 
============================================
*/

/* Obtener la relación de préstamos con sus respectivos saldos.
R(DocPrestamo, FechaPrestamo, Importe, Saldo) */

select	P.DocPrestamo, P.FechaPrestamo, P.Importe, (P.Importe - SUM(ISNULL(A.Importe, 0))) as Saldo
from	Prestamo P left outer join Amortizacion A
on		P.DocPrestamo = A.DocPrestamo
group by P.DocPrestamo, P.FechaPrestamo, P.Importe

/* Obtener la relación de prestatarios con sus respectivos saldos.
R(CodPrestatario, Nombres, DocIdentidad, TotalPrestamos, Saldo) */

-- saldo de cada prestatario
select		P.CodPrestatario, SUM(P.Importe) as TotalPrestamos,(SUM(P.Importe) - SUM(ISNULL(A.Importe, 0))) as Saldo
into		T#1
from		Prestamo P left join Amortizacion A
on			P.DocPrestamo = A.DocPrestamo
group by	P.CodPrestatario;
-- agregar informacion del prestatario
select		P.CodPrestatario, P.Nombres, P.DocIdentidad, TotalPrestamos, Saldo
from		T#1 inner join Prestatario P
on			T#1.CodPrestatario = P.CodPrestatario
drop table  T#1

/* Obtener la relación de comunidades cuyos prestatarios tienen un saldo mayor a 10000.
R(CodComunidad, NombreComunidad, Saldo) */
-- prestatarios con saldo > 10000
select		P.CodPrestatario,(SUM(P.Importe) - SUM(ISNULL(A.Importe, 0))) as Saldo
into		T#2
from		Prestamo P left join Amortizacion A
on			P.DocPrestamo = A .DocPrestamo
group by	P.CodPrestatario

-- totalizar por comunidad y filtrar los mayores a 10000
select		C.CodComunidad, SUM(Saldo) as SaldoComunidad
into		T#3
from		T#2 inner join Prestatario C
on			T#2.CodPrestatario = C.CodPrestatario
group by	C.CodComunidad
having		SUM(Saldo)  > 10000

-- agregar datos de comunidad
select		C.CodComunidad, C.CodComunidad, SaldoComunidad
from		T#3 inner join Comunidad C
on			T#3.CodComunidad = C.CodComunidad
drop table	T#2, T#3

/* Obtener la relación de los 10 prestatarios que tienen los mayores saldos
R(CodPrestatario, Nombres, TotalPrestado, Saldo) */

-- lista de prestatarios con su respectivo saldo
select		P.CodPrestatario, 
			SUM(P.Importe) as TotalPrestamo,
			(SUM(P.Importe) - SUM(ISNULL(A.Importe, 0))) as Saldo
into		T#TMP_Total
from		Prestamo P left join Amortizacion A
on			P.DocPrestamo = A .DocPrestamo
group by	P.CodPrestatario
-- agrrgar datos del prestatario
select		top 10 P.CodPrestatario, P.Nombres, TotalPrestamo, Saldo
from		T#TMP_Total left join Prestatario P
on			T#TMP_Total.CodPrestatario = P.CodPrestatario
order by	Saldo desc
drop table  T#TMP_Total

/*
============================================ 
			Subconsultas. 
============================================
*/

/* Obtener la relación de prestatarios que no hayan solicitado préstamos desde el 01/01/2003 a la fecha, con los
siguientes atributos:
R(CodPrestatario, Nombres, CodComunidad) */

select		CodPrestatario, Nombres, CodComunidad
from		Prestatario
where		CodPrestatario not in (
									select		CodPrestatario
									from		Prestamo
									where		FechaPrestamo >= '01/01/2003')

/* Obtener la relación de préstamos que aún no hayan sido amortizados o cancelados (Importe del préstamo igual
al saldo del préstamo), con los siguientes atributos:
R(DocPrestamo,FechaPrestamo,Importe) */

SELECT		DocPrestamo,FechaPrestamo,Importe
FROM		PRESTAMO P
WHERE		Not Exists	(SELECT *
						 FROM AMORTIZACION A
						 WHERE (P.DocPrestamo = A.DocPrestamo)
						)


/* Obtener la relación de oficiales de crédito que tengan algún préstamo que aún no haya sido amortizados o
cancelados (Importe del préstamo igual al saldo del préstamo), con los siguientes atributos:
R(CodOficial, Nombres) */
SELECT		CodOficial, Nombres
FROM		OFICIAL_CREDITO O
WHERE		Exists		(SELECT		*
						FROM		PRESTAMO P
						WHERE		(P.CodOficial = O.CodOficial) and
						not EXISTS	(SELECT *
									FROM AMORTIZACION A
									WHERE (P.DocPrestamo = A.DocPrestamo)
									)
						)
