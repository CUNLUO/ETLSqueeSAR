select * from radar_terrestre.consolidar_radar('ibis_20150102')

select * from radar_terrestre.registrar_tabla_radar('N','ibis_20150102')
--841

select count(*) from  radar_terrestre.radar_fecha

select count(*) from radar_terrestre.registro_radar order by fecha_radar

truncate  radar_terrestre.radar_fecha