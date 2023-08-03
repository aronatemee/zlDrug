
--以下是使用率
with 数据源 as (
select 出院科室id, 出院科室, 住院医师, count(decode(抗生素, 0, NULL, 抗生素)) as 含抗菌出院人次, count(decode(抗生素, 0, 'NULL', 抗生素)) as 总出院人次 from (
select 出院科室id, 出院科室, 住院医师, 病人姓名, 总第x次入院, max(抗生素) as 抗生素 from (
--总出院病人处方明细。
select decode(a.医嘱期效, 0, '长嘱', 1, '临嘱', a.医嘱期效) as 医嘱期效, b.出院科室id, e.名称 as 出院科室, b.住院医师, a.病人id, a.姓名 as 病人姓名, b.主页id as 总第x次入院
, c.名称 as 药品名称, g.抗生素
, a.单次用量--剂量单位，即 “诊疗项目目录中的计算单位”
, a.首次用量
, a.总给予量--总给予量：售价单位，即 “收费项目目录中的计算单位”；长嘱好像不会有总给予量
, f.ddd值
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
and b.出院日期 between {:KSSJ} and {:JSSJ}
order by b.出院科室id, b.病人id, b.主页id, c.id, b.出院日期
)
group by 出院科室id, 出院科室, 住院医师, 病人id, 病人姓名, 总第x次入院
order by 出院科室id, 出院科室, 住院医师, 病人id, 病人姓名, 总第x次入院
)
group by 出院科室id, 出院科室, 住院医师
order by 出院科室id, 出院科室, 住院医师
)
, 管床医生抗菌药物使用率 as (
select 出院科室id, 出院科室, 住院医师, 含抗菌出院人次, 总出院人次, round(含抗菌出院人次 * 100 / 总出院人次, 2) as 抗菌药物使用率 
from 数据源
)
, 科室抗菌药物使用率 as (
select 出院科室id, 出院科室, 科室含抗菌出院人次, 科室总出院人次, round(科室含抗菌出院人次 * 100 / 科室总出院人次) as 科室抗菌药物使用率 from (
select 出院科室id, 出院科室, sum(含抗菌出院人次) as 科室含抗菌出院人次, sum(总出院人次) as 科室总出院人次 
from 数据源
group by 出院科室id, 出院科室
)
)
--以下是用药强度
, 明细 as (
--明细
select b.出院科室id, g.名称 as 出院科室, b.住院医师, a.病人id, a.姓名 as 病人姓名, b.主页id as 第x次入院, b.出院日期
, a.药品id, e.名称 as 药品名称, a.实际数量 * c.剂量系数 as 实际剂量, c.剂量系数, d.计算单位, a.填制日期 as 申请日期, a.审核日期 as 发药日期, b.住院天数, c.ddd值
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
and b.出院日期 between {:KSSJ} and {:JSSJ}
/*and a.姓名 = '李坚'*/
)
, 医师每个药DDDs as (
select 出院科室id, 出院科室, 住院医师
, 药品id, 药品名称, 剂量系数, sum(实际剂量) as 病人实际剂量, 计算单位, ddd值, round(sum(实际剂量) / ddd值, 2) as DDDs值
from 明细 h
group by 出院科室id, 出院科室, 住院医师, 药品id, 药品名称, 剂量系数, 计算单位, ddd值
order by 出院科室id, 出院科室, 住院医师, 药品id, 药品名称, 剂量系数, 计算单位, ddd值
)
, 医师所有药DDDs汇总 as (
select 出院科室id, 出院科室, 住院医师, sum(DDDs值) as "∑DDDs值"
from 医师每个药DDDs
group by 出院科室id, 出院科室, 住院医师
)
, 医师收治患者人天数 as (
select distinct 出院科室id, 出院科室, 住院医师, 病人id, 住院天数
from 明细 h
)
, 医师收治患者人天数汇总 as (
select 出院科室id, 出院科室, 住院医师, sum(住院天数) as 住院天数 
from 医师收治患者人天数
group by 出院科室id, 出院科室, 住院医师
)
, 管床医师用药强度 as (
select z.出院科室id, z.出院科室, z.住院医师, z."∑DDDs值", y.住院天数, round(z."∑DDDs值" * 100 / y.住院天数) as 抗菌药物使用强度 
from 医师所有药DDDs汇总 z
join 医师收治患者人天数汇总 y on z.出院科室id = y.出院科室id and z.住院医师 = y.住院医师
order by z.出院科室id, z.出院科室, z.住院医师
)
, 科室所有药DDDs汇总 as (
select 出院科室id, 出院科室, sum(DDDs值) as "∑DDDs值"
from 医师每个药DDDs
group by 出院科室id, 出院科室
)
, 科室收治患者人天数汇总 as (
select 出院科室id, 出院科室, sum(住院天数) as 住院天数 
from 医师收治患者人天数
group by 出院科室id, 出院科室
)
, 科室用药强度 as (
select z.出院科室id, z.出院科室, z."∑DDDs值", y.住院天数, round(z."∑DDDs值" * 100 / y.住院天数) as 抗菌药物使用强度 
from 科室所有药DDDs汇总 z
join 科室收治患者人天数汇总 y on z.出院科室id = y.出院科室id
order by z.出院科室id, z.出院科室
)
select * from 管床医生抗菌药物使用率 zz
full join 管床医师用药强度 yy on zz.出院科室id = yy.出院科室id and zz.出院科室 = yy.出院科室 and zz.住院医师 = yy.住院医师
