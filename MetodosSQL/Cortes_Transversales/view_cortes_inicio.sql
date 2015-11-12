DROP VIEW
IF EXISTS "cortes_transversales"."v_cortes_inicio" CASCADE;

CREATE VIEW "cortes_transversales"."v_cortes_inicio" AS (
SELECT DISTINCT
	ON (t1.id_corte) t1.id_corte,
	st_setsrid (
		st_centroid (
			st_geomfromtext (
				(
					(
						(
							(
								(
									(
										(
											(
												'LINESTRING(' :: TEXT || t1.x_0
											) || ' ' :: TEXT
										) || t1.y_0
									) || ',' :: TEXT
								) || t1.x_1
							) || ' ' :: TEXT
						) || t1.y_1
					) || ')' :: TEXT
				),
				4326
			)
		),
		4326
	) AS geom_inicio
FROM
	cortes_transversales.cortes_segmentos t1
ORDER BY
	t1.id_corte,
	t1.id_cortes_segmentos
);