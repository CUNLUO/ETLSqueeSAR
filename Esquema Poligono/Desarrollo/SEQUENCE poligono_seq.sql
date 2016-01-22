--OJO: actualizar el campo START al ejecutar
-- Sequence: poligonos.poligono_seq

-- DROP SEQUENCE poligonos.poligono_seq;

CREATE SEQUENCE poligonos.poligono_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 120
  CACHE 1;
ALTER TABLE poligonos.poligono_seq
  OWNER TO postgres;
