select a.调价号, decode(a.类型, 0, '售价调价', 1, '成本价调价', 2, '成本价售价一起调整', a.类型) as 类型, a.执行日期, a.填制日期, a.填制人, a.说明, decode(a.分类, 0, '药品', 1, '卫材', a.分类) as 分类 from 调价汇总记录 a
where a.分类 = 0
and a.执行日期 between to_date('20230201000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230228235959', 'yyyy-mm-dd hh24:mi:ss')
order by a.执行日期 desc;
