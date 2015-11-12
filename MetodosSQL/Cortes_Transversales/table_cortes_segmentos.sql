--DROP TABLE
--IF EXISTS cortes_transversales.segmentos;
--
--CREATE SEQUENCE cortes_transversales.id_segmentos_seq;
--
CREATE TABLE cortes_transversales.cortes_segmentos (
	"id_segmentos" int8 DEFAULT nextval(
		'cortes_transversales.id_segmentos_seq' :: regclass
	) NOT NULL,
	"x_0" float8 NOT NULL,
	"y_0" float8 NOT NULL,
	"x_1" float8 NOT NULL,
	"y_1" float8 NOT NULL,
	"x_2" float8 NOT NULL,
	"y_2" float8 NOT NULL,
	"x_3" float8 NOT NULL,
	"y_3" float8 NOT NULL,
	"x_4" float8 NOT NULL,
	"y_4" float8 NOT NULL,
	"id_corte" float8,
	PRIMARY KEY ("id_segmentos")
) WITH (OIDS = FALSE);

ALTER TABLE cortes_transversales.cortes_segmentos OWNER TO "postgres";