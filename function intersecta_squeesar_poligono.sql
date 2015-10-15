-- Function: squeesar.intersecta_squeesar_poligono()

-- DROP FUNCTION squeesar.intersecta_squeesar_poligono();

CREATE OR REPLACE FUNCTION squeesar.intersecta_squeesar_poligono()
  RETURNS integer AS
$BODY$

DECLARE

	/*--------------------------------- */
	cur_Interseccion	RECORD;
	cur_fecha		RECORD;
	cur_valores		RECORD;

	
BEGIN

	DELETE FROM
		poligonos.poligono_squeesar;
		
		
	FOR cur_Interseccion IN

		SELECT DISTINCT
			id_squeesar_consolidado as squeesar,
			id as poligono	
		FROM
			squeesar.squeesar_consolidado
		INNER JOIN poligonos.poligono ON ST_Intersects (
			squeesar.squeesar_consolidado.geom,
			poligonos.poligono.geom
			)
		WHERE
			ST_isvalid (squeesar.squeesar_consolidado.geom) = 't'
			AND ST_isvalid (poligonos.poligono.geom) = 't'
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
ALTER FUNCTION squeesar.intersecta_squeesar_poligono()
  OWNER TO postgres;
