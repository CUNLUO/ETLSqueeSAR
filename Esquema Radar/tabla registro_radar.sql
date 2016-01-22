-- Table: radar_terrestre.registro_radar

-- DROP TABLE radar_terrestre.registro_radar;

CREATE TABLE radar_terrestre.registro_radar
(
  id_registro serial NOT NULL,
  fecha_registro timestamp without time zone,
  id_radar bigint,
  nombre_tabla character varying(50),
  fecha_radar timestamp without time zone,
  indicador_uso character varying(1),
  CONSTRAINT registro_radar_pkey PRIMARY KEY (id_registro)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE radar_terrestre.registro_radar
  OWNER TO postgres;

-- Index: radar_terrestre.registro_radar_ind_idx

-- DROP INDEX radar_terrestre.registro_radar_ind_idx;

CREATE INDEX registro_radar_ind_idx
  ON radar_terrestre.registro_radar
  USING btree
  (indicador_uso COLLATE pg_catalog."default");

