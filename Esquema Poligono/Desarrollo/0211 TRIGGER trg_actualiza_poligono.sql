CREATE TRIGGER trg_actualiza_poligono
AFTER UPDATE ON "poligonos"."poligono"
    FOR EACH ROW EXECUTE PROCEDURE "poligonos"."actualiza_poligono_trg"();