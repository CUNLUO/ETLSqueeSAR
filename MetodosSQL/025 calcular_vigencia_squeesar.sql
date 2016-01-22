-- Function: squeesar.calcular_vigencia_squeesar()

-- DROP FUNCTION squeesar.calcular_vigencia_squeesar();

CREATE OR REPLACE FUNCTION squeesar.calcular_vigencia_squeesar(OUT indicador_vigencia character varying)
  RETURNS character  varying  AS
$BODY$

DECLARE

	/*--------------------------------- */


	nNumSqueesar$	integer;	
	nNumError$	integer;
	nNumSqueesarVigente$	integer;
	
BEGIN

	nNumSqueesarVigente$ := 0;
	nNumSqueesar$ := 0;
	

	-------------------------------------------------------------
	-- SELECCIONA EL NUM DE SQUEESAR VIGENTE EN TABLA DE REGISTRO
	-------------------------------------------------------------
	BEGIN
		SELECT DISTINCT
			COALESCE(squeesar,0)
		INTO
			nNumSqueesarVigente$
		FROM
			squeesar.registro_squeesar
		WHERE
			vigencia = 'S';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			nNumSqueesarVigente$ := 0;
	END;
	---------------------------------------------------------------------------------------------
	-- SELECCIONA EL NUM MAX DE SQUEESAR NO VIGENTE CORRECTAMENTE PROCASADO EN TABLA DE REGISTRO
	---------------------------------------------------------------------------------------------
	BEGIN
		SELECT 
			max(squeesar)
		INTO
			nNumSqueesar$
		FROM
			squeesar.registro_squeesar
		WHERE
			vigencia = 'N' and 
			estado = 'FINAL';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			nNumSqueesar$ := 0;
	END;

	-------------------------------------------------------------------------------------------------------------------------
	-- SI MAX SQUEESAR NO VIGENTE ES MAYOR O IGUAL AL VIGENTE, SE DEBE RECALCULAR LA VIGENCIA Y LA INTERSECCION CON POLIGONOS
	-------------------------------------------------------------------------------------------------------------------------
	IF nNumSqueesarVigente$ > nNumSqueesar$  THEN
		indicador_vigencia := 'N';	
	ELSE
		UPDATE
			squeesar.registro_squeesar 
		SET
			vigencia = 'N'
		WHERE
			vigencia  = 'S';
			
		indicador_vigencia := 'S';
	END IF;
		
	UPDATE
		squeesar.registro_squeesar 
	SET
		vigencia = indicador_vigencia
	WHERE
		squeesar  = nNumSqueesar$ 
		AND estado = 'FINAL';

	
	IF indicador_vigencia = 'S' THEN
		nNumError$ := squeesar.intersecta_squeesar_poligonos();
		nNumError$ := squeesar.agrupar_squeesar();
	END IF;			
	
	RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION squeesar.calcular_vigencia_squeesar(out character varying)
  OWNER TO postgres;
