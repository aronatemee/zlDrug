select distinct a.开嘱时间, a.开嘱科室id, c.名称 as 开单科室, a.开嘱医生, a.id, a.姓名 as 病人姓名, a.医嘱内容, b.医嘱内容 as 给药途径
, a.单次用量, a.首次用量, a.总给予量, a.执行频次 
from 病人医嘱记录 a
join 病人医嘱记录 b on a.相关id = b.id
join 部门表 c on a.开嘱科室id = c.id
where (b.医嘱内容 like '%雾化%')
and b.诊疗类别 = 'E'
and a.开嘱时间 between to_date('20230101000000', 'yyyy-mm-dd hh24:mi:ss') and to_date('20230331235959', 'yyyy-mm-dd hh24:mi:ss')
order by a.开嘱时间, a.开嘱科室id, a.开嘱医生, a.id
;

