/*
=============================================
			ACTIVIDADES COMPLEMENTARIAS.
=============================================
*/

/* Relación de préstamos cancelados de un determinado prestatario */

SELECT		P.CodPrestatario, SUM(P.Importe) - SUM(A.Importe) AS SaldoTotal	
FROM		Prestamo P LEFT JOIN Amortizacion A
ON			P.DocPrestamo = A.DocPrestamo
GROUP BY	P.CodPrestatario
HAVING		SUM(P.Importe) - SUM(A.Importe) = 0

/* Relación de préstamos efectuados por los prestatarios de una determinada comunidad. */

SELECT		B.CodPrestatario, B.CodComunidad,SUM(A.Importe) AS PrestamoTotal
--INTO		T#1
FROM		Prestamo A LEFT JOIN Prestatario B
ON			A.CodPrestatario = B.CodPrestatario
GROUP BY	B.CodPrestatario, B.CodComunidad

/* Relación de prestatarios que hasta la fecha hayan efectuado más de 5 préstamos. */

SELECT		CodPrestatario, COUNT(DocPrestamo) AS NroPrestamos
FROM		Prestamo
GROUP BY	CodPrestatario
HAVING		COUNT(DocPrestamo) > 5

/* Relación de prestatarios morosos, es decir, aquellos que aún no han cancelado alguna de sus deudas y ya pasó la fecha
de vencimiento. */

-- PRESTATARIOS CON DEUDAS MOROSAS
SELECT		A.CodPrestatario, A.DocPrestamo,
			SUM(A.Importe) - SUM(ISNULL(B.Importe, 0)) AS Saldo
FROM		Prestamo A LEFT JOIN Amortizacion B
ON			A.DocPrestamo = B.DocPrestamo
WHERE		A.FechaVencimiento < GETDATE()
GROUP BY	A.CodPrestatario, A.DocPrestamo
HAVING		SUM(A.Importe) - SUM(ISNULL(B.Importe, 0)) > 0

/* Relación de las 5 comunidades que tienen el mayor número de prestatarios. */

SELECT		TOP 5 
			A.CodComunidad, COUNT(A.CodPrestatario) AS NroPrestatarios
FROM		Prestatario A 
GROUP BY	A.CodComunidad
ORDER BY	NroPrestatarios DESC

/* Relación de comunidades cuyos prestatarios que aún tienen saldos, no hayan efectuado ninguna amortización en lo que
va del año 2004. */

-- RELACION DE PRESTATARIOS CON SALDOS
SELECT		P.CodPrestatario ,SUM(P.Importe) - SUM(ISNULL(A.Importe, 0)) as SaldoTotal
INTO		#P_SALDOS
FROM		Prestamo P LEFT JOIN Amortizacion A
ON			P.DocPrestamo = A.DocPrestamo
WHERE		P.FechaVencimiento < SYSDATETIME()
GROUP BY	P.CodPrestatario
HAVING		(SUM(P.Importe) - SUM(ISNULL(A.Importe, 0))) > 0

-- COMUNIDADES CUYOS PRESTATARIOS NO HICIERON ALGUNA MORTIZACION EN EL 2004
SELECT		C.CodComunidad, C.Nombre
FROM		Prestatario Pr INNER JOIN Comunidad C
ON			Pr.CodComunidad = C.CodComunidad
WHERE		CodPrestatario IN (	--PRESTATARIOS CON SALDO
								SELECT S.CodPrestatario
								FROM  #P_SALDOS S

								EXCEPT
								-- SI EFECTUARON AMORTIZACION EN EL 2004	
								SELECT	P.CodPrestatario
								FROM	Prestamo P LEFT JOIN Amortizacion A
								ON		P.DocPrestamo = A.DocCancelacion
								WHERE	YEAR(A.FechaCancelacion) = 2004 
							  )
DROP TABLE #P_SALDOS


/* Relación de comunidades que no tengan prestatarios morosos */

-- PRESTATARIOS MOROSOS
SELECT		P.CodPrestatario, SUM(P.Importe) - SUM(A.Importe) as Saldo
INTO		#MOROSOS
FROM		Prestamo P LEFT JOIN Amortizacion A
ON			P.DocPrestamo = A.DocPrestamo
WHERE		P.FechaVencimiento < SYSDATETIME()
GROUP BY	P.CodPrestatario
HAVING		(SUM(P.Importe) - SUM(A.Importe)) > 0
 
-- COMUNIDADES SIN PRESTATARIOS MOROSOS
SELECT		C.CodComunidad, C.Nombre
FROM		Comunidad C INNER JOIN Prestatario P
ON			C.CodComunidad = P.CodComunidad
WHERE		P.CodPrestatario NOT IN ( 
										SELECT	P.CodPrestatario
										FROM	#MOROSOS
									)
