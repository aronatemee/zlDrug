
--查询库存低于上下限的药品

with source as (
select a.库房id, a.药品id, sum(a.可用数量) as 可用数量, sum(a.实际数量) as 实际数量
from 药品库存 a
where a.库房id in ('80', '95')
group by a.库房id, a.药品id
)
select c.名称 as 库房, source.药品id, d.名称 as 药品, source.可用数量, source.实际数量, b.上限, b.下限
, case when source.可用数量 > b.下限 and source.可用数量 < b.上限 then '低于上限，高于下限'
when source.可用数量 < b.下限 then '低于下限' end as 结论
from source
left join 药品储备限额 b on source.库房id = b.库房id and source.药品id = b.药品id
join 部门表 c on source.库房id = c.id
join 收费项目目录 d on source.药品id = d.id
where (source.可用数量 > b.下限 and source.可用数量 < b.上限)
or source.可用数量 < b.下限
order by source.库房id, source.药品id
