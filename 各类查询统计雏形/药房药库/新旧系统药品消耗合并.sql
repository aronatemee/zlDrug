--创建各自的表

CREATE TABLE 新系统药品消耗(编码 VARCHAR(200), 旧系统编码 VARCHAR(200), 名称 VARCHAR(200), 单位 VARCHAR(20), 规格 VARCHAR(50), 数量 NUMBER, 金额 NUMBER, 转换率 NUMBER, 大单位 VARCHAR(20));

CREATE TABLE 旧系统药品消耗(编码 VARCHAR(200), 名称 VARCHAR(200), 单位 VARCHAR(20), 规格 VARCHAR(50), 数量 NUMBER, 金额 NUMBER, 转换率 NUMBER, 大单位 VARCHAR(20), DDD NUMBER, 单剂量 NUMBER, 限制级别 VARCHAR(20));



/* 导入Excel数据。Excel文件需要在开头加一个空列，复制粘贴时，才能正确对齐plsql里面的表字段。*/
/* 记得提交。*/
SELECT * FROM 新系统药品消耗 FOR UPDATE;
SELECT * FROM 旧系统药品消耗 FOR UPDATE;


/* 新系统数据需要按照旧系统编码进行汇总。*/ 
create table 新系统药品消耗2 as select a.名称, a.单位, a.规格, a.旧系统编码, sum(a.数量) as 新系统数量, sum(a.金额) as 新系统金额 
from 新系统药品消耗 a 
group by a.旧系统编码, a.名称, a.单位, a.规格;

select * from 新系统药品消耗2;


/* 将旧系统编码去除&。*/ 
CREATE TABLE 旧系统药品消耗2 as SELECT replace(a.编码, '&', '') as 编码, a.名称, a.单位, a.规格, a.数量, a.金额, a.转换率, a.大单位, a.ddd, a.单剂量, a.限制级别 
FROM 旧系统药品消耗 a;

select * from 旧系统药品消耗2;


/* 合并。*/
create table 新旧系统药品消耗合并表 as
SELECT case when a.编码 is not null then a.编码
when a.编码 is null and b.旧系统编码 is not null then b.旧系统编码
when a.编码 is null and b.旧系统编码 is null then '旧系统本期未使用该编码药品，新系统未对照旧系统编码'
end as 编码
, case when A.名称 is null then B.名称
else a.名称 end  AS 旧系统名称
, case when A.单位 is null then b.单位 else a.单位 end as 单位
, case when A.规格 is null then b.规格 else a.规格 end as 规格
, A.数量 AS 旧系统数量, A.金额 AS 旧系统金额
, B.新系统数量, B.新系统金额
, A.转换率, A.大单位, A.DDD, A.单剂量, A.限制级别
FROM 旧系统药品消耗2 A
FULL JOIN 新系统药品消耗2 B ON A.编码 = B.旧系统编码
ORDER BY 编码;


/* 导出为excel。*/
select * from 新旧系统药品消耗合并表;


/* 清理历史数据。*/
drop table 新系统药品消耗;
drop table 新系统药品消耗2;
drop table 旧系统药品消耗;
drop table 旧系统药品消耗2;
drop table 新旧系统药品消耗合并表;

