SELECT SUM(Z.总给予量), Z.医嘱内容 FROM (
SELECT A.姓名, A.医嘱内容, B.单量, B.实际数量, A.医嘱期效, A.天数, A.总给予量, A.执行频次, C.剂量系数
FROM 病人医嘱记录 A
JOIN 药品收发记录 B ON A.ID = B.医嘱ID
JOIN 药品规格 C ON B.药品ID = C.药品ID
WHERE (A.医嘱内容 LIKE '%奥司他韦胶囊%'
OR A.医嘱内容 LIKE '%奥司他韦颗粒%')
AND A.开嘱时间 BETWEEN TO_DATE('20230307000000', 'YYYY-MM-DD hh24:mi:ss') AND TO_DATE('20230307235959', 'YYYY-MM-DD hh24:mi:ss')
AND A.医嘱状态 <> 4
ORDER BY A.医嘱内容) Z
GROUP BY Z.医嘱内容

SELECT A.总给予量, A.开嘱时间 FROM 病人医嘱记录 A
WHERE A.姓名 = '华志德'
AND A.医嘱内容 LIKE '%维生素B1%';
