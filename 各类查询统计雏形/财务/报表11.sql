/*select * from (
with 属性组 as
(
select listagg(项目,',') as 扩展属性,药品id  from  药品规格扩展信息
group by 药品id
)*/
select z.序号, z.类别, z.类型, z.no, z.编码, z.药品名称, z.进价金额, z.零价金额, z.进零差, z.数量, z.单位, z.规格, z.领用科室, z.产地, listagg(z.扩展信息, ', ') as 扩展信息, z.审核日期
from (
SELECT distinct 1 as 序号, decode(e.类别, '5', '西成药', '6', '中成药', '7', '中草药', e.类别) as 类别, decode(A.单据,6,'移库',7,'领用',A.单据) as 类型,a.no,e.编码,e.名称 as 药品名称,
      A.成本金额 AS 进价金额,
      A.零售金额 AS 零价金额,
      A.差价  AS 进零差,
     (A.实际数量 / i.药库包装)  as 数量,
     i.药库单位 as 单位
     , e.规格
     , c.名称 as 领用科室
     , a.产地
     , j.项目 as 扩展信息
     , a.审核日期
  FROM 药品收发记录 A, 部门表 B, 部门表 C, 药品收发主表 D, 收费项目目录 e,诊疗项目目录 f,药品规格 i,药品规格扩展信息 j
 WHERE A.库房ID = B.ID
   AND A.对方部门ID = C.ID
   AND A.单据 in(6,7)
   And A.库房ID  in (80,77)
   and a.药品id=e.id
   AND A.入出系数 = -1
   AND A.NO = D.NO(+)
   AND D.单据(+) in(6,7)
   And A.对方部门ID = 74
   and i.药名id= f.id
   and i.药品id=a.药品id
   AND A.库房ID = D.库房id(+)
   and a.药品id=j.药品id(+)
   And A.对方部门ID = D.对方部门ID(+)
   --and j.项目 in ('4+7', '国谈药品')
   And A.填制日期 between to_date('20230201000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230630235959', 'yyyy-mm-dd hh24:mi:ss')
   order by 序号, e.类别, a.单据, a.no, e.编码, e.名称, a.成本金额, a.零售金额, a.差价, a.实际数量, i.药库单位, e.规格, c.名称, a.产地, j.项目, a.审核日期
   ) z
 group by z.序号, z.类别, z.类型, z.no, z.编码, z.药品名称, z.进价金额, z.零价金额, z.进零差, z.数量, z.单位, z.规格, z.领用科室, z.产地, z.审核日期
 
 
 union all



  select z.序号, z.类别, z.类型, z.no, z.编码, z.药品名称, z.进价金额, z.零价金额, z.进零差, z.数量, z.单位, z.规格, z.领用科室, z.产地, listagg(z.扩展信息, ', ') as 扩展信息, z.审核日期
from (
SELECT distinct 2 as 序号, decode(e.类别, '5', '西成药', '6', '中成药', '7', '中草药', e.类别) as 类别,'科室移回' as 类型,a.no,e.编码,e.名称 as  药品名称,
--按科室汇总
       -1*A.成本金额 AS 进价金额,
       -1*A.零售金额 AS 零价金额,
       -1*A.差价 AS 进零差
       ,(-1*A.实际数量 / i.药库包装) as 数量 
       ,i.药库单位 as 单位
       , e.规格
       , c.名称 as 领用科室
       , a.产地
       , j.项目 as 扩展信息
       , a.审核日期
  FROM 药品收发记录 A, 部门表 B, 部门表 C, 药品收发主表 D, 收费项目目录 e,诊疗项目目录 f,药品规格 i,药品规格扩展信息 j
 WHERE A.库房ID = B.ID
   AND A.对方部门ID = C.ID
   AND A.单据 =6
   And A.对方部门ID  in (80,77)
   and a.药品id=e.id
   AND A.入出系数 = -1
   AND A.NO = D.NO(+)
   AND D.单据(+) =6
   and i.药名id= f.id
   And A.库房ID = 73
   and i.药品id=a.药品id
   AND A.库房ID = D.库房id(+)
   And A.对方部门ID = D.对方部门ID(+)
   and a.药品id=j.药品id(+)
   --and j.项目 in ('4+7', '国谈药品')
   And A.填制日期 between to_date('20230201000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230630235959', 'yyyy-mm-dd hh24:mi:ss')
   order by 序号, e.类别, a.单据, a.no, e.编码, e.名称, a.成本金额, a.零售金额, a.差价, a.实际数量, i.药库单位, e.规格, c.名称, a.产地, j.项目, a.审核日期
 ) z
 group by z.序号, z.类别, z.类型, z.no, z.编码, z.药品名称, z.进价金额, z.零价金额, z.进零差, z.数量, z.单位, z.规格, z.领用科室, z.产地, z.审核日期
 
 order by 审核日期, 领用科室, 药品名称, 序号

