-- Function: squeesar.procesar_squeesar()

-- DROP FUNCTION squeesar.procesar_squeesar();

CREATE OR REPLACE FUNCTION squeesar.procesar_squeesar(character varying)
  RETURNS integer AS
$BODY$

DECLARE

	sNombreTabla$ alias for $1;
	/*--------------------------------- */
	sQueryInsert$							VARCHAR(2000);
	sQuerySelect$							VARCHAR(2000);
	sQueryFinal$							VARCHAR(2000);
	nCantidad$ 	INTEGER;
	nCantColumnas$	INTEGER;
	cur_Columnas 					RECORD;
	sNombreColumna$ 			VARCHAR(200);
	sFecha$			varchar(8);
	dFecha$ date;
	sIndicadorInsercion$	varchar(1);
	sNombreEsquema$	varchar(200);
	
BEGIN
	sNombreEsquema$:= 'squeesar';
	nCantColumnas$ := 0;
	sQueryInsert$ := '';
	sQuerySelect$ := '';
	sIndicadorInsercion$ := 'N';
	
		FOR cur_Columnas in
				select 
					columns.column_name 
				from 
					information_schema.columns 
				where
					columns.table_schema::text = sNombreEsquema$::text 
					and columns.table_name = sNombreTabla$
					and upper(columns.column_name) <> 'GEOM'
					and upper(columns.column_name) <> 'ID_CONSOLIDADO'
				order by ordinal_position		

		LOOP
				nCantidad$:= 0;
				sNombreColumna$ := cur_Columnas.column_name;
				select 
					count(*) 
				into
					nCantidad$
				from 
					information_schema.columns 
				where
					columns.table_schema::text = 'squeesar'::text 
					and columns.table_name = 'squeesar_consolidado' 
					and columns.column_name = sNombreColumna$;
					
				IF nCantidad$ = 1 then
					IF nCantColumnas$ = 0 then
						sQueryInsert$ := 'INSERT INTO ' || sNombreEsquema$ || '.squeesar_consolidado (' ||sNombreColumna$ || ', geom, id_squeesar_consolidado, nombre_tabla';
						sQuerySelect$ := 'SELECT ' || sNombreColumna$ || ', geom, id_squeesar_consolidado, ''' || sNombreTabla$ || '''';
					ELSE
						sQueryInsert$ := sQueryInsert$ || ' , ' || sNombreColumna$;
						sQuerySelect$ := sQuerySelect$ || ' , ' || sNombreColumna$;
					END IF;
				ELSE
					sFecha$ := TRIM(LEADING 'D' FROM UPPER(sNombreColumna$));
					Raise notice 'sFecha$ %',sFecha$;
					BEGIN
						dFecha$:= TO_DATE(sFecha$,'YYYYMMDD');
					EXCEPTION
					WHEN OTHERS THEN
						Raise notice 'Error en columna %',sNombreColumna$;
						RETURN-1;
					END;
					if sIndicadorInsercion$ = 'N' THEN
						sQueryFinal$ := sQueryInsert$ || ') ' || sQuerySelect$ || ' from ' || sNombreEsquema$ || '.' || sNombreTabla$;
						Raise notice 'Padre %',sQueryFinal$;
						EXECUTE sQueryFinal$;
						sIndicadorInsercion$ := 'S';
					END IF;
					sQueryFinal$ := 'INSERT INTO ' || sNombreEsquema$ || '.squeesar_consolidado_fecha (id_squeesar_consolidado, gid , fecha,deformacion) Select id_squeesar_consolidado, gid , ''' || dFecha$ || ''' , ' || sNombreColumna$ || ' from ' || sNombreEsquema$ || '.' || sNombreTabla$;
					Raise notice 'Query detalle fecha %',sQueryFinal$;
					EXECUTE sQueryFinal$;
				end if;


				nCantColumnas$ := nCantColumnas$ +1;
			end loop;

				
 RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.procesar_squeesar(character varying)
  OWNER TO postgres;
