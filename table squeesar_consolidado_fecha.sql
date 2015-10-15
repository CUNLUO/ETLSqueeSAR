CREATE TABLE squeesar.squeesar_consolidado_fecha
(
  id_squeesar_consolidado bigint not null,
  gid bigint not null,
  fecha	date not null,
  deformacion double precision,
  CONSTRAINT squeesar_consolidado_fecha_pkey PRIMARY KEY (id_squeesar_consolidado,fecha)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.squeesar_consolidado_fecha
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.squeesar_consolidado_fecha TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.squeesar_consolidado_fecha TO user_cmm;
