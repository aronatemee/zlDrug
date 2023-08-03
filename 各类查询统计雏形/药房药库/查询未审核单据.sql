SELECT DISTINCT B.名称 AS 库房,
                A.单据,
                D.名称,
                A.NO,
                A.填制日期,
                A.填制人,
                A.摘要,
                F.名称
  FROM ZLHIS.药品收发记录 a, ZLHIS.部门表 B, ZLHIS.药品单据分类 D, 药品目录 F
 where 审核人 is null
   AND A.库房ID = B.ID
   AND A.单据 = D.编码
   AND A.药品ID = F.药品id
   AND (A.单据 >= 1 AND A.单据 <= 14)
   and a.库房id = 74
   AND F.名称 LIKE '%多烯磷脂%'
   and 填制日期 between TO_DATE('2023-02-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') and TO_DATE('2023-04-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
 ORDER BY A.单据, A.NO;


/*SELECT * FROM 病人医嘱发送 A
JOIN 病人医嘱记录 B ON A.医嘱ID = B.ID
WHERE A.NO IN (SELECT DISTINCT 
                A.NO
  FROM ZLHIS.药品收发记录 a, ZLHIS.部门表 B, ZLHIS.药品单据分类 D
 where 审核人 is null
   AND A.库房ID = B.ID
   AND A.单据 = D.编码
   AND (A.单据 >= 1 AND A.单据 <= 14)
   and a.库房id = 74
   and 填制日期 between TO_DATE('2023-02-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') and TO_DATE('2023-04-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
 )
 ORDER BY  A.NO;*/
