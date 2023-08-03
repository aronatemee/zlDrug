
/* 住院抗菌药物用药强度汇总表（科室汇总 不含留观） */
--用药强度
with drugproperty as (
select b.药品id, b.药名id, h.名称 as 药品, b.剂量系数, a.抗生素, b.ddd值 
from 药品特性 a
join 药品规格 b on a.药名id = b.药名id
join 收费项目目录 h on b.药品id = h.id
)
--再按照 科室 汇总
select zzz.科室, sum(zzz.本期抗生素总消耗量) as 本期抗生素总消耗量, sum(zzz.本期抗生素总DDDs值) as 本期抗生素总DDDs值, sum(zzz.该病人住院天数) as 科室出院病人总住院天数 from (
--接着按 科室、病人 汇总
select zz.科室, zz.病人id, sum(zz.药物消耗总量) as 本期抗生素总消耗量, sum(zz.药品DDDs值) as 本期抗生素总DDDs值, zz.该病人住院天数 from (
--首先按 科室、病人、药品 汇总
select z.科室,z.病人id, z.药品, sum(z.实际数量) as 药物消耗总量, z.药品DDD值, sum(z.实际数量) / z.药品DDD值 as 药品DDDs值, sum(z.住院天数) as 该病人住院天数 from (
--源数据集
select g.名称 as 科室, '总第 ' || c.主页id || ' 次入院' as 入院次数, c.病人id
, d.药品, c.实际数量 * d.剂量系数 as 实际数量, d.ddd值 as 药品DDD值, e.住院天数
from 药品收发记录 c
join drugproperty d on c.药品id = d.药品id
join 病案主页 e on c.病人id = e.病人id and c.主页id = e.主页id 
join 部门表 g on e.出院科室id = g.id
where e.主页id > 0
and e.出院日期 between to_date('20230401000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230430235959', 'yyyy-mm-dd hh24:mi:ss')
and d.抗生素 = 1
)z
group by z.科室, z.病人id, z.药品, z.药品DDD值
order by z.科室, z.病人id, z.药品, z.药品DDD值
)zz
group by zz.科室, zz.病人id, zz.该病人住院天数
)zzz
group by zzz.科室
;


--查询住院天数。
select sum(a.住院天数) as 本期住院天数, b.名称 as 科室
from 病案主页 a
join 部门表 b on a.出院科室id = b.id
where a.主页id > 0 
and a.出院日期 between to_date('20230401000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230430235959', 'yyyy-mm-dd hh24:mi:ss')
group by b.名称
;
