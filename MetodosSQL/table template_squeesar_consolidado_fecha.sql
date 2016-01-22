CREATE TABLE squeesar.template_squeesar_consolidado_fecha
(
  id_squeesar_consolidado bigint not null,
  direccion	character varying(20),
  gid bigint not null,
  fecha	date not null,
  deformacion double precision,
  vel double precision,
  acc double precision,
  CONSTRAINT template_squeesar_consolidado_fecha_pkey PRIMARY KEY (id_squeesar_consolidado,fecha)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.template_squeesar_consolidado_fecha
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.template_squeesar_consolidado_fecha TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.template_squeesar_consolidado_fecha TO user_cmm;
