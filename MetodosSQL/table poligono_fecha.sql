CREATE TABLE squeesar.poligono_fecha
(
  id_poligono bigint,
  direccion character varying(20),
  fecha	date,
  cant_registros bigint,
  deformacion double precision,
  velocidad double precision,
  aceleracion  double precision,
  CONSTRAINT poligono_fecha_pkey PRIMARY KEY (id_poligono,fecha)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.poligono_fecha
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.poligono_fecha TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.poligono_fecha TO user_cmm;
