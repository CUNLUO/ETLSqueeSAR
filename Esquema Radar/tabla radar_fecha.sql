-- Table: radar_terrestre.radar_fecha

-- DROP TABLE radar_terrestre.radar_fecha;

CREATE TABLE radar_terrestre.radar_fecha
(
  id_radar double precision NOT NULL,
  fecha timestamp without time zone NOT NULL,
  desplazamiento double precision
)
WITH (
  OIDS=FALSE
);
ALTER TABLE radar_terrestre.radar_fecha
  OWNER TO postgres;
