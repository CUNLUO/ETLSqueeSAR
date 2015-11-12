CREATE
OR REPLACE FUNCTION fn_refresh_mv_cortes_squeesar_fecha () RETURNS VOID AS $$

DECLARE
tabla RECORD;

BEGIN
	FOR tabla IN SELECT
		t1.need_refresh
	FROM
		"cortes_transversales"."registro_refresh_mat_view" t1
	WHERE
		t1.mat_view = 'mv_cortes_squeesar_fecha'
	LIMIT 1 

	LOOP
		IF (tabla.need_refresh = 'si') THEN
			UPDATE "cortes_transversales"."registro_refresh_mat_view"
			SET need_refresh = 'actualizando'
			WHERE
			mat_view = 'mv_cortes_squeesar_fecha' ;
		
			REFRESH MATERIALIZED VIEW cortes_transversales.mv_cortes_squeesar_fecha;

		END IF ;
	END LOOP ;

END ; 
$$ LANGUAGE plpgsql