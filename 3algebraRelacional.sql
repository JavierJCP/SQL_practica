use Control_Academico;
go

select * from Alumno
where Cod_CP = 'IN';


select * from Alumno
where Cod_CP = 'IN'
union
select * from Alumno
where Cod_CP = 'IL';

select distinct Cod_Asignatura, Cod_CP from Catalogo
where Semestre = '2007-II'
Except
select distinct Cod_Asignatura, Cod_CP from Catalogo
where Semestre = '2008-I';


select distinct Cod_Asignatura, Cod_CP from Catalogo
where Cod_CP= 'IN' and Semestre = '2007-II'
intersect
select distinct Cod_Asignatura, Cod_CP from Catalogo
where Cod_CP= 'IN' and Semestre = '2008-I';


select Cod_Alumno, Paterno, Materno, Nombres, Nombre_CP from Alumno A, Carrera_Profesional C
where A.Cod_CP = C.Cod_CP

select Cod_Alumno, Paterno, Materno, Nombres, Nombre_CP 
from Alumno A inner join Carrera_Profesional C
on a.Cod_CP = c.Cod_CP


select Cod_CP, count(Cod_Alumno) as NroAlumnos 
from Alumno
group by Cod_CP

/*Determinar el número de asignaturas en los que se matricularon los alumnos de Ingeniería Informática en
el semestre ‘2008-I’*/

select Cod_Alumno, count(Cod_Asignatura) as NroAsignaturas from Matricula
where Cod_CP = 'IN' and Semestre = '2008-I'
group by Cod_Alumno

/*Número de alumnos matriculados por semestre y por Carrera Profesional.*/
select		Semestre, Cod_CP, count(Cod_Alumno) as NroAlumnos 
from		Matricula
group by	Semestre,Cod_CP

/*Relación de alumnos con su respectivo número de créditos acumulados*/
--Deternimar los alumnos aprobados
select Cod_Alumno, Creditos, Nota
into T#2
from Matricula M inner join Asignatura A
on M.Cod_Asignatura = A.Cod_Asignatura
where (Case When Nota = 'NSP' then 0 else CAST(Nota as Int) end) > 10
--sumar los creditos por alumnos
select Cod_Alumno, count(Creditos) as CreditosAcumulados
from T#2
group by (Cod_Alumno)
order by CreditosAcumulados desc
drop table T#2

/*Relación de alumnos que hayan aprobado todas sus asignaturas en el último semestre*/
-- alumnos aprobados en el ultimo semestre
select distinct  Cod_Alumno
from Matricula 
where Semestre = '2008-I'
and (Case When Nota = 'NSP' then 0 else CAST(Nota as Int) end) > 10


/*Relación de alumnos con su respectivo promedio aritmético en cada semestre*/
select Cod_Alumno, Semestre, AVG(CASE when Nota = 'NSP' then 0 else CAST(Nota as Int) end) as Promedio
from Matricula
group by Cod_Alumno, Semestre

/*Relación de docentes con el número de asignaturas dictadas en cada semestre.*/
select Cod_Docente, Semestre, count(Cod_Asignatura) as NroAsignaturas
into T#4
from Catalogo 
group by Cod_Docente, Semestre
select Nombres, Paterno, Materno, Semestre, NroAsignaturas
from T#4 A inner join Docente D
on a.Cod_Docente = d.Cod_Docente
drop table T#4
