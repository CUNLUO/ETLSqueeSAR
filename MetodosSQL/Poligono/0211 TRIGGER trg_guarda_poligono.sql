CREATE TRIGGER trg_guarda_poligono
AFTER INSERT OR UPDATE ON "poligonos"."poligono"
    FOR EACH ROW EXECUTE PROCEDURE "poligonos"."intersecta_poligono_squeesar"();