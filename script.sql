select * from squeesar.preparar_tabla('squeesar6_part_3_2',0);

select * from squeesar.procesar_squeesar()

select count(*) from squeesar.squeesar_consolidado_temp --60000

select count(*) from squeesar.squeesar_consolidado_fecha_temp --2760000

select * from squeesar.squeesar_consolidado_temp order by id_consolidado limit 10000--60000

select * from squeesar.squeesar_consolidado_fecha_temp order by id_consolidado limit 10000--2760000


/*
delete from squeesar.squeesar_consolidado_temp --60000

delete from squeesar.squeesar_consolidado_fecha_temp --2760000
*/

select * from squeesar.intersecta_squeesar_poligono()

select * from squeesar.squeesar6_part_3_2 limit 10000--127998

select max(gid) from squeesar.squeesar_consolidado --500000 3704820

select * from squeesar.squeesar_consolidado_fecha --23000000

select * from squeesar.squeesar_consolidado_fecha order by gid, fecha limit 10000

select gid from squeesar.squeesar6_part_3_2_sample order by gid

delete from squeesar.squeesar6_part_3_2_sample where gid > 714000

delete from squeesar.squeesar_consolidado

delete from squeesar.squeesar_consolidado_fecha

delete from squeesar.squeesar6_part_3_2 where gid > 60000




	