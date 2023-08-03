
--5月17日晚22：30之前发送的，使用旧药袋格式
select * from(
 
 --东莞长安医院住院药袋/标签混合sql
 SELECT 科室, 床号, 住院号, 姓名, 日期 AS 服药日期, 时点 AS 服药时间, 医嘱, 规格, 用法, null as 执行频次, null as 频率次数, 用量, 医生嘱托, 0 as 床号0, 病人id, 0 as 首次, 分组标识 as 换页标识, 药品id, 0 as 匹配 FROM (
 --第一部分
 --仅打印长嘱药袋
 SELECT * FROM (
 SELECT * FROM (
 select distinct a.序号,c.首次时间,null 规格,a.库房id,a.药品id,a.医嘱id,zl_to_number(e.出院病床) as 床号2,e.病人id,e.主页id, NVL(h.名称, g.名称) as 医嘱,RTRIM(to_char(b.单次用量/d.剂量系数
 ,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法||decode(b.医生嘱托,null,null,'【'||b.医生嘱托||'】') as 用法,RPAD('服药日期: ' || to_char(c.首次时间,'yyyy-mm-dd'), 30, ' ') as 日期
 ,to_number(to_char(c.首次时间,'hh24')) 时间,RPAD('科    室: ' || f.名称, 30, ' ') as 科室
         ,'床    号: ' || e.出院病床||'床' as 床号,'姓    名: ' || e.姓名||decode(b.婴儿,0,'','【婴】') as 姓名,a.年龄,RPAD('住 院 号: ' || e.住院号, 30, ' ') AS 住院号,a.汇总发药号
         ,e.病人id||'_'||to_char(c.首次时间,'yyyy-mm-dd')||'_'||
         (case
                  when to_number(to_char(c.首次时间, 'hh24')) < 8 and
                       to_number(to_char(c.首次时间, 'hh24')) >= 0 then
                   '1_晨服'
                  when to_number(to_char(c.首次时间, 'hh24')) < 12 and
                       to_number(to_char(c.首次时间, 'hh24')) >= 8 then
                   '2_早上'
                  when to_number(to_char(c.首次时间, 'hh24')) < 16 and
                       to_number(to_char(c.首次时间, 'hh24')) >= 12 then
                   '3_中午'
                  when to_number(to_char(c.首次时间, 'hh24')) < 20.00 and
                       to_number(Replace(to_char(c.首次时间, 'hh24:MI'), ':', '.')) >= 16 then
                   '4_下午'
                  when to_number(to_char(c.首次时间, 'hh24')) <21 and
                       to_number(to_char(c.首次时间, 'hh24')) >= 20 then
                   '5_晚上'
                  else
                   '6_睡前'
                end)||'_'||b.医生嘱托 as 分组标识
,'服药时间: ' || (case
                  when to_number(to_char(c.首次时间, 'hh24')) < 8 and
                       to_number(to_char(c.首次时间, 'hh24')) >= 0 then
                   '晨服'
                  when to_number(to_char(c.首次时间, 'hh24')) < 12 and
                       to_number(to_char(c.首次时间, 'hh24')) >= 8 then
                   '早上'
                  when to_number(to_char(c.首次时间, 'hh24')) < 16 and
                       to_number(to_char(c.首次时间, 'hh24')) >= 12 then
                   '中午'
                  when to_number(to_char(c.首次时间, 'hh24')) < 20.00 and
                       to_number(Replace(to_char(c.首次时间, 'hh24:MI'), ':', '.')) >= 16 then
                   '下午'
                  when to_number(to_char(c.首次时间, 'hh24')) <21 and
                       to_number(to_char(c.首次时间, 'hh24')) >= 20 then
                   '晚上'
                  else
                   '睡前'
                end) as 时点
                , b.医生嘱托
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c, 收费项目目录 g, 收费项目别名 h
  where  a.医嘱id=b.id
  and a.药品id=d.药品id
  and a.病人id=e.病人id
  and a.主页id=e.主页id
  and a.对方部门id=f.id
  and b.id=c.医嘱id
  and  a.no=c.no
  and a.药品id = g.id
  and g.id = h.收费细目id(+)
  and h.性质(+) = 3
  
  and b.医嘱期效 = 0
  
  and a.填制日期 < to_date('20230517223000', 'yyyy-mm-dd hh24:mi:ss')
  
  --仅打印药品规格中，设置为口服类药品的药袋
  --AND D.发药类型 = '口服类'
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --只有口服打印药袋/标签
  AND A.用法 IN ('口服(发热门诊专用)','口服','冲水服','口服研粉','含服','泡服','胃管注入','鼻饲','气管内滴药','开水冲服','煎服')
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )

--虽然分组标识中包含首次时间，但只是年月日，如果是首三次的情况则会导致分组标识相同。故需将首次时间的排序提前。
--order by 床号2, 分组标识, a.药品id



UNION ALL

 
 
 --第二部分
 --★★★该sql仅打印临嘱且一天及以内的药袋。★★★
 select DISTINCT a.序号,G.要求时间 AS 首次时间,null 规格,a.库房id,a.药品id,a.医嘱id,zl_to_number(e.出院病床) as 床号2,e.病人id,e.主页id,Nvl(i.名称, h.名称) as 医嘱 ,RTRIM(to_char(b.单次用量/d.剂量系数
 ,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法||decode(b.医生嘱托,null,null,'【'||b.医生嘱托||'】') as 用法,RPAD('服药日期: ' || to_char(G.要求时间,'yyyy-mm-dd'), 30, ' ') as 日期
 ,to_number(to_char(G.要求时间,'hh24')) 时间,RPAD('科    室: ' || f.名称, 30, ' ') as 科室
         ,'床    号: ' || e.出院病床||'床' as 床号,'姓    名: ' || e.姓名||decode(b.婴儿,0,'','【婴】') as 姓名,a.年龄,RPAD('住 院 号: ' || e.住院号, 30, ' ') AS 住院号,a.汇总发药号
         ,e.病人id||'_'||to_char(G.要求时间,'yyyy-mm-dd')||'_'||
         (case
                  when to_number(to_char(G.要求时间, 'hh24')) < 8 and
                       to_number(to_char(G.要求时间, 'hh24')) >= 0 then
                   '1_晨服'
                  when to_number(to_char(G.要求时间, 'hh24')) < 12 and
                       to_number(to_char(G.要求时间, 'hh24')) >= 8 then
                   '2_早上'
                  when to_number(to_char(G.要求时间, 'hh24')) < 16 and
                       to_number(to_char(G.要求时间, 'hh24')) >= 12 then
                   '3_中午'
                  when to_number(to_char(G.要求时间, 'hh24')) < 20.00 and
                       to_number(Replace(to_char(G.要求时间, 'hh24:MI'), ':', '.')) >= 16 then
                   '4_下午'
                  when to_number(to_char(G.要求时间, 'hh24')) <21 and
                       to_number(to_char(G.要求时间, 'hh24')) >= 20 then
                   '5_晚上'
                  else
                   '6_睡前'
                end)||'_'||b.医生嘱托 as 分组标识
,'服药时间: ' || (case
                  when to_number(to_char(G.要求时间, 'hh24')) < 8 and
                       to_number(to_char(G.要求时间, 'hh24')) >= 0 then
                   '晨服'
                  when to_number(to_char(G.要求时间, 'hh24')) < 12 and
                       to_number(to_char(G.要求时间, 'hh24')) >= 8 then
                   '早上'
                  when to_number(to_char(G.要求时间, 'hh24')) < 16 and
                       to_number(to_char(G.要求时间, 'hh24')) >= 12 then
                   '中午'
                  when to_number(to_char(G.要求时间, 'hh24')) < 20.00 and
                       to_number(Replace(to_char(G.要求时间, 'hh24:MI'), ':', '.')) >= 16 then
                   '下午'
                  when to_number(to_char(G.要求时间, 'hh24')) <21 and
                       to_number(to_char(G.要求时间, 'hh24')) >= 20 then
                   '晚上'
                  else
                   '睡前'
                end) as 时点
                , b.医生嘱托
   from 药品收发记录 a,病人医嘱记录 b,病人医嘱发送 c ,药品规格 d,病案主页 e,部门表 f, 医嘱执行时间 G, 收费项目目录 h, 收费项目别名 i
   ,(
   SELECT Y.医嘱ID, COUNT(Y.医嘱ID) AS 临嘱执行次数 
   FROM 医嘱执行时间 Y
   JOIN 病人医嘱记录 B ON Y.医嘱ID = B.相关ID
   WHERE B.ID IN (select Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(Order_Id number path '$.Order_Id'))) )
   GROUP BY Y.医嘱ID
   )YY
  where  a.医嘱id=b.id
  and a.药品id=d.药品id
  and a.病人id=e.病人id
  and a.主页id=e.主页id
  and a.对方部门id=f.id
  and b.id=c.医嘱id
  and  a.no=c.no
  AND B.相关ID = G.医嘱ID
  AND B.相关ID = YY.医嘱ID
  and a.药品id = h.id
  and h.id = i.收费细目id(+)
  and i.性质(+) = 3
  
  --仅打印药品规格中，设置为口服类药品的药袋
  --AND D.发药类型 = '口服类'
  
  --由于【医嘱执行时间】的特性，仅在打印临嘱时使用
  AND B.医嘱期效 = 1
  
  and a.填制日期 < to_date('20230517223000', 'yyyy-mm-dd hh24:mi:ss')
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --只有口服打印药袋/标签（通过给药途径限制）
  AND A.用法 IN ('口服(发热门诊专用)','口服','冲水服','口服研粉','含服','泡服','胃管注入','鼻饲','气管内滴药','开水冲服','煎服')
  
  --执行时间不能超过一天，否则应该打印标签！
  --当ZL_ADVICEEXECOUNT()返回的执行次数大于一天内最多的次数时，就不应该打印药袋。如下，频次待完善：
  AND YY.临嘱执行次数 = CASE A.频次 
  WHEN '每天四次' THEN 4
  WHEN '每天三次' THEN 3
  WHEN '每天二次' THEN 2 
  WHEN '一次性' THEN 1 
  WHEN '每天一次' THEN 1 
  ELSE 0 END
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
--虽然分组标识中包含首次时间，但只是年月日，如果是首三次的情况则会导致分组标识相同。故需将首次时间的排序提前。
order by 床号2, 分组标识, 药品id
)


UNION ALL

--第三部分
--临嘱一天以上的都只打印标签
 --★★★该sql仅打印临嘱且一天以上的药袋。★★★
 select DISTINCT a.序号,C.首次时间,null 规格,a.库房id,a.药品id,a.医嘱id,zl_to_number(e.出院病床) as 床号2,e.病人id,e.主页id,Nvl(h.名称, g.名称) as 医嘱 ,'总计' || RTRIM(to_char(B.总给予量
 ,'fm990.09999'), '.')||d.住院单位 as 用量,a.用法||decode(b.医生嘱托,null,null,'【'||b.医生嘱托||'】') as 用法, '从' || to_char(C.首次时间,'yyyy-mm-dd') || '开始' as 日期
 ,NULL 时间,RPAD('科    室: ' || f.名称, 30, ' ') as 科室
         ,'床    号: ' || e.出院病床||'床' as 床号,'姓    名: ' || e.姓名||decode(b.婴儿,0,'','【婴】') as 姓名,a.年龄,RPAD('住 院 号: ' || e.住院号, 30, ' ') AS 住院号,a.汇总发药号
         ,NULL 分组标识, A.用法 || ',' || A.频次 || ',每次'||to_char(b.单次用量/d.剂量系数,'fm990.09999')||d.住院单位 时点, b.医生嘱托
   from 药品收发记录 a,病人医嘱记录 b,病人医嘱发送 c ,药品规格 d,病案主页 e,部门表 f, 收费项目目录 g, 收费项目别名 h
   ,(
   SELECT Y.医嘱ID, COUNT(Y.医嘱ID) AS 临嘱执行次数 
   FROM 医嘱执行时间 Y
   JOIN 病人医嘱记录 B ON Y.医嘱ID = B.相关ID
   WHERE B.ID IN (select Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(Order_Id number path '$.Order_Id'))) )
   GROUP BY Y.医嘱ID
   )YY
  where  a.医嘱id=b.id
  and a.药品id=d.药品id
  and a.病人id=e.病人id
  and a.主页id=e.主页id
  and a.对方部门id=f.id
  and b.id=c.医嘱id
  and  a.no=c.no
  AND B.相关ID = YY.医嘱ID
  and a.药品id = g.id
  and g.id = h.收费细目id(+)
  and h.性质(+) = 3
  
  --仅打印药品规格中，设置为口服类药品的药袋
  --AND D.发药类型 = '口服类'
  
  --由于【医嘱执行时间】的特性，仅在打印临嘱时使用
  AND B.医嘱期效 = 1
  
  and a.填制日期 < to_date('20230517223000', 'yyyy-mm-dd hh24:mi:ss')
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --只有口服打印药袋/标签
  AND A.用法 IN ('口服(发热门诊专用)','口服','冲水服','口服研粉','含服','泡服','胃管注入','鼻饲','气管内滴药','开水冲服','煎服')
  
  --执行时间不能超过一天，否则应该打印标签！
  --当ZL_ADVICEEXECOUNT()返回的执行次数大于一天内最多的次数时，就不应该打印药袋。如下，频次待完善：
  AND YY.临嘱执行次数 > CASE A.频次 
  WHEN '每天四次' THEN 4
  WHEN '每天三次' THEN 3
  WHEN '每天二次' THEN 2 
  WHEN '一次性' THEN 1 
  WHEN '每天一次' THEN 1 
  ELSE 0 END
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) ))
--虽然分组标识中包含首次时间，但只是年月日，如果是首三次的情况则会导致分组标识相同。故需将首次时间的排序提前。
--order by 床号2, 首次时间, 药品id, 分组标识

)
WHERE 医嘱 NOT LIKE '%肠内营养%'  
AND 医嘱 NOT LIKE '%氯化钾注射液%'
AND 医嘱 NOT LIKE '%氯化钠注射液%'
)

