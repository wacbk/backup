SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
CREATE SCHEMA IF NOT EXISTS u;
SET search_path TO u;
SET default_tablespace = '';
SET default_table_access_method = heap;
CREATE TABLE log (
    id public.u64 NOT NULL,
    action public.u16 NOT NULL,
    uid public.u64 NOT NULL,
    val bytea DEFAULT '\x'::bytea NOT NULL,
    ctime public.u64 DEFAULT (date_part('epoch'::text, now()))::integer NOT NULL,
    client_id public.u64 NOT NULL
);
CREATE SEQUENCE log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE log_id_seq OWNED BY log.id;
CREATE TABLE password (
    id public.u64 NOT NULL,
    hash public.md5hash NOT NULL,
    ctime public.u64 NOT NULL
);
CREATE SEQUENCE password_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE password_id_seq OWNED BY password.id;
CREATE SEQUENCE uid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER TABLE ONLY log ALTER COLUMN id SET DEFAULT nextval('log_id_seq'::regclass);
ALTER TABLE ONLY password ALTER COLUMN id SET DEFAULT nextval('password_id_seq'::regclass);
ALTER TABLE ONLY log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);
ALTER TABLE ONLY password
    ADD CONSTRAINT password_pkey PRIMARY KEY (id);