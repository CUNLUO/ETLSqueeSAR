-- F|unction: poligonos.intersecta_poligono_squeesar
-- DROP FUNCTION poligonos.intersecta_poligono_squeesar();

CREATE OR REPLACE FUNCTION poligonos.intersecta_poligono_squeesar()
 RETURNS trigger AS
	$BODY$

DECLARE 
	sQuery$			varchar(2000);
	sNombreTabla$	varchar(255);
	
	
	/* Variables LOCALES */
	nIdPoligono$	INTEGER;
	/*variables lectura Cursor cur_Interseccion*/
	cur_Interseccion 		RECORD;	
	sResult$		varchar(200);
	
BEGIN
	nIdPoligono$ := new.id;
	sQuery$ := '';
	sNombreTabla$ := '';
	
	SELECT DISTINCT
		nombre_tabla_consolidada
	INTO
		sNombreTabla$
	FROM
		squeesar.registro_squeesar
	WHERE
		vigencia = 'S';
		
	IF NEW.geom <> OLD.geom THEN 	
		DELETE FROM 
			poligonos.poligono_squeesar
		WHERE
			id_poligono = nIdPoligono$;
			
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
						AND ST_isvalid (poligonos.poligono.geom) = ''t''
						AND poligonos.id = ' || nIdPoligono$;
						
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
			
		SELECT 
			*
		INTO
			sResult$
		FROM 
			squeesar.agrupar_squeesar(nIdPoligono$);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION poligonos.intersecta_poligono_squeesar()
  OWNER TO postgres;
 