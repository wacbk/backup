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
CREATE SCHEMA IF NOT EXISTS bot;
SET search_path TO bot;
SET default_tablespace = '';
SET default_table_access_method = heap;
CREATE TABLE civitai_img (
    id public.u64 NOT NULL,
    post_id public.u64 NOT NULL,
    url text NOT NULL,
    sampler_id public.u64 NOT NULL,
    w public.u32 NOT NULL,
    h public.u32 NOT NULL,
    gen_w public.u32 NOT NULL,
    gen_h public.u32 NOT NULL,
    step public.u16 NOT NULL,
    prompt_id public.u64,
    nprompt_id public.u64,
    meta_id public.u64,
    model_name_hash_id public.u64,
    genway_id public.u32,
    seed bigint,
    laugh public.u32 NOT NULL,
    star public.u32 NOT NULL,
    hate public.u32 NOT NULL,
    cry public.u32 NOT NULL,
    hash public.md5hash
);
CREATE TABLE civitai_model_last_post (
    id public.u64 NOT NULL,
    "time" public.u64,
    day public.u32 NOT NULL
);
CREATE TABLE civitai_post (
    id public.u64 NOT NULL,
    model_id public.u64 NOT NULL,
    user_id public.u64 NOT NULL,
    "time" public.u64 NOT NULL,
    txt text NOT NULL,
    rating public.u8 NOT NULL
);
CREATE TABLE civitai_user (
    id bigint NOT NULL,
    name text NOT NULL
);
CREATE TABLE meta (
    id public.u64 NOT NULL,
    val text NOT NULL,
    hash public.md5hash NOT NULL
);
CREATE SEQUENCE meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE meta_id_seq OWNED BY meta.id;
ALTER TABLE ONLY meta ALTER COLUMN id SET DEFAULT nextval('meta_id_seq'::regclass);
ALTER TABLE ONLY civitai_img
    ADD CONSTRAINT civitai_img_pkey PRIMARY KEY (id);
ALTER TABLE ONLY civitai_model_last_post
    ADD CONSTRAINT civitai_model_last_review_pkey PRIMARY KEY (id);
ALTER TABLE ONLY civitai_post
    ADD CONSTRAINT civitai_review_pkey PRIMARY KEY (id);
ALTER TABLE ONLY civitai_user
    ADD CONSTRAINT civitai_user_pkey PRIMARY KEY (id);
ALTER TABLE ONLY meta
    ADD CONSTRAINT meta_hash_key UNIQUE (hash);
ALTER TABLE ONLY meta
    ADD CONSTRAINT meta_pkey PRIMARY KEY (id);