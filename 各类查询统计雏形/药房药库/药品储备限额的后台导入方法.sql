--批量导入存储上下限

--以下每一句涉及库房、执行科室字段的，都需要注意，改为准备导入的科室。

--1、备份原表
create table 药品储备限额_bak_20230221 as select * from 药品储备限额;
--SELECT * FROM 药品储备限额_bak_20230221;
--drop table 药品储备限额_bak_20230221;

--2、创建中间表导入excel
-- 1=2不会导入任何数据，也就是仅有表结构被复制
-- 有几个注意点：1. 中间表需提前将字段改为vchar2(500)，因为有编码。2. 复制导入时，最左侧需要增加空列，（为了符合plsql的表格）
create table 药品储备限额0223_2 as select * from 药品储备限额 where 1=2;
--SELECT * FROM 药品储备限额4 for update;
--drop table 药品储备限额4;

--根据药品编码获取药品id
--把药品id存进中间表的库房id
update 药品储备限额0223_2 a set a.库房id=(select id from 收费项目目录 b where a.药品id=b.编码);

--如果需要换算单位
--上限换算，下限同理，需注意使用的是售价单位还是库房单位，药品储备限额表，默认是以售价单位来存储的。药库包装是指售价单位到药库单位的换算比
update 药品储备限额0223_2 a set a.上限=a.上限*(select b.药库包装 from 药品规格 b where b.药品id=a.库房id);
update 药品储备限额0223_2 a set a.下限=a.下限*(select b.药库包装 from 药品规格 b where b.药品id=a.库房id);

--3、把正式表的上限下限清0。防止药库提供的表格中有空值，正式表原本不正确的上下限没有被更新。
--记得筛选正式表的库房id，别把其他库房的数据给清零了。
--这个更新的语句可以跟踪导航台的。
update 药品储备限额 set 上限=0 where 库房id = 80 and 药品id in (
Select  I.ID
  From (Select I.ID,
               I.编码,
               I.名称,
               b.名称 As 商品名,
               I.规格,
               I.产地,
               S.原产地,
               I.计算单位,
               S.门诊单位,
               S.门诊包装,
               S.住院单位,
               S.住院包装,
               S.药库单位,
               S.药库包装,
               I.是否变价,
               S.药名id
          From 收费项目目录 I,
               收费项目别名 B,
               药品规格 S,
               (Select Distinct 诊疗项目id
                  From 诊疗执行科室
                 Where 执行科室id = 80) E,
               (select distinct 收费细目id
                  from 收费执行科室
                 where 执行科室id = 80) F
         Where i.Id = b.收费细目id(+)
           And b.性质(+) = 3
           And I.Id = S.药品id
           And S.药名id = E.诊疗项目id
           and I.类别 = '5'
           And i.id = f.收费细目id
           and (I.撤档时间 is null or
               I.撤档时间 = to_date('3000-01-01', 'YYYY-MM-DD'))) I,
       (Select 药品id, 上限, 下限, 盘点属性, 库房货位, 领用标志
          From 药品储备限额 L
         Where 库房id = 80) L,
       收费价目 P
 Where I.ID = P.收费细目id
   And I.Id = L.药品id(+)
   And (p.终止日期 Is Null Or
       Sysdate Between p.执行日期 And
       Nvl(p.终止日期, To_Date('3000-01-01', 'yyyy-MM-dd')))
   And P.价格等级 Is Null
);
SELECT * FROM 药品储备限额 A
WHERE A.库房ID = 80;

--4、导入上下限
update 药品储备限额 a set a.上限=(select decode(b.上限,null,0,b.上限) from 药品储备限额0223_2 b where a.药品id=b.库房id) where a.库房id = 80 and a.药品id in (select b.库房id from 药品储备限额0223_2 b where b.药品id is not null);
update 药品储备限额 a set a.下限=(select decode(b.下限,null,0,b.下限) from 药品储备限额0223_2 b where a.药品id=b.库房id) where a.库房id = 80 and a.药品id in (select b.库房id from 药品储备限额0223_2 b where b.药品id is not null);



