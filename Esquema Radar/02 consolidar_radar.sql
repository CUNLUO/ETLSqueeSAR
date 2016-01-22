-- Function: select * from radar_terrestre.consolidar_radar(character varying)

-- DROP FUNCTION radar_terrestre.consolidar_radar(character varying);

CREATE OR REPLACE FUNCTION radar_terrestre.consolidar_radar(character varying)
  RETURNS integer AS
$BODY$

DECLARE

	sNombreEsquema$ alias for $1;
	/*--------------------------------- */
	sQuery$			VARCHAR(2000);
	--cur_Tablas 		RECORD;
	nCantHoras$		integer;
	tUltimaFechaAnterior$	timestamp;
	tFechaEstandarizada$	timestamp;
	tFechaEstandarizadaIni$	timestamp;
	tUltimaFecha$		timestamp;

	tLimiteInferior$	timestamp;
	nid_registroInferior$	bigint;
	nid_radarInferior$	bigint;
	snombre_tablaInferior$	varchar(50);
	nDiferenciaInferior$	bigint;
	dFactorInferior$	double precision;
	
	tLimiteSuperior$	timestamp;
	nid_registroSuperior$	bigint;
	nid_radarSuperior$	bigint;
	snombre_tablaSuperior$	varchar(50);
	nDiferenciaSuperior$	bigint;	
	dFactorSuperior$	double precision;

	nPos$			integer;
	
	--sNombreTabla$ 			VARCHAR(200);	
	--dFechaRegistro$		timestamp;
	--id_radar$		bigint;
	--fecha_radar$		timestamp;

	--sIndUsoTabla$		varchar(1);		
	sTmp1$ varchar(255);
	--nNumError$	integer;

