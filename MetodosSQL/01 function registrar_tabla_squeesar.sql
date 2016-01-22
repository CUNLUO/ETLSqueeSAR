-- Function: select * from squeesar.registrar_tabla_squeesar()

-- DROP FUNCTION squeesar.registrar_tabla_squeesar();

CREATE OR REPLACE FUNCTION squeesar.registrar_tabla_squeesar(character varying)
  RETURNS integer AS
$BODY$

DECLARE

	
	sIndReproceso$ alias for $1;
	-------------------------------------------------------
	-- posibles valores de sIndReproceso$ (variable de entrada)
	-- N = No se reprocesara; de existir la tabla, la informacion de la tabla a procear, no se considerara, quedando con la data anterior
	-- S = Si se reprocesara: de existir la tabla, la informacion existente se seliminara, y se procesara como una nueva tabla.
	-------------------------------------------------------
	
	/*--------------------------------- */
	sQuery$							VARCHAR(200);
	cur_Tablas 					RECORD;
	cur_ContenidoTabla	RECORD;
	sQueryCount$		VARCHAR(2000);
	nCantidadReg$		bigint;
	sNombreTabla$ 			VARCHAR(200);
	nNumSqueesar$	integer;
	nNumSqueesarAnterior$	integer;	
	sDireccion$	varchar(20);
	sParte$			varchar(20);	
	nCorrelativo$	integer;
	sTmp1$ varchar(255);
	sEstado$	varchar(20);
	sEstadoAnterior$	varchar(20);
	nNumError$	integer;
	sSeparador$	varchar(1);

BEGIN
		nNumSqueesarAnterior$ := 0;
--Raise notice 'sFecha$ %',sFecha$;
		FOR cur_Tablas in
			SELECT
				tables.table_name
			FROM 
				information_schema.tables
			WHERE 
				tables.table_schema::text = 'squeesar'::text 
				AND tables.table_type::text = 'BASE TABLE'::text
				AND lower(tables.table_name) LIKE 'squeesar%' 
				AND (
					tables.table_name not in( select nombre_tabla from squeesar.registro_squeesar)
					or sIndReproceso$ = 'S'
					)
				
			ORDER BY 
				tables.table_name ASC

		LOOP
			sEstado$ := NULL;
			sNombreTabla$ := cur_Tablas.table_name;
			Raise notice '1 sNombreTabla$ %',sNombreTabla$;
			BEGIN
				sTmp1$ := trim(LEADING 'squeesar' from lower( sNombreTabla$));
				Raise notice '2.0 sTmp1$ %',sTmp1$;
				sSeparador$ := substr(sTmp1$,1,1);
				Raise notice '2.1 sSeparador$ %',sSeparador$;
				IF sSeparador$ <> '_' THEN
					nNumSqueesar$ := 0;
					sDireccion$ := NULL;
					sParte$ := NULL;
					sEstado$ := 'ERR_FORMAT';
				ELSE				
					Raise notice '2.2 sTmp1$ %',sTmp1$;
					sTmp1$ := substr(sTmp1$,2);
					Raise notice '2.3 sTmp1$ %',sTmp1$;
					nNumSqueesar$ := cast(substr(sTmp1$,1,strpos(sTmp1$,'_')-1) as integer);
					Raise notice '3 nNumSqueesar$ %',nNumSqueesar$;
					sTmp1$ := substr(sTmp1$,strpos(sTmp1$,'_')+1,length(sTmp1$));
					Raise notice '4 sTmp1$ %',sTmp1$;
					sDireccion$ := substr(sTmp1$,1,3);
					Raise notice '5 sDireccion$ %',sDireccion$;
					IF sDireccion$ <> 'asc' AND sDireccion$ <> 'des' THEN
						sDireccion$ := NULL;
						sParte$ := NULL;
						sEstado$ := 'ERR_DIRECC';
					ELSE
						sEstado$ := 'NUEVO';
						sTmp1$ := substr(sTmp1$,4,length(sTmp1$));
						Raise notice '6 sTmp1$ %',sTmp1$;
						sTmp1$ := substr(sTmp1$,2,length(sTmp1$));
						Raise notice '7 sTmp1$ %',sTmp1$;
						sParte$ := sTmp1$;
						Raise notice '8 sParte$ %',sParte$;
					END IF;
				END IF;
			EXCEPTION
			WHEN OTHERS THEN
				nNumSqueesar$ := 0;
				sDireccion$ := NULL;
				sParte$ := NULL;
				sEstado$ := 'ERR_FORMAT';
			END;

			sQueryCount$ := 'Select count(*) from squeesar.'|| sNombreTabla$;

			IF sEstado$ = 'NUEVO' THEN
				EXECUTE sQueryCount$ into nCantidadReg$ ;
				IF sIndReproceso$ = 'S' THEN
				
					SELECT
						correlativo_parte,
						'REPRO',
						estado
					INTO
						nCorrelativo$,
						sEstado$,
						sEstadoAnterior$
					FROM
						squeesar.registro_squeesar
					WHERE
						nombre_tabla = sNombreTabla$;
							

					IF nCorrelativo$ IS NULL THEN
						nCorrelativo$ := 0;
						sEstado$ := 'NUEVO';
					END IF;

				END IF;				
			ELSE
				nCantidadReg$ := 0;
			END IF;
			
			IF sEstado$ = 'REPRO' THEN
				IF sEstadoAnterior$ <> 'FINAL' THEN
					sEstado$ = 'NUEVO';
				END IF; 
				
				UPDATE
					squeesar.registro_squeesar
				SET
					fecha_registro = NOW(),
					estado = sEstado$,
					fecha_estado = NOW(),
					vigencia = 'N',
					cantidad_registros = nCantidadReg$	
				WHERE
					nombre_tabla = sNombreTabla$;
			
			ELSE	
				IF nNumSqueesarAnterior$ <> nNumSqueesar$ THEN
					nCorrelativo$ := 0;
					SELECT 
						coalesce(MAX(correlativo_parte),0)
					INTO
						nCorrelativo$
					FROM
						squeesar.registro_squeesar
					WHERE
						squeesar = nNumSqueesar$;
						--AND estado <> 'NUEVO';

				END IF;	

				nCorrelativo$ := nCorrelativo$ + 1;
				BEGIN
				------------------------------------------------------------------------------------------------
					INSERT	INTO 
						squeesar.registro_squeesar
						(
							nombre_tabla,
							fecha_registro,
							estado,
							fecha_estado,
							squeesar,
							direccion,
							correlativo_parte ,
							parte,
							vigencia,
							cantidad_registros
						)
						VALUES
						(
							sNombreTabla$,
							NOW(),
							sEstado$,
							NOW(),
							nNumSqueesar$,
							sDireccion$,
							nCorrelativo$,
							sParte$,
							'N',
							nCantidadReg$
						);
				EXCEPTION
					WHEN unique_violation THEN
					RAISE notice 'ALERTA: nombre tabla ya existe';
				END;
			END IF;			
			nNumSqueesarAnterior$ := nNumSqueesar$;
			
		END LOOP;
	
		nNumError$ := squeesar.eliminar_squeesar();

 RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.registrar_tabla_squeesar(character varying)
  OWNER TO postgres;
