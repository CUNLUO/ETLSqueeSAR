DROP MATERIALIZED VIEW
IF EXISTS cortes_transversales.mv_cortes_squeesar_fecha;

CREATE MATERIALIZED VIEW cortes_transversales.mv_cortes_squeesar_fecha AS (
SELECT
	t1.id_cortes_segmentos,
	t1.id_corte,
	t2.geom_segmento,
	t2.distancia,
	(fn_intersecta_squeesar_fecha (t1.x_0, t1.y_0, t1.x_1, t1.y_1, t1.x_2, t1.y_2, t1.x_3, t1.y_3, t1.x_0, t1.y_0 )).*
	FROM
		cortes_transversales.cortes_segmentos t1
	INNER JOIN (
		SELECT
			a1.id_cortes_segmentos,
			a1.id_corte,
			a1.geom_segmento,
			st_distance ((a1.geom_centroide :: geography), (a2.geom_inicio :: geography)) AS distancia
		FROM
			cortes_transversales.v_cortes_segmentos a1
		INNER JOIN
			cortes_transversales.v_cortes_inicio a2
		ON 
			(a1.id_corte = a2.id_corte)
		ORDER BY
			a1.id_cortes_segmentos
	) t2
	ON 
		(t1.id_cortes_segmentos = t2.id_cortes_segmentos)
	WHERE
		t1.id_corte IS NOT NULL
	ORDER BY
		t1.id_corte,
		fecha,
		t2.distancia
) WITH DATA;