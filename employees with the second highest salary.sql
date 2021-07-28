--Find the employees with the second highest salary in the employees table:

--1st option:
--Simply create a dense_rank to rank all the salaries and pick all from the second rank 
select * from(
        select e.*, dense_rank() 
        over(order by e.salary desc) r from employees e) 
where r=2;

--2nd option:
--First, select all the distinct salaries, put in descend order, and fetch only the second one
--Then, select all the employees that match that salary
with second_highest_salary as(select distinct salary 
                                from employees order by salary desc
                              offset 1 rows fetch next 1 rows with ties)
select * from employees emp, second_highest_salary shs
where emp.salary = shs.salary ;

--3rd option:
--First, select all the distinct salaries and put in descend order
--Second, select the 2 first salaries from the top
--Then, chose the minimun value from them
--Finally, select all the employees that match that salary

with 
distinc_salaries as (select distinct emp.salary 
                       from employees emp
                      order by salary desc),
best_two_salaries as (select ds.salary 
                       from distinc_salaries ds
                      where rownum <= 2),
second_highest_salary as ( select min(bts.salary) as salary
                             from best_two_salaries bts)
select emp.* 
  from employees emp, second_highest_salary shs
 where emp.salary = shs.salary;
 
--4th option:
--First, select the maximun salary in all the table
--Then, select the maximum salary again but below the maximum value found in the step before
--Finally, select all the employees that match that salary
with second_highest_salary as 
(select max(salary) salary
                 from employees
                 where salary < (select max(salary)
                                    from employees))
select * from employees emp, second_highest_salary shs
where emp.salary = shs.salary ; 
