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
	sQueryCount$							VARCHAR(2000);
	nIdDetalle$	bigint;
	nNumError$	integer;
	sNombreNuevaTabla$	varchar(200);
	sNombreNuevaTablaFecha$	varchar(200);
	sIndVigencia$	varchar(1);
	sIndDatos$		varchar(1);
	nNumSqueesarVigente$	integer;
	
BEGIN

	nNumSqueesarVigente$ := 0;
	nNumSqueesar$ := 0;
	sIndDatos$ := 'N';
	nNumSqueesarAnterior$ := 0;
	
--Raise notice 'sFecha$ %',sFecha$;
	----------------------------------------------------------------------------------
	-- SELECCIONA TODAS LOS NUEVOS REGISTROS DE TABLAS A PROCESAR (PARTES DE SQUEESAR)
	----------------------------------------------------------------------------------
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
		sIndDatos$ := 'S';
		
		
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

		----------------------------------------------------------------------------------
		-- VERIFICA SI ES OTRA PARTE DEL MISMO SQUEESAR, O ES OTRO SQUEESAR
		----------------------------------------------------------------------------------	
		IF nNumSqueesarAnterior$ <> nNumSqueesar$ THEN
			nIdDetalle$ := 0;
			sQueryCount$ := 'Select
				coalesce(max(id_squeesar_consolidado),0)
			FROM
				squeesar.' || sNombreNuevaTabla$;
				
			BEGIN	
				EXECUTE sQueryCount$ into nIdDetalle$;	
			EXCEPTION
				WHEN SQLSTATE '42P01' THEN
					Raise notice 'ERROR: TABLA NO EXISTE';
					---------------------------------------------------------------
					--SI EL SQUEESAR NO EXISTE, SE CREA LA NUEVA TABLA CONSOLIDADA
					---------------------------------------------------------------
					sQueryCreate$ := 'CREATE TABLE squeesar.' || sNombreNuevaTabla$ || ' (LIKE squeesar.template_squeesar_consolidado 
									INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES)';
					--Raise notice 'creacion Padre %',sQueryCreate$;
					EXECUTE sQueryCreate$;	
					
					sQueryCreate$ := 'CREATE TABLE squeesar.' || sNombreNuevaTablaFecha$ || ' (LIKE squeesar.template_squeesar_consolidado_fecha 
									INCLUDING DEFAULTS INCLUDING CONSTRAINTS INCLUDING INDEXES)';
					--Raise notice 'creacion Hijo %',sQueryCreate$;
					EXECUTE sQueryCreate$;
			END;
			
			UPDATE
				squeesar.registro_squeesar 
			SET
				nombre_tabla_consolidada = sNombreNuevaTabla$
			WHERE
				squeesar = nNumSqueesar$;
		ELSE
			nIdDetalle$ := nCorrelativoAnterior$;
		END IF;

		------------------------------------------------------------------------------------------------------
		-- SE PREPARA LA TABLA CORRESPONDIENTE A LA PARTE DEL SQUEESAR,AGREGANDO COLUMNA CON CORRELATIVO UNICO 
		------------------------------------------------------------------------------------------------------
		nCorrelativoAnterior$ := squeesar.preparar_tabla(sNombreTabla$,nIdDetalle$);

		---------------------------------------------------------------------
		-- SE PROCESA LA TABLA, CONFORMANDO LAS 2 NUEVAS TABLAS CONSOLIDADAS
		---------------------------------------------------------------------
		nNumError$ := squeesar.procesar_tabla(sNombreTabla$,sNombreNuevaTabla$, sNombreNuevaTablaFecha$,sDireccion$);
					
		nNumSqueesarAnterior$ := nNumSqueesar$;
	
		
	END LOOP;
	

	UPDATE
		squeesar.registro_squeesar 
	SET
		estado = 'FINAL'
	WHERE
		estado = 'PROCESO';	
	---------------------------------------------------------------------------------------------------------------------------------
	-- SI EXISTEN NUEVOS DATOS PROCESADOS, SE LLAMA A FUNCION PARA VALDIAR SI CAMBIA LA VIGENCIA DE LOS SQUEESAR EN TABLA DE REGISTRO
	---------------------------------------------------------------------------------------------------------------------------------				
	IF sIndDatos$ = 'S' THEN

		SELECT 
			indicador_vigencia 
		INTO
			sIndVigencia$
		FROM 
			squeesar.calcular_vigencia_squeesar();
			
	END IF;
	
	RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.procesar_squeesar()
  OWNER TO postgres;
