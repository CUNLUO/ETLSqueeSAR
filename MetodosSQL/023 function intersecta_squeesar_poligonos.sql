-- Function: squeesar.intersecta_squeesar_poligonos()

-- DROP FUNCTION squeesar.intersecta_squeesar_poligonos();

CREATE OR REPLACE FUNCTION squeesar.intersecta_squeesar_poligonos(integer)
  RETURNS integer AS
$BODY$

DECLARE

	/*--------------------------------- */
	nNumSqueesar$ alias for $1; 
	cur_Interseccion	RECORD;
	cur_fecha		RECORD;
	cur_valores		RECORD;
	sQuery$			varchar(2000);
	sNombreTabla$	varchar(255);

	
BEGIN
	sQuery$ := '';
	sNombreTabla$ := '';
	
	SELECT DISTINCT
		nombre_tabla_consolidada
	INTO
		sNombreTabla$
	FROM
		squeesar.registro_squeesar
	WHERE
		squeesar = nNumSqueesar$;
		
		
	TRUNCATE poligonos.poligono_squeesar;
		
	sQuery$ := 'SELECT DISTINCT
					id_squeesar_consolidado as squeesar,
					id as poligono	
				FROM
					squeesar.' || sNombreTabla$ || '
				INNER JOIN poligonos.poligono ON ST_Intersects (
					squeesar.' || sNombreTabla$ || '.geom,
					poligonos.poligono.geom
					)
				WHERE
					ST_isvalid (squeesar.' || sNombreTabla$ || '.geom) = ''t''
					AND ST_isvalid (poligonos.poligono.geom) = ''t''';
					
					--Raise notice 'sQuery$ %',sQuery$;
					
	FOR cur_Interseccion IN
		EXECUTE sQuery$
	LOOP

		INSERT INTO
			poligonos.poligono_squeesar
			(
				id_squeesar_consolidado,
				id_poligono
			)
			VALUES
			(
				cur_Interseccion.squeesar,
				cur_Interseccion.poligono
			);
			
	END LOOP;

				
 RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.intersecta_squeesar_poligonos(integer)
  OWNER TO postgres;
