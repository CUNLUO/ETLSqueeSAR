-- Function: squeesar.preparar_tabla()

-- DROP FUNCTION squeesar.preparar_tabla();

CREATE OR REPLACE FUNCTION squeesar.preparar_tabla(character varying,bigint)
  RETURNS integer AS
$BODY$

DECLARE

	sNombreTabla$ alias for $1;
	nUltimoId$ alias for $2;
	/*--------------------------------- */
	cur_datos	RECORD;
	sQueryUpdate$							VARCHAR(2000);
	sQuerySelect$							VARCHAR(2000);
	sQueryAlter$							VARCHAR(2000);
	sNombreEsquema$	varchar(200);
	
BEGIN
	sNombreEsquema$:= 'squeesar';
	
	sQueryAlter$ := 'alter table ' || sNombreEsquema$ || '.' || sNombreTabla$ || ' add id_squeesar_consolidado bigint';
	EXECUTE sQueryAlter$;
	
	sQuerySelect$ := 'SELECT gid 
		FROM ' || sNombreEsquema$ || '.' || sNombreTabla$;

	FOR cur_datos IN
		EXECUTE sQuerySelect$
	LOOP
		nUltimoId$ := nUltimoId$ + 1;		
		sQueryUpdate$:= '';
		sQueryUpdate$ := 'Update '|| sNombreEsquema$ || '.' || sNombreTabla$ || ' set id_squeesar_consolidado = '|| nUltimoId$ || ' where gid = ' || cur_datos.gid;
		EXECUTE sQueryUpdate$;

	END LOOP;

				
 RETURN nUltimoId$;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.preparar_tabla(character varying,bigint)
  OWNER TO postgres;
