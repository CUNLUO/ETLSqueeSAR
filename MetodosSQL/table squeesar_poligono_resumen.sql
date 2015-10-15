CREATE TABLE squeesar.squeesar_poligono_resumen
(
  id_poligono bigint,
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
  CONSTRAINT squeesar_poligono_resumen_pkey PRIMARY KEY (id_poligono)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.squeesar_poligono_resumen
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.squeesar_poligono_resumen TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.squeesar_poligono_resumen TO user_cmm;
