create view "mg_etl".mg_hde_punkt 
(ppeid,nrpl,rej,
strona,
przylaczeid,
ppe,
nrpr,
npp,
mscgus,
pdgrp,
pum01,
pum02,pum03,pum04,pum05,pum06,pum07,pum08,pum09,pum10,pum11,pum12,otp,ulica,kod_p,miejscowosc,adres_poczty,dom,mieszk,gus,dinit,dend,tar,is_koncesja,id_dos,nrpre,skasowany,potrzeby,tg1,tg2,tg3,tg4,tg5,tg6,mc_roz,epr,data_um_przes,nr_um_przes,data_wyg_um_przes,cennik,cennik2,cennikd,dpocz,id_spr_rezer,dpor,dkor,przylacz_skasowany,jr,id_spr) 
as select ((998 || x0.rej ) || LPAD (x0.strona ,5 ,'0' )) ,
x0.nrpl ,
x0.rej ,
x0.strona ,
(((998 || x0.rej ) || LPAD (x0.strona ,5 ,'0' )) || x8.nrpr ) ,
x8.ppe ,
x8.nrpr ,
x0.npp ,
x0.mscgus ,
x0.pdgrp ,
x9.pum01 ,
x9.pum02 ,
x9.pum03 ,
x9.pum04 ,
x9.pum05 ,
x9.pum06 ,
x9.pum07 ,
x9.pum08 ,
x9.pum09 ,
x9.pum10 ,
x9.pum11 
,x9.pum12 ,
x1.otp ,
x3.nazwa ,
x3.kod_p ,
x2.nazwa ,
x3.adres_poczty ,
x0.dom ,
x0.mieszk ,
x2.gus ,
x0.dinit ,
x0.dend 
,x5.tar ,
x0.is_koncesja ,
x1.id_dos ,
x9.nrpr ,
x0.skasowany ,
x0.potrzeby ,
x8.tg1 ,
x8.tg2 ,
x8.tg3 ,
x8.tg4 ,
x8.tg5 ,
x8.tg6 ,x0.mc_roz ,x8.epr ,x8.data_um_przes ,x8.nr_um_przes ,x8.data_wyg_um_przes ,x1.cennik ,x1.cennik2 ,x0.cennikd ,x8.dpocz ,x1.id_spr_rezer ,x1.dpor ,x1.dkor ,
x8.skasowany ,
x0.jr ,
x1.id_spr 
from energos_rze:"galkom".kpp x0 ,
energos_rze:"galkom".kpp_ext x1 ,
energos_rze:"galkom".sl_miejsc x2 ,
energos_rze:"galkom".sl_ulic x3 ,
energos_rze:"galkom".rejony x4 ,
energos_rze:"galkom".taryfy x5 ,
energos_rze:"galkom".sl_gruplat x6 ,
energos_rze:"galkom".kpl x7 ,
energos_rze:"galkom".przylacz x8 ,
energos_rze:"galkom".przyl_ext x9 
where ((((((((((((((x0.id = x1.id_kpp ) 
AND (x0.nr_miejsc = x2.nr_miejsc ) ) 
AND (x0.nr_miejsc = x3.nr_miejsc ) ) 
AND (x0.nr_ulica = x3.nr_ulica ) ) 
AND (x0.rej = x4.nr_rej ) ) 
AND (x0.jr = x4.jr ) ) 
AND (x7.nrpl = x0.nrpl ) ) 
AND (x7.gr = x6.grupa ) ) 
AND (x5.nrtar = x1.tar ) ) 
AND (x0.jr = x7.jr ) ) 
AND (x0.rej = x8.rej ) ) 
AND (x0.strona = x8.strona ) ) 
AND (x8.id = x9.id_przyl ) ) 
AND ((x0.rej = x8.rej ) 
AND (x0.jr = x8.jr ) ) ) ;