/* 药学科处方点评用。*/
SELECT A.姓名 AS 病人姓名, A.医嘱内容, A.开嘱时间, A.开嘱医生, '共' || RTRIM(TO_CHAR(A.天数, 'FM9990.9999'), '.') || '天' AS 总天数, A.执行频次
, CASE WHEN A.单次用量 / F.门诊包装 > 0 THEN RTRIM(TO_CHAR(A.单次用量 / F.剂量系数, 'FM9990.9999'), '.') || F.门诊单位 ELSE TO_CHAR(A.单次用量, 'FM9990.0999') || H.计算单位 END AS 单量
, RTRIM(TO_CHAR(A.总给予量, 'FM9990.9999'), '.') || F.门诊单位 AS 总量
, B.名称 AS 开嘱科室, D.NO
, D.诊断描述
FROM (SELECT * FROM 病人医嘱记录 A
WHERE A.诊疗类别 IN ('5', '6')
AND A.医嘱内容 NOT LIKE '%测试%'
AND A.开嘱医生 <> '系统管理员'
AND A.医嘱状态 = 8
AND A.开嘱时间 BETWEEN to_date('20230401000000', 'yyyy-mm-dd hh24:mi:ss') AND to_date('20230430235959', 'yyyy-mm-dd hh24:mi:ss')) A
JOIN 部门表 B ON A.开嘱科室ID = B.ID
JOIN 药品收发记录 D ON D.医嘱ID = A.ID
JOIN 药品目录 E ON D.药品ID = E.药品id
JOIN 药品规格 F ON E.药品id = F.药品ID
JOIN 收费项目目录 H ON D.药品ID = H.ID
AND D.NO IN (
select ZZ.NO from 病人医嘱发送 ZZ
where zz.医嘱id in (
WITH temp_1 as (
SELECT A.诊疗项目ID, A.ID AS 医嘱ID
FROM 病人医嘱记录 A 
WHERE A.诊疗类别 IN ('5', '6')
AND A.医嘱内容 NOT LIKE '%测试%'
AND A.开嘱医生 <> '系统管理员'
AND A.医嘱状态 = 8
AND A.开嘱时间 BETWEEN to_date('20230401000000', 'yyyy-mm-dd hh24:mi:ss') AND to_date('20230430235959', 'yyyy-mm-dd hh24:mi:ss')
)
, temp_2 as (
select G.药名ID from 药品特性 G 
where G.抗生素 = 1
)
select TEMP_1.医嘱ID from temp_1
join temp_2 on temp_1.诊疗项目ID = TEMP_2.药名ID
)
)
--减少不必要的 order by 以提升效率，但这里不得不排序。
ORDER BY D.NO
