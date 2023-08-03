--ZLHIS查询发药记录的sql。
--有冲销记录，但实际上没有进行退药审核
SELECT CASE WHEN A.记录状态 = 1 THEN '原始记录' || A.记录状态
WHEN Mod(A.记录状态, 3) = 0 THEN '原始记录' || A.记录状态
WHEN Mod(A.记录状态, 3) = 1 THEN '待发药记录' || A.记录状态
WHEN Mod(A.记录状态, 3) = 2 THEN '冲销记录' || A.记录状态
ELSE TO_CHAR(A.记录状态)
END AS 记录状态
, A.NO
--, A.入出类别ID, A.入出系数, A.填写数量, A.实际数量
, A.填制人, A.填制日期, A.配药人, A.审核人
, CASE WHEN A.记录状态 = 1 THEN '首次发药日期：' || TO_CHAR(A.审核日期, 'YYYY-MM-DD hh24:mi:ss')
WHEN Mod(A.记录状态, 3) = 0 THEN '首次发药日期：' || TO_CHAR(A.审核日期, 'YYYY-MM-DD hh24:mi:ss')
WHEN Mod(A.记录状态, 3) = 1 THEN '退药或冲销后，重新发药日期：' || TO_CHAR(A.审核日期, 'YYYY-MM-DD hh24:mi:ss')
WHEN Mod(A.记录状态, 3) = 2 THEN '退药或冲销日期：' || TO_CHAR(A.审核日期, 'YYYY-MM-DD hh24:mi:ss')
ELSE TO_CHAR(A.记录状态)
END AS 操作日期
, A.汇总发药号, A.核查人, A.核查日期, A.姓名 AS 病人
, B.名称 AS 库房, C.名称 AS 科室, D.名称 AS 药品 
FROM 药品收发记录 A
JOIN 部门表 B ON A.库房ID = B.ID
JOIN 部门表 C ON A.对方部门ID = C.ID
JOIN 药品目录 D ON A.药品ID = D.药品id
WHERE B.名称 = '住院药房'
AND C.名称 LIKE '%神经外科重症监护室%'
AND A.填制日期 BETWEEN TO_DATE('20230331000000', 'YYYY-MM-DD hh24:mi:ss') AND TO_DATE('20230331235959', 'YYYY-MM-DD hh24:mi:ss')
AND A.NO = '23000830711'
AND D.名称 = '维生素C注射液'
ORDER BY A.审核日期 ASC
;
