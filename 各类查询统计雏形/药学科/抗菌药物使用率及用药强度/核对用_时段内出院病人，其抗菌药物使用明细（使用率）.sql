--配合《抗菌药物使用率及用药强度》报表使用
--时段内出院病人，其抗菌药物使用明细

select * from (
select null as 序号
, 医嘱期效, 出院科室, 住院医师, 病人id, 病人姓名, 总第x次入院
, 药品名称, 抗生素, 单次用量, 首次用量, 总给予量, ddd值, 排序根据
, 开嘱时间, 出院日期 from (
--总出院病人处方明细。
select decode(a.医嘱期效, 0, '长嘱', 1, '临嘱', a.医嘱期效) as 医嘱期效, e.名称 as 出院科室, b.住院医师, a.病人id, a.姓名 as 病人姓名, b.主页id as 总第x次入院
, c.名称 as 药品名称, g.抗生素, a.单次用量, a.首次用量, a.总给予量, f.ddd值, b.出院科室id || b.病人id || b.主页id || b.出院日期 as 排序根据
, a.开嘱时间, b.出院日期
from 病人医嘱记录 a
join 病案主页 b on a.病人id = b.病人id and a.主页id = b.主页id
join 收费项目目录 c on a.收费细目id = c.id
join 部门表 d on a.开嘱科室id = d.id
join 部门表 e on b.出院科室id = e.id
join 药品规格 f on c.id = f.药品id
join 药品特性 g on a.诊疗项目id = g.药名id
where a.诊疗类别 in ('5', '6', '7')
and c.名称 not like '%测试%' 
and a.开嘱医生 <> '系统管理员'
and a.姓名 not like '%测试%'
and a.病人来源 = 2
and a.医嘱状态 > 4
and f.发药类型 <> '大输液类' 
and b.出院日期 between to_date('20230301000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230331235959', 'yyyy-mm-dd hh24:mi:ss')

--以下用于导出具体医生或科室的核对数据_begin
--and b.住院医师 = '李彩霜'
--and e.名称 like '%肛肠外科%'
--以下用于导出具体医生或科室的核对数据_end

order by b.出院科室id, b.病人id, b.主页id, c.id, b.出院日期
)


union all 


select distinct row_number() over(order by 排序根据) as 序号
, null as 医嘱期效, null as 出院科室, 住院医师, null as 病人id, null as 病人姓名, null as 总第x次入院
, null as 药品名称, null as 抗生素, null as 单次用量, null as 首次用量, null as 总给予量, null as ddd值, 排序根据
, null as 开嘱时间, null as 出院日期 from (
--总出院病人处方明细。
select distinct b.住院医师, b.出院科室id || b.病人id || b.主页id || b.出院日期 as 排序根据
from 病人医嘱记录 a
join 病案主页 b on a.病人id = b.病人id and a.主页id = b.主页id
join 收费项目目录 c on a.收费细目id = c.id
join 部门表 d on a.开嘱科室id = d.id
join 部门表 e on b.出院科室id = e.id
join 药品规格 f on c.id = f.药品id
join 药品特性 g on a.诊疗项目id = g.药名id
where a.诊疗类别 in ('5', '6', '7')
and c.名称 not like '%测试%' 
and a.开嘱医生 <> '系统管理员'
and a.姓名 not like '%测试%'
and a.病人来源 = 2
and a.医嘱状态 > 4
and f.发药类型 <> '大输液类' 
and b.出院日期 between to_date('20230301000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230331235959', 'yyyy-mm-dd hh24:mi:ss')

--以下用于导出具体医生或科室的核对数据_begin
--and b.住院医师 = '李彩霜'
--and e.名称 like '%肛肠外科%'
--以下用于导出具体医生或科室的核对数据_end

)
)
order by 排序根据, 医嘱期效 desc
