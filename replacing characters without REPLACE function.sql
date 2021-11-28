--1) replace characters without using the REPLACE function in a select.
--i.e. replace a phrase with German special characters like "German Orthography considers Â, Ä/ä, Ö/ö, Ü/ü, and ß distinct letters" to English characters.

--Firts, split the phrase in a CTE having each character in a row.
--Then in another CTE compare each row with a case statement and relplace it, and add an order column to identified the order of the characters.
--Finally, use the listagg function to join the result of the second CTE into a single row, in the correct order.

with
split_word as (select substr('German Orthography considers Â, Ä/ä, Ö/ö, Ü/ü, and ß distinct letters',level,1) as letter                      
                from dual
                connect by level <= length('German Orthography considers Â, Ä/ä, Ö/ö, Ü/ü, and ß distinct letters')),
translate_letters as (select  case  
                                when letter in ('à','á','â') then 'a'
                                when letter in ('À','Á','Â') then 'A'
                                when letter in ('ä') then 'ae'
                                when letter in ('Ä') then 'AE'
                                when letter in ('è','é','ê') then 'e'
                                when letter in ('È','É','Ê') then 'E'
                                when letter in ('ì','í','î') then 'i'
                                when letter in ('Ì','Í','Î') then 'I'
                                when letter in ('ò','ó','ô') then 'o'
                                when letter in ('Ò','Ó','Ô') then 'O'
                                when letter in ('ö') then 'oe'
                                when letter in ('Ö') then 'OE'
                                when letter in ('ù','ú','û') then 'u'
                                when letter in ('Ù','Ú','Û') then 'U'
                                when letter in ('ü') then 'ue'
                                when letter in ('Ü') then 'UE'
                                when letter in ('ß') then 'ss'
                                else letter
                              end as new_letter,
                            row_number() over(order by 1) as letter_order
                      from split_word)  
select listagg(new_letter) within group(order by letter_order) as new_word
from translate_letters;

--So the result will be:
--"German Orthography considers A, AE/ae, OE/oe, UE/ue, and ss distinct letters"
