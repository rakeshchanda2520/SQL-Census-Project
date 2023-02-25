---View the TABLE---

SELECT * FROM growth LIMIT 5;
SELECT * FROM populatiON LIMIT 5;

---Number of rows in TABLE---

SELECT COUNT(*) FROM growth;
SELECT COUNT(*) FROM populatiON;

---Data of growth FROM MaharAShtra, Karnataka, Goa---
SELECT * FROM growth WHERE state IN ('MaharAShtra','Karnataka','Goa');

---PopulatiON of India---
SELECT SUM(PopulatiON) FROM populatiON;

---Avg growth---
SELECT state,Avg(growth)*100 AS avg_growth FROM growth GROUP BY state ORDER BY avg_growth DESC;


--Avg sex ratio---
SELECT state, ROUND(Avg(sex_ratio),0) AS avg_sex_ratio FROM growth GROUP BY state ORDER BY avg_sex_ratio DESC;


---Avg literacy rate---
 
SELECT state,round(avg(literacy),0) avg_literacy_ratio FROM project..data1 
GROUP BY state having round(avg(literacy),0)>90 ORDER BY avg_literacy_ratio DESC ;

---TOP 3 state showing highest growth ratio---

SELECT state,avg(growth)*100 avg_growth FROM project..data1 GROUP BY state ORDER BY avg_growth DESC limit 3;


--Bottom 3 state showing lowest sex ratio---

SELECT TOP 3 state,round(avg(sex_ratio),0) avg_sex_ratio FROM project..data1 GROUP BY state ORDER BY avg_sex_ratio ASc;


-- TOP and bottom 3 states in literacy state

DROP TABLE IF EXISTS #TOPstates;
CREATE TABLE #TOPstates
( state nvarchar(255),
  TOPstate float
)

INSERT into #TOPstates
SELECT state,round(avg(literacy),0) avg_literacy_ratio FROM project..data1 
GROUP BY state ORDER BY avg_literacy_ratio DESC;

SELECT TOP 3 * FROM #TOPstates ORDER BY #TOPstates.TOPstate DESC;

DROP TABLE IF EXISTS #bottomstates;
CREATE TABLE #bottomstates
( state nvarchar(255),
  bottomstate float
)

INSERT into #bottomstates
SELECT state,round(avg(literacy),0) avg_literacy_ratio FROM project..data1 
GROUP BY state ORDER BY avg_literacy_ratio DESC;

SELECT TOP 3 * FROM #bottomstates ORDER BY #bottomstates.bottomstate ASc;


--uniON opertor

SELECT * FROM (
SELECT TOP 3 * FROM #TOPstates ORDER BY #TOPstates.TOPstate DESC) a

uniON

SELECT * FROM (
SELECT TOP 3 * FROM #bottomstates ORDER BY #bottomstates.bottomstate ASc) b;


-- States starting with letter a---

SELECT distinct state FROM project..data1 WHERE lower(state) like 'a%' or lower(state) like 'b%'

SELECT distinct state FROM project..data1 WHERE lower(state) like 'a%' and lower(state) like '%m'



-- JOINing both TABLE
--Total males and females---

SELECT d.state,SUM(d.males) total_males,SUM(d.females) total_females FROM
(SELECT c.district,c.state state,round(c.populatiON/(c.sex_ratio+1),0) males, round((c.populatiON*c.sex_ratio)/(c.sex_ratio+1),0) females FROM
(SELECT a.district,a.state,a.sex_ratio/1000 sex_ratio,b.populatiON FROM project..data1 a INNER JOIN project..data2 b ON a.district=b.district ) c) d
GROUP BY d.state;


--Total literacy rate---

SELECT c.state,SUM(literate_people) total_literate_pop,SUM(illiterate_people) total_lliterate_pop FROM 
(SELECT d.district,d.state,round(d.literacy_ratio*d.populatiON,0) literate_people,
round((1-d.literacy_ratio)* d.populatiON,0) illiterate_people FROM
(SELECT a.district,a.state,a.literacy/100 literacy_ratio,b.populatiON FROM project..data1 a 
INNER JOIN project..data2 b ON a.district=b.district) d) c
GROUP BY c.state


--Population in previous census---

SELECT SUM(m.previous_census_populatiON) previous_census_populatiON,SUM(m.current_census_populatiON) current_census_populatiON FROM(
SELECT e.state,SUM(e.previous_census_populatiON) previous_census_populatiON,SUM(e.current_census_populatiON) current_census_populatiON FROM
(SELECT d.district,d.state,round(d.populatiON/(1+d.growth),0) previous_census_populatiON,d.populatiON current_census_populatiON FROM
(SELECT a.district,a.state,a.growth growth,b.populatiON FROM project..data1 a INNER JOIN project..data2 b ON a.district=b.district) d) e
GROUP BY e.state)m


---PopulatiON vs area---

SELECT (g.total_area/g.previous_census_populatiON)  AS previous_census_populatiON_vs_area, (g.total_area/g.current_census_populatiON) AS 
current_census_populatiON_vs_area FROM
(SELECT q.*,r.total_area FROM (

SELECT '1' AS keyy,n.* FROM
(SELECT SUM(m.previous_census_populatiON) previous_census_populatiON,SUM(m.current_census_populatiON) current_census_populatiON FROM(
SELECT e.state,SUM(e.previous_census_populatiON) previous_census_populatiON,SUM(e.current_census_populatiON) current_census_populatiON FROM
(SELECT d.district,d.state,round(d.populatiON/(1+d.growth),0) previous_census_populatiON,d.populatiON current_census_populatiON FROM
(SELECT a.district,a.state,a.growth growth,b.populatiON FROM project..data1 a INNER JOIN project..data2 b ON a.district=b.district) d) e
GROUP BY e.state)m) n) q INNER JOIN (

SELECT '1' AS keyy,z.* FROM (
SELECT SUM(area_km2) total_area FROM project..data2)z) r ON q.keyy=r.keyy)g


--window---

---output TOP 3 districts FROM each state with highest literacy rate---

SELECT a.* FROM
(SELECT district,state,literacy,rank() over(partitiON BY state ORDER BY literacy DESC) rnk FROM project..data1) a
WHERE a.rnk in (1,2,3) ORDER BY state


