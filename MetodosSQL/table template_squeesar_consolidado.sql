CREATE TABLE squeesar.template_squeesar_consolidado
(
  id_squeesar_consolidado bigint not null,
  direccion	character varying(20),
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
  x double precision,
  y double precision,
  geom geometry(Point,1000),
  CONSTRAINT template_squeesar_consolidado_pkey PRIMARY KEY (id_squeesar_consolidado)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.template_squeesar_consolidado
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.template_squeesar_consolidado TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.template_squeesar_consolidado TO user_cmm;

-- Index: squeesar.template_squeesar_consolidado_geom_gist

-- DROP INDEX squeesar.template_squeesar_consolidado_geom_gist;

CREATE INDEX template_squeesar_consolidado_geom_gist
  ON squeesar.template_squeesar_consolidado
  USING gist
  (geom);
  
-- Index: squeesar.template_squeesar_consolidado_x_idx

-- DROP INDEX squeesar.template_squeesar_consolidado_x_idx;

CREATE INDEX template_squeesar_consolidado_x_idx
  ON squeesar.template_squeesar_consolidado
  USING btree
  (x);
  
-- Index: squeesar.template_squeesar_consolidado_y_idx

-- DROP INDEX squeesar.template_squeesar_consolidado_y_idx;

CREATE INDEX template_squeesar_consolidado_y_idx
  ON squeesar.template_squeesar_consolidado
  USING btree
  (y);  