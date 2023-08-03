
--查询时段内【门诊】所有处方明细
with 所有处方 as (
select null as 序号, a.id as 医嘱id, b.no as 处方号, a.开嘱科室id, d.名称 as 开嘱科室, a.开嘱医生
, a.病人id, g.门诊号, a.姓名 as 病人姓名, a.年龄, a.医嘱内容, decode(c.抗生素, 0, '', '是') as 是否抗菌药物
, round(a.单次用量 / f.剂量系数, 2) as 单次用量, a.总给予量, e.计算单位 as 单位, a.天数 
, a.开嘱时间
from 病人医嘱记录 a
join 病人医嘱发送 b on a.id = b.医嘱id
join 药品特性 c on a.诊疗项目id = c.药名id
join 部门表 d on a.开嘱科室id = d.id
join 收费项目目录 e on b.收费细目id = e.id
join 药品规格 f on e.id = f.药品id
join 病人信息 g on a.病人id = g.病人id
where a.医嘱状态 > 4
and a.诊疗类别 in ('5', '6')
and a.姓名 not like '%测试%'
and a.开嘱医生 <> '系统管理员'
and a.病人来源 = 1
and a.开嘱时间 between to_date('20230601000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230601235959', 'yyyy-mm-dd hh24:mi:ss')
)
, 处方区分标识 as (
select row_number() over(order by 处方号) as 序号, 医嘱id, 处方号, 开嘱科室id, 开嘱科室, 开嘱医生, 病人id, 门诊号, 病人姓名, 年龄, 医嘱内容, 是否抗菌药物, 单次用量, 总给予量, 天数, 开嘱时间 from (
select distinct null as 医嘱id, b.no as 处方号, null as 开嘱科室id, null as 开嘱科室, null as 开嘱医生
, null as 病人id, null as 门诊号, null as 病人姓名, null as 年龄, null as 医嘱内容, null as 是否抗菌药物
, null as 单次用量, null as 总给予量, null as 单位, null as 天数 
, null as 开嘱时间
from 病人医嘱记录 a
join 病人医嘱发送 b on a.id = b.医嘱id
join 药品特性 c on a.诊疗项目id = c.药名id
join 部门表 d on a.开嘱科室id = d.id
join 收费项目目录 e on b.收费细目id = e.id
join 药品规格 f on e.id = f.药品id
join 病人信息 g on a.病人id = g.病人id
where a.医嘱状态 > 4
and a.诊疗类别 in ('5', '6')
and a.姓名 not like '%测试%'
and a.开嘱医生 <> '系统管理员'
and a.病人来源 = 1
and a.开嘱时间 between to_date('20230601000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230601235959', 'yyyy-mm-dd hh24:mi:ss')
)
)
select * from (
select y.序号, z.医嘱id, z.处方号, z.开嘱科室id, z.开嘱科室, z.开嘱医生
, z.病人id, z.门诊号, z.病人姓名, z.年龄, z.医嘱内容, z.是否抗菌药物
, z.单次用量, z.总给予量, 单位, z.天数 
, z.开嘱时间 
from 所有处方 z
join 处方区分标识 y on z.处方号 = y.处方号
)
order by 处方号, 序号
