-- Function: squeesar.procesar_tabla(character varying,character varying, character varying, character varying)

-- DROP FUNCTION squeesar.procesar_tabla(character varying,character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION squeesar.procesar_tabla(character varying, character varying, character varying, character varying)
  RETURNS integer AS
$BODY$

DECLARE

	sNombreTabla$ alias for $1;
	sNombreNuevaTabla$ alias for $2;
	sNombreNuevaTablaFecha$ alias for $3;
	sDireccion$ alias for $4;
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
Raise notice 'sNombreTabla$ %',sNombreTabla$;
Raise notice 'sNombreNuevaTabla$ %',sNombreNuevaTabla$;
Raise notice 'sNombreNuevaTablaFecha$ %',sNombreNuevaTablaFecha$;
Raise notice 'sDireccion$ %',sDireccion$;

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
					and upper(columns.column_name) not in ('GEOM','ID_SQUEESAR_CONSOLIDADO','DIRECCION','X','Y', 'NOMBRE_TABLA')
				order by ordinal_position		
				--sDireccion$

		LOOP
		--Raise notice 'INGRESO!!!!!  %',sDireccion$;
				nCantidad$:= 0;
				sNombreColumna$ := cur_Columnas.column_name;
				--Raise notice 'sNombreColumna$ %',sNombreColumna$;
				select 
					count(*) 
				into
					nCantidad$
				from 
					information_schema.columns 
				where
					columns.table_schema::text = sNombreEsquema$
					and columns.table_name = sNombreNuevaTabla$ 
					and columns.column_name = sNombreColumna$;
				--Raise notice 'nCantidad$ %',nCantidad$;	
				IF nCantidad$ = 1 then
					IF nCantColumnas$ = 0 then
						sQueryInsert$ := 'INSERT INTO ' || sNombreEsquema$ || '.' || sNombreNuevaTabla$ || '(' ||sNombreColumna$ || ', geom, x, y, id_squeesar_consolidado, direccion, nombre_tabla';
						sQuerySelect$ := 'SELECT ' || sNombreColumna$ || ', ST_Transform (geom,1000), ST_X(ST_Transform (geom,1000)),  ST_Y(ST_Transform (geom,1000)), id_squeesar_consolidado,  ''' || sDireccion$ || ''', ''' || sNombreTabla$ || '''';
					ELSE
						sQueryInsert$ := sQueryInsert$ || ' , ' || sNombreColumna$;
						sQuerySelect$ := sQuerySelect$ || ' , ' || sNombreColumna$;
					END IF;
				ELSE
					sFecha$ := TRIM(LEADING 'D' FROM UPPER(sNombreColumna$));
					--Raise notice 'sFecha$ %',sFecha$;
					BEGIN
						dFecha$:= TO_DATE(sFecha$,'YYYYMMDD');
					EXCEPTION
					WHEN OTHERS THEN
						Raise notice 'Error en columna %',sNombreColumna$;
						RETURN-1;
					END;
					if sIndicadorInsercion$ = 'N' THEN
						sQueryFinal$ := sQueryInsert$ || ') ' || sQuerySelect$ || ' from ' || sNombreEsquema$ || '.' || sNombreTabla$;
						--Raise notice 'Padre %',sQueryFinal$;
						EXECUTE sQueryFinal$;
						sIndicadorInsercion$ := 'S';
					END IF;
					sQueryFinal$ := 'INSERT INTO ' || sNombreEsquema$ || '.'|| sNombreNuevaTablaFecha$ ||' (id_squeesar_consolidado , direccion, fecha,deformacion) Select id_squeesar_consolidado , ''' || sDireccion$ || ''', ''' || dFecha$ || ''' , ' || sNombreColumna$ || ' from ' || sNombreEsquema$ || '.' || sNombreTabla$;
					--Raise notice 'Query detalle fecha %',sQueryFinal$;
					EXECUTE sQueryFinal$;
				end if;

--Raise notice 'nCantidad$ %',nCantidad$;
				nCantColumnas$ := nCantColumnas$ +1;
			end loop;
			
			sQueryFinal$ := 'TRUNCATE ' || sNombreEsquema$ || '.'|| sNombreTabla$;
			EXECUTE sQueryFinal$;
			sQueryFinal$ := 'DROP TABLE ' || sNombreEsquema$ || '.'|| sNombreTabla$;
			EXECUTE sQueryFinal$;

				
 RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.procesar_tabla(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
