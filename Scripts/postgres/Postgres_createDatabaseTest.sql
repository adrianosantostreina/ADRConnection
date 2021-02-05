CREATE DATABASE adrconntest
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.utf8'
    LC_CTYPE = 'en_US.utf8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

CREATE TABLE public.person
(
    id numeric NOT NULL,
	name varchar(100),
	birthdayDate date,
    CONSTRAINT person_pkey PRIMARY KEY (id)
);

CREATE SEQUENCE public.idperson
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

insert into person (id, name, birthdayDate) values (
	NEXTVAL('idperson'),
	'person 1',
	'1990-02-13'
);

CREATE TABLE public.account
(
    id numeric NOT NULL,
    ammount numeric(18,2),
    CONSTRAINT account_pkey PRIMARY KEY (id)
)

CREATE SEQUENCE public.idaccount
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

