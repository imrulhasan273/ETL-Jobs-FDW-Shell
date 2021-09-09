

-- https://www.percona.com/blog/2018/08/21/foreign-data-wrappers-postgresql-postgres_fdw/


select
	name,
	default_version,
	installed_version,
	left(comment, 30) as comment
from
	pg_available_extensions
where
	1=1
	and installed_version is not null
order by
	name
;



/*
	Source 		: source is the remote postgres server from where the tables are accessed by the destination database server as foreign tables.
	Destination : destination is another postgres server where the foreign tables are created which is referring tables in source database server.
*/


-- Step 1: Create a user on the source
-- -----------------------------------

CREATE USER fdw_user WITH ENCRYPTED PASSWORD 'secret';




-- Step 2: Create test tables (optional) on the source
-- ---------------------------------------------------

create table employee (id int, first_name varchar(20), last_name varchar(20));
insert into employee values (1,'jobin','augustine'),(2,'avinash','vallarapu'),(3,'fernando','camargos');

create table employee2 (id int, first_name varchar(20), last_name varchar(20));
insert into employee2 values (1,'jobin','augustine'),(2,'avinash','vallarapu'),(3,'fernando','camargos');

create table employee3 (id int, first_name varchar(20), last_name varchar(20));
insert into employee3 values (1,'jobin','augustine'),(2,'avinash','vallarapu'),(3,'fernando','camargos');

create table employee4 (id int, first_name varchar(20), last_name varchar(20));
insert into employee4 values (1,'jobin','augustine'),(2,'avinash','vallarapu'),(3,'fernando','camargos');

-- Step 3: Grant privileges to user in the source
-- ----------------------------------------------

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE employee TO fdw_user;


-- Step 4: Modify ACL in pg_hba.conf
-- ---------------------------------

-- hba.conf
host    all 	all		destination_server_ip/32	md5
host    all   	all 	 0.0.0.0/0      			md5


-- postgresql.conf
listen_address = '*'


-- Step 5: Create postgres_fdw extension on the destination
-- --------------------------------------------------------

CREATE EXTENSION postgres_fdw SCHEMA public ;


select
	name,
	default_version,
	installed_version,
	left(comment, 30) as comment
from pg_available_extensions where 1=1 and installed_version is not null order by name
;




-- Step 6: Grant privileges to user in the destination
-- ---------------------------------------------------

--CREATE USER app_user WITH ENCRYPTED PASSWORD 'secret';

GRANT ALL PRIVILEGES ON DATABASE postgres TO app_user;

grant usage on FOREIGN DATA WRAPPER postgres_fdw to app_user ;


-- Step 7: Create a server definition
-- ----------------------------------

-- Information about Source Server
CREATE SERVER hr 
 FOREIGN DATA WRAPPER postgres_fdw
 OPTIONS (dbname 'postgres', host '10.9.0.222', port '5432');  



-- Step 8: Create user mapping from destination user to source user
-- ----------------------------------------------------------------

CREATE USER MAPPING for app_user
SERVER hr
OPTIONS (user 'fdw_user', password 'secret');


DROP USER MAPPING IF EXISTS FOR postgres SERVER hr;

CREATE USER MAPPING FOR postgres
SERVER hr
OPTIONS (user 'fdw_user', password 'secret');




-- Step 9: Create foreign table definition on the destination
-- -----------------------------------------------------------

--- SINGLE TABLE 
CREATE FOREIGN TABLE foreign_schema.employees	-- Destination Schema: foreign_schema
(id int, first_name character varying(20), last_name character varying(20))
SERVER hr
OPTIONS (schema_name 'public', table_name 'employee');	-- Source Schema: public


--- MULTIPLE TABLE::ALL
IMPORT FOREIGN SCHEMA "public" 	-- Source Schema: public
FROM SERVER hr INTO foreign_schema; -- Destination Schema: foreign_schema

--- MULTIPLE TABLE::LIMIT
IMPORT FOREIGN SCHEMA "public" limit to (employee,employee2,employee3,employee4) 	-- Source Schema: public
FROM SERVER hr INTO foreign_schema; -- Destination Schema: foreign_schema

-- Step 10: Test foreign table
-- ---------------------------

select * from foreign_schema.employees ;



-- --------------------------------------------------------------
-- --------------------------------------------------------------
-- --------------------------------------------------------------
-- --------------------------------------------------------------
-- --------------------------------------------------------------
-- --------------------------------------------------------------




CREATE EXTENSION postgres_fdw SCHEMA public ;




CREATE SERVER hr 
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (dbname 'postgres', host '10.9.0.222', port '5432'); 






CREATE USER MAPPING for postgres
SERVER hr
OPTIONS (user 'fdw_user', password 'secret');


IMPORT FOREIGN SCHEMA "public" 	-- Source Schema: public
FROM SERVER hr INTO foreign_schema; -- Destination Schema: foreign_schema


IMPORT FOREIGN SCHEMA "public" limit to (employee,employee2,employee3,employee4) 	-- Source Schema: public
FROM SERVER hr INTO foreign_schema; -- Destination Schema: foreign_schema

- --

IMPORT FOREIGN SCHEMA "public" limit to (employee,employee2,employee3,employee4) 	-- Source Schema: public
FROM SERVER hr INTO foreign_schema; 





select * from foreign_schema.employee4;


CREATE table public.employee as
select * from foreign_schema.employee;


select * from public.t_etl_tables tet ;

















