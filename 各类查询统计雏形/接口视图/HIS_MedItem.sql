
--接口视图：HIS_MedItem
create or replace view HIS_MedItem as
select a.编码, a.名称, d.编码 as 药品类别编码, d.名称 as 药品类别名称 
from 收费项目目录 a
join 药品规格 b on a.id = b.药品id
join 诊疗项目目录 c on b.药名id = c.id
join 诊疗项目类别 d on c.类别 = d.编码
;


