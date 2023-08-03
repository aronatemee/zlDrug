SELECT A.是否绿色通道, A.病人ID, A.挂号ID 
FROM 急诊就诊记录 A
JOIN 病人挂号记录 B ON A.挂号ID = B.ID
JOIN (SELECT * FROM  Z WHERE Z.NO = '')
;


SELECT * FROM 病人医嘱发送 A;

SELECT * FROM 病人挂号记录 B;
