-- Function: squeesar.agrupar_squeesar()

-- DROP FUNCTION squeesar.agrupar_squeesar();

CREATE OR REPLACE FUNCTION squeesar.agrupar_squeesar()
  RETURNS integer AS
$BODY$

DECLARE

	/*--------------------------------- */
	cur_fecha		RECORD;
	cur_valores		RECORD;
	
	nIdPoligonoAnterior$		bigint;
	dFechaAnterior$	date;
	fDeformacionAnterior$	double precision;
	fAceleracion$	double precision;
	fAceleracionAnterior$	double precision;
	fVelocidad$	double precision;
	fVelocidadAnterior$	double precision;
	
	nDiferenciaDias$	integer;
	
BEGIN

		
	DELETE FROM
		squeesar.squeesar_poligono_fecha;	
		
	DELETE FROM
		squeesar.squeesar_poligono_resumen;
	
	nIdPoligonoAnterior$ := 0;
	
	FOR cur_fecha IN

		SELECT 
			poligono_squeesar.id_poligono,
			squeesar_consolidado_fecha.fecha,
			count(*) as cantidad,
			AVG(deformacion) AS prom_deformacion
		FROM 
			squeesar.squeesar_consolidado_fecha
			INNER JOIN poligonos.poligono_squeesar ON
				poligono_squeesar.id_squeesar_consolidado = squeesar_consolidado_fecha.id_squeesar_consolidado
		GROUP BY 
			poligono_squeesar.id_poligono,
			squeesar_consolidado_fecha.fecha
		ORDER BY 
			poligono_squeesar.id_poligono,
			squeesar_consolidado_fecha.fecha	
			
	LOOP
		
		IF nIdPoligonoAnterior$  = cur_fecha.id_poligono THEN
			nDiferenciaDias$ := cur_fecha.fecha - dFechaAnterior$;
			IF nDiferenciaDias$ > 0 THEN
				fVelocidad$ := (cur_fecha.prom_deformacion - fDeformacionAnterior$) / nDiferenciaDias$;
				IF fVelocidadAnterior$ IS NOT NULL THEN
					fAceleracion$ := (fVelocidad$ - fVelocidadAnterior$) / nDiferenciaDias$;
				ELSE
					fAceleracion$ := NULL;
				END IF;
			ELSE
				fVelocidad$ := 0;
				IF fVelocidadAnterior$ <> NULL THEN
					fAceleracion$ := 0;
				ELSE
					fAceleracion$ := NULL;
				END IF;	
			END IF;
		ELSE
			fVelocidad$ := NULL;
			fAceleracion$ := NULL;
		END IF;
		INSERT INTO
			squeesar.squeesar_poligono_fecha
			(
				id_poligono,
				fecha,
				cant_registros,
				deformacion,
				velocidad,
				aceleracion
			)
			VALUES
			(
				cur_fecha.id_poligono,
				cur_fecha.fecha,
				cur_fecha.cantidad,
				cur_fecha.prom_deformacion,
				fVelocidad$,
				fAceleracion$
			);
			
			dFechaAnterior$ := cur_fecha.fecha;
			nIdPoligonoAnterior$:= cur_fecha.id_poligono;
			fDeformacionAnterior$:= cur_fecha.prom_deformacion;
			fAceleracionAnterior$:= fAceleracion$;
			fVelocidadAnterior$:= fVelocidad$;
	
	END LOOP;
	
	FOR cur_valores IN

		SELECT 
			id_poligono,
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
			squeesar.squeesar_consolidado
			INNER JOIN poligonos.poligono_squeesar ON
				poligono_squeesar.id_squeesar_consolidado = squeesar_consolidado.id_squeesar_consolidado
		GROUP BY 
			id_poligono
	LOOP


		INSERT INTO
			squeesar.squeesar_poligono_resumen
			(
				id_poligono ,
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
ALTER FUNCTION squeesar.agrupar_squeesar()
  OWNER TO postgres;
