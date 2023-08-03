--出院病人的处方明细;
--剂量单位的总量（但不一定是实际使用量），所以需要使用医嘱记录的“单次用量”字段
--总量如何计算？长嘱、临嘱都可以用【医嘱执行时间】这个表，或者使用 zl_adviceexecount()函数来计算指定时间内医嘱的执行次数。


with source as (
--源消耗数据（精确到病人）
select distinct a.id as 医嘱id, a.开嘱科室id, f.住院医师, e.名称 as 开嘱科室, a.病人id, a.姓名 as 病人姓名, '总 第 ' || f.主页id || ' 次入院' as 第x次入院
, d.名称 as 药品, a.单次用量 as 单次消耗剂量, d.计算单位 as 剂量单位
, zl_adviceexecount(a.id, to_date('20230209000000', 'yyyy-mm-dd hh24:mi:ss'), to_date('30000101235959', 'yyyy-mm-dd hh24:mi:ss')) as 医嘱执行次数
, a.单次用量 * zl_adviceexecount(a.id, to_date('20230209000000', 'yyyy-mm-dd hh24:mi:ss'), to_date('30000101235959', 'yyyy-mm-dd hh24:mi:ss')) as 总消耗剂量, g.ddd值
, round(a.单次用量 * zl_adviceexecount(a.id, to_date('20230209000000', 'yyyy-mm-dd hh24:mi:ss'), to_date('30000101235959', 'yyyy-mm-dd hh24:mi:ss')) / g.ddd值, 2) as "DDDs"
, f.住院天数
from 病人医嘱记录 a
join 药品特性 c on a.诊疗项目id = c.药名id
join 诊疗项目目录 d on a.诊疗项目id = d.id
join 部门表 e on a.开嘱科室id = e.id
join 病案主页 f on a.病人id = f.病人id and a.主页id = f.主页id
join (select distinct a.id as 医嘱id, b.收费细目id as 药品id, c.ddd值
from 病人医嘱记录 a
join 病人医嘱发送 b on a.id = b.医嘱id
join 药品规格 c on b.收费细目id = c.药品id) g on a.id = g.医嘱id
where a.医嘱状态 > 4
and a.诊疗类别 in ('5', '6', '7')
and a.姓名 not like '%测试%'
and a.开嘱医生 <> '系统管理员'
and a.病人来源 = 2
--出院带药的不算
and a.执行性质 <> 5
--必须是已经出院了的病人
and f.出院日期 between to_date('20230401000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230430235959', 'yyyy-mm-dd hh24:mi:ss')
and c.抗生素 > 0
order by a.开嘱科室id, a.病人id
)
, 病人用药强度 as (select 开嘱科室id, 开嘱科室, 住院医师, 病人id, 病人姓名, 第x次入院 as 该病人第几次入院, sum("DDDs") as "该病人∑DDDs", 住院天数 as 该病人住院天数
, round(sum("DDDs") * 100 / 住院天数, 2) as 该病人用药强度 
from source
group by 开嘱科室id, 开嘱科室, 住院医师, 病人id, 病人姓名, 第x次入院, 住院天数
order by 开嘱科室id, 开嘱科室, 住院医师, 病人id, 病人姓名, 第x次入院, 住院天数
)
, 医生用药强度 as (
select 开嘱科室id, 开嘱科室, 住院医师, sum("该病人∑DDDs") as "该医师∑DDDs"
, sum(该病人住院天数) as 该医师住院天数, round(sum("该病人∑DDDs") * 100 / sum(该病人住院天数), 2) as 该医师用药强度
from 病人用药强度
group by 开嘱科室id, 开嘱科室, 住院医师
)
, 科室用药强度 as (
select 开嘱科室id, 开嘱科室, sum("该医师∑DDDs") as "该科室∑DDDs"
, sum(该医师住院天数) as 该科室住院天数, round(sum("该医师∑DDDs") * 100 / sum(该医师住院天数), 2) as 该科室用药强度
from 医生用药强度
group by 开嘱科室id, 开嘱科室
order by 开嘱科室id, 开嘱科室
)
select * from 病人用药强度
;