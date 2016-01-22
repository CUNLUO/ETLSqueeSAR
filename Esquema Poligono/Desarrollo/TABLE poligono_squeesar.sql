CREATE TABLE poligonos.poligono_squeesar
(
  id_squeesar_consolidado bigint,
  id_poligono bigint,
  CONSTRAINT poligono_squeesar_pkey PRIMARY KEY (id_squeesar_consolidado,id_poligono)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE poligonos.poligono_squeesar
  OWNER TO postgres;
GRANT ALL ON TABLE poligonos.poligono_squeesar TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE poligonos.poligono_squeesar TO user_cmm;
