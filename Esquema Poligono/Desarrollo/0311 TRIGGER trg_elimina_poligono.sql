CREATE TRIGGER trg_elimina_poligono
BEFORE DELETE ON "poligonos"."poligono"
    FOR EACH ROW EXECUTE PROCEDURE "poligonos"."elimina_poligono_trg"();