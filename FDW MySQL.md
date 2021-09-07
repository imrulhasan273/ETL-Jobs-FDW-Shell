# **Foreign Data Wrapper | MySQL to Postgres**

---

- [Ref](https://www.percona.com/blog/2018/08/24/postgresql-accessing-mysql-as-a-data-source-using-mysql_fdw/)

- Source: source is the remote postgres server from where the tables are accessed by the destination database server as foreign tables.
- Destination: destination is another postgres server where the foreign tables are created which is referring tables in source database server.

### [Localhost] ==> [10.9.0.222]

---

## **Preparing MySQL for fdw connectivity**

---

```sql
mysql> create user 'fdw_user'@'%' identified by 'Secret!123';
```

```sql
mysql> grant select,insert,update,delete on EMP to fdw_user@'%';
mysql> grant select,insert,update,delete on DEPT to fdw_user@'%';
```

---

## **Installing mysql_fdw on PostgreSQL server**

---

```shell
sudo yum install Percona-Server-devel-57-5.7.22-22.1.el7.x86_64.rpm
sudo yum install mysql_fdw_10.x86_64
```

```sql
postgres=# create extension mysql_fdw;
```

```sql
postgres=# CREATE SERVER mysql_svr  FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host 'hr',port '3306');
```

```sql
postgres=# CREATE USER MAPPING FOR PUBLIC SERVER mysql_svr OPTIONS (username 'fdw_user',password 'Secret!123');
```

---

## **Import schema objects**

---

```sql
postgres=# IMPORT FOREIGN SCHEMA hrdb FROM SERVER mysql_svr INTO public;
```

```sql
postgres=# IMPORT FOREIGN SCHEMA hrdb limit to ("EMP","DEPT") FROM SERVER mysql_svr INTO public;
```

**Let’s create a schema in postgres:**

```sql
postgres=# create schema hrdb;
```

```sql
postgres=# IMPORT FOREIGN SCHEMA hrdb limit to ("EMP","DEPT") FROM SERVER mysql_svr INTO hrdb;
```

**Suppose we need the foreign table to be part of multiple schemas of PostgreSQL. Yes, it is possible.**

```sql
postgres=# create schema payroll;
CREATE SCHEMA

postgres=# create schema finance;
CREATE SCHEMA

postgres=# create schema sales;
CREATE SCHEMA

postgres=# IMPORT FOREIGN SCHEMA  hrdb limit to ("EMP","DEPT") FROM SERVER mysql_svr INTO payroll;
IMPORT FOREIGN SCHEMA

postgres=# IMPORT FOREIGN SCHEMA  hrdb limit to ("EMP","DEPT") FROM SERVER mysql_svr INTO finance;
IMPORT FOREIGN SCHEMA

postgres=# IMPORT FOREIGN SCHEMA  hrdb limit to ("EMP","DEPT") FROM SERVER mysql_svr INTO sales;
IMPORT FOREIGN SCHEMA
```

---

## **Foreign tables with a subset of columns**

---

```sql
CREATE TABLE `film` (
    `film_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
    `title` varchar(255) NOT NULL,
    `description` text,
    `release_year` year(4) DEFAULT NULL,
    `language_id` tinyint(3) unsigned NOT NULL,
    `original_language_id` tinyint(3) unsigned DEFAULT NULL,
    `rental_duration` tinyint(3) unsigned NOT NULL DEFAULT '3',
    `rental_rate` decimal(4,2) NOT NULL DEFAULT '4.99',
    `length` smallint(5) unsigned DEFAULT NULL,
    `replacement_cost` decimal(5,2) NOT NULL DEFAULT '19.99',
    `rating` enum('G','PG','PG-13','R','NC-17') DEFAULT 'G',
    `special_features` set('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
    `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`film_id`),
    KEY `idx_title` (`title`),
    KEY `idx_fk_language_id` (`language_id`),
    KEY `idx_fk_original_language_id` (`original_language_id`),
    CONSTRAINT `fk_film_language` FOREIGN KEY (`language_id`) REFERENCES `language` (`language_id`) ON UPDATE CASCADE,
    CONSTRAINT `fk_film_language_original` FOREIGN KEY (`original_language_id`) REFERENCES `language` (`language_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8
```

> Imagine that we don’t need all of these fields to be available to the PostgreSQL database and its application. In such cases, we can create a foreign table with only the necessary columns in the PostgreSQL side. For example:

```sql
CREATE FOREIGN TABLE film (
    film_id smallint NOT NULL,
    title varchar(255) NOT NULL,
) SERVER mysql_svr OPTIONS (dbname 'sakila', table_name 'film');
```


---

## **The challenges of incompatible syntax and datatypes**

---


```sql
CREATE TYPE rating_t AS enum('G','PG','PG-13','R','NC-17');
```

```sql
CREATE FOREIGN TABLE film (
film_id smallint NOT NULL,
title varchar(255) NOT NULL,
rating text,
special_features text
) SERVER mysql_svr OPTIONS (dbname 'sakila', table_name 'film');
```
