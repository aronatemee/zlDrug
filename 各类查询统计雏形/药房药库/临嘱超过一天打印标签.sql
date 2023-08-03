--★★★临嘱超过一天打印标签★★★
select * from (
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
  json_table('[{
  "Rcp_No": "23000008136",
  "Pati_Id": "2026",
  "Storehouse_Id": "74",
  "Order_Id": "22781",
  "Pati_Name": "流川枫",
  "Pati_Bed": "27",
  "Inpatient_Num": "200361",
  "Pati_Page_Id": "1"
}, {
  "Rcp_No": "23000008138",
  "Pati_Id": "2026",
  "Storehouse_Id": "74",
  "Order_Id": "22781",
  "Pati_Name": "流川枫",
  "Pati_Bed": "27",
  "Inpatient_Num": "200361",
  "Pati_Page_Id": "1"
}, {
  "Rcp_No": "23000008141",
  "Pati_Id": "2026",
  "Storehouse_Id": "74",
  "Order_Id": "22785",
  "Pati_Name": "流川枫",
  "Pati_Bed": "27",
  "Inpatient_Num": "200361",
  "Pati_Page_Id": "1"
}]','$'columns (nested path '$[*]' columns(Order_Id number path '$.Order_Id'))) )
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
  
  --由于【医嘱执行时间】的特性，仅在打印临嘱时使用
  AND B.医嘱期效 = 1
  
  --药品收发记录中，(Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 意味着原始记录。
  and   (Mod(A.记录状态, 3) = 0 Or A.记录状态 = 1) 
  
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
  json_table('[{
  "Rcp_No": "23000008136",
  "Pati_Id": "2026",
  "Storehouse_Id": "74",
  "Order_Id": "22781",
  "Pati_Name": "流川枫",
  "Pati_Bed": "27",
  "Inpatient_Num": "200361",
  "Pati_Page_Id": "1"
}, {
  "Rcp_No": "23000008138",
  "Pati_Id": "2026",
  "Storehouse_Id": "74",
  "Order_Id": "22781",
  "Pati_Name": "流川枫",
  "Pati_Bed": "27",
  "Inpatient_Num": "200361",
  "Pati_Page_Id": "1"
}, {
  "Rcp_No": "23000008141",
  "Pati_Id": "2026",
  "Storehouse_Id": "74",
  "Order_Id": "22785",
  "Pati_Name": "流川枫",
  "Pati_Bed": "27",
  "Inpatient_Num": "200361",
  "Pati_Page_Id": "1"
}]','$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
  /*order by ...*/
