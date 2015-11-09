CREATE TABLE squeesar.poligono_resumen
(
  id_poligono bigint,
  direccion character varying(20),
  cant_registros bigint,
  height double precision,
  h_stdev double precision,
  vel double precision,
  v_stdev double precision,
  acc double precision,
  coherence double precision,
  a_stdev double precision,
  eff_area double precision,
  range double precision,
  azimuth double precision,
  CONSTRAINT poligono_resumen_pkey PRIMARY KEY (id_poligono)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.poligono_resumen
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.poligono_resumen TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.poligono_resumen TO user_cmm;
