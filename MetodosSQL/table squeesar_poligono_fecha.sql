CREATE TABLE squeesar.squeesar_poligono_fecha
(
  id_poligono bigint,
  fecha	date,
  cant_registros bigint,
  deformacion double precision,
  velocidad double precision,
  aceleracion  double precision,
  CONSTRAINT squeesar_poligono_fecha_pkey PRIMARY KEY (id_poligono,fecha)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.squeesar_poligono_fecha
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.squeesar_poligono_fecha TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.squeesar_poligono_fecha TO user_cmm;
