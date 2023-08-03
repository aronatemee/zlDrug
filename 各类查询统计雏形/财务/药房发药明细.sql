with 扩展属性 as (select listagg(a.项目, ',') as 扩展属性, a.药品id from 药品规格扩展信息 a group by a.药品id)
, temp as (
select b.no, d.名称 as 库房, b.姓名 as 病人, e.名称 as 药品, e.规格
, case when trunc(b.实际数量 / f.药库包装) > 0 then trunc((b.实际数量 / f.药库包装)) else 0 end as 药库数量, f.药库单位 
, case when trunc(mod(b.实际数量, f.药库包装)) > 0 then mod(b.实际数量, f.药库包装) else b.实际数量 end as 售价数量, e.计算单位 as 售价单位
, b.成本金额 as 进价金额, b.零售金额 as 零价金额, b.差价 as 进零差
, b.产地 as 生产厂商, b.审核日期 as 发药日期, c.扩展属性
from 药品收发记录 b
join 扩展属性 c on b.药品id = c.药品id
join 部门表 d on b.库房id = d.id
join 收费项目目录 e on b.药品id = e.id
join 药品规格 f on b.药品id = f.药品id
join 诊疗项目目录 g on f.药名id = g.id
where d.名称 in ('门诊药房', '中药房', '住院药房')
and (b.记录状态 = 1 or mod(b.记录状态, 3) = 0)
and b.单据 in (8, 9, 10)
and b.姓名 not like '%测试%'
and b.填制人 not like '%管理员%'
and b.审核日期 between to_date('20230201000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230228235959', 'yyyy-mm-dd hh24:mi:ss')
)
, temp2 as (
select * from temp 
where temp.扩展属性 like '%' || '' || '%'
)
select * from temp
order by temp.no, temp.发药日期;
