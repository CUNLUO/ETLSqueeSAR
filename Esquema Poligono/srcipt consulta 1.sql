select * FROM poligonos.poligono WHERE id = 102;

select count(*) FROM poligonos.points WHERE poligono_id = 102;

select count(*) FROM poligonos.poligono_prisma WHERE id_poligono = 102;

select count(*) FROM prismas.poligono_alarma WHERE id_poligono = 102;

select count(*) FROM poligonos.poligono_squeesar WHERE id_poligono = 102;

select count(*) FROM squeesar.poligono_fecha WHERE id_poligono = 102;

select count(*) FROM squeesar.poligono_resumen WHERE id_poligono = 102;