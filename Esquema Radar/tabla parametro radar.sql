-- Table: public.parametros

-- DROP TABLE public.parametros;

CREATE TABLE public.parametros
(
  id_parametro bigint NOT NULL,
  codigo character varying(10) NOT NULL,
  descripcion character varying(255),
  valor_numerico double precision,
  valor_alfanumerico character varying(100),
  CONSTRAINT parametros_pkey PRIMARY KEY (id_parametro, codigo)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.parametros
  OWNER TO postgres;
