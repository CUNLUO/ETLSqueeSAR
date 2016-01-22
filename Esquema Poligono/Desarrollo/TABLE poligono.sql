-- Table: poligonos.poligono

-- DROP TABLE poligonos.poligono;

CREATE TABLE poligonos.poligono
(
  id bigint NOT NULL,
  nombre character varying,
  zona_id bigint,
  geom geometry,
  riesgo bigint,
  CONSTRAINT poligono_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE poligonos.poligono
  OWNER TO postgres;

