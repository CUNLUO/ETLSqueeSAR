-- Function: select * from squeesar.registrar_tabla_squeesar()

-- DROP FUNCTION squeesar.registrar_tabla_squeesar();

CREATE OR REPLACE FUNCTION squeesar.registrar_tabla_squeesar()
  RETURNS integer AS
$BODY$

DECLARE

	/*--------------------------------- */
	sQuery$							VARCHAR(200);
	cur_Tablas 					RECORD;
	cur_ContenidoTabla	RECORD;
	sNombreTabla$ 			VARCHAR(200);
	nNumSqueesar$	integer;
	nNumSqueesarAnterior$	integer;	
	sDireccion$	varchar(20);
	sParte$			varchar(20);	
	nCorrelativo$	integer;
	sTmp1$ varchar(255);
	sEstado$	varchar(20);


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
				AND tables.table_name not in( select nombre_tabla from squeesar.registro_squeesar)
				AND lower(tables.table_name) LIKE 'squeesar%' 
			ORDER BY 
				tables.table_name ASC

		LOOP
			sEstado$ := NULL;
			sNombreTabla$ := cur_Tablas.table_name;
			Raise notice '1 sNombreTabla$ %',sNombreTabla$;
			BEGIN
				sTmp1$ := trim(LEADING 'squeesar_' from lower( sNombreTabla$));
				Raise notice '2 sTmp1$ %',sTmp1$;
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
			EXCEPTION
			WHEN OTHERS THEN
				nNumSqueesar$ := 0;
				sDireccion$ := NULL;
				sParte$ := NULL;
				sEstado$ := 'ERR_FORMAT';
			END;
			IF nNumSqueesarAnterior$ <> nNumSqueesar$ THEN
				nCorrelativo$ := 1;
			ELSE
				nCorrelativo$ := nCorrelativo$ + 1;
			END IF;	
			
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
					vigencia
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
					'N'
				);
						
			nNumSqueesarAnterior$ := nNumSqueesar$;
			
		END LOOP;
	
 RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.registrar_tabla_squeesar()
  OWNER TO postgres;
