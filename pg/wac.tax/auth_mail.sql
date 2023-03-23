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
CREATE SCHEMA IF NOT EXISTS auth_mail;
SET search_path TO auth_mail;
CREATE OR REPLACE FUNCTION mail_set(mail_id public.u64, uid public.u64) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM user
  WHERE val = uid;
INSERT INTO user
    VALUES (mail_id, uid)
  ON CONFLICT (id)
    DO UPDATE SET
      val = uid;
END
$$;
CREATE OR REPLACE FUNCTION signup(client_id public.u64, mail_id public.u64, ctime public.u64, password_hash bytea) RETURNS public.u64
    LANGUAGE plpgsql
    AS $$
DECLARE
  PASSWORD CONSTANT u16 := 1;
MAIL_SIGNUP CONSTANT u16 := 2;
user_id u64;
BEGIN
  -- JS_RETURN [0][0]
  SELECT val INTO user_id
  FROM user
  WHERE id = mail_id;
IF user_id IS NULL THEN
    SELECT nextval('u.uid'::regclass) INTO user_id;
INSERT INTO user
      VALUES (mail_id, user_id);
END IF;
INSERT INTO u.log(action, client_id, uid, ctime, val)
    VALUES (PASSWORD, client_id, user_id, ctime, password_hash);
INSERT INTO u.log(action, client_id, uid, ctime, val)
    VALUES (MAIL_SIGNUP, client_id, user_id, ctime, mail_id::u64);
INSERT INTO u.password
    VALUES (user_id, password_hash, ctime)
  ON CONFLICT (id)
    DO UPDATE SET hash = password_hash, ctime = signup.ctime;
RETURN user_id;
END
$$;
CREATE OR REPLACE FUNCTION uid_by_mail_id(mail_id public.u64) RETURNS TABLE(user_id public.u64, hash bytea, ctime public.u64)
    LANGUAGE plpgsql
    AS $$
DECLARE
  user_id u64;
password_hash bytea;
BEGIN
  -- JS_RETURN [0]
  SELECT val INTO user_id
  FROM user
  WHERE id = mail_id;
IF user_id IS NOT NULL THEN
    RETURN QUERY
    SELECT id, p.hash::bytea, p.ctime
    FROM u.password p
    WHERE id = user_id;
END IF;
END
$$;
CREATE SEQUENCE user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
SET default_tablespace = '';
SET default_table_access_method = heap;
CREATE TABLE "user" (
    id public.u64 DEFAULT nextval('user_id_seq'::regclass) NOT NULL,
    val public.u64 NOT NULL
);
ALTER TABLE ONLY "user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);