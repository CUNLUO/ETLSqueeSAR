-- Function: poligonos.agrupar_squeesar()

-- DROP FUNCTION poligonos.agrupar_squeesar();

CREATE OR REPLACE FUNCTION poligonos.agrupar_squeesar(integer)
  RETURNS integer AS
$BODY$

DECLARE

	nIDPoligono$ alias for $1;
	/*--------------------------------- */
	sQuery_Fecha$							VARCHAR(2000);
	sQuery_Resumen$			varchar(2000);
	sNombreTabla$	varchar(255);
	cur_fecha		RECORD;
	cur_valores		RECORD;
	
	sDireccionAnterior$		varchar(20);
	--nIdPoligonoAnterior$		bigint;
	dFechaAnterior$	date;
	fDeformacionAnterior$	double precision;
	fAceleracion$	double precision;
	fAceleracionAnterior$	double precision;
	fVelocidad$	double precision;
	fVelocidadAnterior$	double precision;
	
	nDiferenciaDias$	integer;
	
BEGIN
	sQuery_Fecha$ := '';
	sNombreTabla$ := '';
	
	SELECT DISTINCT
		nombre_tabla_consolidada
	INTO
		sNombreTabla$
	FROM
		squeesar.registro_squeesar
	WHERE
		vigencia  = 'S';
		
	DELETE FROM 
		squeesar.poligono_fecha
	WHERE
		id_poligono = nIDPoligono$;
		
	DELETE FROM 
		squeesar.poligono_resumen
	WHERE
		id_poligono = nIDPoligono$;
	
	--nIdPoligonoAnterior$ := 0;
	sQuery_Fecha$ := 'SELECT 
			poligono_squeesar.id_poligono,
			' || sNombreTabla$ || '_fecha.fecha,
			' || sNombreTabla$ || '_fecha.direccion,
			count(*) as cantidad,
			AVG(deformacion) AS prom_deformacion
		FROM 
			squeesar.' || sNombreTabla$ || '_fecha
			INNER JOIN poligonos.poligono_squeesar ON
				poligono_squeesar.id_squeesar_consolidado = ' || sNombreTabla$ || '_fecha.id_squeesar_consolidado
		WHERE
			poligono_squeesar.id_poligono = ' || nIDPoligono$ || ' 
		GROUP BY 
			poligono_squeesar.id_poligono,
			' || sNombreTabla$ || '_fecha.direccion,
			' || sNombreTabla$ || '_fecha.fecha
		ORDER BY 
			poligono_squeesar.id_poligono,
			' || sNombreTabla$ || '_fecha.direccion,
			' || sNombreTabla$ || '_fecha.fecha';
			
	FOR cur_fecha IN
		EXECUTE sQuery_Fecha$	
	LOOP
		
		IF sDireccionAnterior$ = cur_fecha.direccion THEN
			nDiferenciaDias$ := cur_fecha.fecha - dFechaAnterior$;
			IF nDiferenciaDias$ > 0 THEN
				fVelocidad$ := (cur_fecha.prom_deformacion - fDeformacionAnterior$) / nDiferenciaDias$;
				IF fVelocidadAnterior$ <> 0 THEN
					fAceleracion$ := (fVelocidad$ - fVelocidadAnterior$) / nDiferenciaDias$;
				ELSE
					fAceleracion$ := 0;
				END IF;
			ELSE
				fVelocidad$ := 0;
				fAceleracion$ := 0;
			END IF;
		ELSE
			fVelocidad$ := 0;
			fAceleracion$ := 0;
		END IF;
		INSERT INTO
			squeesar.poligono_fecha
			(
				id_poligono,
				direccion,
				fecha,
				cant_registros,
				deformacion,
				velocidad,
				aceleracion
			)
			VALUES
			(
				cur_fecha.id_poligono,
				cur_fecha.direccion,
				cur_fecha.fecha,
				cur_fecha.cantidad,
				cur_fecha.prom_deformacion,
				fVelocidad$,
				fAceleracion$
			);
			
			dFechaAnterior$ := cur_fecha.fecha;
			sDireccionAnterior$ := cur_fecha.direccion;
			fDeformacionAnterior$:= cur_fecha.prom_deformacion;
			fAceleracionAnterior$:= fAceleracion$;
			fVelocidadAnterior$:= fVelocidad$;
	
	END LOOP;

	sQuery_Resumen$ := '	SELECT 
			id_poligono,
			direccion,
			count(*) as cantidad,
			AVG(height) as prom_height,
			AVG(h_stdev) as prom_h_stdev,
			AVG(vel) as prom_vel,
			AVG(v_stdev) as prom_v_stdev,
			AVG(acc) as prom_acc,
			AVG(coherence) as prom_coherence,
			AVG(a_stdev) as prom_a_stdev,
			AVG(eff_area) as prom_eff_area,
			AVG(range) as prom_range,
			AVG(azimuth) as prom_azimuth
		FROM 
			squeesar.' || sNombreTabla$ || '
			INNER JOIN poligonos.poligono_squeesar ON
				poligono_squeesar.id_squeesar_consolidado = squeesar.' || sNombreTabla$ || '.id_squeesar_consolidado
		WHERE
			poligono_squeesar.id_poligono = ' || nIDPoligono$ || ' 
		GROUP BY 
			id_poligono,
			direccion';
			
	FOR cur_valores IN
		EXECUTE sQuery_Resumen$	
	LOOP

		INSERT INTO
			squeesar.poligono_resumen
			(
				id_poligono ,
				direccion,
				cant_registros,
				height,
				h_stdev,
				vel,
				v_stdev,
				acc,
				coherence,
				a_stdev ,
				eff_area,
				range,
				azimuth
			)
			VALUES
			(
				cur_valores.id_poligono ,
				cur_valores.direccion ,
				cur_valores.cantidad ,
				cur_valores.prom_height,
				cur_valores.prom_h_stdev,
				cur_valores.prom_vel,
				cur_valores.prom_v_stdev,
				cur_valores.prom_acc,
				cur_valores.prom_coherence,
				cur_valores.prom_a_stdev,
				cur_valores.prom_eff_area,
				cur_valores.prom_range,
				cur_valores.prom_azimuth
			);
			
	END LOOP;
	

				
 RETURN 0;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION poligonos.agrupar_squeesar(integer)
  OWNER TO postgres;