BEGIN
	--dFechaRegistro$ := now();
	nCantHoras$ := 0;

	nPos$ := -1;
	--begin
	SELECT
		valor_numerico
	INTO
		nCantHoras$
	FROM
		parametros
	WHERE
		id_parametro = 2 and
		codigo = 'HRS_RADAR';
	--exception
	--	when NO_DATA_FOUND then
	--	RAISE notice 'ALERTA: No existen parametro';
	--	return -100;
	--end;

	nPos$ := -2;
	UPDATE
		radar_terrestre.registro_radar
	SET
		indicador_uso = 'T'
	WHERE
		indicador_uso = 'P';

	nPos$ := -3;
	SELECT
		COALESCE(MAX(fecha),TO_TIMESTAMP('2000','yyyy'))
	INTO
		tUltimaFechaAnterior$
	FROM
		radar_terrestre.radar_fecha;
		

	IF (TO_CHAR(tUltimaFechaAnterior$,'yyyy') = '2000') THEN
		nPos$ := -4;
		SELECT
			COALESCE(to_char(MIN(fecha_radar),'yyyymmdd'),'20000101')
		INTO
			sTmp1$
		FROM 
			radar_terrestre.registro_radar
		WHERE
			indicador_uso = 'T'; 
			
		IF sTmp1$ = '20000101' THEN
			RAISE notice 'ALERTA: No existen fechas para procesar';
			return 0;
		ELSE
			tFechaEstandarizada$ := TO_TIMESTAMP(sTmp1$,'yyyymmdd');
		END IF;
			
	ELSE
		nPos$ := -5;
		sTmp1$ := to_char(tUltimaFechaAnterior$,'yyyymmddhh24mi');
		sQuery$	:= ' select to_timestamp(''' || sTmp1$ || ''',''yyyymmddhh24mi'') + interval ''' || nCantHoras$ || ' hr'''; 
		EXECUTE sQuery$ into tFechaEstandarizada$ ;
	END IF;	

	nPos$ := -6;
	SELECT
		COALESCE(MAX(fecha_radar),TO_TIMESTAMP('2100','yyyy'))
	INTO
		tUltimaFecha$
	FROM 
		radar_terrestre.registro_radar
	WHERE
		indicador_uso = 'T'; 
		
	IF TO_CHAR(tUltimaFecha$,'YYYY') = '2100' THEN
		RAISE notice 'ALERTA: No existen fechas para procesar';
		return 0;
	END IF;

	tFechaEstandarizadaIni$ := tFechaEstandarizada$;
	
	nPos$ := -7;
	LOOP	

		SELECT
			id_registro,
			id_radar,
			nombre_tabla,
			fecha_radar
		INTO
			nid_registroInferior$,
			nid_radarInferior$,
			snombre_tablaInferior$,
			tLimiteInferior$
		FROM 
			radar_terrestre.registro_radar
		WHERE
			indicador_uso in ('T','S') AND
			fecha_radar < tFechaEstandarizada$
		ORDER BY 
			fecha_radar DESC
		LIMIT 1;
		
	
			
		SELECT
			id_registro,
			id_radar,
			nombre_tabla,
			fecha_radar
		INTO
			nid_registroSuperior$,
			nid_radarSuperior$,
			snombre_tablaSuperior$,
			tLimiteSuperior$
		FROM 
			radar_terrestre.registro_radar
		WHERE
			indicador_uso in ('T','S') AND
			fecha_radar > tFechaEstandarizada$
		ORDER BY 
			fecha_radar ASC
		LIMIT 1;


		IF tLimiteInferior$ IS NULL THEN
			IF TO_CHAR(tUltimaFechaAnterior$,'yyyy') = '2000' THEN
				RAISE notice '1 VALOR NULO '; -- AVANZO AL SIGUIENTE
			ELSE
			-- tLimiteInferior$ = CALCULAR CON ULTIMO VALOR REAL ANTERIOR
				SELECT
					id_registro,
					id_radar,
					nombre_tabla,
					fecha_radar
				INTO
					nid_registroInferior$,
					nid_radarInferior$,
					snombre_tablaInferior$,
					tLimiteInferior$
				FROM 
					radar_terrestre.registro_radar
				WHERE
					fecha_radar < tFechaEstandarizada$
				ORDER BY 
					fecha_radar DESC
				LIMIT 1;
			END IF;
		END IF;
		IF tLimiteInferior$ IS NOT NULL AND tLimiteSuperior$ IS NOT NULL THEN
			nDiferenciaInferior$ := extract(epoch from (tFechaEstandarizada$ - tLimiteInferior$)) ;
			nDiferenciaSuperior$ := extract(epoch from (tLimiteSuperior$ - tFechaEstandarizada$));

			dFactorInferior$ := cast (nDiferenciaInferior$ as float4) / cast(nDiferenciaInferior$ + nDiferenciaSuperior$ as float4);
			--dFactorSuperior$ := cast (nDiferenciaSuperior$ as float4) / cast(nDiferenciaInferior$ + nDiferenciaSuperior$ as float4);
			RAISE notice '1 tFechaEstandarizada$ %',tFechaEstandarizada$;
			sQuery$ := '
				INSERT INTO 
					radar_terrestre.radar_fecha
				
				SELECT 
					0, '''|| tFechaEstandarizada$ ||''', ant."ibis-db" + ((post."ibis-db" - ant."ibis-db") * ' || dFactorInferior$ || ')
				FROM
					' ||sNombreEsquema$ ||'."'||snombre_tablaInferior$||'" ant
					INNER JOIN ' ||sNombreEsquema$ ||'."'||snombre_tablaSuperior$||'" post ON
					ant.x = post.x AND
					ant.y = post.y';

			EXECUTE sQuery$;
			
			UPDATE
				radar_terrestre.registro_radar
			SET
				indicador_uso = 'S'
			WHERE
				id_registro in (nid_registroInferior$,nid_registroSuperior$);
			

		END IF;


		sTmp1$ := to_char(tFechaEstandarizada$,'yyyymmddhh24mi');	
		sQuery$	:= ' select to_timestamp(''' || sTmp1$ || ''',''yyyymmddhh24mi'') + interval ''' || nCantHoras$ || ' hr'''; 	
		EXECUTE sQuery$ into tFechaEstandarizada$ ;
		
		IF tFechaEstandarizada$ > tUltimaFecha$ THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	nPos$ := -8;	
	UPDATE
		radar_terrestre.registro_radar
	SET
		indicador_uso = 'N'
	WHERE
		indicador_uso = 'T';
				

 RETURN 0;
 EXCEPTION
	WHEN OTHERS THEN
		RAISE notice 'ERROR: rollbak, SQLSTATE: %',SQLSTATE;
		return nPos$;
 
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION radar_terrestre.consolidar_radar(character varying)
  OWNER TO postgres;
