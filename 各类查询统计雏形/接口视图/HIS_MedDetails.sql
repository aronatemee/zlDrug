
--接口视图：HIS_MedDetails
--就诊流水号、患者编号、患者姓名、记账时间、门诊或住院、库房名称、消耗科室代码、消耗科室名称、药品代码、药品名称、药品类别编码、药品类别名称、药品规格、药品单位、单价、消耗量、金额


create or replace view HIS_MedDetails as 
select a.病人id || a.主页id as 就诊流水号, a.病人id as 患者编号, a.姓名 as 患者姓名, a.填制日期 as 记账时间, decode(a.病人来源, 1, '门诊', 2, '住院', a.病人来源) as 门诊或住院
, b.名称 as 库房名称, c.编码 as 消耗科室代码, c.名称 as 消耗科室名称
, d.编码 as 药品代码, d.名称 as 药品名称, d.类别 as 药品类别编码, e.名称 as 药品类别名称
, d.规格 as 药品规格, d.计算单位 as 药品单位, round(a.零售价, 2) as 单价, round(a.实际数量, 2) as 消耗量, round(a.零售金额, 2) as 金额
from 药品收发记录 a
join 部门表 b on a.库房id = b.id
join 部门表 c on a.对方部门id = c.id
join 收费项目目录 d on a.药品id = d.id
join 收费项目类别 e on d.类别 = e.编码
join 药品规格 f on d.id = f.药品id
where a.单据 in (8, 9, 10)
and (a.记录状态 = 1 or Mod(a.记录状态, 3) = 0)
;