DROP TABLE	#MOROSOS

/* Relación de comunidades con 3 de sus prestatarios más importantes (los prestatarios más importantes son los que han
obtenido mayor número de préstamos). */

-- RANKING DE PRESTATARIOS POR COMUNIDAD
SELECT		A.CodPrestatario, B.Nombres,B.CodComunidad, 
			ROW_NUMBER() OVER(PARTITION BY A.CodPrestatario, B.CodComunidad  ORDER BY COUNT(A.DocPrestamo) DESC) AS Ranking
INTO		#RankPrestatarios
FROM		Prestamo A 
LEFT JOIN	Prestatario B
ON			A.CodPrestatario = B.CodPrestatario
GROUP BY	A.CodPrestatario, B.CodComunidad, B.Nombres

-- TOP 3 PRESTARIOS POR COMUNIDAD
SELECT		C.CodComunidad, C.Nombre AS NombreComunidad, R.CodPrestatario, R.Nombres, R.Ranking
FROM		#RankPrestatarios R INNER JOIN Comunidad C
ON			R.CodComunidad = C.CodComunidad
WHERE		R.Ranking <= 3
DROP TABLE	#RankPrestatarios


/* Relación de prestatarios que en ninguno de sus préstamos hayan incurrido en mora */
--RELACION DE PRESTATARIOS MOROSOS
SELECT		P.CodPrestatario, SUM(P.Importe) - SUM(ISNULL(A.Importe, 0)) as Saldo
INTO		#MOROSOS
FROM		Prestamo P 
LEFT JOIN	Amortizacion A
ON			P.DocPrestamo = A.DocPrestamo
WHERE		P.FechaVencimiento <= SYSDATETIME()
GROUP BY	P.CodPrestatario
HAVING		SUM(P.Importe) - SUM(ISNULL(A.Importe, 0)) > 0

-- RELACION DE PRESTATARIOS SIN MORA
SELECT		CodPrestatario, Nombres
FROM		Prestatario
WHERE		CodPrestatario NOT IN	(
									SELECT	CodPrestatario
									FROM	#MOROSOS
									)
DROP TABLE #MOROSOS

/* Relación de prestatarios que en todas las veces que solicitó un préstamo, sólo una vez incurrió en mora. */
-- SALDOS POR PRESTATARIO Y PRESTAMO
SELECT		P.CodPrestatario, P.DocPrestamo, SUM(P.Importe) - SUM(ISNULL(A.Importe, 0)) as Saldo
INTO		#Morosos
FROM		Prestamo P LEFT JOIN Amortizacion A
ON			P.DocPrestamo = A.DocPrestamo
WHERE		P.FechaVencimiento <= SYSDATETIME()
GROUP BY	P.CodPrestatario, P.DocPrestamo
HAVING		SUM(P.Importe) - SUM(ISNULL(A.Importe, 0)) > 0

-- PRESTATARIOS CON MAXIMO UNA MORA
SELECT		M.CodPrestatario, COUNT(DocPrestamo) NroAtrazos
FROM		#Morosos M
GROUP BY	M.CodPrestatario
HAVING		COUNT(DocPrestamo) <= 1
DROP TABLE	#Morosos

/* Relación de prestatarios que hayan cancelado sus préstamos sin pagos parciales. */
-- REALACION DE PRESTATARIOS SIN DEUDAS
SELECT		P.CodPrestatario, A.DocCancelacion, SUM(P.Importe) - SUM(ISNULL(A.Importe, 0)) as Saldo
INTO		#PrestatariosSinDeudas
FROM		Prestamo P 
LEFT JOIN	Amortizacion A
ON			P.DocPrestamo = A.DocPrestamo
GROUP BY	P.CodPrestatario, A.DocCancelacion
HAVING		SUM(P.Importe) - SUM(ISNULL(A.Importe, 0)) = 0

-- PRESTATARIOS QUE CANCELARON SIN PAGOS PARCIALES
SELECT		CodPrestatario, COUNT(P.DocCancelacion) as NroPagos
FROM		#PrestatariosSinDeudas P
GROUP BY	CodPrestatario
HAVING		COUNT(P.DocCancelacion) <= 1
DROP TABLE	#PrestatariosSinDeudas

/* Relación de los oficiales de crédito estrella de cada mes del año 2003. (Se considera oficial de crédito “estrella” del
mes, al oficial de crédito que haya colocado el mayor número de préstamos en el mes) */
SELECT		P.CodOficial, MONTH(P.FechaPrestamo),
			ROW_NUMBER() OVER(PARTITION BY MONTH(P.FechaPrestamo) ORDER BY COUNT(DocPrestamo) DESC ) AS RankingOficial
FROM		Prestamo P
WHERE		YEAR(P.FechaPrestamo) = 2008
GROUP BY	P.CodOficial



