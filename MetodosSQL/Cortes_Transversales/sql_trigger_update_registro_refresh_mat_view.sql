-- Crear la funcion del riger para actualizar la tabla "registro_refresh_mat_view"
CREATE
OR REPLACE FUNCTION update_registro_refresh_mat_view () RETURNS TRIGGER AS $$
BEGIN
	UPDATE "cortes_transversales"."registro_refresh_mat_view"
SET need_refresh = 'si'
WHERE
	mat_view = 'mv_cortes_squeesar_fecha' ; RETURN NULL ;
END ; $$ LANGUAGE plpgsql;

-- Drop trigger si existe
DROP TRIGGER
IF EXISTS tg_registro_refresh_mat_view ON "cortes_transversales"."cortes_segmentos";

-- Crear el trigger
CREATE TRIGGER tg_registro_refresh_mat_view AFTER INSERT
OR UPDATE
OR DELETE ON "cortes_transversales"."cortes_segmentos" FOR EACH ROW EXECUTE PROCEDURE update_registro_refresh_mat_view ();