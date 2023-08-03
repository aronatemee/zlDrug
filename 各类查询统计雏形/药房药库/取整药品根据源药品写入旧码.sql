--1、查询对应关系
with temp as (
--找出所有取整的项目，并将所有编码去掉右侧第一位字符，必定是13位编码
select a.编码, substr(a.编码, 1, 12) as 去掉右侧首位字符的编码 
from 收费项目目录 a
join 药品规格 b on a.id = b.药品id
where b.药品来源 like '%取整%'
and length(a.编码) = 13
)
, temp_2 as (
select d.编码 as "（待处理）取整药品的编码", d.去掉右侧首位字符的编码 as "（源）非取整药品的编码", c.说明 as "（源）旧系统编码"
from 收费项目目录 c
join temp d on c.编码 = d.去掉右侧首位字符的编码
)
select distinct * from temp_2

;

--2、导出excel
create table temp_3(取整药品的编码 VARCHAR2(400), 非取整药品的编码 VARCHAR2(400), 旧系统编码 VARCHAR2(400))
;

--3、通过导出的excel再写回来
select * from temp_3 for update
;

--4、备份收费项目目录
create table 收费项目目录_bak_20230619 as select * from 收费项目目录
;

--5、update语句
update 收费项目目录 a
set (a.说明) = (select distinct temp_3.旧系统编码 from temp_3 where a.编码 = temp_3.取整药品的编码)
where exists (select temp_3.旧系统编码 from temp_3 where a.编码 = temp_3.取整药品的编码)
;

drop table temp_3
;
