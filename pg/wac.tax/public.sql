--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 15.2 (Ubuntu 15.2-1.pgdg22.04+1)

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: client_new(public.u64, bytea, character varying, public.u32, character varying, public.u32, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.client_new(client_id public.u64, ip bytea, browser_name character varying, browser_ver public.u32, os_name character varying, os_ver public.u32, device_vendor character varying, device_model character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  now u64;
browser_id u32;
os_id u32;
device_id u32;
BEGIN
  IF browser_name != '' THEN
    SELECT id INTO browser_id
    FROM browser
    WHERE name = browser_name
      AND ver = browser_ver;
IF browser_id IS NULL THEN
      INSERT INTO browser (name, ver)
        VALUES (browser_name, browser_ver)
      ON CONFLICT (name, ver)
        DO NOTHING
      RETURNING id INTO browser_id;
END IF;
ELSE
    browser_id = 0;
END IF;
IF os_name != '' THEN
    WITH e AS (
INSERT INTO os (name, ver)
        VALUES (os_name, os_ver)
      ON CONFLICT (name, ver)
        DO NOTHING
      RETURNING id)
      SELECT id INTO os_id
      FROM e
      UNION
      SELECT id
      FROM os
      WHERE name = os_name
          AND ver = os_ver;
ELSE
    os_id = 0;
END IF;
IF device_vendor != '' THEN
    WITH e AS (
INSERT INTO device (vendor, model)
        VALUES (device_vendor, device_model)
      ON CONFLICT (vendor, model)
        DO NOTHING
      RETURNING id)
      SELECT id INTO device_id
      FROM e
      UNION
      SELECT id
      FROM device
      WHERE vendor = device_vendor
          AND model = device_model;
ELSE
    device_id = 0;
END IF;
now = (date_part('epoch'::text, now()))::integer;
INSERT INTO client_ip (client_id, ip, ctime)
    VALUES (client_id, ip, now)
  ON CONFLICT
    DO NOTHING;
INSERT INTO client_meta (client_id, os_id, browser_id, device_id, ctime)
    VALUES (client_id, os_id, browser_id, device_id, now);
END;
$$;


--
-- Name: drop_func(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.drop_func(_name text, OUT functions_dropped integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  _sql text;
BEGIN
  SELECT count(*)::int, 'drop function ' || string_agg(oid::regprocedure::text, ';
drop function ')
  FROM pg_catalog.pg_proc
  WHERE proname = _name
    AND pg_function_is_visible(oid) -- restrict to current search_path
    INTO functions_dropped, _sql;
IF functions_dropped > 0 THEN
    -- only if function(s) found
    EXECUTE _sql;
END IF;
END
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: browser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.browser (
    id public.u32 NOT NULL,
    name character varying(255) NOT NULL,
    ver public.u32 NOT NULL
);


--
-- Name: browser_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.browser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.browser_id_seq OWNED BY public.browser.id;


--
-- Name: client_ip; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_ip (
    id public.u64 NOT NULL,
    client_id public.u64 NOT NULL,
    ip bytea NOT NULL,
    ctime public.u64 DEFAULT (date_part('epoch'::text, now()))::integer NOT NULL
);


--
-- Name: client_ip_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_ip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_ip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_ip_id_seq OWNED BY public.client_ip.id;


--
-- Name: client_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_meta (
    id public.u64 NOT NULL,
    device_id public.u32 NOT NULL,
    browser_id public.u32 NOT NULL,
    os_id public.u32 NOT NULL,
    client_id public.u64 NOT NULL,
    ctime public.u64 DEFAULT (date_part('epoch'::text, now()))::integer NOT NULL
);


--
-- Name: client_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_meta_id_seq OWNED BY public.client_meta.id;


--
-- Name: device_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device (
    id public.u32 DEFAULT nextval('public.device_id_seq'::regclass) NOT NULL,
    vendor character varying(255) NOT NULL,
    model character varying(255) NOT NULL
);


--
-- Name: os; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.os (
    id public.u64 NOT NULL,
    name character varying(255) NOT NULL,
    ver public.u32 NOT NULL
);


--
-- Name: os_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.os_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.os_id_seq OWNED BY public.os.id;


--
-- Name: browser id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser ALTER COLUMN id SET DEFAULT nextval('public.browser_id_seq'::regclass);


--
-- Name: client_ip id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_ip ALTER COLUMN id SET DEFAULT nextval('public.client_ip_id_seq'::regclass);


--
-- Name: client_meta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_meta ALTER COLUMN id SET DEFAULT nextval('public.client_meta_id_seq'::regclass);


--
-- Name: os id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os ALTER COLUMN id SET DEFAULT nextval('public.os_id_seq'::regclass);


--
-- Name: browser browser.name.ver; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser
    ADD CONSTRAINT "browser.name.ver" UNIQUE (name, ver);


--
-- Name: browser browser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.browser
    ADD CONSTRAINT browser_pkey PRIMARY KEY (id);


--
-- Name: client_ip client_ip.ctime; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_ip
    ADD CONSTRAINT "client_ip.ctime" UNIQUE (ip, ctime);


--
-- Name: client_ip client_ip_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_ip
    ADD CONSTRAINT client_ip_pkey PRIMARY KEY (id);


--
-- Name: client_meta client_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_meta
    ADD CONSTRAINT client_meta_pkey PRIMARY KEY (id);


--
-- Name: device device.vendor.model; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT "device.vendor.model" UNIQUE (vendor, model);


--
-- Name: device device_model_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device
    ADD CONSTRAINT device_model_pkey PRIMARY KEY (id);


--
-- Name: os os.name.ver; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os
    ADD CONSTRAINT "os.name.ver" UNIQUE (name, ver);


--
-- Name: os os_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.os
    ADD CONSTRAINT os_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

