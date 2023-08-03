
--统计时段内门诊含药品的处方数量。
SELECT COUNT(DISTINCT B.NO) FROM 病人医嘱记录 A
JOIN 病人医嘱发送 B ON A.ID = B.医嘱ID
JOIN 收费项目目录 C ON B.收费细目ID = C.ID
WHERE A.医嘱状态 <> '4'
AND A.病人来源 = 1
AND C.类别 IN ('5', '6', '7')
AND A.开嘱时间 BETWEEN TO_DATE('20230201000000', 'YYYY-MM-DD hh24:mi:ss') AND TO_DATE('20230228235959', 'YYYY-MM-DD hh24:mi:ss')
;

SELECT COUNT(DISTINCT B.NO) FROM 病人医嘱记录 A
JOIN 病人医嘱发送 B ON A.ID = B.医嘱ID
JOIN 收费项目目录 C ON B.收费细目ID = C.ID
WHERE A.医嘱状态 <> '4'
AND A.病人来源 = 1
AND C.类别 IN ('5', '6', '7')
AND A.开嘱时间 BETWEEN TO_DATE('20230301000000', 'YYYY-MM-DD hh24:mi:ss') AND TO_DATE('20230331235959', 'YYYY-MM-DD hh24:mi:ss')
;
