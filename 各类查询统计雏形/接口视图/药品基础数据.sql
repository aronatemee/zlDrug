select a.药品id as "医院产品ID（后端）", a.编码 as "医院产品ID（前端）" , a.名称 as "产品名称（必填）"
, b.药品剂型 as "剂型", a.规格 as "规格", a.产地 as "厂家", a.批准文号 as "批准文号"
/*, a.撤档时间*/, case when to_date('3000/1/1', 'yyyy/mm/dd') = a.撤档时间 then '在用' else '已停用' end as 是否停用
from 药品目录 a
join 药品特性 b on a.药名id = b.药名id
