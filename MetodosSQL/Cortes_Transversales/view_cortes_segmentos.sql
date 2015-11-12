DROP VIEW
IF EXISTS "cortes_transversales"."v_cortes_segmentos" CASCADE;

CREATE
OR REPLACE VIEW "cortes_transversales"."v_cortes_segmentos" AS (
	 SELECT
	t1.id_cortes_segmentos AS id_cortes_segmentos,
	t1.id_corte,
	st_setsrid (
		st_makepolygon (
			st_geomfromtext (
				(
					(
						(
							(
								(
									(
										(
											(
												(
													(
														(
															(
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
																	) || ',' :: TEXT
																) || t1.x_2
															) || ' ' :: TEXT
														) || t1.y_2
													) || ', ' :: TEXT
												) || t1.x_3
											) || ' ' :: TEXT
										) || t1.y_3
									) || ', ' :: TEXT
								) || t1.x_4
							) || ' ' :: TEXT
						) || t1.y_4
					) || ')' :: TEXT
				),
				4326
			)
		),
		4326
	) AS geom_segmento,
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
												(
													(
														(
															(
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
																	) || ',' :: TEXT
																) || t1.x_2
															) || ' ' :: TEXT
														) || t1.y_2
													) || ', ' :: TEXT
												) || t1.x_3
											) || ' ' :: TEXT
										) || t1.y_3
									) || ', ' :: TEXT
								) || t1.x_4
							) || ' ' :: TEXT
						) || t1.y_4
					) || ')' :: TEXT
				),
				4326
			)
		),
		4326
	) AS geom_centroide
FROM
	cortes_transversales.cortes_segmentos t1
);