CREATE TABLE squeesar.squeesar_consolidado
(
  id_squeesar_consolidado bigint not null,
  gid bigint not null,
  nombre_tabla character varying(255), 
  code character varying(5),
  height double precision,
  h_stdev double precision,
  vel double precision,
  v_stdev double precision,
  acc double precision,
  coherence double precision,
  a_stdev double precision,
  eff_area integer,
  range integer,
  azimuth integer,
  geom geometry(Point,1000),
  CONSTRAINT squeesar_consolidado_pkey PRIMARY KEY (id_squeesar_consolidado)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.squeesar_consolidado
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.squeesar_consolidado TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.squeesar_consolidado TO user_cmm;

-- Index: squeesar.squeesar_consolidado_geom_gist

-- DROP INDEX squeesar.squeesar_consolidado_geom_gist;

CREATE INDEX squeesar_consolidado_geom_gist
  ON squeesar.squeesar_consolidado
  USING gist
  (geom);