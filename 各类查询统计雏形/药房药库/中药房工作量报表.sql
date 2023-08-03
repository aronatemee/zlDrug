
--中药房工作量报表
--字段：日期、配药人、发药人、库房、饮片处方数、饮片处方付数、饮片品种数、颗粒处方数、颗粒处方付数、颗粒品种数。

/* 核心数据 */


--最后使用聚合函数SUM就好了，分组条件是发药日期、配药人、发药人
--再根据中药形态（饮片和散装）进行拆分表示。
SELECT ZZZZ.发药日期, ZZZZ.配药人, ZZZZ.发药人
, SUM(ZZZZ.散装处方数) AS 散装处方数, SUM(ZZZZ.散装处方付数) AS 散装处方付数, SUM(ZZZZ.散装品种数) AS 散装品种数
, SUM(ZZZZ.中药饮片处方数) AS 中药饮片处方数, SUM(ZZZZ.中药饮片处方付数) AS 中药饮片处方付数, SUM(ZZZZ.中药饮片品种数) AS 中药饮片品种数 FROM (
SELECT ZZZ.发药日期, ZZZ.配药人, ZZZ.发药人
, DECODE(ZZZ.中药形态, '散装', ZZZ.药品处方数, 0) AS 散装处方数
, DECODE(ZZZ.中药形态, '散装', ZZZ.药品处方付数, 0) AS 散装处方付数
, DECODE(ZZZ.中药形态, '散装', ZZZ.药品品种数, 0) AS 散装品种数
, DECODE(ZZZ.中药形态, '中药饮片', ZZZ.药品处方数, 0) AS 中药饮片处方数
, DECODE(ZZZ.中药形态, '中药饮片', ZZZ.药品处方付数, 0) AS 中药饮片处方付数
, DECODE(ZZZ.中药形态, '中药饮片', ZZZ.药品品种数, 0) AS 中药饮片品种数 FROM (
--再计算某日期、某配药发药人组合、某库房下处方总数、处方付数总数、处方品种总数
SELECT ZZ.发药日期, ZZ.配药人, ZZ.发药人, COUNT(ZZ.NO) AS 药品处方数, SUM(ZZ.处方付数) AS 药品处方付数, SUM(ZZ.处方品种数) AS 药品品种数, ZZ.中药形态 FROM (
--同一张处方的付数一定是相同的，取一个即可。同时计算每张处方单（NO）中有多少品种。
SELECT Z.NO, Z.发药日期, Z.配药人, Z.发药人, COUNT(Z.药品品种) AS 处方品种数, Z.库房, MAX(Z.付数) AS 处方付数, Z.中药形态 FROM (
--原始数据
SELECT A.NO, TO_CHAR(A.审核日期, 'YYYY-MM-DD') AS 发药日期, A.配药人, A.审核人 AS 发药人, C.名称 AS 药品品种, B.名称 AS 库房, A.付数, DECODE(D.中药形态, 0, '散装', 1, '中药饮片', 2, '免煎剂') AS 中药形态
FROM 药品收发记录 A
LEFT JOIN 部门表 B ON A.库房ID = B.ID
LEFT JOIN 药品目录 C ON A.药品ID = C.药品id
LEFT JOIN 药品规格 D ON A.药品ID = D.药品ID
WHERE B.名称 = '中药房'
--收费处方发药、记账单处方发药、记账表处方发药
AND A.单据 IN (8, 9, 10)
--原始记录
AND (A.记录状态 = 1 OR MOD(A.记录状态, 3) = 0)
AND A.审核日期 BETWEEN TO_DATE('20230328000000', 'YYYY-MM-DD hh24:mi:ss') AND TO_DATE('20230328235959', 'YYYY-MM-DD hh24:mi:ss')
ORDER BY A.审核日期, A.NO
)Z
GROUP BY Z.NO, Z.发药日期, Z.配药人, Z.发药人, Z.库房, Z.中药形态
ORDER BY Z.NO, Z.发药日期, Z.配药人, Z.发药人, Z.库房, Z.中药形态
)ZZ
GROUP BY ZZ.发药日期, ZZ.配药人, ZZ.发药人, ZZ.中药形态
ORDER BY ZZ.发药日期, ZZ.配药人, ZZ.发药人, ZZ.中药形态
)ZZZ
)ZZZZ
GROUP BY ZZZZ.发药日期, ZZZZ.配药人, ZZZZ.发药人
ORDER BY ZZZZ.发药日期, ZZZZ.配药人, ZZZZ.发药人