union all 


select * from (



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

每个药袋只能有五种药，那么就需要先用row_number列出同病人、同日、同时点的药品行号，然后用 行号 / 5 来换页！

别忘了顺序要和摆药单一致。


*/
select * from (
select * from (
--★★★长嘱必定打印药袋★★★
select zz.科室, zz.床号, zz.住院号, zz.姓名, zz.服药日期, zz.服药时间, zz.医嘱, zz.规格, zz.用法, zz.执行频次, zz.频率次数, zz.用量, zz.医生嘱托, zz.床号0, zz.病人id, zz.首次
, zz.病人id || '/' || to_char(zz.日期, 'yyyy-mm-dd') || '/' || zz.匹配 || '/' || decode(zz.医生嘱托, null, 'null', '', '空字符串', zz.医生嘱托) || '/' || trunc(zz.首次 / 5) as 换页标识, zz.药品id
, zz.匹配 from (
select * from (
select 
  RPAD('科    室: ' || temp_origin_continuous.科室, 30, ' ') as 科室,'床    号: ' || temp_origin_continuous.床号 || '床' as 床号
  , RPAD('住 院 号: ' || temp_origin_continuous.住院号, 30, ' ') AS 住院号, '姓    名: ' || temp_origin_continuous.姓名 as 姓名
  , RPAD('服药日期: ' || to_char(temp_origin_continuous.日期, 'yyyy-mm-dd'), 30, ' ') as 服药日期, '服药时间: ' || drugbag_rec.时点 as 服药时间
  , temp_origin_continuous.医嘱, temp_origin_continuous.规格, temp_origin_continuous.用法, temp_origin_continuous.执行频次, temp_origin_continuous.频率次数
  , temp_origin_continuous.用量, temp_origin_continuous.医生嘱托
  , temp_origin_continuous.床号 as 床号0, temp_origin_continuous.病人id, temp_origin_continuous.日期, drugbag_rec.匹配, drugbag_rec.首次, temp_origin_continuous.药品id
  , temp_origin_continuous.开始执行时间
from (
--源数据集
select distinct i.规格, a.库房id, a.药品id, a.医嘱id, zl_to_number(e.出院病床) as 床号, e.病人id, e.主页id, NVL(h.名称, g.名称) as 医嘱
  , RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法
  , c.首次时间 as 日期, b.执行频次, b.频率次数, b.首日数次, f.名称 as 科室, b.姓名||decode(b.婴儿,0,'','【婴】') as 姓名, a.年龄, e.住院号, b.医生嘱托, b.开始执行时间
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c, 收费项目目录 g, 收费项目别名 h, 药品目录 i
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
  and h.性质(+) = 3
  
  -- 长嘱
  and b.医嘱期效 = 0
  and a.填制日期 > to_date('20230517223000', 'yyyy-mm-dd hh24:mi:ss')
  
  -- 没有嘱托
  and (b.医生嘱托 is null or b.医生嘱托 = '')
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_continuous 
--药袋时点表
join drugbag_rec on temp_origin_continuous.执行频次 = drugbag_rec.执行频率
--当前no的首次执行时间 = 首日 && 首日数次匹配。
where (to_char(temp_origin_continuous.日期, 'yyyy-mm-dd') = to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd') and drugbag_rec.首次 <= temp_origin_continuous.首日数次)
--当前no首次执行时间 ！= 首日，匹配全部次数。
or (to_char(temp_origin_continuous.日期, 'yyyy-mm-dd') <> to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd'))
order by temp_origin_continuous.床号 asc, temp_origin_continuous.病人id asc, temp_origin_continuous.日期 asc, drugbag_rec.匹配 desc, temp_origin_continuous.药品id

) abc


union all

select * from (
--★★★临嘱一天内需打印药袋★★★
--注意，临嘱没有首日数次这个字段。
select 
  RPAD('科    室: ' || temp_origin_temporary.科室, 30, ' ') as 科室,'床    号: ' || temp_origin_temporary.床号 || '床' as 床号
  , RPAD('住 院 号: ' || temp_origin_temporary.住院号, 30, ' ') AS 住院号, '姓    名: ' || temp_origin_temporary.姓名 as 姓名
  , RPAD('服药日期: ' || to_char(temp_origin_temporary.日期, 'yyyy-mm-dd'), 30, ' ') as 服药日期, '服药时间: ' || drugbag_rec.时点 as 服药时间
  , temp_origin_temporary.医嘱, temp_origin_temporary.规格, temp_origin_temporary.用法, temp_origin_temporary.执行频次, temp_origin_temporary.频率次数
  , temp_origin_temporary.用量, temp_origin_temporary.医生嘱托
  , temp_origin_temporary.床号 as 床号0, temp_origin_temporary.病人id, temp_origin_temporary.日期, drugbag_rec.匹配, drugbag_rec.首次, temp_origin_temporary.药品id
  , temp_origin_temporary.开始执行时间
from (
--源数据集
select distinct i.规格, a.库房id, a.药品id, a.医嘱id, zl_to_number(e.出院病床) as 床号, e.病人id, e.主页id, NVL(h.名称, g.名称) as 医嘱
  , RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法
  , c.首次时间 as 日期, b.执行频次, b.频率次数, b.首日数次, f.名称 as 科室, b.姓名||decode(b.婴儿,0,'','【婴】') as 姓名, a.年龄, e.住院号, b.医生嘱托, b.开始执行时间
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c, 收费项目目录 g, 收费项目别名 h, 药品目录 i, 医嘱执行时间 j
  , (
  SELECT Y.医嘱ID, COUNT(Y.医嘱ID) AS 临嘱执行次数 
  FROM 医嘱执行时间 Y
  JOIN 病人医嘱记录 B ON Y.医嘱ID = B.相关ID
  WHERE B.ID IN (select Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
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
  and a.填制日期 > to_date('20230517223000', 'yyyy-mm-dd hh24:mi:ss')
  
  -- 没有嘱托
  and (b.医生嘱托 is null or b.医生嘱托 = '')
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --按照执行次数
  AND YY.临嘱执行次数 <= CASE b.执行频次
  WHEN '每天四次' THEN 4
  WHEN '每天三次' THEN 3
  WHEN '每天二次' THEN 2 
  WHEN '一次性' THEN 1 
  WHEN '每天一次' THEN 1 
  ELSE 0 END
  
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_temporary 
--药袋时点表
left join drugbag_rec on temp_origin_temporary.执行频次 = drugbag_rec.执行频率
order by temp_origin_temporary.床号 asc, temp_origin_temporary.病人id asc, temp_origin_temporary.日期 asc, drugbag_rec.匹配 desc, temp_origin_temporary.药品id
) def
) zz
order by zz.床号0 asc, zz.病人id asc, to_char(zz.日期, 'yyyy-mm-dd') asc, zz.匹配 desc, zz.药品id asc
) xxx



union all 



select yyy.科室, yyy.床号, yyy.住院号, yyy.姓名, yyy.服药日期, yyy.服药时间, null as 医嘱, null as 规格, '本袋共 ' || sum(yyy.用量0) || ' 粒' as 用法, null as 执行频次, null as 频率次数
, null as 用量, null as 医生嘱托, yyy.床号0, yyy.病人id, null as 首次, yyy.换页标识, 9999999 as 药品id
, yyy.匹配 from (
--★★★长嘱必定打印药袋★★★
select zz.科室, zz.床号, zz.住院号, zz.姓名, zz.服药日期, zz.服药时间, zz.医嘱, zz.规格, zz.用法, zz.执行频次, zz.频率次数, zz.用量0, zz.用量, zz.医生嘱托, zz.床号0, zz.病人id, zz.首次
, zz.病人id || '/' || to_char(zz.日期, 'yyyy-mm-dd') || '/' || zz.匹配 || '/' || decode(zz.医生嘱托, null, 'null', '', '空字符串', zz.医生嘱托) || '/' || trunc(zz.首次 / 5) as 换页标识, zz.药品id
, zz.匹配 from (
select * from (
select 
  RPAD('科    室: ' || temp_origin_continuous.科室, 30, ' ') as 科室,'床    号: ' || temp_origin_continuous.床号 || '床' as 床号
  , RPAD('住 院 号: ' || temp_origin_continuous.住院号, 30, ' ') AS 住院号, '姓    名: ' || temp_origin_continuous.姓名 as 姓名
  , RPAD('服药日期: ' || to_char(temp_origin_continuous.日期, 'yyyy-mm-dd'), 30, ' ') as 服药日期, '服药时间: ' || drugbag_rec.时点 as 服药时间
  , temp_origin_continuous.医嘱, temp_origin_continuous.规格, temp_origin_continuous.用法, temp_origin_continuous.执行频次, temp_origin_continuous.频率次数
  , temp_origin_continuous.用量0, temp_origin_continuous.用量, temp_origin_continuous.医生嘱托
  , temp_origin_continuous.床号 as 床号0, temp_origin_continuous.病人id, temp_origin_continuous.日期, drugbag_rec.匹配, drugbag_rec.首次, temp_origin_continuous.药品id
  , temp_origin_continuous.开始执行时间
from (
--源数据集
select distinct i.规格, a.库房id, a.药品id, a.医嘱id, zl_to_number(e.出院病床) as 床号, e.病人id, e.主页id, NVL(h.名称, g.名称) as 医嘱
  , RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.') as 用量0, RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法
  , c.首次时间 as 日期, b.执行频次, b.频率次数, b.首日数次, f.名称 as 科室, b.姓名||decode(b.婴儿,0,'','【婴】') as 姓名, a.年龄, e.住院号, b.医生嘱托, b.开始执行时间
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c, 收费项目目录 g, 收费项目别名 h, 药品目录 i
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
  and h.性质(+) = 3
  
  -- 长嘱
  and b.医嘱期效 = 0
  and a.填制日期 > to_date('20230517223000', 'yyyy-mm-dd hh24:mi:ss')
  
  
  -- 没有嘱托
  and (b.医生嘱托 is null or b.医生嘱托 = '')
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_continuous 
--药袋时点表
join drugbag_rec on temp_origin_continuous.执行频次 = drugbag_rec.执行频率
--当前no的首次执行时间 = 首日 && 首日数次匹配。
where (to_char(temp_origin_continuous.日期, 'yyyy-mm-dd') = to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd') and drugbag_rec.首次 <= temp_origin_continuous.首日数次)
--当前no首次执行时间 ！= 首日，匹配全部次数。
or (to_char(temp_origin_continuous.日期, 'yyyy-mm-dd') <> to_char(temp_origin_continuous.开始执行时间, 'yyyy-mm-dd'))
order by temp_origin_continuous.床号 asc, temp_origin_continuous.病人id asc, temp_origin_continuous.日期 asc, drugbag_rec.匹配 desc, temp_origin_continuous.药品id

) abc


union all

select * from (
--★★★临嘱一天内需打印药袋★★★
--注意，临嘱没有首日数次这个字段。
select 
  RPAD('科    室: ' || temp_origin_temporary.科室, 30, ' ') as 科室,'床    号: ' || temp_origin_temporary.床号 || '床' as 床号
  , RPAD('住 院 号: ' || temp_origin_temporary.住院号, 30, ' ') AS 住院号, '姓    名: ' || temp_origin_temporary.姓名 as 姓名
  , RPAD('服药日期: ' || to_char(temp_origin_temporary.日期, 'yyyy-mm-dd'), 30, ' ') as 服药日期, '服药时间: ' || drugbag_rec.时点 as 服药时间
  , temp_origin_temporary.医嘱, temp_origin_temporary.规格, temp_origin_temporary.用法, temp_origin_temporary.执行频次, temp_origin_temporary.频率次数
  , temp_origin_temporary.用量0, temp_origin_temporary.用量, temp_origin_temporary.医生嘱托
  , temp_origin_temporary.床号 as 床号0, temp_origin_temporary.病人id, temp_origin_temporary.日期, drugbag_rec.匹配, drugbag_rec.首次, temp_origin_temporary.药品id
  , temp_origin_temporary.开始执行时间
from (
--源数据集
select distinct i.规格, a.库房id, a.药品id, a.医嘱id, zl_to_number(e.出院病床) as 床号, e.病人id, e.主页id, NVL(h.名称, g.名称) as 医嘱
  , RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.') as 用量0, RTRIM(to_char(b.单次用量/d.剂量系数,'fm990.99999'), '.')||d.住院单位 as 用量,a.用法
  , c.首次时间 as 日期, b.执行频次, b.频率次数, b.首日数次, f.名称 as 科室, b.姓名||decode(b.婴儿,0,'','【婴】') as 姓名, a.年龄, e.住院号, b.医生嘱托, b.开始执行时间
  from 药品收发记录 a,病人医嘱记录 b ,药品规格 d,病案主页 e,部门表 f,病人医嘱发送 c, 收费项目目录 g, 收费项目别名 h, 药品目录 i, 医嘱执行时间 j
  , (
  SELECT Y.医嘱ID, COUNT(Y.医嘱ID) AS 临嘱执行次数 
  FROM 医嘱执行时间 Y
  JOIN 病人医嘱记录 B ON Y.医嘱ID = B.相关ID
  WHERE B.ID IN (select Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
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
  and a.填制日期 > to_date('20230517223000', 'yyyy-mm-dd hh24:mi:ss')
  
  
  -- 没有嘱托
  and (b.医生嘱托 is null or b.医生嘱托 = '')
  
  --执行性质 = 5，表现为离院带药等。由于本sql是服务于药袋，故不需要离院带药的部分。
  and b.执行性质 <> 5
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
  --按照执行次数
  AND YY.临嘱执行次数 <= CASE b.执行频次
  WHEN '每天四次' THEN 4
  WHEN '每天三次' THEN 3
  WHEN '每天二次' THEN 2 
  WHEN '一次性' THEN 1 
  WHEN '每天一次' THEN 1 
  ELSE 0 END
  
  --AND A.汇总发药号 IS NOT NULL
  and (a.no, a.病人id, a.库房id, a.医嘱id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table('[{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720565","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720566","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1819576","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829107","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1829155","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1833450","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1888259","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953788","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720567","Pati_Id":"611105","Storehouse_Id":"74","Order_Id":"1953820","Pati_Name":"秦福全","Pati_Bed":"1","Inpatient_Num":"200643","Pati_Page_Id":"9","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720870","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720871","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1494117","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1596754","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1660985","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1735281","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1776130","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1851612","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1852993","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1853008","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1897137","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2},{"Rcp_No":"23001720872","Pati_Id":"3044095","Storehouse_Id":"74","Order_Id":"1947782","Pati_Name":"黄石水","Pati_Bed":"9","Inpatient_Num":"417984","Pati_Page_Id":"1","Pat_Source":2}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_temporary 
--药袋时点表
left join drugbag_rec on temp_origin_temporary.执行频次 = drugbag_rec.执行频率
order by temp_origin_temporary.床号 asc, temp_origin_temporary.病人id asc, temp_origin_temporary.日期 asc, drugbag_rec.匹配 desc, temp_origin_temporary.药品id
) def
) zz
order by zz.床号0 asc, zz.病人id asc, to_char(zz.日期, 'yyyy-mm-dd') asc, zz.匹配 desc, zz.药品id asc
) yyy
group by yyy.科室, yyy.床号, yyy.住院号, yyy.姓名, yyy.服药日期, yyy.服药时间, yyy.床号0, yyy.病人id, yyy.服药日期, yyy.匹配, yyy.换页标识
) zzzz
order by zzzz.床号0 asc, zzzz.病人id asc, zzzz.服药日期 asc, zzzz.匹配 desc, zzzz.药品id asc

)
