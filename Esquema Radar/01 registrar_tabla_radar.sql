-- Function: select * from radar_terrestre.registrar_tabla_radar()

-- DROP FUNCTION radar_terrestre.registrar_tabla_radar();

CREATE OR REPLACE FUNCTION radar_terrestre.registrar_tabla_radar(character varying, character varying)
  RETURNS integer AS
$BODY$

DECLARE

	
	sIndReproceso$ alias for $1;
	sNombreEsquema$ alias for $2;
	-------------------------------------------------------
	-- posibles valores de sIndReproceso$ (variable de entrada)
	-- N = No se reprocesara; de existir la tabla, la informacion de la tabla a procear, no se considerara, quedando con la data anterior
	-- S = Si se reprocesara: por construir
	-------------------------------------------------------
	
	/*--------------------------------- */
	--sQuery$			VARCHAR(2000);
	cur_Tablas 		RECORD;
	sDia$			VARCHAR(2);
	sMes$			VARCHAR(2);
	sAnio$			VARCHAR(2);
	sHora$			VARCHAR(2);
	sMinuto$		VARCHAR(2);
	
	sNombreTabla$ 			VARCHAR(200);	
	dFechaRegistro$		timestamp;
	id_radar$		bigint;
	fecha_radar$		timestamp;

	sIndUsoTabla$		varchar(1);		
	sTmp1$ varchar(255);
	--nNumError$	integer;

BEGIN
	dFechaRegistro$ := now();


	
	FOR cur_Tablas in
		SELECT
			tables.table_name
		FROM 
			information_schema.tables
		WHERE 
			tables.table_schema::text =  sNombreEsquema$ 
			AND tables.table_type::text = 'BASE TABLE'::text
			AND lower(tables.table_name) LIKE 'from_%' 
			AND (
				tables.table_name not in( select nombre_tabla from radar_terrestre.registro_radar)
				--or sIndReproceso$ = 'S'
				)
			
		ORDER BY 
			tables.table_name ASC
			
	LOOP
		sNombreTabla$ := cur_Tablas.table_name;
		--Raise notice '1 sNombreTabla$ %',sNombreTabla$;
		
		BEGIN
			sTmp1$ := trim(LEADING 'from_' from lower( sNombreTabla$));
			sTmp1$ := substr(sTmp1$,strpos(sTmp1$,'to')+3,length(sTmp1$));
			sDia$:= substr(trim(sTmp1$),7,2);
			sMes$:= substr(trim(sTmp1$),4,2);		
			sAnio$:= substr(trim(sTmp1$),1,2);
			sHora$:= substr(trim(sTmp1$),10,2);
			sMinuto$:= substr(trim(sTmp1$),13,2);
			fecha_radar$ := to_timestamp(sAnio$||sMes$||sDia$||sHora$||sMinuto$,'yymmddhh24mi');

			BEGIN
				INSERT	INTO 
					radar_terrestre.registro_radar
					(
						fecha_registro,
						id_radar,
						nombre_tabla ,
						fecha_radar,
						indicador_uso 
					)
					VALUES
					(
						dFechaRegistro$,
						0,
						sNombreTabla$,
						fecha_radar$,
						'P' -- pendiente
					);
			EXCEPTION
				WHEN unique_violation THEN
				RAISE notice 'ALERTA: nombre tabla ya existe';
			END;
			
		EXCEPTION
		WHEN OTHERS THEN
			RAISE notice 'ALERTA: error al procesar tabla %',sNombreTabla$;
			return -2;
		END;

		
	END LOOP;

 RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION radar_terrestre.registrar_tabla_radar(character varying,character varying)
  OWNER TO postgres;
