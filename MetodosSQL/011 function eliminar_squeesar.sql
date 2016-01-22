-- Function: select * from squeesar.eliminar_squeesar()

-- DROP FUNCTION squeesar.eliminar_squeesar();

CREATE OR REPLACE FUNCTION squeesar.eliminar_squeesar()
  RETURNS integer AS
$BODY$

DECLARE


	/*--------------------------------- */
	sQuery$							VARCHAR(2000);
	cur_Tablas 					RECORD;
	--cur_ContenidoTabla	RECORD;
	sNombreTabla$ 			VARCHAR(200);
	sNombreTablaConsolidada$ 			VARCHAR(200);
	nNumSqueesar$	integer;
	nCantidad$	integer;
	--nNumSqueesarAnterior$	integer;	
	--sDireccion$	varchar(20);
	--sParte$			varchar(20);	
	nCorrelativo$	integer;
	--sTmp1$ varchar(255);
	sEstadoActual$	varchar(20);
	sEstadoNuevo$	varchar(20);
	--nNumError$	integer;

BEGIN
		--nNumSqueesarAnterior$ := 0;
		--Raise notice 'sFecha$ %',sFecha$;

		-----------------------------------------------------------------------------------------------------------
		-- Eliminacion de tablas consolidadas completas a reprocesar o pendiente de eliminacion (todo un squeesar)
		-----------------------------------------------------------------------------------------------------------
		FOR cur_Tablas in
			SELECT
				nombre_tabla_consolidada,
				squeesar,
				COUNT(*) AS cant_repro
			FROM 
				squeesar.registro_squeesar
			WHERE 
				estado IN ('REPRO','PENDI_ELIM')
			GROUP BY 
				nombre_tabla_consolidada,
				squeesar

		LOOP
			sEstadoNuevo$ :=NULL;
			sNombreTablaConsolidada$ := cur_Tablas.nombre_tabla_consolidada;
			nNumSqueesar$ := cur_Tablas.squeesar;
			
			SELECT
				COUNT(*)
			INTO
				nCantidad$
			FROM
				squeesar.registro_squeesar
			WHERE
				squeesar = nNumSqueesar$;
				
			IF nCantidad$  = cur_Tablas.cant_repro THEN
				IF sNombreTablaConsolidada$ IS NOT NULL THEN
					sQuery$ := 'DROP TABLE squeesar.' || sNombreTablaConsolidada$;
					EXECUTE sQuery$;
					sQuery$ := 'DROP TABLE squeesar.' || sNombreTablaConsolidada$ ||'_fecha';
					EXECUTE sQuery$;
				END IF;

				SELECT
					estado
				INTO
					sEstadoActual$
				FROM 
					squeesar.registro_squeesar
				WHERE 
					squeesar = nNumSqueesar$;

				IF sEstadoActual$ = 'REPRO' THEN
					sEstadoNuevo$ := 'NUEVO';
				END IF;

				IF sEstadoActual$ = 'PENDI_ELIM' THEN
					sEstadoNuevo$ := 'ELIMI';
				END IF;

					
				UPDATE
					squeesar.registro_squeesar
				SET
					nombre_tabla_consolidada = NULL,
					estado = sEstadoNuevo$,
					fecha_estado = NOW(),
					vigencia = 'N'
				WHERE
					squeesar = nNumSqueesar$;
			END IF;
		END LOOP;

		-------------------------------------------------------------------------------
		-- Eliminacion de sólo partes de un squeesar a reprocesar
		-------------------------------------------------------------------------------		
		FOR cur_Tablas in
			SELECT
				nombre_tabla_consolidada,
				nombre_tabla,
				squeesar,
				correlativo_parte,
				estado
			FROM 
				squeesar.registro_squeesar
			WHERE 
				estado in('REPRO','PENDI_ELIM')	
				
		LOOP
			sNombreTablaConsolidada$ := cur_Tablas.nombre_tabla_consolidada;
			sNombreTabla$ := cur_Tablas.nombre_tabla;
			nNumSqueesar$ := cur_Tablas.squeesar;
			nCorrelativo$ := cur_Tablas.correlativo_parte;
			sEstadoActual$ := cur_Tablas.estado;
			sEstadoNuevo$ :=NULL;

			IF sEstadoActual$ = 'REPRO' THEN
				sEstadoNuevo$ := 'NUEVO';
			END IF;

			IF sEstadoActual$ = 'PENDI_ELIM' THEN
				sEstadoNuevo$ := 'ELIMI';
			END IF;

			IF sNombreTablaConsolidada$ IS NOT NULL THEN	
				sQuery$ := 'DELETE FROM squeesar.' || sNombreTablaConsolidada$ ||'_fecha 
				WHERE ' || sNombreTablaConsolidada$ ||'_fecha.id_squeesar_consolidado IN (
					SELECT ' || sNombreTablaConsolidada$ ||'.id_squeesar_consolidado 
					FROM squeesar.' || sNombreTablaConsolidada$ ||' 
					WHERE ' || sNombreTablaConsolidada$ ||'.nombre_tabla = ''' || sNombreTabla$ || ''')';
				EXECUTE sQuery$;
				
				sQuery$ := 'DELETE FROM squeesar.' || sNombreTablaConsolidada$ ||' 
				WHERE ' || sNombreTablaConsolidada$ ||'.nombre_tabla = ''' || sNombreTabla$ || '''';
				EXECUTE sQuery$;
			END IF;
			
			UPDATE
				squeesar.registro_squeesar
			SET
				nombre_tabla_consolidada = NULL,
				estado = sEstadoNuevo$,
				fecha_estado = NOW(),
				vigencia = 'N'
			WHERE
				nombre_tabla = sNombreTabla$ 
				AND correlativo_parte = nCorrelativo$;
			
		END LOOP;
		
		-------------------------------------------------------------------------------
		-- Eliminacion de tablas subidas y no reprocesadas
		-------------------------------------------------------------------------------			
		FOR cur_Tablas in
			SELECT
				tables.table_name
			FROM 
				information_schema.tables
			WHERE 
				tables.table_schema::text = 'squeesar'::text 
				AND tables.table_type::text = 'BASE TABLE'::text
				AND lower(tables.table_name) LIKE 'squeesar%' 
				AND tables.table_name in( select nombre_tabla from squeesar.registro_squeesar where estado in ('FINAL','ELIMI'))	
			ORDER BY 
				tables.table_name ASC

		LOOP
		
			sQuery$ := 'DROP TABLE squeesar.' || cur_Tablas.table_name;
			EXECUTE sQuery$;
				
		END LOOP;		

 RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.eliminar_squeesar()
  OWNER TO postgres;
