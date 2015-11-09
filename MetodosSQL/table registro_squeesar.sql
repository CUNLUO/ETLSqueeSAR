CREATE TABLE squeesar.registro_squeesar
(
  id_registro_squeesar serial not null,
  nombre_tabla character varying(255), 
  nombre_tabla_consolidada character varying(255), 
  fecha_registro timestamp,
  estado character varying(10),
  fecha_estado timestamp,
  squeesar integer,
  direccion	character varying(20),
  parte character varying(20),
  correlativo_parte	integer,
  vigencia	character varying(1),
  CONSTRAINT registro_squeesar_pkey PRIMARY KEY (id_registro_squeesar),
  CONSTRAINT correlativo_tabla_unique UNIQUE (nombre_tabla,correlativo_parte)
  
)
WITH (
  OIDS=FALSE
);
ALTER TABLE squeesar.registro_squeesar
  OWNER TO postgres;
GRANT ALL ON TABLE squeesar.registro_squeesar TO postgres;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE squeesar.registro_squeesar TO user_cmm;
