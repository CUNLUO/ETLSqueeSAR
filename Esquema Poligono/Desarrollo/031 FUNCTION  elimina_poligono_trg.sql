-- Function: poligonos.elimina_poligono_trg
-- DROP FUNCTION poligonos.elimina_poligono_trg();

CREATE OR REPLACE FUNCTION poligonos.elimina_poligono_trg()
 RETURNS trigger AS
$BODY$

DECLARE
	/* Variables LOCALES */
	nIdPoligono$	INTEGER;
	nCantidad$		INTEGER;
	sResult$		varchar(200);
	
BEGIN
	nIdPoligono$ := old.id;
	-------------------------------------------------------------------
	-- POINTS
	DELETE FROM 
		poligonos.points
	WHERE
		poligono_id = nIdPoligono$;
	-------------------------------------------------------------------
	-- PRISMAS
	DELETE FROM 
		poligonos.poligono_prisma
	WHERE
		id_poligono = nIdPoligono$;
		
	DELETE FROM 
		prismas.poligono_alarma	
	WHERE
		id_poligono = nIdPoligono$;		
					
	-------------------------------------------------------------------
	-- SQUEESAR
	DELETE FROM 
		poligonos.poligono_squeesar
	WHERE
		id_poligono = nIdPoligono$;
			
	DELETE FROM	
		squeesar.poligono_fecha
	WHERE
		id_poligono = nIdPoligono$;
		
	DELETE FROM 
		squeesar.poligono_resumen
	WHERE
		id_poligono = nIdPoligono$;			
	
	RETURN old;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION poligonos.elimina_poligono_trg()
  OWNER TO postgres;
 