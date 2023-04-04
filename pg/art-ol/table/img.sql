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
CREATE SCHEMA IF NOT EXISTS img;
SET search_path TO img;
SET default_tablespace = '';
SET default_table_access_method = heap;
CREATE TABLE genway (
    id public.u32 NOT NULL,
    name text NOT NULL
);
CREATE SEQUENCE genway_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE genway_id_seq OWNED BY genway.id;
CREATE TABLE model_name_hash (
    id bigint NOT NULL,
    name text NOT NULL,
    hash text NOT NULL
);
CREATE SEQUENCE model_name_hash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE model_name_hash_id_seq OWNED BY model_name_hash.id;
CREATE TABLE nprompt (
    id public.u64 NOT NULL,
    val text NOT NULL,
    hash public.md5hash NOT NULL
);
CREATE SEQUENCE nprompt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE nprompt_id_seq OWNED BY nprompt.id;
CREATE TABLE prompt (
    id public.u64 NOT NULL,
    val text NOT NULL,
    hash public.md5hash NOT NULL
);
CREATE SEQUENCE prompt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE prompt_id_seq OWNED BY prompt.id;
CREATE TABLE sampler (
    id bigint NOT NULL,
    name text NOT NULL
);
CREATE SEQUENCE sampler_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE sampler_id_seq OWNED BY sampler.id;
ALTER TABLE ONLY genway ALTER COLUMN id SET DEFAULT nextval('genway_id_seq'::regclass);
ALTER TABLE ONLY model_name_hash ALTER COLUMN id SET DEFAULT nextval('model_name_hash_id_seq'::regclass);
ALTER TABLE ONLY nprompt ALTER COLUMN id SET DEFAULT nextval('nprompt_id_seq'::regclass);
ALTER TABLE ONLY prompt ALTER COLUMN id SET DEFAULT nextval('prompt_id_seq'::regclass);
ALTER TABLE ONLY sampler ALTER COLUMN id SET DEFAULT nextval('sampler_id_seq'::regclass);
ALTER TABLE ONLY genway
    ADD CONSTRAINT genway_name_key UNIQUE (name);
ALTER TABLE ONLY genway
    ADD CONSTRAINT genway_pkey PRIMARY KEY (id);
ALTER TABLE ONLY model_name_hash
    ADD CONSTRAINT model_name_hash_name_hash_key UNIQUE (name, hash);
ALTER TABLE ONLY model_name_hash
    ADD CONSTRAINT model_name_hash_pkey PRIMARY KEY (id);
ALTER TABLE ONLY nprompt
    ADD CONSTRAINT nprompt_hash_key UNIQUE (hash);
ALTER TABLE ONLY nprompt
    ADD CONSTRAINT nprompt_pkey PRIMARY KEY (id);
ALTER TABLE ONLY prompt
    ADD CONSTRAINT prompt_hash_key UNIQUE (hash);
ALTER TABLE ONLY prompt
    ADD CONSTRAINT prompt_pkey PRIMARY KEY (id);
ALTER TABLE ONLY sampler
    ADD CONSTRAINT sampler_name_key UNIQUE (name);
ALTER TABLE ONLY sampler
    ADD CONSTRAINT sampler_pkey PRIMARY KEY (id);