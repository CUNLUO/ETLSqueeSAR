DROP FUNCTION
IF EXISTS fn_intersecta_squeesar_fecha (
	x_0 FLOAT,
	y_0 FLOAT,
	x_1 FLOAT,
	y_1 FLOAT,
	x_2 FLOAT,
	y_2 FLOAT,
	x_3 FLOAT,
	y_3 FLOAT,
	x_4 FLOAT,
	y_4 FLOAT
);

CREATE FUNCTION fn_intersecta_squeesar_fecha (
	x_0 FLOAT,
	y_0 FLOAT,
	x_1 FLOAT,
	y_1 FLOAT,
	x_2 FLOAT,
	y_2 FLOAT,
	x_3 FLOAT,
	y_3 FLOAT,
	x_4 FLOAT,
	y_4 FLOAT
) RETURNS TABLE (
	new_geom geometry,
	def_mean FLOAT,
	n BIGINT,
	fecha DATE
) AS $$ SELECT
	ST_Transform (
		ST_GeomFromText (
			'POLYGON((' || $2 || ' ' || $1 || ' ,' || $4 || ' ' || $3 || ',' || $6 || ' ' || $5 || ',' || $8 || ' ' || $7 || ',' || $10 || ' ' || $9 || '))',
			4326
		),
		1000
	) AS geom_segmento,
	AVG (t2.deformacion) AS def_mean,
	COUNT (t1.geom) AS n,
	t2.fecha
FROM
	"squeesar"."historico_squeesar_6" AS t1
INNER JOIN squeesar.historico_squeesar_6_fecha AS t2 ON (
	t1.id_squeesar_consolidado = t2.id_squeesar_consolidado
)
WHERE
	ST_Intersects (
		t1.geom,
		ST_Transform (
			ST_GeomFromText (
				'POLYGON((' || $2 || ' ' || $1 || ' ,' || $4 || ' ' || $3 || ',' || $6 || ' ' || $5 || ',' || $8 || ' ' || $7 || ',' || $10 || ' ' || $9 || '))',
				4326
			),
			1000
		)
	)
AND ST_isvalid (t1.geom) = 't'
AND ST_isvalid (
	ST_Transform (
		ST_GeomFromText (
			'POLYGON((' || $2 || ' ' || $1 || ' ,' || $4 || ' ' || $3 || ',' || $6 || ' ' || $5 || ',' || $8 || ' ' || $7 || ',' || $10 || ' ' || $9 || '))',
			4326
		),
		1000
	)
) = 't'
AND t1.x >= st_xmin (
	ST_Transform (
		ST_GeomFromText (
			'POLYGON((' || $2 || ' ' || $1 || ' ,' || $4 || ' ' || $3 || ',' || $6 || ' ' || $5 || ',' || $8 || ' ' || $7 || ',' || $10 || ' ' || $9 || '))',
			4326
		),
		1000
	)
)
AND t1.x <= st_xmax (
	ST_Transform (
		ST_GeomFromText (
			'POLYGON((' || $2 || ' ' || $1 || ' ,' || $4 || ' ' || $3 || ',' || $6 || ' ' || $5 || ',' || $8 || ' ' || $7 || ',' || $10 || ' ' || $9 || '))',
			4326
		),
		1000
	)
)
AND t1.y >= st_ymin (
	ST_Transform (
		ST_GeomFromText (
			'POLYGON((' || $2 || ' ' || $1 || ' ,' || $4 || ' ' || $3 || ',' || $6 || ' ' || $5 || ',' || $8 || ' ' || $7 || ',' || $10 || ' ' || $9 || '))',
			4326
		),
		1000
	)
)
AND t1.y <= st_ymax (
	ST_Transform (
		ST_GeomFromText (
			'POLYGON((' || $2 || ' ' || $1 || ' ,' || $4 || ' ' || $3 || ',' || $6 || ' ' || $5 || ',' || $8 || ' ' || $7 || ',' || $10 || ' ' || $9 || '))',
			4326
		),
		1000
	)
)
GROUP BY
	ST_Transform (
		ST_GeomFromText (
			'POLYGON((' || $2 || ' ' || $1 || ' ,' || $4 || ' ' || $3 || ',' || $6 || ' ' || $5 || ',' || $8 || ' ' || $7 || ',' || $10 || ' ' || $9 || '))',
			4326
		),
		1000
	),
	t2.fecha $$ LANGUAGE SQL;