--配合《抗菌药物用药强度》报表使用
--时段内出院病人，其抗菌药物使用明细

--数据
select * from (
select null as 序号
, 出院科室, 住院医师, 病人id, 病人姓名, 第x次入院
, 药品名称, 实际剂量, 剂量单位, ddd值, 住院天数, 排序根据 
from (
--总出院病人处方明细。
select b.出院科室id, g.名称 as 出院科室, b.住院医师, a.病人id, a.姓名 as 病人姓名, b.主页id as 第x次入院, b.出院日期
, a.药品id, e.名称 as 药品名称, a.实际数量 * c.剂量系数 as 实际剂量, c.剂量系数, d.计算单位 as 剂量单位, a.填制日期 as 申请日期, a.审核日期 as 发药日期, b.住院天数, c.ddd值
, b.出院科室id || b.病人id || b.主页id || b.出院日期 as 排序根据
from 药品收发记录 a
join 病案主页 b on a.病人id = b.病人id and a.主页id = b.主页id
join 药品规格 c on a.药品id = c.药品id
join 诊疗项目目录 d on c.药名id = d.id
join 收费项目目录 e on a.药品id = e.id
join 药品特性 f on c.药名id = f.药名id
join 部门表 g on b.出院科室id = g.id
where (a.记录状态 = 1 or mod(a.记录状态, 3) = 0)
and a.单据 in ('8', '9', '10')
and a.病人来源 = 2
and f.抗生素 <> 0
and b.出院日期 between to_date('20230301000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230331235959', 'yyyy-mm-dd hh24:mi:ss')

--以下用于导出具体医生或科室的核对数据_begin
--and g.名称 = '外二科病区'
--and b.住院医师 = '张硕凌'
--以下用于导出具体医生或科室的核对数据_end

order by b.出院科室id, b.病人id, b.主页id, e.id, b.出院日期
)


union all 


--排序
select distinct row_number() over(order by 排序根据) as 序号
, null as 出院科室, null as 住院医师, null as 病人id, null as 病人姓名, null as 第x次入院
, null as 药品名称, null as 实际剂量, null as 剂量单位, null as ddd值, null as 住院天数, 排序根据
from (
--总出院病人处方明细。
select distinct b.出院科室id || b.病人id || b.主页id || b.出院日期 as 排序根据
from 药品收发记录 a
join 病案主页 b on a.病人id = b.病人id and a.主页id = b.主页id
join 药品规格 c on a.药品id = c.药品id
join 诊疗项目目录 d on c.药名id = d.id
join 收费项目目录 e on a.药品id = e.id
join 药品特性 f on c.药名id = f.药名id
join 部门表 g on b.出院科室id = g.id
where (a.记录状态 = 1 or mod(a.记录状态, 3) = 0)
and a.单据 in ('8', '9', '10')
and a.病人来源 = 2
and f.抗生素 <> 0
and b.出院日期 between to_date('20230301000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230331235959', 'yyyy-mm-dd hh24:mi:ss')

--以下用于导出具体医生或科室的核对数据_begin
--and g.名称 = '外二科病区'
--and b.住院医师 = '张硕凌'
--以下用于导出具体医生或科室的核对数据_end

)
)
order by 排序根据, 序号
