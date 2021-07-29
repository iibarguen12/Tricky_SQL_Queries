--1)Display a comma separated string value in diferent rows including the null values:
--input_value= ",param B,,param D,param E,param F,param G,,,,param K,,"

--First, add a space before and after each comma in orden to include null values as well
--Then, create a regular expression that identify when a comma appears and the respective value
--After that, create a level to iterate the string and connect it to the amount of times the regular expression matches the string
--Finally, replace again the added spaces to the result BUT without delete the ones from the original string

with 
input_value as  (select ',param B,,param D,param E,param F,param G,,    ,,param K,,' val 
                   from dual),
adding_space as (select replace(val,',',' , ') val_with_space
                   from input_value),
dirty_result as (select regexp_substr(val_with_space,'[^,]+',1,level) cols 
                   from adding_space
                 connect by level <= regexp_count(val_with_space,'[^,]+') 
                )
select regexp_replace(cols,'^ | $','') clean_cols
  from dirty_result;
  

--2)Given a string separated by space reverse the words in the string:
--input_value 'hello world here!' have to display 'here! world hello'

--For this one, use the same approach as before. First split the prhase in several rows, but insted of usgin comma use space
--Then, add a row_nunmber column to enumerate each row (word)
--Finally, use the listagg function to join all the rows into a single one separated by space, and specify descending order to reverse the rows (words)
```sql
with 
input_value    as (select 'hello world here!' val 
                     from dual),
prhase_to_rows as (select regexp_substr(val,'[^ ]+',1,level) word_col,
                          row_number() over(order by 1)      row_num_col
                     from input_value
                   connect by level <= regexp_count(val,'[^ ]+')),
rows_to_prhase as (select listagg(word_col,' ')
                   within group(order by row_num_col desc) as prhase
                     from prhase_to_rows)                   
select prhase 
  from rows_to_prhase;
```

--3) Given two rows of separated comma values, convert it to multiple rows:
--input_value: 
--'David,Estefania'
--'Juan,Laura,Martha,Nicolas'
--output_value:
--David
--Estefania
--Juan
--Laura
--Martha
--Nicolas

--For this one, is necessary to create a different level for each row, due the first row has just 2 values and the second 4 values
--To achieve this, is possible to create a inline view and use the LATERAL clause in order to reference the table on the left
--After that is easy to follow the same pattern as exercise 1 and 2
```sql
with 
input_value as (select 'David,Estefania' as various_names from dual
                union all
                select 'Juan,Laura,Martha,Nicolas' as various_names  from dual)
select regexp_substr(input_value.various_names,'[^,]+',1,lvl) single_name
from input_value, 
lateral(select level lvl from dual connect by level <= regexp_count(input_value.various_names,'[^,]+'));
```

--The same result can be achieved in several ways, for example instead of using LATERAL, just create a level for all the rows indiscriminately
--and then get only the unique ones with the DISTINCT clause, but be aware that in these cases the generated rows can increase exponentially 
--as well that you will lose equal names in different rows
```sql
with 
input_value as (select 'David,Estefania' as various_names from dual
                union all
                select 'Juan,Laura,Martha,Nicolas' as various_names  from dual)
select distinct regexp_substr(input_value.various_names,'[^,]+',1,level) single_name
from input_value 
connect by regexp_substr(various_names,'[^,]+',1,level) is not null
order by single_name;
```
