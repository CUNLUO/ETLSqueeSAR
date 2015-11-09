-- Function: squeesar.procesar_squeesar()

-- DROP FUNCTION squeesar.procesar_squeesar();

CREATE OR REPLACE FUNCTION squeesar.procesar_squeesar()
  RETURNS integer AS
$BODY$

DECLARE

	/*--------------------------------- */
	sQuery$							VARCHAR(200);
	cur_Tablas 					RECORD;

	nIdRegistro$	integer;
	sNombreTabla$ 			VARCHAR(200);
	nNumSqueesar$	integer;	
	nNumSqueesarAnterior$	integer;	
	sDireccion$		varchar(20);
	nCorrelativo$	integer;
	nCorrelativoAnterior$	integer;
	sQueryCreate$							VARCHAR(2000);
	nIdDetalle$	bigint;
	nNumError$	integer;
	sNombreNuevaTabla$	varchar(200);
	sNombreNuevaTablaFecha$	varchar(200);
	sIndVigencia$	varchar(1);
	nNumSqueesarVigente$	integer;
	
BEGIN

	nNumSqueesarVigente$ := 0;
	
	SELECT DISTINCT
		squeesar
	INTO
		nNumSqueesarVigente$
	FROM
		squeesar.registro_squeesar
	WHERE
		vigencia = 'S';
		
	nNumSqueesarAnterior$ := 0;
	
--Raise notice 'sFecha$ %',sFecha$;
	FOR cur_Tablas in
		SELECT	
			id_registro_squeesar,
			nombre_tabla,
			squeesar,
			direccion,
			correlativo_parte
		FROM 
			squeesar.registro_squeesar 
		WHERE 
			estado in('NUEVO')
		ORDER BY
			squeesar,
			correlativo_parte

	LOOP

		nIdRegistro$ := cur_Tablas.id_registro_squeesar;
		sNombreTabla$ := cur_Tablas.nombre_tabla;
		nNumSqueesar$ := cur_Tablas.squeesar;
		sDireccion$ := cur_Tablas.direccion;
		nCorrelativo$ := cur_Tablas.correlativo_parte;
		sNombreNuevaTabla$ := 'historico_squeesar_' || cast(nNumSqueesar$ as character varying);
		sNombreNuevaTablaFecha$ := 'historico_squeesar_' || cast(nNumSqueesar$ as character varying) || '_fecha';
		
		UPDATE
			squeesar.registro_squeesar 
		SET
			estado = 'PROCESO'
		WHERE
			id_registro_squeesar  = nIdRegistro$;
			
		IF nNumSqueesarAnterior$ <> nNumSqueesar$ THEN
			nIdDetalle$ := 0;
			sQueryCreate$ := 'CREATE TABLE squeesar.' || sNombreNuevaTabla$ || ' (LIKE squeesar.template_squeesar_consolidado 
							INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES)';
			--Raise notice 'creacion Padre %',sQueryCreate$;
			EXECUTE sQueryCreate$;	
			
			sQueryCreate$ := 'CREATE TABLE squeesar.' || sNombreNuevaTablaFecha$ || ' (LIKE squeesar.template_squeesar_consolidado_fecha 
							INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES)';
			--Raise notice 'creacion Hijo %',sQueryCreate$;
			EXECUTE sQueryCreate$;
			
			UPDATE
				squeesar.registro_squeesar 
			SET
				nombre_tabla_consolidada = sNombreNuevaTabla$
			WHERE
				squeesar = nNumSqueesar$;
		ELSE
			nIdDetalle$ := nCorrelativoAnterior$ + 1;
		END IF;

		nCorrelativoAnterior$ := squeesar.preparar_tabla(sNombreTabla$,nIdDetalle$);
		
		nNumError$ := squeesar.procesar_tabla(sNombreTabla$,sNombreNuevaTabla$, sNombreNuevaTablaFecha$,sDireccion$);
					
		nNumSqueesarAnterior$ := nNumSqueesar$;
		
		commit;
		
	END LOOP;
	
	IF nNumSqueesar$ > nNumSqueesarVigente$ THEN
		UPDATE
			squeesar.registro_squeesar 
		SET
			vigencia = 'N'
		WHERE
			vigencia  = 'S';
			
		sIndVigencia$ := 'S';
		
		nNumError$ := squeesar.intersecta_squeesar_poligonos(nNumSqueesar$);	
	ELSE
		sIndVigencia$ := 'N';
	END IF;
	
	UPDATE
		squeesar.registro_squeesar 
	SET
		vigencia = sIndVigencia$,
		estado = 'FINAL'
	WHERE
		squeesar  = nNumSqueesar$;	
		
	
	RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.procesar_squeesar()
  OWNER TO postgres;
