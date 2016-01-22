-- Function: poligonos.actualiza_poligono_trg
-- DROP FUNCTION poligonos.actualiza_poligono_trg();

CREATE OR REPLACE FUNCTION poligonos.actualiza_poligono_trg()
 RETURNS trigger AS
$BODY$

DECLARE
	/* Variables LOCALES */
	nIdPoligono$	INTEGER;
	nCantidad$		INTEGER;
	sResult$		varchar(200);
	
BEGIN
	nIdPoligono$ := new.id;

	SELECT
		COUNT(*)
	INTO
		nCantidad$
	FROM
		poligonos.poligono
	WHERE
		id = nIdPoligono$
		AND ST_isvalid (poligonos.poligono.geom) = 't';
			
	IF	nCantidad$ > 0 THEN
		-------------------------------------------------------------------
		-- PRISMAS
		SELECT 
			*
		INTO
			sResult$
		FROM 
			poligonos.intersecta_poligono_prisma(nIdPoligono$);
			
		SELECT 
			*
		INTO
			sResult$
		FROM 
			prismas.verificar_alarmas();	
			
		-------------------------------------------------------------------
		-- SQUEESAR
		SELECT 
			*
		INTO
			sResult$
		FROM 
			poligonos.intersecta_poligono_squeesar(nIdPoligono$);
			
		SELECT 
			*
		INTO
			sResult$
		FROM 
			squeesar.agrupar_squeesar_poligono(nIdPoligono$);			
	END IF;
	
	RETURN new;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION poligonos.actualiza_poligono_trg()
  OWNER TO postgres;
 