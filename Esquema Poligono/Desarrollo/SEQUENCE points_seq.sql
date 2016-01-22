-- Sequence: poligonos.points_seq

-- DROP SEQUENCE poligonos.points_seq;
-- 
--OJO: actualizar el campo START al ejecutar
CREATE SEQUENCE poligonos.points_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 406
  CACHE 1;
ALTER TABLE poligonos.points_seq
  OWNER TO postgres;
