create table patient_info (
patient_id varchar2(50) primary key);

create table sample_info (
sample_id varchar2(50) primary key,
patient_id varchar2(50) references patient_info(patient_id),
pam50_subtype varchar2(50));

create table protein_metadata(
symbol varchar2(50) primary key,
top_keywords varchar2(255));

create table protein_expression (
symbol varchar2(50) constraint fk_protein_sym references protein_metadata(symbol),
sample_id varchar2(50) references sample_info(sample_id),
expression_value number,
primary key(symbol, sample_id));

alter table protein_expression disable constraint fk_protein_sym;

select * from(
select m.symbol, m.top_keywords, round(avg(e.expression_value), 2) as avg_expression
from protein_metadata m join protein_expression e on m.symbol = substr(e.symbol, 1, instr(e.symbol, '|') -1)
join sample_info s on e.sample_id = s.sample_id
join patient_info p on s.patient_id = p.patient_id
where s.pam50_subtype = 'Basal'
and lower(m.top_keywords) like '%immune%'
group by m.symbol, m.top_keywords
order by avg_expression desc)
where rownum <= 10;
