--更改之后的 新·药袋
/* 
药袋，使用SQL来编写：
时点对照表已完成，

打印药袋规则：
1. 固定早上只出今日长嘱、临嘱药袋；下午出今天及明天长嘱药袋、今天临嘱药袋。（需使用最新版本药品系统进行测试）
2. 长嘱必定有药袋，临嘱只有执行次数 <= 单日执行频次的才打印药袋。

换页标识规则：
1. 每 5 种药 + 1 行汇总，换页。
2. 同名时点合并，不同时点换页。
3. 若有嘱托，该药单独计算药袋。
4. 若药品规格中的使用说明字段有值，则单独计算。（此处一般是标识0-8度药品需单独保存）（未完成）
5. 药品名称中含有“咀嚼”、“泡腾”的，需要单独计算药袋。（完成）

每个药袋只能有五种药，那么就需要先用row_number列出同病人、同日、同时点的药品行号，然后用 行号 / 5 来换页！

别忘了顺序要和摆药单一致。

床号有可能含有非数字：cast(regexp_replace(出院病床, '[^0-9]', '') as numeric)

*/
select * from (
select * from (
--计算实际换页标识。
select zz.科室, zz.床号, zz.住院号, zz.姓名, zz.护士实际一次发送哪几天 as 真_服药日期, zz.服药时间, zz.医嘱, zz.规格, zz.用法, zz.执行频次, zz.频率次数, zz.用量, zz.医生嘱托, zz.床号0, zz.病人id, zz.首次, zz.嘱托换页, zz.咀嚼泡腾换页
, zz.病人id || '/' || to_char(zz.日期, 'yyyy-mm-dd') || '/' || zz.匹配 || '/' || zz.嘱托换页 || '/' || zz.咀嚼泡腾换页 ||  '/' || zz.护士实际一次发送哪几天 ||  '/' || trunc(zz.该药袋第几种药 / 6) as 换页标识, zz.药品id
, zz.匹配 from (
--计算原本药袋有多少种药。
select ww.科室, ww.床号, ww.住院号, ww.姓名, ww.服药日期, ww.服药时间, ww.医嘱, ww.规格, ww.用法, ww.执行频次, ww.频率次数, ww.用量, ww.医生嘱托, ww.床号0, ww.病人id, ww.首次
, ww.药品id, case when ww.医生嘱托 is not null then ww.医生嘱托 else '' end as 嘱托换页, case when ww.医嘱 like '%咀嚼%' then '咀嚼' when ww.医嘱 like '%泡腾%' then '泡腾' else '通常' end as 咀嚼泡腾换页
, ww.日期, ww.匹配, row_number() over(partition by ww.床号0, ww.病人id, to_char(ww.日期, 'yyyy-mm-dd'), case when ww.医生嘱托 is not null then ww.药品id || ww.医生嘱托 else '' end, ww.匹配
 order by ww.床号0 asc, ww.病人id asc, to_char(ww.日期, 'yyyy-mm-dd') asc, case when ww.医生嘱托 is not null then ww.药品id || ww.医生嘱托 else '' end, ww.匹配 desc, ww.药品id asc) as 该药袋第几种药, ww.护士实际一次发送哪几天 
 from (
--★★★长嘱必定打印药袋★★★
select * from (
select 
  RPAD('科室: ' || temp_origin_continuous.科室, 30, ' ') as 科室, '床号: ' || temp_origin_continuous.床号 || ' 床' as 床号
  , RPAD('住院号: ' || temp_origin_continuous.住院号, 30, ' ') AS 住院号, '姓名: ' || temp_origin_continuous.姓名 as 姓名
  , RPAD('服药日期: ' || to_char(temp_origin_continuous.日期, 'yyyy-mm-dd'), 30, ' ') as 服药日期, '服药时间: ' || drugbag_rec.时点 as 服药时间
  , temp_origin_continuous.医嘱, temp_origin_continuous.规格, temp_origin_continuous.用法, temp_origin_continuous.执行频次, temp_origin_continuous.频率次数
  , temp_origin_continuous.用量, temp_origin_continuous.医生嘱托
  , cast(regexp_replace(temp_origin_continuous.床号, '[^0-9]', '') as numeric) as 床号0, temp_origin_continuous.病人id, temp_origin_continuous.日期, drugbag_rec.匹配, drugbag_rec.首次, temp_origin_continuous.药品id
  , temp_origin_continuous.开始执行时间, RPAD('服药日期: ' || temp_origin_continuous.护士实际一次发送哪几天, 30, ' ')  as 护士实际一次发送哪几天
from (
--源数据集（转科后，e.出院病床 是最新的床号，而 e.入院病床 是原来的
select distinct i.规格, a.库房id, a.药品id, a.医嘱id, e.出院病床 as 床号, e.病人id, e.主页id, NVL(h.名称, g.名称) as 医嘱
  , RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法
  , c.首次时间 as 日期, b.执行频次, b.频率次数, b.首日数次, f.名称 as 科室, b.姓名||decode(b.婴儿,0,'','【婴】') as 姓名, a.年龄, e.住院号, b.医生嘱托, b.开始执行时间
  , datesplit.要求日期 as 护士实际一次发送哪几天
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c,病人医嘱发送 c2, 收费项目目录 g, 收费项目别名 h, 药品目录 i
  , (select distinct to_char(yzzxsj.要求时间, 'yyyy-mm-dd') as 要求日期, yzzxsj.医嘱id, yzzxsj.发送号 
from 医嘱执行时间 yzzxsj
where (yzzxsj.医嘱id, yzzxsj.发送号) in (
select a.id as 给药途径医嘱id, b.发送号 as 给药途径发送号 
from 病人医嘱记录 a 
join 病人医嘱发送 b on a.id = b.医嘱id
where (a.id, b.发送时间) in (
select 给药途径医嘱id, 药品发送时间 from 
(
select a.id as 药品医嘱id, a.相关id as 给药途径医嘱id, b.发送号 as 药品医嘱发送号, b.发送时间 as 药品发送时间 
from 病人医嘱记录 a
join 病人医嘱发送 b on a.id = b.医嘱id
where (b.no, b.医嘱id) in  
(select no, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
)
)
)) datesplit
  where  a.医嘱id=b.id
  and a.药品id=d.药品id
  and a.病人id=e.病人id
  and a.主页id=e.主页id
  and a.对方部门id=f.id
  and b.id=c.医嘱id
  and b.相关id = c2.医嘱id
  and  a.no=c.no
  and a.药品id = g.id
  and g.id = h.收费细目id(+)
  and a.药品id = i.药品id
  and h.性质(+) = 3
  and datesplit.医嘱id = b.相关id and c2.发送号 = datesplit.发送号
  
  -- 长嘱
  and b.医嘱期效 = 0
  and a.填制日期 > to_date('20230518223500', 'yyyy-mm-dd hh24:mi:ss')
  
/*  -- 没有嘱托
  and (b.医生嘱托 is null or b.医生嘱托 = '')*/
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --只有口服需要打印药袋
  AND A.用法 IN ('口服(发热门诊专用)','口服','冲水服','口服研粉','含服','泡服','胃管注入','鼻饲','气管内滴药','开水冲服','煎服')
  
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_continuous 
--药袋时点表
join drugbag_rec on temp_origin_continuous.执行频次 = drugbag_rec.执行频率
--当前no的首次执行时间 = 首日 && 首日数次匹配（医生填了首日数次才会有值）。
where (temp_origin_continuous.护士实际一次发送哪几天 = to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd') and drugbag_rec.首次 <= temp_origin_continuous.首日数次 and temp_origin_continuous.首日数次 is not null)
--当前no的首次执行时间 = 首日 && 医生没有填写首日数次
or (temp_origin_continuous.护士实际一次发送哪几天 = to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd') and temp_origin_continuous.首日数次 is null)
--当前no首次执行时间 ！= 首日，匹配全部次数。
or (temp_origin_continuous.护士实际一次发送哪几天 <> to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd'))
order by temp_origin_continuous.床号 asc, temp_origin_continuous.病人id asc, temp_origin_continuous.日期 asc, drugbag_rec.匹配 desc, temp_origin_continuous.药品id

) abc


union all

select * from (
--★★★临嘱一天内需打印药袋★★★
--注意，临嘱没有首日数次这个字段。
select 
  RPAD('科室: ' || temp_origin_temporary.科室, 30, ' ') as 科室, '床号: ' || temp_origin_temporary.床号 || ' 床' as 床号
  , RPAD('住院号: ' || temp_origin_temporary.住院号, 30, ' ') AS 住院号, '姓名: ' || temp_origin_temporary.姓名 as 姓名
  , RPAD('服药日期: ' || to_char(temp_origin_temporary.日期, 'yyyy-mm-dd'), 30, ' ') as 服药日期, '服药时间: ' || drugbag_rec.时点 as 服药时间
  , temp_origin_temporary.医嘱, temp_origin_temporary.规格, temp_origin_temporary.用法, temp_origin_temporary.执行频次, temp_origin_temporary.频率次数
  , temp_origin_temporary.用量, temp_origin_temporary.医生嘱托
  , cast(regexp_replace(temp_origin_temporary.床号, '[^0-9]', '') as numeric) as 床号0, temp_origin_temporary.病人id, temp_origin_temporary.日期, drugbag_rec.匹配, drugbag_rec.首次, temp_origin_temporary.药品id
  , temp_origin_temporary.开始执行时间, RPAD('服药日期: ' || to_char(temp_origin_temporary.日期, 'yyyy-mm-dd'), 30, ' ') as 护士实际一次发送哪几天
from (
--源数据集
select distinct i.规格, a.库房id, a.药品id, a.医嘱id, e.出院病床 as 床号, e.病人id, e.主页id, NVL(h.名称, g.名称) as 医嘱
  , RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法
  , c.首次时间 as 日期, b.执行频次, b.频率次数, b.首日数次, f.名称 as 科室, b.姓名||decode(b.婴儿,0,'','【婴】') as 姓名, a.年龄, e.住院号, b.医生嘱托, b.开始执行时间
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c, 收费项目目录 g, 收费项目别名 h, 药品目录 i, 医嘱执行时间 j
  , (
  SELECT Y.医嘱ID, COUNT(Y.医嘱ID) AS 临嘱执行次数 
  FROM 医嘱执行时间 Y
  JOIN 病人医嘱记录 B ON Y.医嘱ID = B.相关ID
  WHERE B.ID IN (select Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
  GROUP BY Y.医嘱ID
  ) YY
  where  a.医嘱id=b.id
  and a.药品id=d.药品id
  and a.病人id=e.病人id
  and a.主页id=e.主页id
  and a.对方部门id=f.id
  and b.id=c.医嘱id
  and  a.no=c.no
  and a.药品id = g.id
  and g.id = h.收费细目id(+)
  and a.药品id = i.药品id
  and b.相关id = j.医嘱id
  and b.相关id = yy.医嘱ID
  and h.性质(+) = 3
  
  
  -- 临嘱
  and b.医嘱期效 = 1
  and a.填制日期 > to_date('20230518223500', 'yyyy-mm-dd hh24:mi:ss')
  
/*  -- 没有嘱托
  and (b.医生嘱托 is null or b.医生嘱托 = '')*/
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --只有口服需要打印药袋
  AND A.用法 IN ('口服(发热门诊专用)','口服','冲水服','口服研粉','含服','泡服','胃管注入','鼻饲','气管内滴药','开水冲服','煎服')
  
  --按照执行次数
  AND YY.临嘱执行次数 <= CASE b.执行频次
  WHEN '每天四次' THEN 4
  WHEN '每天三次' THEN 3
  WHEN '每天二次' THEN 2 
  WHEN '一次性' THEN 1 
  WHEN '每天一次' THEN 1 
  WHEN '每天早晨一次' THEN 1
  WHEN '每天上午一次' THEN 1
  WHEN '每天早晨一次' THEN 1
  WHEN '每天晚上一次' THEN 1
  WHEN '每4小时一次' THEN 6
  WHEN '每6小时一次' THEN 4
  WHEN '每8小时一次' THEN 3
  WHEN '每12小时一次' THEN 2
  WHEN '需要时' THEN 1
  ELSE 0 END
  
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_temporary 
--药袋时点表
left join drugbag_rec on temp_origin_temporary.执行频次 = drugbag_rec.执行频率
order by temp_origin_temporary.床号 asc, temp_origin_temporary.病人id asc, temp_origin_temporary.日期 asc, drugbag_rec.匹配 desc, temp_origin_temporary.药品id
) def
) ww
order by ww.床号0 asc, ww.病人id asc, to_char(ww.日期, 'yyyy-mm-dd') asc, case when ww.医生嘱托 is not null then ww.药品id || ww.医生嘱托 else '' end, ww.匹配 desc, ww.药品id asc
) zz
order by zz.床号0 asc, zz.病人id asc, to_char(zz.日期, 'yyyy-mm-dd') asc, zz.嘱托换页, zz.咀嚼泡腾换页, zz.匹配 desc, zz.药品id asc
) xxx



union all 


/* 每袋合计多少粒？ */
select yyy.科室, yyy.床号, yyy.住院号, yyy.姓名, yyy.真_服药日期, yyy.服药时间, null as 医嘱, null as 规格, '本袋共 ' || sum(yyy.用量0) || ' 粒' as 用法, null as 执行频次, null as 频率次数
, null as 用量, null as 医生嘱托, yyy.床号0, yyy.病人id, null as 首次, yyy.嘱托换页, yyy.咀嚼泡腾换页, yyy.换页标识, 9999999 as 药品id
, yyy.匹配 from (
--计算实际换页标识。
select zz.科室, zz.床号, zz.住院号, zz.姓名, zz.护士实际一次发送哪几天 as 真_服药日期, zz.服药时间, zz.医嘱, zz.规格, zz.用法, zz.执行频次, zz.频率次数, zz.用量0, zz.用量, zz.医生嘱托, zz.床号0, zz.病人id, zz.首次, zz.嘱托换页, zz.咀嚼泡腾换页
, zz.病人id || '/' || to_char(zz.日期, 'yyyy-mm-dd') || '/' || zz.匹配 || '/' || zz.嘱托换页 || '/' || zz.咀嚼泡腾换页 || '/' || zz.护士实际一次发送哪几天 ||  '/' || trunc(zz.该药袋第几种药 / 6) as 换页标识, zz.药品id
, zz.匹配 from (
--计算原本药袋有多少种药。
select ww.科室, ww.床号, ww.住院号, ww.姓名, ww.服药日期, ww.服药时间, ww.医嘱, ww.规格, ww.用法, ww.执行频次, ww.频率次数, ww.用量, ww.医生嘱托, ww.床号0, ww.病人id, ww.首次
, ww.药品id, ww.用量0, case when ww.医生嘱托 is not null then ww.医生嘱托 else '' end as 嘱托换页, case when ww.医嘱 like '%咀嚼%' then '咀嚼' when ww.医嘱 like '%泡腾%' then '泡腾' else '通常' end as 咀嚼泡腾换页
, ww.日期, ww.匹配, row_number() over(partition by ww.床号0, ww.病人id, to_char(ww.日期, 'yyyy-mm-dd'), case when ww.医生嘱托 is not null then ww.药品id || ww.医生嘱托 else '' end, ww.匹配
 order by ww.床号0 asc, ww.病人id asc, to_char(ww.日期, 'yyyy-mm-dd') asc, case when ww.医生嘱托 is not null then ww.药品id || ww.医生嘱托 else '' end, ww.匹配 desc, ww.药品id asc) as 该药袋第几种药, ww.护士实际一次发送哪几天 
 from (
--★★★长嘱必定打印药袋★★★
select * from (
select 
  RPAD('科室: ' || temp_origin_continuous.科室, 30, ' ') as 科室, '床号: ' || temp_origin_continuous.床号 || ' 床' as 床号
  , RPAD('住院号: ' || temp_origin_continuous.住院号, 30, ' ') AS 住院号, '姓名: ' || temp_origin_continuous.姓名 as 姓名
  , RPAD('服药日期: ' || to_char(temp_origin_continuous.日期, 'yyyy-mm-dd'), 30, ' ') as 服药日期, '服药时间: ' || drugbag_rec.时点 as 服药时间
  , temp_origin_continuous.医嘱, temp_origin_continuous.规格, temp_origin_continuous.用法, temp_origin_continuous.执行频次, temp_origin_continuous.频率次数
  , temp_origin_continuous.用量0, temp_origin_continuous.用量, temp_origin_continuous.医生嘱托
  , cast(regexp_replace(temp_origin_continuous.床号, '[^0-9]', '') as numeric) as 床号0, temp_origin_continuous.病人id, temp_origin_continuous.日期, drugbag_rec.匹配, drugbag_rec.首次, temp_origin_continuous.药品id
  , temp_origin_continuous.开始执行时间, RPAD('服药日期: ' || temp_origin_continuous.护士实际一次发送哪几天, 30, ' ') as 护士实际一次发送哪几天
from (
--源数据集
select distinct i.规格, a.库房id, a.药品id, a.医嘱id, e.出院病床 as 床号, e.病人id, e.主页id, NVL(h.名称, g.名称) as 医嘱
  , RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.') as 用量0, RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法
  , c.首次时间 as 日期, b.执行频次, b.频率次数, b.首日数次, f.名称 as 科室, b.姓名||decode(b.婴儿,0,'','【婴】') as 姓名, a.年龄, e.住院号, b.医生嘱托, b.开始执行时间
  , datesplit.要求日期 as 护士实际一次发送哪几天
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c,病人医嘱发送 c2, 收费项目目录 g, 收费项目别名 h, 药品目录 i
  , (select distinct to_char(yzzxsj.要求时间, 'yyyy-mm-dd') as 要求日期, yzzxsj.医嘱id, yzzxsj.发送号 
from 医嘱执行时间 yzzxsj
where (yzzxsj.医嘱id, yzzxsj.发送号) in (
select a.id as 给药途径医嘱id, b.发送号 as 给药途径发送号 
from 病人医嘱记录 a 
join 病人医嘱发送 b on a.id = b.医嘱id
where (a.id, b.发送时间) in (
select 给药途径医嘱id, 药品发送时间 from 
(
select a.id as 药品医嘱id, a.相关id as 给药途径医嘱id, b.发送号 as 药品医嘱发送号, b.发送时间 as 药品发送时间 
from 病人医嘱记录 a
join 病人医嘱发送 b on a.id = b.医嘱id
where (b.no, b.医嘱id) in  
(select no, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
)
)
)) datesplit
  where  a.医嘱id=b.id
  and a.药品id=d.药品id
  and a.病人id=e.病人id
  and a.主页id=e.主页id
  and a.对方部门id=f.id
  and b.id=c.医嘱id
  and b.相关id = c2.医嘱id
  and  a.no=c.no
  and a.药品id = g.id
  and g.id = h.收费细目id(+)
  and a.药品id = i.药品id
  and h.性质(+) = 3
  and datesplit.医嘱id = b.相关id and c2.发送号 = datesplit.发送号
  
  -- 长嘱
  and b.医嘱期效 = 0
  and a.填制日期 > to_date('20230518223500', 'yyyy-mm-dd hh24:mi:ss')
  
  
/*  -- 没有嘱托
  and (b.医生嘱托 is null or b.医生嘱托 = '')*/
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --只有口服需要打印药袋
  AND A.用法 IN ('口服(发热门诊专用)','口服','冲水服','口服研粉','含服','泡服','胃管注入','鼻饲','气管内滴药','开水冲服','煎服')
  
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_continuous 
--药袋时点表
join drugbag_rec on temp_origin_continuous.执行频次 = drugbag_rec.执行频率
--当前no的首次执行时间 = 首日 && 首日数次匹配（医生填了首日数次才会有值）。
where (temp_origin_continuous.护士实际一次发送哪几天 = to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd') and drugbag_rec.首次 <= temp_origin_continuous.首日数次 and temp_origin_continuous.首日数次 is not null)
--当前no的首次执行时间 = 首日 && 医生没有填写首日数次
or (temp_origin_continuous.护士实际一次发送哪几天 = to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd') and temp_origin_continuous.首日数次 is null)
--当前no首次执行时间 ！= 首日，匹配全部次数。
or (temp_origin_continuous.护士实际一次发送哪几天 <> to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd'))
order by temp_origin_continuous.床号 asc, temp_origin_continuous.病人id asc, temp_origin_continuous.日期 asc, drugbag_rec.匹配 desc, temp_origin_continuous.药品id

) abc

union all

select * from (
--★★★临嘱一天内需打印药袋★★★
--注意，临嘱没有首日数次这个字段。
select 
  RPAD('科室: ' || temp_origin_temporary.科室, 30, ' ') as 科室, '床号: ' || temp_origin_temporary.床号 || ' 床' as 床号
  , RPAD('住院号: ' || temp_origin_temporary.住院号, 30, ' ') AS 住院号, '姓名: ' || temp_origin_temporary.姓名 as 姓名
  , RPAD('服药日期: ' || to_char(temp_origin_temporary.日期, 'yyyy-mm-dd'), 30, ' ') as 服药日期, '服药时间: ' || drugbag_rec.时点 as 服药时间
  , temp_origin_temporary.医嘱, temp_origin_temporary.规格, temp_origin_temporary.用法, temp_origin_temporary.执行频次, temp_origin_temporary.频率次数
  , temp_origin_temporary.用量0, temp_origin_temporary.用量, temp_origin_temporary.医生嘱托
  , cast(regexp_replace(temp_origin_temporary.床号, '[^0-9]', '') as numeric) as 床号0, temp_origin_temporary.病人id, temp_origin_temporary.日期, drugbag_rec.匹配, drugbag_rec.首次, temp_origin_temporary.药品id
  , temp_origin_temporary.开始执行时间, RPAD('服药日期: ' || to_char(temp_origin_temporary.日期, 'yyyy-mm-dd'), 30, ' ') as 护士实际一次发送哪几天
from (
--源数据集
select distinct i.规格, a.库房id, a.药品id, a.医嘱id, e.出院病床 as 床号, e.病人id, e.主页id, NVL(h.名称, g.名称) as 医嘱
  , RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.') as 用量0, RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法
  , c.首次时间 as 日期, b.执行频次, b.频率次数, b.首日数次, f.名称 as 科室, b.姓名||decode(b.婴儿,0,'','【婴】') as 姓名, a.年龄, e.住院号, b.医生嘱托, b.开始执行时间
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c, 收费项目目录 g, 收费项目别名 h, 药品目录 i, 医嘱执行时间 j
  , (
  SELECT Y.医嘱ID, COUNT(Y.医嘱ID) AS 临嘱执行次数 
  FROM 医嘱执行时间 Y
  JOIN 病人医嘱记录 B ON Y.医嘱ID = B.相关ID
  WHERE B.ID IN (select Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
  GROUP BY Y.医嘱ID
  ) YY
  where  a.医嘱id=b.id
  and a.药品id=d.药品id
  and a.病人id=e.病人id
  and a.主页id=e.主页id
  and a.对方部门id=f.id
  and b.id=c.医嘱id
  and  a.no=c.no
  and a.药品id = g.id
  and g.id = h.收费细目id(+)
  and a.药品id = i.药品id
  and b.相关id = j.医嘱id
  and b.相关id = yy.医嘱ID
  and h.性质(+) = 3
  
  
  -- 临嘱
  and b.医嘱期效 = 1
  and a.填制日期 > to_date('20230518223500', 'yyyy-mm-dd hh24:mi:ss')
  
  
/*  -- 没有嘱托
  and (b.医生嘱托 is null or b.医生嘱托 = '')*/
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --只有口服需要打印药袋
  AND A.用法 IN ('口服(发热门诊专用)','口服','冲水服','口服研粉','含服','泡服','胃管注入','鼻饲','气管内滴药','开水冲服','煎服')
  
  --按照执行次数
  AND YY.临嘱执行次数 <= CASE b.执行频次
  WHEN '每天四次' THEN 4
  WHEN '每天三次' THEN 3
  WHEN '每天二次' THEN 2 
  WHEN '一次性' THEN 1 
  WHEN '每天一次' THEN 1 
  WHEN '每天早晨一次' THEN 1
  WHEN '每天上午一次' THEN 1
  WHEN '每天早晨一次' THEN 1
  WHEN '每天晚上一次' THEN 1
  WHEN '每4小时一次' THEN 6
  WHEN '每6小时一次' THEN 4
  WHEN '每8小时一次' THEN 3
  WHEN '每12小时一次' THEN 2
  WHEN '需要时' THEN 1
  ELSE 0 END
  
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_temporary 
--药袋时点表
left join drugbag_rec on temp_origin_temporary.执行频次 = drugbag_rec.执行频率
order by temp_origin_temporary.床号 asc, temp_origin_temporary.病人id asc, temp_origin_temporary.日期 asc, drugbag_rec.匹配 desc, temp_origin_temporary.药品id
) def
) ww
order by ww.床号0 asc, ww.病人id asc, to_char(ww.日期, 'yyyy-mm-dd') asc, case when ww.医生嘱托 is not null then ww.药品id || ww.医生嘱托 else '' end, ww.匹配 desc, ww.药品id asc
) zz
order by zz.床号0 asc, zz.病人id asc, to_char(zz.日期, 'yyyy-mm-dd') asc, zz.嘱托换页, zz.咀嚼泡腾换页, zz.匹配 desc, zz.药品id asc
) yyy
group by yyy.科室, yyy.床号, yyy.住院号, yyy.姓名, yyy.真_服药日期, yyy.服药时间, yyy.床号0, yyy.病人id, yyy.真_服药日期, yyy.嘱托换页, yyy.咀嚼泡腾换页, yyy.匹配, yyy.换页标识
) zzzz
where zzzz.医嘱 not like '%肠内营养液%'
or zzzz.医嘱 is null
order by zzzz.床号0 asc, zzzz.病人id asc, zzzz.真_服药日期 asc, zzzz.嘱托换页, zzzz.咀嚼泡腾换页, zzzz.匹配 desc, zzzz.换页标识, zzzz.药品id asc
