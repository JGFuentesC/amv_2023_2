SELECT
DATE_TRUNC(FECHA,month) AS fecha,
COUNT(*) AS casos
FROM
aire.contaminantes
GROUP BY
1
ORDER BY
1;
SELECT
ESTACION,
COUNT(*) casos
FROM
`bigdatita-366901.aire.contaminantes`
GROUP BY
1
ORDER BY
2 DESC ;
SELECT
*
FROM
`bigdatita-366901.aire.contaminantes`
WHERE
ESTACION ='MER'
AND CAST(FECHA AS date) BETWEEN '2014-01-23'
AND '2014-01-24'
ORDER BY
estacion,
contaminante,
fecha,
hora ;

CREATE OR REPLACE TABLE aire.agg partition by date_trunc(fecha,month)
AS
WITH
base AS (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora) AS rn
FROM
`bigdatita-366901.aire.contaminantes`)
SELECT
*,
AVG(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 5 PRECEDING AND 0 FOLLOWING) X_media_6,
AVG(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 11 PRECEDING AND 0 FOLLOWING) X_media_12,
AVG(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 17 PRECEDING AND 0 FOLLOWING) X_media_18,
AVG(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING) X_media_24,
MIN(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 5 PRECEDING AND 0 FOLLOWING) X_minimo_6,
MIN(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 11 PRECEDING AND 0 FOLLOWING) X_minimo_12,
MIN(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 17 PRECEDING AND 0 FOLLOWING) X_minimo_18,
MIN(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING) X_minimo_24,
MAX(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 5 PRECEDING AND 0 FOLLOWING) X_maximo_6,
MAX(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 11 PRECEDING AND 0 FOLLOWING) X_maximo_12,
MAX(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 17 PRECEDING AND 0 FOLLOWING) X_maximo_18,
MAX(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING) X_maximo_24,
STDDEV(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 5 PRECEDING AND 0 FOLLOWING) X_desv_6,
STDDEV(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 11 PRECEDING AND 0 FOLLOWING) X_desv_12,
STDDEV(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 17 PRECEDING AND 0 FOLLOWING) X_desv_18,
STDDEV(valor) OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING) X_desv_24,
FROM
base;


CREATE OR REPLACE TABLE aire.X partition by date_trunc(fecha,month) as
WITH
base AS (
SELECT
fecha,
hora,
estacion,
contaminante,
X_media_6,
X_media_12,
X_media_18,
X_media_24,
X_minimo_6,
X_minimo_12,
X_minimo_18,
X_minimo_24,
X_maximo_6,
X_maximo_12,
X_maximo_18,
X_maximo_24,
X_desv_6,
X_desv_12,
X_desv_18,
X_desv_24
FROM
aire.agg
WHERE
rn>=24 )
SELECT
*
FROM
base PIVOT(SUM(X_media_6) X_media_6,
SUM(X_media_12) X_media_12,
SUM(X_media_18) X_media_18,
SUM(X_media_24) X_media_24,
SUM(X_minimo_6) X_minimo_6,
SUM(X_minimo_12) X_minimo_12,
SUM(X_minimo_18) X_minimo_18,
SUM(X_minimo_24) X_minimo_24,
SUM(X_maximo_6) X_maximo_6,
SUM(X_maximo_12) X_maximo_12,
SUM(X_maximo_18) X_maximo_18,
SUM(X_maximo_24) X_maximo_24,
SUM(X_desv_6) X_desv_6,
SUM(X_desv_12) X_desv_12,
SUM(X_desv_18) X_desv_18,
SUM(X_desv_24) X_desv_24 FOR contaminante IN( 'CO',
'NO',
'NO2',
'NOX',
'O3',
'PM10',
'PM25',
'PMCO',
'SO2'));

CREATE OR REPLACE TABLE
aire.Y
PARTITION BY
DATE_TRUNC(fecha,month) AS
WITH
base AS (
SELECT
*,
ROW_NUMBER() OVER (PARTITION BY estacion, contaminante ORDER BY fecha, hora) AS rn
FROM
`bigdatita-366901.aire.contaminantes`
WHERE
contaminante = 'O3')
SELECT
fecha,
hora,
estacion,
rn,
SUM(valor) OVER (PARTITION BY estacion ORDER BY fecha, hora ROWS BETWEEN 6 FOLLOWING AND 6 FOLLOWING) target_o3_6,
FROM
base ;
CREATE OR REPLACE TABLE
aire.tad AS
SELECT
* EXCEPT(rn)
FROM
aire.X
INNER JOIN
aire.Y
USING
(fecha,
hora,
estacion);