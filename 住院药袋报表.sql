
/* 
ҩ����ʹ��SQL����д��
ʱ����ձ�����ɣ�

��ӡҩ������
1. �̶�����ֻ�����ճ���������ҩ������������켰���쳤��ҩ������������ҩ��������ʹ�����°汾ҩƷϵͳ���в��ԣ�
2. �����ض���ҩ��������ֻ��ִ�д��� <= ����ִ��Ƶ�εĲŴ�ӡҩ����

��ҳ��ʶ����
1. ÿ 5 ��ҩ + 1 �л��ܣ���ҳ��
2. ͬ��ʱ��ϲ�����ͬʱ�㻻ҳ��
3. �������У���ҩ��������ҩ����
4. ��ҩƷ����е�ʹ��˵���ֶ���ֵ���򵥶����㡣���˴�һ���Ǳ�ʶ0-8��ҩƷ�赥�����棩��δ��ɣ�
5. ҩƷ�����к��С��׽����������ڡ��ģ���Ҫ��������ҩ��������ɣ�

ÿ��ҩ��ֻ��������ҩ����ô����Ҫ����row_number�г�ͬ���ˡ�ͬ�ա�ͬʱ���ҩƷ�кţ�Ȼ���� �к� / 5 ����ҳ��

������˳��Ҫ�Ͱ�ҩ��һ�¡�

�����п��ܺ��з����֣�cast(regexp_replace(��Ժ����, '[^0-9]', '') as numeric)

*/
select * from (
select * from (
--����ʵ�ʻ�ҳ��ʶ��
select zz.����, zz.����, zz.סԺ��, zz.����, zz.��ʿʵ��һ�η����ļ��� as ��_��ҩ����, zz.��ҩʱ��, zz.ҽ��, zz.���, zz.�÷�, zz.ִ��Ƶ��, zz.Ƶ�ʴ���, zz.����, zz.ҽ������, zz.����0, zz.����id, zz.�״�, zz.���л�ҳ, zz.�׽����ڻ�ҳ
, zz.����id || '/' || to_char(zz.����, 'yyyy-mm-dd') || '/' || zz.ƥ�� || '/' || zz.���л�ҳ || '/' || zz.�׽����ڻ�ҳ ||  '/' || zz.��ʿʵ��һ�η����ļ��� ||  '/' || trunc(zz.��ҩ���ڼ���ҩ / 6) as ��ҳ��ʶ, zz.ҩƷid
, zz.ƥ�� from (
--����ԭ��ҩ���ж�����ҩ��
select ww.����, ww.����, ww.סԺ��, ww.����, ww.��ҩ����, ww.��ҩʱ��, ww.ҽ��, ww.���, ww.�÷�, ww.ִ��Ƶ��, ww.Ƶ�ʴ���, ww.����, ww.ҽ������, ww.����0, ww.����id, ww.�״�
, ww.ҩƷid, case when ww.ҽ������ is not null then ww.ҽ������ else '' end as ���л�ҳ, case when ww.ҽ�� like '%�׽�%' then '�׽�' when ww.ҽ�� like '%����%' then '����' else 'ͨ��' end as �׽����ڻ�ҳ
, ww.����, ww.ƥ��, row_number() over(partition by ww.����0, ww.����id, to_char(ww.����, 'yyyy-mm-dd'), case when ww.ҽ������ is not null then ww.ҩƷid || ww.ҽ������ else '' end, ww.ƥ��
 order by ww.����0 asc, ww.����id asc, to_char(ww.����, 'yyyy-mm-dd') asc, case when ww.ҽ������ is not null then ww.ҩƷid || ww.ҽ������ else '' end, ww.ƥ�� desc, ww.ҩƷid asc) as ��ҩ���ڼ���ҩ, ww.��ʿʵ��һ�η����ļ��� 
 from (
--���ﳤ���ض���ӡҩ������
select * from (
select 
  RPAD('����: ' || temp_origin_continuous.����, 30, ' ') as ����, '����: ' || temp_origin_continuous.���� || ' ��' as ����
  , RPAD('סԺ��: ' || temp_origin_continuous.סԺ��, 30, ' ') AS סԺ��, '����: ' || temp_origin_continuous.���� as ����
  , RPAD('��ҩ����: ' || to_char(temp_origin_continuous.����, 'yyyy-mm-dd'), 30, ' ') as ��ҩ����, '��ҩʱ��: ' || drugbag_rec.ʱ�� as ��ҩʱ��
  , temp_origin_continuous.ҽ��, temp_origin_continuous.���, temp_origin_continuous.�÷�, temp_origin_continuous.ִ��Ƶ��, temp_origin_continuous.Ƶ�ʴ���
  , temp_origin_continuous.����, temp_origin_continuous.ҽ������
  , cast(regexp_replace(temp_origin_continuous.����, '[^0-9]', '') as numeric) as ����0, temp_origin_continuous.����id, temp_origin_continuous.����, drugbag_rec.ƥ��, drugbag_rec.�״�, temp_origin_continuous.ҩƷid
  , temp_origin_continuous.��ʼִ��ʱ��, RPAD('��ҩ����: ' || temp_origin_continuous.��ʿʵ��һ�η����ļ���, 30, ' ')  as ��ʿʵ��һ�η����ļ���
from (
--Դ���ݼ���ת�ƺ�e.��Ժ���� �����µĴ��ţ��� e.��Ժ���� ��ԭ����
select distinct i.���, a.�ⷿid, a.ҩƷid, a.ҽ��id, e.��Ժ���� as ����, e.����id, e.��ҳid, NVL(h.����, g.����) as ҽ��
  , RTRIM(to_char(b.��������/d.����ϵ��,'fm990.99999'), '.')||d.סԺ��λ as ����,a.�÷�
  , c.�״�ʱ�� as ����, b.ִ��Ƶ��, b.Ƶ�ʴ���, b.��������, f.���� as ����, b.����||decode(b.Ӥ��,0,'','��Ӥ��') as ����, a.����, e.סԺ��, b.ҽ������, b.��ʼִ��ʱ��
  , datesplit.Ҫ������ as ��ʿʵ��һ�η����ļ���
  from ҩƷ�շ���¼ a,����ҽ����¼ b ,ҩƷ��� d,������ҳ e,���ű� f,����ҽ������ c, �շ���ĿĿ¼ g, �շ���Ŀ���� h, ҩƷĿ¼ i
  , (select distinct to_char(c.Ҫ��ʱ��, 'yyyy-mm-dd') as Ҫ������, c.ҽ��id, e.���ͺ� from ҽ��ִ��ʱ�� c
  join (select a.���id, b.���ͺ� from ����ҽ����¼ a
  join ����ҽ������ b on a.id = b.ҽ��id
  where (b.no, b.ҽ��id) in
 (select no, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) e on c.ҽ��id = e.���id and c.���ͺ� = e.���ͺ�
  order by to_char(c.Ҫ��ʱ��, 'yyyy-mm-dd')) datesplit
  where  a.ҽ��id=b.id
  and a.ҩƷid=d.ҩƷid
  and a.����id=e.����id
  and a.��ҳid=e.��ҳid
  and a.�Է�����id=f.id
  and b.id=c.ҽ��id
  and  a.no=c.no
  and a.ҩƷid = g.id
  and g.id = h.�շ�ϸĿid(+)
  and a.ҩƷid = i.ҩƷid
  and h.����(+) = 3
  and datesplit.ҽ��id = b.���id and c.���ͺ� = datesplit.���ͺ�
  
  -- ����
  and b.ҽ����Ч = 0
  and a.�������� > to_date('20230518223500', 'yyyy-mm-dd hh24:mi:ss')
  
/*  -- û������
  and (b.ҽ������ is null or b.ҽ������ = '')*/
  
  --ִ������ = 5������Ϊ��Ժ��ҩ�ȡ����ڱ�sql�Ƿ�����ҩ�����ʲ���Ҫ��Ժ��ҩ�Ĳ��֡�
  and b.ִ������ <> 5
  
  --ҩƷ�շ���¼�У�(Mod(A.��¼״̬, 3) = 0 Or A.��¼״̬ = 1) ��ζ��ԭʼ��¼��
  and   (Mod(A.��¼״̬, 3) = 0 Or A.��¼״̬ = 1) 
  
  --ֻ�пڷ���Ҫ��ӡҩ��
  AND A.�÷� IN ('�ڷ�(��������ר��)','�ڷ�','��ˮ��','�ڷ��з�','����','�ݷ�','θ��ע��','����','�����ڵ�ҩ','��ˮ���','���')
  
  --AND A.���ܷ�ҩ�� IS NOT NULL
  and (a.no, a.����id, a.�ⷿid, a.ҽ��id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_continuous 
--ҩ��ʱ���
join drugbag_rec on temp_origin_continuous.ִ��Ƶ�� = drugbag_rec.ִ��Ƶ��
--��ǰno���״�ִ��ʱ�� = ���� && ��������ƥ�䣨ҽ�������������βŻ���ֵ����
where (temp_origin_continuous.��ʿʵ��һ�η����ļ��� = to_char(temp_origin_continuous.��ʼִ��ʱ��, 'yyyy-mm-dd') and drugbag_rec.�״� <= temp_origin_continuous.�������� and temp_origin_continuous.�������� is not null)
--��ǰno���״�ִ��ʱ�� = ���� && ҽ��û����д��������
or (temp_origin_continuous.��ʿʵ��һ�η����ļ��� = to_char(temp_origin_continuous.��ʼִ��ʱ��, 'yyyy-mm-dd') and temp_origin_continuous.�������� is null)
--��ǰno�״�ִ��ʱ�� ��= ���գ�ƥ��ȫ��������
or (temp_origin_continuous.��ʿʵ��һ�η����ļ��� <> to_char(temp_origin_continuous.��ʼִ��ʱ��, 'yyyy-mm-dd'))
order by temp_origin_continuous.���� asc, temp_origin_continuous.����id asc, temp_origin_continuous.���� asc, drugbag_rec.ƥ�� desc, temp_origin_continuous.ҩƷid

) abc


union all

select * from (
--��������һ�������ӡҩ������
--ע�⣬����û��������������ֶΡ�
select 
  RPAD('����: ' || temp_origin_temporary.����, 30, ' ') as ����, '����: ' || temp_origin_temporary.���� || ' ��' as ����
  , RPAD('סԺ��: ' || temp_origin_temporary.סԺ��, 30, ' ') AS סԺ��, '����: ' || temp_origin_temporary.���� as ����
  , RPAD('��ҩ����: ' || to_char(temp_origin_temporary.����, 'yyyy-mm-dd'), 30, ' ') as ��ҩ����, '��ҩʱ��: ' || drugbag_rec.ʱ�� as ��ҩʱ��
  , temp_origin_temporary.ҽ��, temp_origin_temporary.���, temp_origin_temporary.�÷�, temp_origin_temporary.ִ��Ƶ��, temp_origin_temporary.Ƶ�ʴ���
  , temp_origin_temporary.����, temp_origin_temporary.ҽ������
  , cast(regexp_replace(temp_origin_temporary.����, '[^0-9]', '') as numeric) as ����0, temp_origin_temporary.����id, temp_origin_temporary.����, drugbag_rec.ƥ��, drugbag_rec.�״�, temp_origin_temporary.ҩƷid
  , temp_origin_temporary.��ʼִ��ʱ��, RPAD('��ҩ����: ' || to_char(temp_origin_temporary.����, 'yyyy-mm-dd'), 30, ' ') as ��ʿʵ��һ�η����ļ���
from (
--Դ���ݼ�
select distinct i.���, a.�ⷿid, a.ҩƷid, a.ҽ��id, e.��Ժ���� as ����, e.����id, e.��ҳid, NVL(h.����, g.����) as ҽ��
  , RTRIM(to_char(b.��������/d.����ϵ��,'fm990.99999'), '.')||d.סԺ��λ as ����,a.�÷�
  , c.�״�ʱ�� as ����, b.ִ��Ƶ��, b.Ƶ�ʴ���, b.��������, f.���� as ����, b.����||decode(b.Ӥ��,0,'','��Ӥ��') as ����, a.����, e.סԺ��, b.ҽ������, b.��ʼִ��ʱ��
  from ҩƷ�շ���¼ a,����ҽ����¼ b ,ҩƷ��� d,������ҳ e,���ű� f,����ҽ������ c, �շ���ĿĿ¼ g, �շ���Ŀ���� h, ҩƷĿ¼ i, ҽ��ִ��ʱ�� j
  , (
  SELECT Y.ҽ��ID, COUNT(Y.ҽ��ID) AS ����ִ�д��� 
  FROM ҽ��ִ��ʱ�� Y
  JOIN ����ҽ����¼ B ON Y.ҽ��ID = B.���ID
  WHERE B.ID IN (select Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
  GROUP BY Y.ҽ��ID
  ) YY
  where  a.ҽ��id=b.id
  and a.ҩƷid=d.ҩƷid
  and a.����id=e.����id
  and a.��ҳid=e.��ҳid
  and a.�Է�����id=f.id
  and b.id=c.ҽ��id
  and  a.no=c.no
  and a.ҩƷid = g.id
  and g.id = h.�շ�ϸĿid(+)
  and a.ҩƷid = i.ҩƷid
  and b.���id = j.ҽ��id
  and b.���id = yy.ҽ��ID
  and h.����(+) = 3
  
  
  -- ����
  and b.ҽ����Ч = 1
  and a.�������� > to_date('20230518223500', 'yyyy-mm-dd hh24:mi:ss')
  
/*  -- û������
  and (b.ҽ������ is null or b.ҽ������ = '')*/
  
  --ִ������ = 5������Ϊ��Ժ��ҩ�ȡ����ڱ�sql�Ƿ�����ҩ�����ʲ���Ҫ��Ժ��ҩ�Ĳ��֡�
  and b.ִ������ <> 5
  
  --ҩƷ�շ���¼�У�(Mod(A.��¼״̬, 3) = 0 Or A.��¼״̬ = 1) ��ζ��ԭʼ��¼��
  and   (Mod(A.��¼״̬, 3) = 0 Or A.��¼״̬ = 1) 
  
  --ֻ�пڷ���Ҫ��ӡҩ��
  AND A.�÷� IN ('�ڷ�(��������ר��)','�ڷ�','��ˮ��','�ڷ��з�','����','�ݷ�','θ��ע��','����','�����ڵ�ҩ','��ˮ���','���')
  
  --����ִ�д���
  AND YY.����ִ�д��� <= CASE b.ִ��Ƶ��
  WHEN 'ÿ���Ĵ�' THEN 4
  WHEN 'ÿ������' THEN 3
  WHEN 'ÿ�����' THEN 2 
  WHEN 'һ����' THEN 1 
  WHEN 'ÿ��һ��' THEN 1 
  WHEN 'ÿ���糿һ��' THEN 1
  WHEN 'ÿ������һ��' THEN 1
  WHEN 'ÿ���糿һ��' THEN 1
  WHEN 'ÿ������һ��' THEN 1
  WHEN 'ÿ4Сʱһ��' THEN 6
  WHEN 'ÿ6Сʱһ��' THEN 4
  WHEN 'ÿ8Сʱһ��' THEN 3
  WHEN 'ÿ12Сʱһ��' THEN 2
  WHEN '��Ҫʱ' THEN 1
  ELSE 0 END
  
  --AND A.���ܷ�ҩ�� IS NOT NULL
  and (a.no, a.����id, a.�ⷿid, a.ҽ��id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_temporary 
--ҩ��ʱ���
left join drugbag_rec on temp_origin_temporary.ִ��Ƶ�� = drugbag_rec.ִ��Ƶ��
order by temp_origin_temporary.���� asc, temp_origin_temporary.����id asc, temp_origin_temporary.���� asc, drugbag_rec.ƥ�� desc, temp_origin_temporary.ҩƷid
) def
) ww
order by ww.����0 asc, ww.����id asc, to_char(ww.����, 'yyyy-mm-dd') asc, case when ww.ҽ������ is not null then ww.ҩƷid || ww.ҽ������ else '' end, ww.ƥ�� desc, ww.ҩƷid asc
) zz
order by zz.����0 asc, zz.����id asc, to_char(zz.����, 'yyyy-mm-dd') asc, zz.���л�ҳ, zz.�׽����ڻ�ҳ, zz.ƥ�� desc, zz.ҩƷid asc
) xxx



union all 


/* ÿ���ϼƶ������� */
select yyy.����, yyy.����, yyy.סԺ��, yyy.����, yyy.��_��ҩ����, yyy.��ҩʱ��, null as ҽ��, null as ���, '������ ' || sum(yyy.����0) || ' ��' as �÷�, null as ִ��Ƶ��, null as Ƶ�ʴ���
, null as ����, null as ҽ������, yyy.����0, yyy.����id, null as �״�, yyy.���л�ҳ, yyy.�׽����ڻ�ҳ, yyy.��ҳ��ʶ, 9999999 as ҩƷid
, yyy.ƥ�� from (
--����ʵ�ʻ�ҳ��ʶ��
select zz.����, zz.����, zz.סԺ��, zz.����, zz.��ʿʵ��һ�η����ļ��� as ��_��ҩ����, zz.��ҩʱ��, zz.ҽ��, zz.���, zz.�÷�, zz.ִ��Ƶ��, zz.Ƶ�ʴ���, zz.����0, zz.����, zz.ҽ������, zz.����0, zz.����id, zz.�״�, zz.���л�ҳ, zz.�׽����ڻ�ҳ
, zz.����id || '/' || to_char(zz.����, 'yyyy-mm-dd') || '/' || zz.ƥ�� || '/' || zz.���л�ҳ || '/' || zz.�׽����ڻ�ҳ || '/' || zz.��ʿʵ��һ�η����ļ��� ||  '/' || trunc(zz.��ҩ���ڼ���ҩ / 6) as ��ҳ��ʶ, zz.ҩƷid
, zz.ƥ�� from (
--����ԭ��ҩ���ж�����ҩ��
select ww.����, ww.����, ww.סԺ��, ww.����, ww.��ҩ����, ww.��ҩʱ��, ww.ҽ��, ww.���, ww.�÷�, ww.ִ��Ƶ��, ww.Ƶ�ʴ���, ww.����, ww.ҽ������, ww.����0, ww.����id, ww.�״�
, ww.ҩƷid, ww.����0, case when ww.ҽ������ is not null then ww.ҽ������ else '' end as ���л�ҳ, case when ww.ҽ�� like '%�׽�%' then '�׽�' when ww.ҽ�� like '%����%' then '����' else 'ͨ��' end as �׽����ڻ�ҳ
, ww.����, ww.ƥ��, row_number() over(partition by ww.����0, ww.����id, to_char(ww.����, 'yyyy-mm-dd'), case when ww.ҽ������ is not null then ww.ҩƷid || ww.ҽ������ else '' end, ww.ƥ��
 order by ww.����0 asc, ww.����id asc, to_char(ww.����, 'yyyy-mm-dd') asc, case when ww.ҽ������ is not null then ww.ҩƷid || ww.ҽ������ else '' end, ww.ƥ�� desc, ww.ҩƷid asc) as ��ҩ���ڼ���ҩ, ww.��ʿʵ��һ�η����ļ��� 
 from (
--���ﳤ���ض���ӡҩ������
select * from (
select 
  RPAD('����: ' || temp_origin_continuous.����, 30, ' ') as ����, '����: ' || temp_origin_continuous.���� || ' ��' as ����
  , RPAD('סԺ��: ' || temp_origin_continuous.סԺ��, 30, ' ') AS סԺ��, '����: ' || temp_origin_continuous.���� as ����
  , RPAD('��ҩ����: ' || to_char(temp_origin_continuous.����, 'yyyy-mm-dd'), 30, ' ') as ��ҩ����, '��ҩʱ��: ' || drugbag_rec.ʱ�� as ��ҩʱ��
  , temp_origin_continuous.ҽ��, temp_origin_continuous.���, temp_origin_continuous.�÷�, temp_origin_continuous.ִ��Ƶ��, temp_origin_continuous.Ƶ�ʴ���
  , temp_origin_continuous.����0, temp_origin_continuous.����, temp_origin_continuous.ҽ������
  , cast(regexp_replace(temp_origin_continuous.����, '[^0-9]', '') as numeric) as ����0, temp_origin_continuous.����id, temp_origin_continuous.����, drugbag_rec.ƥ��, drugbag_rec.�״�, temp_origin_continuous.ҩƷid
  , temp_origin_continuous.��ʼִ��ʱ��, RPAD('��ҩ����: ' || temp_origin_continuous.��ʿʵ��һ�η����ļ���, 30, ' ') as ��ʿʵ��һ�η����ļ���
from (
--Դ���ݼ�
select distinct i.���, a.�ⷿid, a.ҩƷid, a.ҽ��id, e.��Ժ���� as ����, e.����id, e.��ҳid, NVL(h.����, g.����) as ҽ��
  , RTRIM(to_char(b.��������/d.����ϵ��,'fm990.99999'), '.') as ����0, RTRIM(to_char(b.��������/d.����ϵ��,'fm990.99999'), '.')||d.סԺ��λ as ����,a.�÷�
  , c.�״�ʱ�� as ����, b.ִ��Ƶ��, b.Ƶ�ʴ���, b.��������, f.���� as ����, b.����||decode(b.Ӥ��,0,'','��Ӥ��') as ����, a.����, e.סԺ��, b.ҽ������, b.��ʼִ��ʱ��
  , datesplit.Ҫ������ as ��ʿʵ��һ�η����ļ���
  from ҩƷ�շ���¼ a,����ҽ����¼ b ,ҩƷ��� d,������ҳ e,���ű� f,����ҽ������ c, �շ���ĿĿ¼ g, �շ���Ŀ���� h, ҩƷĿ¼ i
  , (select distinct to_char(c.Ҫ��ʱ��, 'yyyy-mm-dd') as Ҫ������, c.ҽ��id, e.���ͺ� from ҽ��ִ��ʱ�� c
  join (select a.���id, b.���ͺ� from ����ҽ����¼ a
  join ����ҽ������ b on a.id = b.ҽ��id
  where (b.no, b.ҽ��id) in
 (select no, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) e on c.ҽ��id = e.���id and c.���ͺ� = e.���ͺ�
  order by to_char(c.Ҫ��ʱ��, 'yyyy-mm-dd')) datesplit
  where  a.ҽ��id=b.id
  and a.ҩƷid=d.ҩƷid
  and a.����id=e.����id
  and a.��ҳid=e.��ҳid
  and a.�Է�����id=f.id
  and b.id=c.ҽ��id
  and  a.no=c.no
  and a.ҩƷid = g.id
  and g.id = h.�շ�ϸĿid(+)
  and a.ҩƷid = i.ҩƷid
  and h.����(+) = 3
  and datesplit.ҽ��id = b.���id and c.���ͺ� = datesplit.���ͺ�
  
  -- ����
  and b.ҽ����Ч = 0
  and a.�������� > to_date('20230518223500', 'yyyy-mm-dd hh24:mi:ss')
  
  
/*  -- û������
  and (b.ҽ������ is null or b.ҽ������ = '')*/
  
  --ִ������ = 5������Ϊ��Ժ��ҩ�ȡ����ڱ�sql�Ƿ�����ҩ�����ʲ���Ҫ��Ժ��ҩ�Ĳ��֡�
  and b.ִ������ <> 5
  
  --ҩƷ�շ���¼�У�(Mod(A.��¼״̬, 3) = 0 Or A.��¼״̬ = 1) ��ζ��ԭʼ��¼��
  and   (Mod(A.��¼״̬, 3) = 0 Or A.��¼״̬ = 1) 
  
  --ֻ�пڷ���Ҫ��ӡҩ��
  AND A.�÷� IN ('�ڷ�(��������ר��)','�ڷ�','��ˮ��','�ڷ��з�','����','�ݷ�','θ��ע��','����','�����ڵ�ҩ','��ˮ���','���')
  
  --AND A.���ܷ�ҩ�� IS NOT NULL
  and (a.no, a.����id, a.�ⷿid, a.ҽ��id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_continuous 
--ҩ��ʱ���
join drugbag_rec on temp_origin_continuous.ִ��Ƶ�� = drugbag_rec.ִ��Ƶ��
--��ǰno���״�ִ��ʱ�� = ���� && ��������ƥ�䣨ҽ�������������βŻ���ֵ����
where (temp_origin_continuous.��ʿʵ��һ�η����ļ��� = to_char(temp_origin_continuous.��ʼִ��ʱ��, 'yyyy-mm-dd') and drugbag_rec.�״� <= temp_origin_continuous.�������� and temp_origin_continuous.�������� is not null)
--��ǰno���״�ִ��ʱ�� = ���� && ҽ��û����д��������
or (temp_origin_continuous.��ʿʵ��һ�η����ļ��� = to_char(temp_origin_continuous.��ʼִ��ʱ��, 'yyyy-mm-dd') and temp_origin_continuous.�������� is null)
--��ǰno�״�ִ��ʱ�� ��= ���գ�ƥ��ȫ��������
or (temp_origin_continuous.��ʿʵ��һ�η����ļ��� <> to_char(temp_origin_continuous.��ʼִ��ʱ��, 'yyyy-mm-dd'))
order by temp_origin_continuous.���� asc, temp_origin_continuous.����id asc, temp_origin_continuous.���� asc, drugbag_rec.ƥ�� desc, temp_origin_continuous.ҩƷid

) abc

union all

select * from (
--��������һ�������ӡҩ������
--ע�⣬����û��������������ֶΡ�
select 
  RPAD('����: ' || temp_origin_temporary.����, 30, ' ') as ����, '����: ' || temp_origin_temporary.���� || ' ��' as ����
  , RPAD('סԺ��: ' || temp_origin_temporary.סԺ��, 30, ' ') AS סԺ��, '����: ' || temp_origin_temporary.���� as ����
  , RPAD('��ҩ����: ' || to_char(temp_origin_temporary.����, 'yyyy-mm-dd'), 30, ' ') as ��ҩ����, '��ҩʱ��: ' || drugbag_rec.ʱ�� as ��ҩʱ��
  , temp_origin_temporary.ҽ��, temp_origin_temporary.���, temp_origin_temporary.�÷�, temp_origin_temporary.ִ��Ƶ��, temp_origin_temporary.Ƶ�ʴ���
  , temp_origin_temporary.����0, temp_origin_temporary.����, temp_origin_temporary.ҽ������
  , cast(regexp_replace(temp_origin_temporary.����, '[^0-9]', '') as numeric) as ����0, temp_origin_temporary.����id, temp_origin_temporary.����, drugbag_rec.ƥ��, drugbag_rec.�״�, temp_origin_temporary.ҩƷid
  , temp_origin_temporary.��ʼִ��ʱ��, RPAD('��ҩ����: ' || to_char(temp_origin_temporary.����, 'yyyy-mm-dd'), 30, ' ') as ��ʿʵ��һ�η����ļ���
from (
--Դ���ݼ�
select distinct i.���, a.�ⷿid, a.ҩƷid, a.ҽ��id, e.��Ժ���� as ����, e.����id, e.��ҳid, NVL(h.����, g.����) as ҽ��
  , RTRIM(to_char(b.��������/d.����ϵ��,'fm990.99999'), '.') as ����0, RTRIM(to_char(b.��������/d.����ϵ��,'fm990.99999'), '.')||d.סԺ��λ as ����,a.�÷�
  , c.�״�ʱ�� as ����, b.ִ��Ƶ��, b.Ƶ�ʴ���, b.��������, f.���� as ����, b.����||decode(b.Ӥ��,0,'','��Ӥ��') as ����, a.����, e.סԺ��, b.ҽ������, b.��ʼִ��ʱ��
  from ҩƷ�շ���¼ a,����ҽ����¼ b ,ҩƷ��� d,������ҳ e,���ű� f,����ҽ������ c, �շ���ĿĿ¼ g, �շ���Ŀ���� h, ҩƷĿ¼ i, ҽ��ִ��ʱ�� j
  , (
  SELECT Y.ҽ��ID, COUNT(Y.ҽ��ID) AS ����ִ�д��� 
  FROM ҽ��ִ��ʱ�� Y
  JOIN ����ҽ����¼ B ON Y.ҽ��ID = B.���ID
  WHERE B.ID IN (select Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
  GROUP BY Y.ҽ��ID
  ) YY
  where  a.ҽ��id=b.id
  and a.ҩƷid=d.ҩƷid
  and a.����id=e.����id
  and a.��ҳid=e.��ҳid
  and a.�Է�����id=f.id
  and b.id=c.ҽ��id
  and  a.no=c.no
  and a.ҩƷid = g.id
  and g.id = h.�շ�ϸĿid(+)
  and a.ҩƷid = i.ҩƷid
  and b.���id = j.ҽ��id
  and b.���id = yy.ҽ��ID
  and h.����(+) = 3
  
  
  -- ����
  and b.ҽ����Ч = 1
  and a.�������� > to_date('20230518223500', 'yyyy-mm-dd hh24:mi:ss')
  
  
/*  -- û������
  and (b.ҽ������ is null or b.ҽ������ = '')*/
  
  --ִ������ = 5������Ϊ��Ժ��ҩ�ȡ����ڱ�sql�Ƿ�����ҩ�����ʲ���Ҫ��Ժ��ҩ�Ĳ��֡�
  and b.ִ������ <> 5
  
  --ҩƷ�շ���¼�У�(Mod(A.��¼״̬, 3) = 0 Or A.��¼״̬ = 1) ��ζ��ԭʼ��¼��
  and   (Mod(A.��¼״̬, 3) = 0 Or A.��¼״̬ = 1) 
  
  --ֻ�пڷ���Ҫ��ӡҩ��
  AND A.�÷� IN ('�ڷ�(��������ר��)','�ڷ�','��ˮ��','�ڷ��з�','����','�ݷ�','θ��ע��','����','�����ڵ�ҩ','��ˮ���','���')
  
  --����ִ�д���
  AND YY.����ִ�д��� <= CASE b.ִ��Ƶ��
  WHEN 'ÿ���Ĵ�' THEN 4
  WHEN 'ÿ������' THEN 3
  WHEN 'ÿ�����' THEN 2 
  WHEN 'һ����' THEN 1 
  WHEN 'ÿ��һ��' THEN 1 
  WHEN 'ÿ���糿һ��' THEN 1
  WHEN 'ÿ������һ��' THEN 1
  WHEN 'ÿ���糿һ��' THEN 1
  WHEN 'ÿ������һ��' THEN 1
  WHEN 'ÿ4Сʱһ��' THEN 6
  WHEN 'ÿ6Сʱһ��' THEN 4
  WHEN 'ÿ8Сʱһ��' THEN 3
  WHEN 'ÿ12Сʱһ��' THEN 2
  WHEN '��Ҫʱ' THEN 1
  ELSE 0 END
  
  --AND A.���ܷ�ҩ�� IS NOT NULL
  and (a.no, a.����id, a.�ⷿid, a.ҽ��id) in
 (select no, pid, Storehouse_id, Order_Id from
  json_table({:CS},'$'columns (nested path '$[*]' columns(no varchar2(20) path '$.Rcp_No', pid number path '$.Pati_Id', Storehouse_Id number path '$.Storehouse_Id',Order_Id number path '$.Order_Id'))) )
) temp_origin_temporary 
--ҩ��ʱ���
left join drugbag_rec on temp_origin_temporary.ִ��Ƶ�� = drugbag_rec.ִ��Ƶ��
order by temp_origin_temporary.���� asc, temp_origin_temporary.����id asc, temp_origin_temporary.���� asc, drugbag_rec.ƥ�� desc, temp_origin_temporary.ҩƷid
) def
) ww
order by ww.����0 asc, ww.����id asc, to_char(ww.����, 'yyyy-mm-dd') asc, case when ww.ҽ������ is not null then ww.ҩƷid || ww.ҽ������ else '' end, ww.ƥ�� desc, ww.ҩƷid asc
) zz
order by zz.����0 asc, zz.����id asc, to_char(zz.����, 'yyyy-mm-dd') asc, zz.���л�ҳ, zz.�׽����ڻ�ҳ, zz.ƥ�� desc, zz.ҩƷid asc
) yyy
group by yyy.����, yyy.����, yyy.סԺ��, yyy.����, yyy.��_��ҩ����, yyy.��ҩʱ��, yyy.����0, yyy.����id, yyy.��_��ҩ����, yyy.���л�ҳ, yyy.�׽����ڻ�ҳ, yyy.ƥ��, yyy.��ҳ��ʶ
) zzzz
where zzzz.ҽ�� not like '%����Ӫ��Һ%'
or zzzz.ҽ�� is null
order by zzzz.����0 asc, zzzz.����id asc, zzzz.��_��ҩ���� asc, zzzz.���л�ҳ, zzzz.�׽����ڻ�ҳ, zzzz.ƥ�� desc, zzzz.��ҳ��ʶ, zzzz.ҩƷid asc
