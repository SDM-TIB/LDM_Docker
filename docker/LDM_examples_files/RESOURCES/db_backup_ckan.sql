--
-- PostgreSQL database dump
--

-- Dumped from database version 11.2 (Debian 11.2-1.pgdg90+1)
-- Dumped by pg_dump version 11.2 (Debian 11.2-1.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: ckan
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO ckan;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: ckan
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO ckan;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: ckan
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO ckan;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: ckan
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activity; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.activity (
    id text NOT NULL,
    "timestamp" timestamp without time zone,
    user_id text,
    object_id text,
    revision_id text,
    activity_type text,
    data text
);


ALTER TABLE public.activity OWNER TO ckan;

--
-- Name: activity_detail; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.activity_detail (
    id text NOT NULL,
    activity_id text,
    object_id text,
    object_type text,
    activity_type text,
    data text
);


ALTER TABLE public.activity_detail OWNER TO ckan;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO ckan;

--
-- Name: api_token; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.api_token (
    id text NOT NULL,
    name text,
    user_id text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_access timestamp without time zone,
    plugin_extras jsonb
);


ALTER TABLE public.api_token OWNER TO ckan;

--
-- Name: dashboard; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.dashboard (
    user_id text NOT NULL,
    activity_stream_last_viewed timestamp without time zone NOT NULL,
    email_last_sent timestamp without time zone DEFAULT LOCALTIMESTAMP NOT NULL
);


ALTER TABLE public.dashboard OWNER TO ckan;

--
-- Name: dataset_service; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.dataset_service (
    dataset_id text NOT NULL,
    service_id text NOT NULL
);


ALTER TABLE public.dataset_service OWNER TO ckan;

--
-- Name: doi; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.doi (
    identifier text NOT NULL,
    package_id text NOT NULL,
    published timestamp without time zone
);


ALTER TABLE public.doi OWNER TO ckan;

--
-- Name: group; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public."group" (
    id text NOT NULL,
    name text NOT NULL,
    title text,
    description text,
    created timestamp without time zone,
    state text,
    type text NOT NULL,
    approval_status text,
    image_url text,
    is_organization boolean DEFAULT false
);


ALTER TABLE public."group" OWNER TO ckan;

--
-- Name: group_extra; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.group_extra (
    id text NOT NULL,
    group_id text,
    key text,
    value text,
    state text
);


ALTER TABLE public.group_extra OWNER TO ckan;

--
-- Name: group_extra_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.group_extra_revision (
    id text NOT NULL,
    group_id text,
    key text,
    value text,
    state text,
    revision_id text NOT NULL,
    continuity_id text,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean
);


ALTER TABLE public.group_extra_revision OWNER TO ckan;

--
-- Name: group_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.group_revision (
    id text NOT NULL,
    name text NOT NULL,
    title text,
    description text,
    created timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    state text,
    revision_id text NOT NULL,
    continuity_id text,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean,
    type text NOT NULL,
    approval_status text,
    image_url text,
    is_organization boolean DEFAULT false
);


ALTER TABLE public.group_revision OWNER TO ckan;

--
-- Name: member; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.member (
    id text NOT NULL,
    group_id text,
    table_id text NOT NULL,
    state text,
    table_name text NOT NULL,
    capacity text NOT NULL
);


ALTER TABLE public.member OWNER TO ckan;

--
-- Name: member_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.member_revision (
    id text NOT NULL,
    table_id text NOT NULL,
    group_id text,
    state text,
    revision_id text NOT NULL,
    continuity_id text,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean,
    table_name text NOT NULL,
    capacity text NOT NULL
);


ALTER TABLE public.member_revision OWNER TO ckan;

--
-- Name: package; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package (
    id text NOT NULL,
    name character varying(100) NOT NULL,
    title text,
    version character varying(100),
    url text,
    notes text,
    author text,
    author_email text,
    maintainer text,
    maintainer_email text,
    state text,
    license_id text,
    type text,
    owner_org text,
    private boolean DEFAULT false,
    metadata_modified timestamp without time zone,
    creator_user_id text,
    metadata_created timestamp without time zone
);


ALTER TABLE public.package OWNER TO ckan;

--
-- Name: package_extra; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package_extra (
    id text NOT NULL,
    key text,
    value text,
    state text,
    package_id text
);


ALTER TABLE public.package_extra OWNER TO ckan;

--
-- Name: package_extra_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package_extra_revision (
    id text NOT NULL,
    key text,
    value text,
    revision_id text NOT NULL,
    state text,
    package_id text,
    continuity_id text,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean
);


ALTER TABLE public.package_extra_revision OWNER TO ckan;

--
-- Name: package_member; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package_member (
    package_id text NOT NULL,
    user_id text NOT NULL,
    capacity text NOT NULL,
    modified timestamp without time zone NOT NULL
);


ALTER TABLE public.package_member OWNER TO ckan;

--
-- Name: package_relationship; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package_relationship (
    id text NOT NULL,
    subject_package_id text,
    object_package_id text,
    type text,
    comment text,
    state text
);


ALTER TABLE public.package_relationship OWNER TO ckan;

--
-- Name: package_relationship_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package_relationship_revision (
    id text NOT NULL,
    subject_package_id text,
    object_package_id text,
    type text,
    comment text,
    revision_id text NOT NULL,
    continuity_id text,
    state text,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean
);


ALTER TABLE public.package_relationship_revision OWNER TO ckan;

--
-- Name: package_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package_revision (
    id text NOT NULL,
    name character varying(100) NOT NULL,
    title text,
    version character varying(100),
    url text,
    notes text,
    author text,
    author_email text,
    maintainer text,
    maintainer_email text,
    revision_id text NOT NULL,
    state text,
    continuity_id text,
    license_id text,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean,
    type text,
    owner_org text,
    private boolean DEFAULT false,
    metadata_modified timestamp without time zone,
    creator_user_id text,
    metadata_created timestamp without time zone
);


ALTER TABLE public.package_revision OWNER TO ckan;

--
-- Name: package_tag; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package_tag (
    id text NOT NULL,
    state text,
    package_id text,
    tag_id text
);


ALTER TABLE public.package_tag OWNER TO ckan;

--
-- Name: package_tag_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.package_tag_revision (
    id text NOT NULL,
    revision_id text NOT NULL,
    state text,
    package_id text,
    tag_id text,
    continuity_id text,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean
);


ALTER TABLE public.package_tag_revision OWNER TO ckan;

--
-- Name: rating; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.rating (
    id text NOT NULL,
    user_id text,
    user_ip_address text,
    rating double precision,
    created timestamp without time zone,
    package_id text
);


ALTER TABLE public.rating OWNER TO ckan;

--
-- Name: resource; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.resource (
    id text NOT NULL,
    url text NOT NULL,
    format text,
    description text,
    "position" integer,
    hash text,
    state text,
    extras text,
    name text,
    resource_type text,
    mimetype text,
    mimetype_inner text,
    size bigint,
    last_modified timestamp without time zone,
    cache_url text,
    cache_last_updated timestamp without time zone,
    webstore_url text,
    webstore_last_updated timestamp without time zone,
    created timestamp without time zone,
    url_type text,
    package_id text DEFAULT ''::text NOT NULL,
    metadata_modified timestamp without time zone
);


ALTER TABLE public.resource OWNER TO ckan;

--
-- Name: resource_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.resource_revision (
    id text NOT NULL,
    url text NOT NULL,
    format text,
    description text,
    "position" integer,
    revision_id text NOT NULL,
    hash text,
    state text,
    continuity_id text,
    extras text,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean,
    name text,
    resource_type text,
    mimetype text,
    mimetype_inner text,
    size bigint,
    last_modified timestamp without time zone,
    cache_url text,
    cache_last_updated timestamp without time zone,
    webstore_url text,
    webstore_last_updated timestamp without time zone,
    created timestamp without time zone,
    url_type text,
    package_id text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.resource_revision OWNER TO ckan;

--
-- Name: resource_view; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.resource_view (
    id text NOT NULL,
    resource_id text,
    title text,
    description text,
    view_type text NOT NULL,
    "order" integer NOT NULL,
    config text
);


ALTER TABLE public.resource_view OWNER TO ckan;

--
-- Name: revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.revision (
    id text NOT NULL,
    "timestamp" timestamp without time zone,
    author character varying(200),
    message text,
    state text,
    approved_timestamp timestamp without time zone
);


ALTER TABLE public.revision OWNER TO ckan;

--
-- Name: system_info; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.system_info (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    value text,
    state text DEFAULT 'active'::text NOT NULL
);


ALTER TABLE public.system_info OWNER TO ckan;

--
-- Name: system_info_id_seq; Type: SEQUENCE; Schema: public; Owner: ckan
--

CREATE SEQUENCE public.system_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.system_info_id_seq OWNER TO ckan;

--
-- Name: system_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ckan
--

ALTER SEQUENCE public.system_info_id_seq OWNED BY public.system_info.id;


--
-- Name: system_info_revision; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.system_info_revision (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    value text,
    revision_id text NOT NULL,
    continuity_id integer,
    state text DEFAULT 'active'::text NOT NULL,
    expired_id text,
    revision_timestamp timestamp without time zone,
    expired_timestamp timestamp without time zone,
    current boolean
);


ALTER TABLE public.system_info_revision OWNER TO ckan;

--
-- Name: tag; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.tag (
    id text NOT NULL,
    name character varying(100) NOT NULL,
    vocabulary_id character varying(100)
);


ALTER TABLE public.tag OWNER TO ckan;

--
-- Name: task_status; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.task_status (
    id text NOT NULL,
    entity_id text NOT NULL,
    entity_type text NOT NULL,
    task_type text NOT NULL,
    key text NOT NULL,
    value text NOT NULL,
    state text,
    error text,
    last_updated timestamp without time zone
);


ALTER TABLE public.task_status OWNER TO ckan;

--
-- Name: term_translation; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.term_translation (
    term text NOT NULL,
    term_translation text NOT NULL,
    lang_code text NOT NULL
);


ALTER TABLE public.term_translation OWNER TO ckan;

--
-- Name: tracking_raw; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.tracking_raw (
    user_key character varying(100) NOT NULL,
    url text NOT NULL,
    tracking_type character varying(10) NOT NULL,
    access_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tracking_raw OWNER TO ckan;

--
-- Name: tracking_summary; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.tracking_summary (
    url text NOT NULL,
    package_id text,
    tracking_type character varying(10) NOT NULL,
    count integer NOT NULL,
    running_total integer DEFAULT 0 NOT NULL,
    recent_views integer DEFAULT 0 NOT NULL,
    tracking_date date
);


ALTER TABLE public.tracking_summary OWNER TO ckan;

--
-- Name: user; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public."user" (
    id text NOT NULL,
    name text NOT NULL,
    apikey text,
    created timestamp without time zone,
    about text,
    password text,
    fullname text,
    email text,
    reset_key text,
    sysadmin boolean DEFAULT false,
    activity_streams_email_notifications boolean DEFAULT false,
    state text DEFAULT 'active'::text NOT NULL,
    plugin_extras jsonb,
    image_url text
);


ALTER TABLE public."user" OWNER TO ckan;

--
-- Name: user_following_dataset; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.user_following_dataset (
    follower_id text NOT NULL,
    object_id text NOT NULL,
    datetime timestamp without time zone NOT NULL
);


ALTER TABLE public.user_following_dataset OWNER TO ckan;

--
-- Name: user_following_group; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.user_following_group (
    follower_id text NOT NULL,
    object_id text NOT NULL,
    datetime timestamp without time zone NOT NULL
);


ALTER TABLE public.user_following_group OWNER TO ckan;

--
-- Name: user_following_user; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.user_following_user (
    follower_id text NOT NULL,
    object_id text NOT NULL,
    datetime timestamp without time zone NOT NULL
);


ALTER TABLE public.user_following_user OWNER TO ckan;

--
-- Name: vocabulary; Type: TABLE; Schema: public; Owner: ckan
--

CREATE TABLE public.vocabulary (
    id text NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.vocabulary OWNER TO ckan;

--
-- Name: system_info id; Type: DEFAULT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.system_info ALTER COLUMN id SET DEFAULT nextval('public.system_info_id_seq'::regclass);


--
-- Data for Name: activity; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.activity (id, "timestamp", user_id, object_id, revision_id, activity_type, data) FROM stdin;
34f2c423-e8b4-40b3-8ffe-d22e751ec5e7	2017-08-08 16:45:41.113149	17755db4-395a-4b3b-ac09-e8e3484ca700	17755db4-395a-4b3b-ac09-e8e3484ca700	\N	new user	\N
349ee903-ed55-4d30-984f-4b1fe9a6df35	2017-08-08 16:46:26.188993	17755db4-395a-4b3b-ac09-e8e3484ca700	724ae83b-ae78-433c-8586-69e7202931c4	729f6192-b932-4413-904c-a72e21f8ef69	new organization	{"group": {"description": "China United Network Communications Group Co., Ltd. (Chinese: 中国联合网络通信集团有限公司) or China Unicom (Chinese: 中国联通) is a Chinese state-owned telecommunications operator in the People's Republic of China. China Unicom is the world's fourth-largest mobile service provider by subscriber base.", "title": "China UNICOM", "created": "2017-08-08T16:46:26.164305", "approval_status": "approved", "is_organization": true, "state": "active", "image_url": "https://upload.wikimedia.org/wikipedia/en/thumb/f/fa/China_Unicom.svg/252px-China_Unicom.svg.png", "revision_id": "729f6192-b932-4413-904c-a72e21f8ef69", "type": "organization", "id": "724ae83b-ae78-433c-8586-69e7202931c4", "name": "china-unicom"}}
79cd60d9-b153-4584-8e8b-c2418b824b01	2017-08-08 16:50:27.383826	17755db4-395a-4b3b-ac09-e8e3484ca700	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	2b61e1eb-c56d-4852-b55c-47f0e7308c6e	new package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:26.707978", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "2b61e1eb-c56d-4852-b55c-47f0e7308c6e", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
ee660257-e306-4c18-adb7-721940032324	2017-08-08 16:50:50.711252	17755db4-395a-4b3b-ac09-e8e3484ca700	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	3d4c3cf2-2604-49a3-b846-bcfca91c4b22	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:49.591262", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "2b61e1eb-c56d-4852-b55c-47f0e7308c6e", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
c2459c06-478a-4893-98c9-c2bc1c9d8045	2017-08-08 16:50:51.427455	17755db4-395a-4b3b-ac09-e8e3484ca700	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	bffaa2dd-7e21-45e1-9c62-336b10a1381d	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:50.837755", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "bffaa2dd-7e21-45e1-9c62-336b10a1381d", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
d5c7c2f1-11ba-40e7-a9cf-387cfbe4f9da	2017-08-08 16:52:30.212465	17755db4-395a-4b3b-ac09-e8e3484ca700	903d964e-9c2c-47d2-8708-25363ef8d772	65a08933-48aa-426b-bf8a-d11aa32dca95	new package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "services-information", "metadata_modified": "2017-08-08T16:52:29.614984", "author": "", "url": "", "notes": "Several services offered in our company", "title": "Services information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "65a08933-48aa-426b-bf8a-d11aa32dca95", "type": "dataset", "id": "903d964e-9c2c-47d2-8708-25363ef8d772", "metadata_created": "2017-08-08T16:52:29.614969"}}
3e8e8301-501f-4e6f-9b5e-5ba0b4b47767	2017-08-08 16:52:49.548884	17755db4-395a-4b3b-ac09-e8e3484ca700	903d964e-9c2c-47d2-8708-25363ef8d772	15c99021-e05b-4678-b035-a1e8203dd9e1	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "services-information", "metadata_modified": "2017-08-08T16:52:48.402586", "author": "", "url": "", "notes": "Several services offered in our company", "title": "Services information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "65a08933-48aa-426b-bf8a-d11aa32dca95", "type": "dataset", "id": "903d964e-9c2c-47d2-8708-25363ef8d772", "metadata_created": "2017-08-08T16:52:29.614969"}}
8d57bc35-165b-455c-bce7-202977427302	2017-08-08 16:52:50.181502	17755db4-395a-4b3b-ac09-e8e3484ca700	903d964e-9c2c-47d2-8708-25363ef8d772	ba506755-adf8-4f97-bf70-90355c658dd7	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "services-information", "metadata_modified": "2017-08-08T16:52:49.648987", "author": "", "url": "", "notes": "Several services offered in our company", "title": "Services information", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "ba506755-adf8-4f97-bf70-90355c658dd7", "type": "dataset", "id": "903d964e-9c2c-47d2-8708-25363ef8d772", "metadata_created": "2017-08-08T16:52:29.614969"}}
856541dc-535f-4a05-aa53-6173b63b6c80	2017-08-08 16:54:35.903892	17755db4-395a-4b3b-ac09-e8e3484ca700	817668d7-be70-479e-92c6-c7e4e8182603	8b393d77-16b0-4e7c-b64e-63acf71345d5	new package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:54:35.136352", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "8b393d77-16b0-4e7c-b64e-63acf71345d5", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
977f7a94-cd3c-4284-9260-cd73d8b5ecc9	2017-08-08 16:55:28.396814	17755db4-395a-4b3b-ac09-e8e3484ca700	817668d7-be70-479e-92c6-c7e4e8182603	4537cbb8-b49b-4611-9721-a775af0095fe	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:55:27.253651", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "8b393d77-16b0-4e7c-b64e-63acf71345d5", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
ed4ebc6c-b036-4dbf-8f2e-fd7f6e51bb26	2022-03-16 07:46:04.9843	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	\N	changed package	{"package": {"author": "Autodesk", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-23T17:37:00.362900", "metadata_modified": "2022-03-16T07:46:02.632334", "name": "example-cad", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "num_resources": 2, "num_tags": 6, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example CAD Visualizations", "type": "dataset", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "version": "", "extras": [{"__extras": {"id": "adf12ac1-5e68-45ca-8adc-10a50e8f7deb", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "state": "active"}, "key": "foobar", "value": "baz"}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:37:19.897441", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "last_modified": "2017-12-01T16:52:30.511835", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 2D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 0, "resource_type": null, "size": 169807, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/Drive_shaft.dwg", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:40:23.217872", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "last_modified": "2017-12-01T16:53:23.693615", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 3D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 1, "resource_type": null, "size": 733036, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/visualization_-_aerial.dwg", "url_type": ""}], "tags": [{"display_name": "2D", "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D", "state": "active", "vocabulary_id": null}, {"display_name": "3D", "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D", "state": "active", "vocabulary_id": null}, {"display_name": "CAD", "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD", "state": "active", "vocabulary_id": null}, {"display_name": "dwg", "id": "675a1366-8d81-4e07-ab30-8c492c34b91d", "name": "dwg", "state": "active", "vocabulary_id": null}, {"display_name": "example", "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example", "state": "active", "vocabulary_id": null}, {"display_name": "visualization", "id": "7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd", "name": "visualization", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/243x4f8c", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
a2db6a75-ed2e-40cf-8ec5-0a54cea6b228	2017-08-08 16:55:29.097122	17755db4-395a-4b3b-ac09-e8e3484ca700	817668d7-be70-479e-92c6-c7e4e8182603	d2a0b75b-4856-4b6c-affc-729a99bbe985	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:55:28.497851", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "d2a0b75b-4856-4b6c-affc-729a99bbe985", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
92ab1224-9afe-422a-9a03-5337c6805189	2017-08-08 16:57:30.780325	17755db4-395a-4b3b-ac09-e8e3484ca700	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	dd70f0dc-ac9d-4ea3-8888-ddb077b44502	new package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-08T16:57:30.243013", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "dd70f0dc-ac9d-4ea3-8888-ddb077b44502", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
0fd4c8b8-6bee-4b9b-a0ee-d17059501409	2017-08-08 16:57:43.011765	17755db4-395a-4b3b-ac09-e8e3484ca700	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	1815b63f-6afc-43d0-aac9-d8a9daec8f93	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-08T16:57:41.818903", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "dd70f0dc-ac9d-4ea3-8888-ddb077b44502", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
667f1e21-dd0f-4c38-896b-81c6a3f80682	2017-08-08 16:57:43.644775	17755db4-395a-4b3b-ac09-e8e3484ca700	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	18ca3b06-e9d5-4129-b12c-1eacc9c8de32	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-08T16:57:43.112965", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "18ca3b06-e9d5-4129-b12c-1eacc9c8de32", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
af4d03ce-89ab-4aee-bf36-2180e3a461a2	2017-08-09 09:04:45.585197	17755db4-395a-4b3b-ac09-e8e3484ca700	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	9280682a-0335-4e81-85d6-52933a06e3c9	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-09T09:04:44.595145", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "18ca3b06-e9d5-4129-b12c-1eacc9c8de32", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
95939c34-a48c-4b67-845b-034d3c67bf17	2017-11-23 17:07:42.114419	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	1d7a208f-a535-4f6d-ad3c-18d8c9866feb	new package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:07:42.009865", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "1d7a208f-a535-4f6d-ad3c-18d8c9866feb", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
29dde80c-6d54-45d6-b46c-513673c9592b	2017-11-23 17:07:50.774252	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	d74a18d9-14a3-40a4-b848-d1d9148e2102	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:07:50.644778", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "1d7a208f-a535-4f6d-ad3c-18d8c9866feb", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
fcdef847-909e-438e-bdf4-a31cdaf1f4c3	2017-11-23 17:07:50.910006	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	76a15254-7ed3-4c64-94e0-4c93fd886a70	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:07:50.816957", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
f1caf191-27d6-4fa1-9514-f5182198c9cb	2017-11-23 17:10:49.456915	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	61558a1e-8f38-4eea-be11-4831ab21f9ab	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:10:49.355965", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
5427f274-8abe-4927-8d90-6c7dcd9fcb53	2017-11-23 17:11:24.080889	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	4609ef6f-b90f-49f1-aef7-0381acb539ba	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:11:23.957264", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
8511c608-a30f-4cee-92d8-11a6b02ce9a1	2022-03-16 07:50:20.357064	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	\N	changed package	{"package": {"author": "Autodesk", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-23T17:37:00.362900", "metadata_modified": "2022-03-16T07:50:19.400546", "name": "example-cad", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "num_resources": 3, "num_tags": 6, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example CAD Visualizations", "type": "dataset", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "version": "", "extras": [{"__extras": {"id": "adf12ac1-5e68-45ca-8adc-10a50e8f7deb", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "state": "active"}, "key": "foobar", "value": "baz"}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:37:19.897441", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "last_modified": "2017-12-01T16:52:30.511835", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 2D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 0, "resource_type": null, "size": 169807, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/Drive_shaft.dwg", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:40:23.217872", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "last_modified": "2017-12-01T16:53:23.693615", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 3D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 1, "resource_type": null, "size": 733036, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/visualization_-_aerial.dwg", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T07:50:19.425337", "datastore_active": false, "description": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "format": "ZIP", "hash": "", "id": "ade79b5d-14e3-4d08-a556-2135fee359f4", "last_modified": "2022-03-16T07:50:19.388180", "metadata_modified": "2022-03-16T07:50:19.407288", "mimetype": "application/zip", "mimetype_inner": null, "name": "PANGEA CAD example", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 2, "resource_type": null, "size": 3414733, "state": "active", "url": "http://localhost:5000/dataset/476cdf71-1048-4a6f-a28a-58fff547dae5/resource/ade79b5d-14e3-4d08-a556-2135fee359f4/download/gkg_steel_zinced.zip", "url_type": "upload"}], "tags": [{"display_name": "2D", "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D", "state": "active", "vocabulary_id": null}, {"display_name": "3D", "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D", "state": "active", "vocabulary_id": null}, {"display_name": "CAD", "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD", "state": "active", "vocabulary_id": null}, {"display_name": "dwg", "id": "675a1366-8d81-4e07-ab30-8c492c34b91d", "name": "dwg", "state": "active", "vocabulary_id": null}, {"display_name": "example", "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example", "state": "active", "vocabulary_id": null}, {"display_name": "visualization", "id": "7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd", "name": "visualization", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/243x4f8c", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
b33f9a10-c386-4940-930a-6ff16982dccc	2017-11-23 17:13:07.283322	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	b832bb18-8732-45d7-858a-97f2a9f85006	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:13:07.174920", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
c0ec79c3-71cf-4dc0-a210-6fd6433196c2	2017-11-23 17:13:31.509843	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	c84a2f2b-7aae-4ce0-9746-ed5ff839a497	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:13:31.390334", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
3f35f708-51ee-4aeb-a4a1-20ca344c80fb	2017-11-23 17:15:23.580018	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	be62d02b-aac3-4fa9-adda-5f7055efe684	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:15:23.475276", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
6cfd936e-6149-4354-96a6-b1686928340c	2017-11-23 17:15:54.520296	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	54de6fec-f172-4558-8292-950fa99f513a	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:15:54.401224", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
8de8fc21-e9ab-4170-83b4-cedda5daf96c	2017-11-23 17:16:10.4882	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	99077077-577e-48cc-bd73-2f28656f45f5	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:16:10.380381", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
5b3ccd7e-4d3e-429a-a469-09668048e259	2017-11-23 17:23:12.635455	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	cd6b8c3c-4df5-42a5-a76a-db925c99dbde	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:23:12.524274", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
0e647a87-b993-44ad-8f2f-1290d2f3ba14	2017-11-23 17:23:33.353019	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	ad0c12ae-80f3-437a-8f31-ce5bef87b962	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:23:33.217281", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
2c31cc42-0ae9-487a-a7a6-bf1ebb4c38f8	2017-11-23 17:25:49.986004	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	2d0e5c97-33d8-47d3-9c65-f334df5365fc	changed package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:25:49.828970", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
931b2bed-223e-4fda-8843-eb51282d69d1	2017-11-23 17:28:58.796512	17755db4-395a-4b3b-ac09-e8e3484ca700	54f83106-f2bf-45a8-8523-53a415c99e47	b8777631-802d-4981-aa3a-b71e40e44ea9	deleted package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:25:49.828970", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "b8777631-802d-4981-aa3a-b71e40e44ea9", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
2766a7e7-4a1a-4992-b441-d78cdb584065	2017-11-23 17:29:52.584551	17755db4-395a-4b3b-ac09-e8e3484ca700	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	78e33def-565f-45dc-b9a4-a1dda81e1ce1	deleted package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:50.837755", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "78e33def-565f-45dc-b9a4-a1dda81e1ce1", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
ae632789-8f12-4ba8-9485-34ec7fb5a851	2022-03-16 07:53:55.957942	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	\N	changed package	{"package": {"author": "Autodesk", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-23T17:37:00.362900", "metadata_modified": "2022-03-16T07:53:55.484045", "name": "example-cad", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "num_resources": 3, "num_tags": 6, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example CAD Visualizations", "type": "dataset", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "version": "", "extras": [{"__extras": {"id": "adf12ac1-5e68-45ca-8adc-10a50e8f7deb", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "state": "active"}, "key": "foobar", "value": "baz"}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:37:19.897441", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "last_modified": "2022-03-16T07:53:55.475515", "metadata_modified": "2022-03-16T07:53:55.487806", "mimetype": null, "mimetype_inner": null, "name": "Example 2D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 0, "resource_type": null, "size": 169807, "state": "active", "url": "http://localhost:5000/dataset/476cdf71-1048-4a6f-a28a-58fff547dae5/resource/4ee0ec1c-c72b-4bad-be73-364a735cea5c/download/drive_shaft.dwg", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:40:23.217872", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "last_modified": "2017-12-01T16:53:23.693615", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 3D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 1, "resource_type": null, "size": 733036, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/visualization_-_aerial.dwg", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T07:50:19.425337", "datastore_active": false, "description": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "format": "ZIP", "hash": "", "id": "ade79b5d-14e3-4d08-a556-2135fee359f4", "last_modified": "2022-03-16T07:50:19.388180", "metadata_modified": "2022-03-16T07:53:55.488104", "mimetype": "application/zip", "mimetype_inner": null, "name": "PANGEA CAD example", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 2, "resource_type": null, "size": 3414733, "state": "active", "url": "http://localhost:5000/dataset/476cdf71-1048-4a6f-a28a-58fff547dae5/resource/ade79b5d-14e3-4d08-a556-2135fee359f4/download/gkg_steel_zinced.zip", "url_type": "upload"}], "tags": [{"display_name": "2D", "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D", "state": "active", "vocabulary_id": null}, {"display_name": "3D", "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D", "state": "active", "vocabulary_id": null}, {"display_name": "CAD", "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD", "state": "active", "vocabulary_id": null}, {"display_name": "dwg", "id": "675a1366-8d81-4e07-ab30-8c492c34b91d", "name": "dwg", "state": "active", "vocabulary_id": null}, {"display_name": "example", "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example", "state": "active", "vocabulary_id": null}, {"display_name": "visualization", "id": "7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd", "name": "visualization", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/243x4f8c", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
1c2b381b-41d9-4c92-adc4-60fd3617265b	2022-03-16 07:54:28.650818	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	\N	changed package	{"package": {"author": "Autodesk", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-23T17:37:00.362900", "metadata_modified": "2022-03-16T07:54:28.333206", "name": "example-cad", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "num_resources": 3, "num_tags": 6, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example CAD Visualizations", "type": "dataset", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "version": "", "extras": [{"__extras": {"id": "adf12ac1-5e68-45ca-8adc-10a50e8f7deb", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "state": "active"}, "key": "foobar", "value": "baz"}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:37:19.897441", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "last_modified": "2022-03-16T07:53:55.475515", "metadata_modified": "2022-03-16T07:53:55.487806", "mimetype": null, "mimetype_inner": null, "name": "Example 2D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 0, "resource_type": null, "size": 169807, "state": "active", "url": "http://localhost:5000/dataset/476cdf71-1048-4a6f-a28a-58fff547dae5/resource/4ee0ec1c-c72b-4bad-be73-364a735cea5c/download/drive_shaft.dwg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:40:23.217872", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "last_modified": "2022-03-16T07:54:28.325436", "metadata_modified": "2022-03-16T07:54:28.336364", "mimetype": null, "mimetype_inner": null, "name": "Example 3D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 1, "resource_type": null, "size": 733036, "state": "active", "url": "http://localhost:5000/dataset/476cdf71-1048-4a6f-a28a-58fff547dae5/resource/1342ec64-f18e-4860-93cc-f6dd194d56ec/download/visualization_-_aerial.dwg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T07:50:19.425337", "datastore_active": false, "description": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "format": "ZIP", "hash": "", "id": "ade79b5d-14e3-4d08-a556-2135fee359f4", "last_modified": "2022-03-16T07:50:19.388180", "metadata_modified": "2022-03-16T07:53:55.488104", "mimetype": "application/zip", "mimetype_inner": null, "name": "PANGEA CAD example", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 2, "resource_type": null, "size": 3414733, "state": "active", "url": "http://localhost:5000/dataset/476cdf71-1048-4a6f-a28a-58fff547dae5/resource/ade79b5d-14e3-4d08-a556-2135fee359f4/download/gkg_steel_zinced.zip", "url_type": "upload"}], "tags": [{"display_name": "2D", "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D", "state": "active", "vocabulary_id": null}, {"display_name": "3D", "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D", "state": "active", "vocabulary_id": null}, {"display_name": "CAD", "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD", "state": "active", "vocabulary_id": null}, {"display_name": "dwg", "id": "675a1366-8d81-4e07-ab30-8c492c34b91d", "name": "dwg", "state": "active", "vocabulary_id": null}, {"display_name": "example", "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example", "state": "active", "vocabulary_id": null}, {"display_name": "visualization", "id": "7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd", "name": "visualization", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/243x4f8c", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
c6dad858-18de-4062-bbbc-d6aba021ebbd	2017-11-23 17:29:52.647157	17755db4-395a-4b3b-ac09-e8e3484ca700	817668d7-be70-479e-92c6-c7e4e8182603	201d00c8-1f94-43d3-ac75-e9bfeb22a2f4	deleted package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:55:28.497851", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "201d00c8-1f94-43d3-ac75-e9bfeb22a2f4", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
a4aa87f8-fa10-4f5f-844e-81529fa3a411	2017-11-23 17:29:52.785419	17755db4-395a-4b3b-ac09-e8e3484ca700	903d964e-9c2c-47d2-8708-25363ef8d772	7d60ea7c-29e6-447b-a3c6-e32ad2ccd4f9	deleted package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "services-information", "metadata_modified": "2017-08-08T16:52:49.648987", "author": "", "url": "", "notes": "Several services offered in our company", "title": "Services information", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "7d60ea7c-29e6-447b-a3c6-e32ad2ccd4f9", "type": "dataset", "id": "903d964e-9c2c-47d2-8708-25363ef8d772", "metadata_created": "2017-08-08T16:52:29.614969"}}
dffcf571-4cb3-40fe-aef7-1fdc2f345233	2017-11-23 17:30:37.763902	17755db4-395a-4b3b-ac09-e8e3484ca700	0c5362f5-b99e-41db-8256-3d0d7549bf4d	34c3de5f-7e58-4806-9177-733da1fca73c	new organization	{"group": {"description": "", "title": "TIB iASiS", "created": "2017-11-23T17:30:37.757128", "approval_status": "approved", "is_organization": true, "state": "active", "image_url": "", "revision_id": "34c3de5f-7e58-4806-9177-733da1fca73c", "type": "organization", "id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis"}}
4e28330a-cc18-4736-9e4a-71dbdada03a7	2017-11-23 17:37:00.449098	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	f732828b-2166-4541-9128-f838a260ae1b	new package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-11-23T17:37:00.362905", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f732828b-2166-4541-9128-f838a260ae1b", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
46fe0eca-6275-4d0b-8a5e-df73f411e7dc	2017-11-23 17:37:20.164102	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-11-23T17:37:20.059543", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
505a69df-026a-4e8a-9484-855bd449580b	2017-11-23 17:40:23.320077	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	f4499856-fe22-47ba-9e93-ac6f2c547685	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-11-23T17:40:23.210138", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
399cb478-9920-4de7-9543-5e8792a122b7	2017-11-23 17:40:57.543313	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	40aaa8c6-d66d-4632-bfab-bf3daad5244d	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-11-23T17:40:57.417452", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
78b8e6e8-47a3-44de-8061-3670b189bad0	2017-11-24 13:40:21.973859	17755db4-395a-4b3b-ac09-e8e3484ca700	0c5362f5-b99e-41db-8256-3d0d7549bf4d	6d7701f6-3ad0-4073-a1a9-262f793ac188	changed organization	{"group": {"description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "title": "TIB", "created": "2017-11-23T17:30:37.757128", "approval_status": "approved", "is_organization": true, "state": "active", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "revision_id": "6a333863-cac8-4957-9ed5-968dc91c74be", "type": "organization", "id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis"}}
11c1f4ab-cfef-4494-aff1-87562f0064ec	2017-11-23 17:29:52.70055	17755db4-395a-4b3b-ac09-e8e3484ca700	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	19ac713d-48f0-48b9-9cd5-7061843bc62f	deleted package	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-09T09:04:44.595145", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "19ac713d-48f0-48b9-9cd5-7061843bc62f", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
f1d2e7db-b0cd-4216-b4df-f222295fa7b6	2017-11-23 17:31:36.658912	17755db4-395a-4b3b-ac09-e8e3484ca700	0c5362f5-b99e-41db-8256-3d0d7549bf4d	935c959c-8191-4dc4-81b0-50e9e829d325	changed organization	{"group": {"description": "", "title": "TIB iASiS", "created": "2017-11-23T17:30:37.757128", "approval_status": "approved", "is_organization": true, "state": "active", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "revision_id": "34c3de5f-7e58-4806-9177-733da1fca73c", "type": "organization", "id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis"}}
18c4aaed-a497-49e4-998a-50590bb5bdf5	2022-03-16 08:14:30.702937	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "54920aae-f322-4fca-bd09-cd091946632c", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-24T13:42:19.407543", "metadata_modified": "2022-03-16T08:14:28.633508", "name": "example-video-2", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.\\r\\nVideo about boundary value problem of a push rod. The video was published by Leibniz University Hannover.\\r\\nVideo about boundary value problem of a spring. The video was published by Leibniz University Hannover.", "num_resources": 1, "num_tags": 7, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Video Visualizations", "type": "dataset", "url": "", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:42:36.237930", "datastore_active": false, "description": "", "format": "video/mp4", "hash": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "last_modified": "2017-12-01T16:35:53.307078", "metadata_modified": null, "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 0, "resource_type": null, "size": 71194509, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/STF50_autocombustions_with_varying_phi_v2_HD.mp4", "url_type": ""}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}, {"display_name": "Combustion", "id": "23f7f291-52c1-4942-aa23-008a9b23a5e1", "name": "Combustion", "state": "active", "vocabulary_id": null}, {"display_name": "EDTA", "id": "9d0587af-aad0-4352-ab8f-fc7b90f7430b", "name": "EDTA", "state": "active", "vocabulary_id": null}, {"display_name": "Experiment", "id": "a6bbc1be-05c4-406c-8d13-b9e2018b311a", "name": "Experiment", "state": "active", "vocabulary_id": null}, {"display_name": "Reactions", "id": "a292a3c1-b272-4c02-bfb2-385e12ff6b66", "name": "Reactions", "state": "active", "vocabulary_id": null}, {"display_name": "STF50", "id": "53b4f8bd-5778-4ece-b3ac-78e8a60be011", "name": "STF50", "state": "active", "vocabulary_id": null}, {"display_name": "Video", "id": "7d945dfc-6203-4ef8-8369-90704d7498ac", "name": "Video", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/d9c4ly9i", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
a9aebdb9-f6fe-43df-8c2a-46ecf8777408	2022-03-16 08:18:39.401428	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "54920aae-f322-4fca-bd09-cd091946632c", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-24T13:42:19.407543", "metadata_modified": "2022-03-16T08:18:38.619402", "name": "example-video-2", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.\\r\\nVideo about boundary value problem of a push rod. The video was published by Leibniz University Hannover.\\r\\nVideo about boundary value problem of a spring. The video was published by Leibniz University Hannover.", "num_resources": 2, "num_tags": 7, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Video Visualizations", "type": "dataset", "url": "", "version": "", "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:42:36.237930", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "last_modified": "2022-03-16T08:15:16.584473", "metadata_modified": "2022-03-16T08:16:23.472676", "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi (MP4)", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 0, "resource_type": null, "size": 71194509, "state": "active", "url": "http://localhost:5000/dataset/54920aae-f322-4fca-bd09-cd091946632c/resource/8649545f-f1d0-49d2-b9cd-88f2593ec059/download/stf50_autocombustions_with_varying_phi_v2_hd.mp4", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:18:38.634836", "datastore_active": false, "description": "The video was published by Leibniz University Hannover.", "format": "WebM", "hash": "", "id": "849a62dc-45fe-4f7e-9687-09543b7f8512", "last_modified": "2022-03-16T08:18:38.610661", "metadata_modified": "2022-03-16T08:18:38.622201", "mimetype": "video/webm", "mimetype_inner": null, "name": "Boundary value problem of a push rod (WEBM)", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 1, "resource_type": null, "size": 369844, "state": "active", "url": "http://localhost:5000/dataset/54920aae-f322-4fca-bd09-cd091946632c/resource/849a62dc-45fe-4f7e-9687-09543b7f8512/download/pushrod.webm", "url_type": "upload"}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}, {"display_name": "Combustion", "id": "23f7f291-52c1-4942-aa23-008a9b23a5e1", "name": "Combustion", "state": "active", "vocabulary_id": null}, {"display_name": "EDTA", "id": "9d0587af-aad0-4352-ab8f-fc7b90f7430b", "name": "EDTA", "state": "active", "vocabulary_id": null}, {"display_name": "Experiment", "id": "a6bbc1be-05c4-406c-8d13-b9e2018b311a", "name": "Experiment", "state": "active", "vocabulary_id": null}, {"display_name": "Reactions", "id": "a292a3c1-b272-4c02-bfb2-385e12ff6b66", "name": "Reactions", "state": "active", "vocabulary_id": null}, {"display_name": "STF50", "id": "53b4f8bd-5778-4ece-b3ac-78e8a60be011", "name": "STF50", "state": "active", "vocabulary_id": null}, {"display_name": "Video", "id": "7d945dfc-6203-4ef8-8369-90704d7498ac", "name": "Video", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/d9c4ly9i", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
e3683d94-253c-4730-ae84-19ebe61f2128	2017-11-23 17:32:08.014374	17755db4-395a-4b3b-ac09-e8e3484ca700	0c5362f5-b99e-41db-8256-3d0d7549bf4d	6a333863-cac8-4957-9ed5-968dc91c74be	changed organization	{"group": {"description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "title": "TIB iASiS", "created": "2017-11-23T17:30:37.757128", "approval_status": "approved", "is_organization": true, "state": "active", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "revision_id": "935c959c-8191-4dc4-81b0-50e9e829d325", "type": "organization", "id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis"}}
3647c32f-8a96-4c6a-8c4c-c4948e364f7f	2017-11-23 17:35:47.492877	17755db4-395a-4b3b-ac09-e8e3484ca700	acc9dc22-eff3-486b-a715-9a69ef93ade0	00277d2f-879f-426e-98e9-39839776d89d	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-videos", "metadata_modified": "2017-11-23T17:35:47.357177", "author": "", "url": "", "notes": "", "title": "Example videos", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "00277d2f-879f-426e-98e9-39839776d89d", "type": "dataset", "id": "acc9dc22-eff3-486b-a715-9a69ef93ade0", "metadata_created": "2017-11-23T17:32:40.506721"}}
ab5731ed-4566-4d86-a364-e1c8a3c7b6eb	2017-11-23 17:37:20.0145	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	469f7ad0-8cce-4220-8859-7f640494206b	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-11-23T17:37:19.887042", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f732828b-2166-4541-9128-f838a260ae1b", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
5137f9dd-9882-4bb7-a7b8-0f0fe02a78f5	2017-11-24 12:31:07.787952	17755db4-395a-4b3b-ac09-e8e3484ca700	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f4b8e39c-ebec-4108-b18e-146f213a6a3b	changed organization	{"group": {"description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "title": "TIB iASiS", "created": "2017-11-23T17:30:37.757128", "approval_status": "approved", "is_organization": true, "state": "active", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "revision_id": "6a333863-cac8-4957-9ed5-968dc91c74be", "type": "organization", "id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis"}}
b6b56eb0-bd29-4995-a1ec-e9d8bf056af0	2017-12-01 11:56:50.818499	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	c0d32fee-6737-4a91-920a-d8aab223e545	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-01T11:56:50.590910", "author": "", "url": "", "notes": "", "title": "Example CAD 2", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c0d32fee-6737-4a91-920a-d8aab223e545", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
1c0cc55f-1748-43f3-91b4-977ff52f15d3	2017-12-01 11:57:19.470172	17755db4-395a-4b3b-ac09-e8e3484ca700	bf46d212-6fde-4670-ab59-52bb38c513bc	78462af9-3e29-41e7-b739-815aa263ff3d	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "test-jupyter", "metadata_modified": "2017-12-01T11:57:19.351983", "author": "", "url": "", "notes": "", "title": "Test jupyter", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "78462af9-3e29-41e7-b739-815aa263ff3d", "type": "dataset", "id": "bf46d212-6fde-4670-ab59-52bb38c513bc", "metadata_created": "2017-11-28T19:31:59.868119"}}
c9b28971-06de-4022-a7c2-716558a8cd4c	2017-12-01 11:57:31.760832	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	beb04331-d499-485b-9369-1f57aa6f7395	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T11:57:31.640981", "author": "", "url": "", "notes": "", "title": "Example video 2", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "beb04331-d499-485b-9369-1f57aa6f7395", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
b8806ae8-b2c3-4970-883f-040d37783bec	2017-12-01 12:26:03.511705	17755db4-395a-4b3b-ac09-e8e3484ca700	acc9dc22-eff3-486b-a715-9a69ef93ade0	f8632874-e874-4ec3-97ce-c15bffe12f28	deleted package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-videos", "metadata_modified": "2017-11-23T17:35:47.357177", "author": "", "url": "", "notes": "", "title": "Example videos", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f8632874-e874-4ec3-97ce-c15bffe12f28", "type": "dataset", "id": "acc9dc22-eff3-486b-a715-9a69ef93ade0", "metadata_created": "2017-11-23T17:32:40.506721"}}
5f389a45-31ea-429b-9247-12758057a04b	2017-12-01 12:26:27.680642	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	f69e3832-0198-44c5-a4f2-f52a65fe3ca2	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T12:26:27.564010", "author": "", "url": "", "notes": "", "title": "Example video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f69e3832-0198-44c5-a4f2-f52a65fe3ca2", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
13df1fff-32cf-4fd2-9abd-ef82e3d75593	2017-12-01 12:27:24.246594	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	f42bf4cf-a31c-4645-bb98-9ecbdf58d1ca	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-01T12:27:24.137068", "author": "", "url": "", "notes": "", "title": "Example CAD Pangaea", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f42bf4cf-a31c-4645-bb98-9ecbdf58d1ca", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
c6cc3d32-0ec1-4492-b954-cdf5976184a6	2022-03-16 08:15:17.76809	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "54920aae-f322-4fca-bd09-cd091946632c", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-24T13:42:19.407543", "metadata_modified": "2022-03-16T08:15:16.589235", "name": "example-video-2", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.\\r\\nVideo about boundary value problem of a push rod. The video was published by Leibniz University Hannover.\\r\\nVideo about boundary value problem of a spring. The video was published by Leibniz University Hannover.", "num_resources": 1, "num_tags": 7, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Video Visualizations", "type": "dataset", "url": "", "version": "", "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:42:36.237930", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "last_modified": "2022-03-16T08:15:16.584473", "metadata_modified": "2022-03-16T08:15:16.591690", "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 0, "resource_type": null, "size": 71194509, "state": "active", "url": "http://localhost:5000/dataset/54920aae-f322-4fca-bd09-cd091946632c/resource/8649545f-f1d0-49d2-b9cd-88f2593ec059/download/stf50_autocombustions_with_varying_phi_v2_hd.mp4", "url_type": "upload"}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}, {"display_name": "Combustion", "id": "23f7f291-52c1-4942-aa23-008a9b23a5e1", "name": "Combustion", "state": "active", "vocabulary_id": null}, {"display_name": "EDTA", "id": "9d0587af-aad0-4352-ab8f-fc7b90f7430b", "name": "EDTA", "state": "active", "vocabulary_id": null}, {"display_name": "Experiment", "id": "a6bbc1be-05c4-406c-8d13-b9e2018b311a", "name": "Experiment", "state": "active", "vocabulary_id": null}, {"display_name": "Reactions", "id": "a292a3c1-b272-4c02-bfb2-385e12ff6b66", "name": "Reactions", "state": "active", "vocabulary_id": null}, {"display_name": "STF50", "id": "53b4f8bd-5778-4ece-b3ac-78e8a60be011", "name": "STF50", "state": "active", "vocabulary_id": null}, {"display_name": "Video", "id": "7d945dfc-6203-4ef8-8369-90704d7498ac", "name": "Video", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/d9c4ly9i", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
530af8ab-a4ac-46d0-9596-f2413d305e6a	2017-12-01 12:26:42.761463	17755db4-395a-4b3b-ac09-e8e3484ca700	bf46d212-6fde-4670-ab59-52bb38c513bc	4c6cf89c-065e-4c3e-85a0-bd6c7ed30b75	deleted package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "test-jupyter", "metadata_modified": "2017-12-01T11:57:19.351983", "author": "", "url": "", "notes": "", "title": "Test jupyter", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4c6cf89c-065e-4c3e-85a0-bd6c7ed30b75", "type": "dataset", "id": "bf46d212-6fde-4670-ab59-52bb38c513bc", "metadata_created": "2017-11-28T19:31:59.868119"}}
c3354d91-317e-4469-be79-9bfe6b175946	2017-12-01 12:42:21.114566	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	0489aebe-7484-4f6b-a051-9907f1b31b20	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T12:42:20.934980", "author": "", "url": "", "notes": "", "title": "Example video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f69e3832-0198-44c5-a4f2-f52a65fe3ca2", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
c351585b-0db7-47aa-a58f-7f2a8c01df3a	2017-12-01 12:43:40.032307	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	29af1387-94a1-460f-b0d1-fdfb7de377e7	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T12:43:39.909737", "author": "", "url": "", "notes": "", "title": "Example video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f69e3832-0198-44c5-a4f2-f52a65fe3ca2", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
c28d5815-58c9-4a23-a270-b7e95f9dca25	2017-12-01 12:51:37.580585	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	3951536e-4b6f-4e7a-add1-b55c5002dcc0	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T12:51:37.466460", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
caf40a6b-9a5b-4a50-a544-09e2cb86e849	2017-12-01 12:51:49.643808	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	b0de1461-ba0a-4971-8682-f14af889ae40	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T12:51:49.532303", "author": "", "url": "", "notes": "", "title": "Video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "b0de1461-ba0a-4971-8682-f14af889ae40", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
284b516c-c10f-4133-81c5-918978e6d54d	2017-12-01 12:52:07.501333	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	997a3d54-bb90-4c1e-88bf-417e4c95ba21	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-01T12:52:07.397075", "author": "", "url": "", "notes": "", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "997a3d54-bb90-4c1e-88bf-417e4c95ba21", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
377f88b8-6a7e-4b6c-902f-9e90187aa41d	2017-12-01 12:52:47.260241	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	6fc03502-641d-4cd0-96d6-e56dfb3caa62	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T12:52:47.135742", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
bf856c8e-87f1-4191-93e3-4f728bcb6056	2017-12-01 12:54:05.246275	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	2e56ef3c-2f4f-4f73-b213-4214ece22001	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T12:54:05.118474", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
e2fa6206-3c5a-4427-9fb1-8ff54506186a	2017-12-01 12:55:06.805108	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	41602a5a-b63a-4104-ba15-52f0c1c35526	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T12:55:06.664533", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
69c19d68-b662-4693-8d6a-c81d00649dc9	2017-12-01 12:56:06.997013	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	670dffd1-3172-40b8-8e0d-8956760a084a	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T12:56:06.851631", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
e815d2c7-f236-4019-b97a-fb1e5332bf54	2022-03-16 08:16:23.737235	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "54920aae-f322-4fca-bd09-cd091946632c", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-24T13:42:19.407543", "metadata_modified": "2022-03-16T08:16:23.470006", "name": "example-video-2", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.\\r\\nVideo about boundary value problem of a push rod. The video was published by Leibniz University Hannover.\\r\\nVideo about boundary value problem of a spring. The video was published by Leibniz University Hannover.", "num_resources": 1, "num_tags": 7, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Video Visualizations", "type": "dataset", "url": "", "version": "", "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:42:36.237930", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "last_modified": "2022-03-16T08:15:16.584473", "metadata_modified": "2022-03-16T08:16:23.472676", "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi (MP4)", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 0, "resource_type": null, "size": 71194509, "state": "active", "url": "http://localhost:5000/dataset/54920aae-f322-4fca-bd09-cd091946632c/resource/8649545f-f1d0-49d2-b9cd-88f2593ec059/download/stf50_autocombustions_with_varying_phi_v2_hd.mp4", "url_type": "upload"}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}, {"display_name": "Combustion", "id": "23f7f291-52c1-4942-aa23-008a9b23a5e1", "name": "Combustion", "state": "active", "vocabulary_id": null}, {"display_name": "EDTA", "id": "9d0587af-aad0-4352-ab8f-fc7b90f7430b", "name": "EDTA", "state": "active", "vocabulary_id": null}, {"display_name": "Experiment", "id": "a6bbc1be-05c4-406c-8d13-b9e2018b311a", "name": "Experiment", "state": "active", "vocabulary_id": null}, {"display_name": "Reactions", "id": "a292a3c1-b272-4c02-bfb2-385e12ff6b66", "name": "Reactions", "state": "active", "vocabulary_id": null}, {"display_name": "STF50", "id": "53b4f8bd-5778-4ece-b3ac-78e8a60be011", "name": "STF50", "state": "active", "vocabulary_id": null}, {"display_name": "Video", "id": "7d945dfc-6203-4ef8-8369-90704d7498ac", "name": "Video", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/d9c4ly9i", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
dc0f5775-5264-4f9e-9f88-e62031625f6a	2017-12-01 12:58:36.002139	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	ec55548e-a397-4b9c-afac-2f24518f3991	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T12:58:35.867409", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
4a7e58d7-5bc8-40cb-8e00-5f0c2bbcc672	2017-12-01 16:35:53.506476	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	6bbacefb-7a0e-47f0-b3b6-fe7f99b2fd4e	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T16:35:53.315115", "author": "", "url": "", "notes": "", "title": "Video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "b0de1461-ba0a-4971-8682-f14af889ae40", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
aed87a9d-a678-4378-8265-2da5fb4b08f3	2017-12-01 16:47:34.41067	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	f1e7cf9b-cca1-4e09-ae98-7433e34718ac	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T16:47:34.242733", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
a3bad026-3f24-411e-a614-c98ee4e0d684	2017-12-01 16:47:43.431496	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	ddb53a5e-f9ff-47c5-be50-657f6214d787	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T16:47:43.274592", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
bf3c0672-19cc-4e7f-b94a-4b0d39bf8640	2017-12-01 16:47:55.033072	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	f41688c5-b4da-4fb5-9165-e5aa2783ba73	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T16:47:54.884283", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
12eccb51-82e7-4bf9-83ad-483c5e6bf6f6	2017-12-01 16:48:04.634261	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	9b14e4f2-5d5d-4693-b0b6-27bc2cd40e4a	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T16:48:04.515672", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
fec26c29-3670-499c-b1e6-406d71253bd4	2017-12-01 16:48:21.68399	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	83b264fc-0dd9-4270-9c2a-e3ec22ebafee	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T16:48:21.533955", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
bb6e0100-9f39-4fa2-9e0e-7a34ef431fa6	2017-12-01 16:50:38.023373	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	ba4e1fea-9747-477a-adb7-82447b0e99a1	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-01T16:50:37.903007", "author": "", "url": "", "notes": "", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "997a3d54-bb90-4c1e-88bf-417e4c95ba21", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
9a77c594-c442-4d5a-bde6-ea90bda29e6d	2017-12-01 16:52:30.672662	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	36f8a864-0e03-43c8-a8d7-91ca0fe7ec1e	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-01T16:52:30.518916", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
7377d7a7-62d6-4d2d-9b0c-494f137a2aa2	2017-12-01 16:53:23.823807	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	1dfe4f70-fe22-4f93-b708-93d2166875e0	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-01T16:53:23.700233", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
816af85c-6468-42bb-87b7-aea58b2ffefb	2022-03-16 08:19:58.882493	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "54920aae-f322-4fca-bd09-cd091946632c", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-24T13:42:19.407543", "metadata_modified": "2022-03-16T08:19:58.017397", "name": "example-video-2", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.\\r\\nVideo about boundary value problem of a push rod. The video was published by Leibniz University Hannover.\\r\\nVideo about boundary value problem of a spring. The video was published by Leibniz University Hannover.", "num_resources": 3, "num_tags": 7, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Video Visualizations", "type": "dataset", "url": "", "version": "", "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:42:36.237930", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "last_modified": "2022-03-16T08:15:16.584473", "metadata_modified": "2022-03-16T08:16:23.472676", "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi (MP4)", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 0, "resource_type": null, "size": 71194509, "state": "active", "url": "http://localhost:5000/dataset/54920aae-f322-4fca-bd09-cd091946632c/resource/8649545f-f1d0-49d2-b9cd-88f2593ec059/download/stf50_autocombustions_with_varying_phi_v2_hd.mp4", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:18:38.634836", "datastore_active": false, "description": "The video was published by Leibniz University Hannover.", "format": "WebM", "hash": "", "id": "849a62dc-45fe-4f7e-9687-09543b7f8512", "last_modified": "2022-03-16T08:18:38.610661", "metadata_modified": "2022-03-16T08:19:58.022597", "mimetype": "video/webm", "mimetype_inner": null, "name": "Boundary value problem of a push rod (WEBM)", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 1, "resource_type": null, "size": 369844, "state": "active", "url": "http://localhost:5000/dataset/54920aae-f322-4fca-bd09-cd091946632c/resource/849a62dc-45fe-4f7e-9687-09543b7f8512/download/pushrod.webm", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:19:58.037751", "datastore_active": false, "description": "The video was published by Leibniz University Hannover.", "format": "OGG", "hash": "", "id": "a86b71e3-c68a-421e-b995-b172d603df62", "last_modified": "2022-03-16T08:19:58.009932", "metadata_modified": "2022-03-16T08:19:58.022788", "mimetype": "audio/ogg", "mimetype_inner": null, "name": "Boundary value problem of a spring (OGG)", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 2, "resource_type": null, "size": 543985, "state": "active", "url": "http://localhost:5000/dataset/54920aae-f322-4fca-bd09-cd091946632c/resource/a86b71e3-c68a-421e-b995-b172d603df62/download/spring.ogg", "url_type": "upload"}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}, {"display_name": "Combustion", "id": "23f7f291-52c1-4942-aa23-008a9b23a5e1", "name": "Combustion", "state": "active", "vocabulary_id": null}, {"display_name": "EDTA", "id": "9d0587af-aad0-4352-ab8f-fc7b90f7430b", "name": "EDTA", "state": "active", "vocabulary_id": null}, {"display_name": "Experiment", "id": "a6bbc1be-05c4-406c-8d13-b9e2018b311a", "name": "Experiment", "state": "active", "vocabulary_id": null}, {"display_name": "Reactions", "id": "a292a3c1-b272-4c02-bfb2-385e12ff6b66", "name": "Reactions", "state": "active", "vocabulary_id": null}, {"display_name": "STF50", "id": "53b4f8bd-5778-4ece-b3ac-78e8a60be011", "name": "STF50", "state": "active", "vocabulary_id": null}, {"display_name": "Video", "id": "7d945dfc-6203-4ef8-8369-90704d7498ac", "name": "Video", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/d9c4ly9i", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
e361bdcd-090d-4d3c-bf58-056e7de5e2b2	2017-12-04 16:42:27.821866	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	25711b9c-54ee-4629-ba88-03fbd139dda0	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:42:27.659128", "author": "Lorena A. Barba", "url": "", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "25711b9c-54ee-4629-ba88-03fbd139dda0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
9af28f62-f4ab-447e-af25-59523c30c12f	2017-12-04 16:43:57.788856	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	4f99eafe-97a2-4b14-be62-63ad7cffc7be	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:43:57.659289", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
1622c60f-24bf-4a79-9d27-7f09705e8715	2017-12-05 11:07:10.757763	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	e58c8491-4add-4147-b929-e12d05531f9d	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T11:07:10.618785", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
5245f777-f8d1-4712-a5b5-d80a045b60c2	2017-12-05 11:08:32.089783	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	41e8a326-3a0c-4ab2-af20-7427bd551504	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T11:08:31.917600", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "41e8a326-3a0c-4ab2-af20-7427bd551504", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
50a30a7a-f059-4f41-8abf-131e01b2ae64	2017-12-05 12:29:57.837506	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	7a7537ca-0c0c-4501-b244-a3d813e376d1	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T12:29:57.692677", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "41e8a326-3a0c-4ab2-af20-7427bd551504", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
2ca1bac2-cebd-4d06-83f5-764cb45ff848	2017-12-05 12:47:03.110573	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	959e1cc4-8271-4643-b3d5-4a6dd3e92074	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
ccdc0d8b-9611-4752-9610-a68074350791	2017-12-05 12:49:18.720281	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	778fcf5c-b993-40b3-ad2b-088dcb674c2e	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T12:49:18.579271", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "Example usage of CAD visualization in 2D and 3D.", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "778fcf5c-b993-40b3-ad2b-088dcb674c2e", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
1e2298ea-a34e-4a01-8190-9147647c0697	2017-12-05 12:50:32.81822	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	9c6d5cc2-06e9-46c9-acd2-77a99cf3ac8b	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T12:50:32.680631", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "9c6d5cc2-06e9-46c9-acd2-77a99cf3ac8b", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
ae2b18f3-fdea-47a2-91a5-011843b41bde	2017-12-05 12:53:48.029619	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	c7cbaa34-461b-4cd7-932d-d70ae8e2254b	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T12:53:47.896014", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
e16cfa90-314c-4694-9125-f91c699d1b6f	2017-12-05 13:10:44.877222	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	fc2b5cb3-7333-4ac3-b707-2548a16d6e1a	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:10:44.629506", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
3ceda134-8a0b-456e-bd2c-837d6d78eb29	2017-12-05 13:11:18.621291	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	74a74b6a-3df2-4d28-92dd-956bcdad2265	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:11:18.467298", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
ddc37615-8361-467b-9234-3aab5c04965c	2017-12-05 13:12:32.988144	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	d325e2f3-8a4a-4b42-b99d-2d1152e093ea	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T13:12:32.843326", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "d325e2f3-8a4a-4b42-b99d-2d1152e093ea", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
90bbb19b-2c0b-4937-a724-3745a7606c83	2017-12-05 16:11:57.487292	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	606a0443-92eb-443b-8f03-5d342a4c53a7	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T16:11:57.333706", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "d325e2f3-8a4a-4b42-b99d-2d1152e093ea", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
5c8b9bb2-c24e-4ded-b9b9-f6fe1e1d749a	2017-12-05 16:12:30.474167	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	1154ccc2-5934-43a5-99d8-fb903dde0691	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T16:12:30.328483", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "d325e2f3-8a4a-4b42-b99d-2d1152e093ea", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
da535949-1a1c-46c3-a86d-77a799fe450f	2017-12-05 16:15:34.462703	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	690a634b-a609-4502-b01e-c1c08da7e478	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T16:15:34.312869", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
54504cc7-9324-454b-9ee7-2c98e74eda0e	2017-12-05 16:16:53.180356	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	38a2a6f3-e1b4-4bf0-be67-9570df5257ef	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T16:16:53.013621", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "9c6d5cc2-06e9-46c9-acd2-77a99cf3ac8b", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
12e9dc99-5b6d-4d7f-afb7-b06252f73005	2017-12-05 16:17:38.261069	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	d15e34ce-171d-4b7c-97fa-7f962f51bc54	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T16:17:38.099079", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "9c6d5cc2-06e9-46c9-acd2-77a99cf3ac8b", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
a188dce1-f8e6-466d-8508-c968d5341b3c	2017-12-05 16:18:11.526446	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	5c1a7014-4c5e-46d7-bf6e-71c09d905edb	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-05T16:18:11.317508", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
76e6f8f4-3797-41b4-8d33-521e6dd3e574	2017-12-05 16:19:39.603094	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	a62f6486-cf27-4b3f-b739-207b5f69d06c	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-05T16:19:39.441006", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
69d4f7f7-7581-4479-92a5-a3c2c7491272	2017-12-05 16:19:56.373177	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	b9cbf887-ecb8-4874-bb03-1c62f312d158	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-05T16:19:56.237954", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
fb9e266b-cc51-41a2-acf4-2154af5bc381	2017-12-05 16:20:26.630904	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	065ffe84-177e-4e13-8319-20bce551300f	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-05T16:20:26.498874", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
46cb05d4-2376-428a-a1cd-161b8b302c37	2017-12-05 16:20:10.402307	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	92d37aae-e70c-40f9-ab15-028a15ae3991	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-05T16:20:10.271226", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
d81f707e-48d7-463b-9b3d-fe0eeba390de	2018-02-01 19:02:42.803411	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	83811581-08a7-489a-952c-aa3eb3d14c05	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2018-02-01T19:02:42.568140", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
916b9b8f-1b27-4993-9af7-9759a84288c4	2018-02-01 19:04:44.226373	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	f27b53aa-d2ec-4bf8-8344-e5d116e8eff9	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2018-02-01T19:04:43.984172", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
59960add-1787-4215-a266-b50175f55050	2018-02-01 19:05:20.039164	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	a55ac040-dcc7-4a52-89c8-7d6655c3d7a5	changed package	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2018-02-01T19:05:19.818781", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
68fc4b8c-bdfe-42e0-9de6-59de6f674d97	2021-03-03 10:11:49.098893	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	\N	changed package	{"package": {"author": "Lorena A. Barba", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-12-01T12:51:12.218503", "metadata_modified": "2021-03-03T10:11:48.942065", "name": "jupyter-notebooks", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "num_resources": 10, "num_tags": 5, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Jupyter notebooks", "type": "dataset", "url": "https://unidata.github.io/online-python-training/introduction.html", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:51:28.891625", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "last_modified": "2017-12-01T16:47:34.233655", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example Machine Learning notebook", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 0, "resource_type": null, "size": 703819, "state": "active", "url": "https://raw.githubusercontent.com/guillermobet/files/master/Example%20Machine%20Learning%20Notebook.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:51:28.891625", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "last_modified": "2017-12-01T16:47:34.233655", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example Machine Learning notebook", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 0, "resource_type": null, "size": 703819, "state": "active", "url": "https://raw.githubusercontent.com/guillermobet/files/master/Example%20Machine%20Learning%20Notebook.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:54:05.127144", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "last_modified": "2017-12-01T16:47:43.266081", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Labeled Faces in the Wild recognition", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 1, "resource_type": null, "size": 717993, "state": "active", "url": "https://raw.githubusercontent.com/ogrisel/notebooks/master/Labeled%2520Faces%2520in%2520the%2520Wild%2520recognition.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:54:05.127144", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "last_modified": "2017-12-01T16:47:43.266081", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Labeled Faces in the Wild recognition", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 1, "resource_type": null, "size": 717993, "state": "active", "url": "https://raw.githubusercontent.com/ogrisel/notebooks/master/Labeled%2520Faces%2520in%2520the%2520Wild%2520recognition.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:55:06.673960", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "last_modified": "2017-12-01T16:47:54.872809", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Satellite example", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 2, "resource_type": null, "size": 7216, "state": "active", "url": "http://unidata.github.io/python-gallery/_downloads/Satellite_Example.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:55:06.673960", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "last_modified": "2017-12-01T16:47:54.872809", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Satellite example", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 2, "resource_type": null, "size": 7216, "state": "active", "url": "http://unidata.github.io/python-gallery/_downloads/Satellite_Example.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:56:06.860736", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "last_modified": "2017-12-01T16:48:04.508028", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "GW150914 tutorial", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 3, "resource_type": null, "size": 2683661, "state": "active", "url": "https://losc.ligo.org/s/events/GW150914/GW150914_tutorial.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:56:06.860736", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "last_modified": "2017-12-01T16:48:04.508028", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "GW150914 tutorial", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 3, "resource_type": null, "size": 2683661, "state": "active", "url": "https://losc.ligo.org/s/events/GW150914/GW150914_tutorial.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:58:35.877330", "datastore_active": false, "description": "", "format": "TAR", "hash": "", "id": "ec1c5422-b8ab-4401-96fb-0792dacb8e40", "last_modified": "2017-12-01T16:48:21.527146", "metadata_modified": null, "mimetype": "application/x-tar", "mimetype_inner": null, "name": "12 steps to Navier-Stokes", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 4, "resource_type": null, "size": 5708395, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/12%20steps%20to%20Navier-Stokes.tar.gz", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:58:35.877330", "datastore_active": false, "description": "", "format": "TAR", "hash": "", "id": "ec1c5422-b8ab-4401-96fb-0792dacb8e40", "last_modified": "2017-12-01T16:48:21.527146", "metadata_modified": null, "mimetype": "application/x-tar", "mimetype_inner": null, "name": "12 steps to Navier-Stokes", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 4, "resource_type": null, "size": 5708395, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/12%20steps%20to%20Navier-Stokes.tar.gz", "url_type": ""}], "tags": [{"display_name": "computer vision", "id": "f650b4e3-9955-49b0-ba7b-2d302a990978", "name": "computer vision", "state": "active", "vocabulary_id": null}, {"display_name": "imagery analysis", "id": "5581fcb2-a2b7-41aa-aa4e-822d8837fcfe", "name": "imagery analysis", "state": "active", "vocabulary_id": null}, {"display_name": "jupyter notebook", "id": "e2bb9482-6eb5-43c3-b14e-903c519d5e38", "name": "jupyter notebook", "state": "active", "vocabulary_id": null}, {"display_name": "machine learning", "id": "9e42784b-6ee7-47e8-a69a-28b8c510212b", "name": "machine learning", "state": "active", "vocabulary_id": null}, {"display_name": "satellite", "id": "c3ea41c3-899c-4b54-a4f4-caa50617b956", "name": "satellite", "state": "active", "vocabulary_id": null}], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
63650d79-ea10-4dce-9137-a09929ee0764	2021-03-03 10:12:51.076484	17755db4-395a-4b3b-ac09-e8e3484ca700	476cdf71-1048-4a6f-a28a-58fff547dae5	\N	changed package	{"package": {"author": "Autodesk", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-23T17:37:00.362900", "metadata_modified": "2021-03-03T10:12:51.030530", "name": "example-cad", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "num_resources": 4, "num_tags": 6, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Example CAD", "type": "dataset", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "version": "", "extras": [{"key": "foobar", "value": "baz"}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:37:19.897441", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "last_modified": "2017-12-01T16:52:30.511835", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 2D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 0, "resource_type": null, "size": 169807, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/Drive_shaft.dwg", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:37:19.897441", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "last_modified": "2017-12-01T16:52:30.511835", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 2D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 0, "resource_type": null, "size": 169807, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/Drive_shaft.dwg", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:40:23.217872", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "last_modified": "2017-12-01T16:53:23.693615", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 3D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 1, "resource_type": null, "size": 733036, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/visualization_-_aerial.dwg", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-11-23T17:40:23.217872", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "last_modified": "2017-12-01T16:53:23.693615", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example 3D .dwg file", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "position": 1, "resource_type": null, "size": 733036, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/visualization_-_aerial.dwg", "url_type": ""}], "tags": [{"display_name": "2D", "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D", "state": "active", "vocabulary_id": null}, {"display_name": "3D", "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D", "state": "active", "vocabulary_id": null}, {"display_name": "CAD", "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD", "state": "active", "vocabulary_id": null}, {"display_name": "dwg", "id": "675a1366-8d81-4e07-ab30-8c492c34b91d", "name": "dwg", "state": "active", "vocabulary_id": null}, {"display_name": "example", "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example", "state": "active", "vocabulary_id": null}, {"display_name": "visualization", "id": "7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd", "name": "visualization", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
6235d7a9-4db0-4b89-ab7e-1ea7bef90d95	2021-03-03 10:14:21.579307	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	\N	changed package	{"package": {"author": "", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-24T13:36:15.887852", "metadata_modified": "2021-03-03T10:14:21.513141", "name": "example-cad-2", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "num_resources": 2, "num_tags": 5, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Pangaea CAD files", "type": "dataset", "url": "", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:37:06.599034", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "0ce74f0d-bf35-4627-9f69-92d5c1150dff", "last_modified": "2017-12-01T16:50:37.896845", "metadata_modified": null, "mimetype": "application/zip", "mimetype_inner": null, "name": "Example .dwg file", "package_id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "position": 0, "resource_type": null, "size": 3414733, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/gkg_steel_zinced.zip", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:37:06.599034", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "0ce74f0d-bf35-4627-9f69-92d5c1150dff", "last_modified": "2017-12-01T16:50:37.896845", "metadata_modified": null, "mimetype": "application/zip", "mimetype_inner": null, "name": "Example .dwg file", "package_id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "position": 0, "resource_type": null, "size": 3414733, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/gkg_steel_zinced.zip", "url_type": ""}], "tags": [{"display_name": "2D", "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D", "state": "active", "vocabulary_id": null}, {"display_name": "3D", "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D", "state": "active", "vocabulary_id": null}, {"display_name": "CAD", "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD", "state": "active", "vocabulary_id": null}, {"display_name": "example", "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example", "state": "active", "vocabulary_id": null}, {"display_name": "pangaea", "id": "816b2a52-8852-4298-803f-f34556cae9e0", "name": "pangaea", "state": "active", "vocabulary_id": null}], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
7358bef0-bb10-4982-a229-a693b1fc1789	2021-03-03 10:15:41.922397	17755db4-395a-4b3b-ac09-e8e3484ca700	54920aae-f322-4fca-bd09-cd091946632c	\N	changed package	{"package": {"author": "", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "54920aae-f322-4fca-bd09-cd091946632c", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-24T13:42:19.407543", "metadata_modified": "2021-03-03T10:15:41.845072", "name": "example-video-2", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "num_resources": 2, "num_tags": 7, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Autocombustion reactions STF50 video", "type": "dataset", "url": "", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:42:36.237930", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "last_modified": "2017-12-01T16:35:53.307078", "metadata_modified": null, "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 0, "resource_type": null, "size": 71194509, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/STF50_autocombustions_with_varying_phi_v2_HD.mp4", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:42:36.237930", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "last_modified": "2017-12-01T16:35:53.307078", "metadata_modified": null, "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi", "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "position": 0, "resource_type": null, "size": 71194509, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/STF50_autocombustions_with_varying_phi_v2_HD.mp4", "url_type": ""}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}, {"display_name": "Combustion", "id": "23f7f291-52c1-4942-aa23-008a9b23a5e1", "name": "Combustion", "state": "active", "vocabulary_id": null}, {"display_name": "EDTA", "id": "9d0587af-aad0-4352-ab8f-fc7b90f7430b", "name": "EDTA", "state": "active", "vocabulary_id": null}, {"display_name": "Experiment", "id": "a6bbc1be-05c4-406c-8d13-b9e2018b311a", "name": "Experiment", "state": "active", "vocabulary_id": null}, {"display_name": "Reactions", "id": "a292a3c1-b272-4c02-bfb2-385e12ff6b66", "name": "Reactions", "state": "active", "vocabulary_id": null}, {"display_name": "STF50", "id": "53b4f8bd-5778-4ece-b3ac-78e8a60be011", "name": "STF50", "state": "active", "vocabulary_id": null}, {"display_name": "Video", "id": "7d945dfc-6203-4ef8-8369-90704d7498ac", "name": "Video", "state": "active", "vocabulary_id": null}], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
9d8f52c4-81bd-45b3-8a52-3098393c3790	2021-03-09 09:23:57.490851	17755db4-395a-4b3b-ac09-e8e3484ca700	44892bd1-6fb7-477b-858e-483cb1290798	\N	new package	{"package": {"author": "", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "44892bd1-6fb7-477b-858e-483cb1290798", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2021-03-09T09:23:57.460329", "metadata_modified": "2021-03-09T09:23:57.461015", "name": "video-test", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "num_resources": 0, "num_tags": 1, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "draft", "title": "Video test", "type": "dataset", "url": "", "version": "", "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}], "resources": [], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
04c064c8-e9ca-43ce-b9ce-b3cb88ed6738	2021-03-09 09:25:41.821827	17755db4-395a-4b3b-ac09-e8e3484ca700	44892bd1-6fb7-477b-858e-483cb1290798	\N	changed package	{"package": {"author": "", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "44892bd1-6fb7-477b-858e-483cb1290798", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2021-03-09T09:23:57.460329", "metadata_modified": "2021-03-09T09:25:41.776246", "name": "video-test", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "num_resources": 1, "num_tags": 1, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "draft", "title": "Video test", "type": "dataset", "url": "", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2021-03-09T09:25:41.793402", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "7b29ccb4-997c-41ee-8c43-e9d20bbd7554", "last_modified": null, "metadata_modified": "2021-03-09T09:25:41.784658", "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi", "package_id": "44892bd1-6fb7-477b-858e-483cb1290798", "position": 0, "resource_type": null, "size": null, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/STF50_autocombustions_with_varying_phi_v2_HD.mp4", "url_type": null}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
70a9dba7-1561-4ada-9e2e-dfde8c09b88c	2021-03-09 09:25:41.984597	17755db4-395a-4b3b-ac09-e8e3484ca700	44892bd1-6fb7-477b-858e-483cb1290798	\N	changed package	{"package": {"author": "", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "44892bd1-6fb7-477b-858e-483cb1290798", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2021-03-09T09:23:57.460329", "metadata_modified": "2021-03-09T09:25:41.949741", "name": "video-test", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "num_resources": 1, "num_tags": 1, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Video test", "type": "dataset", "url": "", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2021-03-09T09:25:41.793402", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "7b29ccb4-997c-41ee-8c43-e9d20bbd7554", "last_modified": null, "metadata_modified": "2021-03-09T09:25:41.952955", "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi", "package_id": "44892bd1-6fb7-477b-858e-483cb1290798", "position": 0, "resource_type": null, "size": null, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/STF50_autocombustions_with_varying_phi_v2_HD.mp4", "url_type": null}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
d8f98781-3a5b-4a8e-810c-ae65c8faf044	2021-03-09 09:33:22.966322	17755db4-395a-4b3b-ac09-e8e3484ca700	44892bd1-6fb7-477b-858e-483cb1290798	\N	changed package	{"package": {"author": "", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "44892bd1-6fb7-477b-858e-483cb1290798", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2021-03-09T09:23:57.460329", "metadata_modified": "2021-03-09T09:33:22.911024", "name": "video-test", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "num_resources": 1, "num_tags": 1, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib-iasis", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Video test", "type": "dataset", "url": "", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2021-03-09T09:25:41.793402", "datastore_active": false, "description": "", "format": "MP4", "hash": "", "id": "7b29ccb4-997c-41ee-8c43-e9d20bbd7554", "last_modified": null, "metadata_modified": "2021-03-09T09:25:41.952955", "mimetype": "video/mp4", "mimetype_inner": null, "name": "STF50 autocombustions with varying Phi", "package_id": "44892bd1-6fb7-477b-858e-483cb1290798", "position": 0, "resource_type": null, "size": null, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/STF50_autocombustions_with_varying_phi_v2_HD.mp4", "url_type": null}], "tags": [{"display_name": "CA", "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA", "state": "active", "vocabulary_id": null}], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
63663aa5-50c9-43f3-ab7c-301be8438593	2022-03-16 07:05:55.613096	17755db4-395a-4b3b-ac09-e8e3484ca700	0c5362f5-b99e-41db-8256-3d0d7549bf4d	\N	changed organization	{"group": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}}
4170df81-f91d-465f-b8f7-9d090adbe9ef	2022-03-16 07:42:06.645002	17755db4-395a-4b3b-ac09-e8e3484ca700	6284da8e-908c-4666-81c6-64a0fedf10e2	\N	new organization	{"group": {"id": "6284da8e-908c-4666-81c6-64a0fedf10e2", "name": "institut-fur-geologie", "title": "Institut für Geologie", "type": "organization", "description": "Leibniz Universität Hannover\\r\\nCallinstr. 30\\r\\n30167 Hannover\\r\\n\\r\\nhttp://www.geologie.uni-hannover.de/\\r\\n", "image_url": "https://www.geologie.uni-hannover.de/typo3temp/_processed_/e/4/csm_cf132247a6b40f73102849c767bde47979deccba-fp-3-1-0-0_e2d52b6bf9.jpg", "created": "2022-03-16T07:42:06.633095", "is_organization": true, "approval_status": "approved", "state": "active"}}
1474aa78-406d-4c46-83d6-6805b6e24b86	2022-03-16 07:44:14.532435	17755db4-395a-4b3b-ac09-e8e3484ca700	0ddcfe50-9e31-4225-b68f-e777d72fb859	\N	new package	{"package": {"author": "Armin Dielforder, Gian Maria Bocchini, Kilian B. Kemna, Rebecca M Harrington, Andrea Hampel, Onno Oncken", "author_email": "dielforder@geowi.uni-hannover.de", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "doi": "10.25835/0072357", "doi_date_published": "2021-11-18", "doi_publisher": "LUIS", "doi_status": "true", "domain": "https://data.uni-hannover.de", "have_copyright": "Yes", "id": "0ddcfe50-9e31-4225-b68f-e777d72fb859", "isopen": false, "license_id": "CC-BY-NC-3.0", "license_title": "CC-BY-NC-3.0", "maintainer": "Armin Dielforder", "maintainer_email": "dielforder@geowi.uni-hannover.de", "metadata_created": "2022-03-16T07:44:14.209142", "metadata_modified": "2022-03-16T07:44:14.209154", "name": "luh-aftershocks-and-forearc-mechanics", "notes": "This data repository contains the data to the manuscript \\"Aftershocks of great megathrust earthquakes and the mechanics of forearcs\\" by A. Dielforder, G. M. Bocchini, K. Kemna, R. M. Harrington, A. Hampel, and O. Oncken (in prep).\\r\\n\\r\\nThe file reference-models-japan-chile.zip contains the ABAQUS ODBs for the models presented in the main text.\\r\\nThe file \\"alternative-models-japan-chile.zip\\" contains the ABAQUS ODBs for the models presented in the Supplementary Information.\\r\\n\\r\\nThe files \\"Catalogue-Chile.csv\\" and \\"Catalogue-Japan.csv\\" contain the filtered seismic catalogues and stress drop data. ", "num_resources": 4, "num_tags": 3, "organization": {"id": "6284da8e-908c-4666-81c6-64a0fedf10e2", "name": "institut-fur-geologie", "title": "Institut für Geologie", "type": "organization", "description": "Leibniz Universität Hannover\\r\\nCallinstr. 30\\r\\n30167 Hannover\\r\\n\\r\\nhttp://www.geologie.uni-hannover.de/\\r\\n", "image_url": "https://www.geologie.uni-hannover.de/typo3temp/_processed_/e/4/csm_cf132247a6b40f73102849c767bde47979deccba-fp-3-1-0-0_e2d52b6bf9.jpg", "created": "2022-03-16T07:42:06.633095", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "6284da8e-908c-4666-81c6-64a0fedf10e2", "private": false, "repository_name": "Leibniz University Hannover", "services_used_list": "", "source_metadata_created": "2021-11-18T12:12:04.400313", "source_metadata_modified": "2022-01-20T10:58:45.613744", "state": "active", "terms_of_usage": "Yes", "title": "Aftershocks of great megathrust earthquakes and the mechanics of forearcs", "type": "vdataset", "url": "https://data.uni-hannover.de/dataset/aftershocks-and-forearc-mechanics", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2021-11-18T12:12:45.516111", "datastore_active": false, "description": "", "format": "ZIP", "hash": "", "id": "822d5c4a-751b-457c-b5f8-22f9ac88f1e8", "last_modified": "2021-11-18T12:12:45.480716", "metadata_modified": "2022-03-16T07:44:14.184699", "mimetype": "application/zip", "mimetype_inner": null, "name": "alternative-models-japan-chile.zip", "package_id": "0ddcfe50-9e31-4225-b68f-e777d72fb859", "position": 0, "resource_type": null, "size": 80335372, "state": "active", "url": "https://data.uni-hannover.de/dataset/0ddcfe50-9e31-4225-b68f-e777d72fb859/resource/822d5c4a-751b-457c-b5f8-22f9ac88f1e8/download/alternative-models-japan-chile.zip", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2021-11-18T12:13:01.091467", "datastore_active": false, "description": "", "format": "ZIP", "hash": "", "id": "9d137f93-7576-4654-8256-4ae7897ee469", "last_modified": "2021-11-18T12:13:01.056643", "metadata_modified": "2022-03-16T07:44:14.187228", "mimetype": "application/zip", "mimetype_inner": null, "name": "reference-models-japan-chile.zip", "package_id": "0ddcfe50-9e31-4225-b68f-e777d72fb859", "position": 1, "resource_type": null, "size": 24943572, "state": "active", "url": "https://data.uni-hannover.de/dataset/0ddcfe50-9e31-4225-b68f-e777d72fb859/resource/9d137f93-7576-4654-8256-4ae7897ee469/download/reference-models-japan-chile.zip", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2021-11-22T15:01:33.838702", "datastore_active": false, "description": "", "format": "CSV", "hash": "", "id": "cc05a1c2-948b-4965-aea7-de09abdad953", "last_modified": "2021-11-22T15:01:33.805133", "metadata_modified": "2022-03-16T07:44:14.190012", "mimetype": "text/csv", "mimetype_inner": null, "name": "Catalogue-Japan.csv", "package_id": "0ddcfe50-9e31-4225-b68f-e777d72fb859", "position": 2, "resource_type": null, "size": 973437, "state": "active", "url": "https://data.uni-hannover.de/dataset/0ddcfe50-9e31-4225-b68f-e777d72fb859/resource/cc05a1c2-948b-4965-aea7-de09abdad953/download/catalogue-japan.csv", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2021-11-22T15:03:16.704088", "datastore_active": false, "description": "", "format": "CSV", "hash": "", "id": "aad9e24e-1046-4b70-9bb8-7d17a8371969", "last_modified": "2021-11-22T15:03:16.671280", "metadata_modified": "2022-03-16T07:44:14.192871", "mimetype": "text/csv", "mimetype_inner": null, "name": "Catalogue-Chile.csv", "package_id": "0ddcfe50-9e31-4225-b68f-e777d72fb859", "position": 3, "resource_type": null, "size": 349250, "state": "active", "url": "https://data.uni-hannover.de/dataset/0ddcfe50-9e31-4225-b68f-e777d72fb859/resource/aad9e24e-1046-4b70-9bb8-7d17a8371969/download/catalogue-chile.csv", "url_type": ""}], "tags": [{"display_name": "aftershocks", "id": "e6d56045-9569-4230-93f4-699fb1b96f7e", "name": "aftershocks", "state": "active", "vocabulary_id": null}, {"display_name": "megathrust earthquakes", "id": "f94d461f-a9ee-4b35-91ce-5bdcfefa4a91", "name": "megathrust earthquakes", "state": "active", "vocabulary_id": null}, {"display_name": "subduction zones", "id": "5534061d-2eff-448a-8814-2d119df0e73e", "name": "subduction zones", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
c8c8527b-23a8-4c3a-a9ab-03b8fc9adaec	2022-03-16 07:44:14.776442	17755db4-395a-4b3b-ac09-e8e3484ca700	2d2ca2a7-26f5-497b-b5a4-a559a28f3042	\N	new organization	{"group": {"id": "2d2ca2a7-26f5-497b-b5a4-a559a28f3042", "name": "ag-palm", "title": "AG PALM", "type": "organization", "description": "", "image_url": "", "created": "2022-03-16T07:44:14.760944", "is_organization": true, "approval_status": "approved", "state": "active"}}
3c59bb69-24b0-4e4c-82e3-4ec2c6673210	2022-03-16 07:44:14.991581	17755db4-395a-4b3b-ac09-e8e3484ca700	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	\N	new package	{"package": {"author": "Knoop, H., F. Ament, B. Maronga", "author_email": "knoop@muk.uni-hannover.de", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "doi": "10.25835/0067988", "doi_date_published": "2019-07-10", "doi_publisher": "LUIS", "doi_status": "true", "domain": "https://data.uni-hannover.de", "have_copyright": "Yes", "id": "c76adf5a-9aa8-4ebe-bbbe-0e61436cf033", "isopen": false, "license_id": "CC-BY-3.0", "license_title": "CC-BY-3.0", "maintainer": "Helge Knoop", "maintainer_email": "knoop@muk.uni-hannover.de", "metadata_created": "2022-03-16T07:44:14.935203", "metadata_modified": "2022-03-16T07:44:14.935209", "name": "luh-a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis", "notes": "This dataset is associated with the paper Knoop et al. (2019) titled  \\"A generic gust definition and detection method based on wavelet-analysis\\" published in \\"Advances in Science and Research (ASR)\\" within the Special Issue: 18th EMS Annual Meeting: European Conference for Applied Meteorology and Climatology 2018. It contains the data and analysis software required to recreate all figures in the publication.", "num_resources": 1, "num_tags": 6, "organization": {"id": "2d2ca2a7-26f5-497b-b5a4-a559a28f3042", "name": "ag-palm", "title": "AG PALM", "type": "organization", "description": "", "image_url": "", "created": "2022-03-16T07:44:14.760944", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "2d2ca2a7-26f5-497b-b5a4-a559a28f3042", "private": false, "repository_name": "Leibniz University Hannover", "source_metadata_created": "2019-07-09T17:21:22.824534", "source_metadata_modified": "2022-01-20T10:58:47.075885", "state": "active", "terms_of_usage": "Yes", "title": "A generic gust definition and detection method based on wavelet-analysis", "type": "vdataset", "url": "https://data.uni-hannover.de/dataset/a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2019-07-09T17:27:20.908781", "datastore_active": false, "description": "Wind velocity data in netCDF format, a python script for data analysis and a requirements.txt file containing all python package dependencies.", "format": "ZIP", "hash": "", "id": "bd5d8d95-b3e2-4f25-a928-d75df8faf462", "last_modified": "2019-07-09T17:27:20.810267", "metadata_modified": "2022-03-16T07:44:14.881407", "mimetype": "application/zip", "mimetype_inner": null, "name": "wavelet_gust_analysis.zip", "package_id": "c76adf5a-9aa8-4ebe-bbbe-0e61436cf033", "position": 0, "resource_type": null, "size": 96112, "state": "active", "url": "https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/bd5d8d95-b3e2-4f25-a928-d75df8faf462/download/wavelet_gust_analysis.zip", "url_type": ""}], "tags": [{"display_name": "Gusts", "id": "8bd7857b-cc2b-46a8-ac2e-f73dcd46d659", "name": "Gusts", "state": "active", "vocabulary_id": null}, {"display_name": "LES", "id": "e9c2218b-05ce-47d2-a936-a7185dafd264", "name": "LES", "state": "active", "vocabulary_id": null}, {"display_name": "LES model", "id": "417bc38b-82b2-45d9-9768-b420bbb413ee", "name": "LES model", "state": "active", "vocabulary_id": null}, {"display_name": "Meteorology", "id": "18486445-68da-490e-b690-56f10770fac9", "name": "Meteorology", "state": "active", "vocabulary_id": null}, {"display_name": "Wavelet Analysis", "id": "418ade6e-6742-4a47-a6d7-d1c6546d6a4e", "name": "Wavelet Analysis", "state": "active", "vocabulary_id": null}, {"display_name": "large eddy simulation", "id": "30f6129d-ce3e-413d-be1e-6b92dd9ed9ee", "name": "large eddy simulation", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "services_used_list": ""}, "actor": "admin"}
5845ff4e-6806-411d-be7e-4483da70d58f	2022-03-16 07:44:15.206712	17755db4-395a-4b3b-ac09-e8e3484ca700	ef96d2db-9cbe-4738-b7bf-da556e12bdc2	\N	new package	{"package": {"author": "David Morris, Peichen Tang, and Ralph Ewerth", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "doi": "10.25835/0030443", "doi_date_published": "2019-06-27", "doi_publisher": "LUIS", "doi_status": "true", "domain": "https://data.uni-hannover.de", "have_copyright": "Yes", "id": "ef96d2db-9cbe-4738-b7bf-da556e12bdc2", "isopen": false, "license_id": "CC-BY-3.0", "license_title": "CC-BY-3.0", "maintainer": "David Morris, Peichen Tang, and Ralph Ewerth", "maintainer_email": "", "metadata_created": "2022-03-16T07:44:15.166295", "metadata_modified": "2022-03-16T07:44:15.166300", "name": "luh-a-neural-approach-for-text-extraction-from-scholarly-figures", "notes": "# A Neural Approach for Text Extraction from Scholarly Figures\\r\\nThis is the readme for the supplemental data for our ICDAR 2019 paper.\\r\\n\\r\\nYou can read our paper via IEEE here: https://ieeexplore.ieee.org/document/8978202\\r\\n\\r\\nIf you found this dataset useful, please consider citing our paper:\\r\\n\\r\\n\\t@inproceedings{DBLP:conf/icdar/MorrisTE19,\\r\\n\\t  author    = {David Morris and\\r\\n\\t\\t\\t\\t   Peichen Tang and\\r\\n\\t\\t\\t\\t   Ralph Ewerth},\\r\\n\\t  title     = {A Neural Approach for Text Extraction from Scholarly Figures},\\r\\n\\t  booktitle = {2019 International Conference on Document Analysis and Recognition,\\r\\n\\t\\t\\t\\t   {ICDAR} 2019, Sydney, Australia, September 20-25, 2019},\\r\\n\\t  pages     = {1438--1443},\\r\\n\\t  publisher = {{IEEE}},\\r\\n\\t  year      = {2019},\\r\\n\\t  url       = {https://doi.org/10.1109/ICDAR.2019.00231},\\r\\n\\t  doi       = {10.1109/ICDAR.2019.00231},\\r\\n\\t  timestamp = {Tue, 04 Feb 2020 13:28:39 +0100},\\r\\n\\t  biburl    = {https://dblp.org/rec/conf/icdar/MorrisTE19.bib},\\r\\n\\t  bibsource = {dblp computer science bibliography, https://dblp.org}\\r\\n\\t}\\r\\n\\r\\nThis work was financially supported by the German Federal Ministry of Education and Research (BMBF) and European Social Fund (ESF) (InclusiveOCW project, no. 01PE17004).\\r\\n## Datasets\\r\\nWe used different sources of data for testing, validation, and training. Our testing set was assembled by the work we cited by Böschen et al. We excluded the DeGruyter dataset, and use it as our validation dataset.\\r\\n### Testing\\r\\nThese datasets contain a readme with license information. Further information about the associated project can be found in the authors' published work we cited: https://doi.org/10.1007/978-3-319-51811-4_2\\r\\n### Validation\\r\\nThe DeGruyter dataset does not include the labeled images due to license restrictions. As of writing, the images can still be downloaded from DeGruyter via the links in the readme. Note that depending on what program you use to strip the images out of the PDF they are provided in, you may have to re-number the images.\\r\\n### Training\\r\\nWe used [label_generator](https://github.com/domoritz/label_generator)'s  generated dataset, which the author made available on a requester-pays [amazon s3 bucket](s3://escience.washington.edu.viziometrics).\\r\\nWe also used the Multi-Type Web Images dataset, which is mirrored [here](https://tianchi.aliyun.com/competition/introduction.htm?spm=5176.100066.0.0.3bcad780oQ9Ce4&raceId=231651).\\r\\n## Code\\r\\nWe have made our code available in `code.zip`. We will upload code, announce further news, and field questions via the [github repo](https://github.com/david-morris/Neural-Figure-Text).\\r\\n\\r\\nOur text detection network is adapted from [Argman's EAST implementation](https://github.com/argman/EAST). The `EAST/checkpoints/ours` subdirectory contains the trained weights we used in the paper.\\r\\n\\r\\nWe used a tesseract script to run text extraction from detected text rows. This is inside our code `code.tar` as `text_recognition_multipro.py`.\\r\\n\\r\\nWe used a java script provided by Falk Böschen and adapted to our file structure.  We included this as `evaluator.jar`.\\r\\n\\r\\nParameter sweeps are automated by `param_sweep.rb`. This file also shows how to invoke all of these components.", "num_resources": 1, "num_tags": 3, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "repository_name": "Leibniz University Hannover", "source_metadata_created": "2019-06-27T16:29:02.921892", "source_metadata_modified": "2022-01-20T13:48:50.142253", "state": "active", "terms_of_usage": "Yes", "title": "A Neural Approach for Text Extraction from Scholarly Figures", "type": "vdataset", "url": "https://data.uni-hannover.de/dataset/a-neural-approach-for-text-extraction-from-scholarly-figures", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2019-06-27T16:35:58.670413", "datastore_active": false, "description": "", "format": "ZIP", "hash": "", "id": "106f7149-6161-4117-893a-44990c05cbe4", "last_modified": "2019-06-27T16:35:58.612669", "metadata_modified": "2022-03-16T07:44:15.159307", "mimetype": "application/zip", "mimetype_inner": null, "name": "code.zip", "package_id": "ef96d2db-9cbe-4738-b7bf-da556e12bdc2", "position": 0, "resource_type": null, "size": 798357692, "state": "active", "url": "https://data.uni-hannover.de/dataset/ef96d2db-9cbe-4738-b7bf-da556e12bdc2/resource/106f7149-6161-4117-893a-44990c05cbe4/download/code.zip", "url_type": ""}], "tags": [{"display_name": "computer vision", "id": "f650b4e3-9955-49b0-ba7b-2d302a990978", "name": "computer vision", "state": "active", "vocabulary_id": null}, {"display_name": "document analysis", "id": "b5d28237-06f1-4ecb-9cf0-1ad354b0ff3f", "name": "document analysis", "state": "active", "vocabulary_id": null}, {"display_name": "machine learning", "id": "9e42784b-6ee7-47e8-a69a-28b8c510212b", "name": "machine learning", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "services_used_list": ""}, "actor": "admin"}
072901d1-80c7-4d70-9923-59cfb1b3e352	2022-03-16 07:44:15.542694	17755db4-395a-4b3b-ac09-e8e3484ca700	a6ac49d3-2eff-4f4d-bb17-709595cf72d7	\N	new organization	{"group": {"id": "a6ac49d3-2eff-4f4d-bb17-709595cf72d7", "name": "institut-fur-umweltplanung", "title": "Institut für Umweltplanung ", "type": "organization", "description": "Institute of Environmental Planning\\r\\nHerrenhäuser Str. 2, 30419 Hannover", "image_url": "https://data.uni-hannover.de/uploads/group/2021-08-05-071444.382087IUPbildmarke.png", "created": "2022-03-16T07:44:15.535151", "is_organization": true, "approval_status": "approved", "state": "active"}}
f7da6235-fe8f-406c-82ff-6ead61f35fa3	2022-03-16 07:44:15.695862	17755db4-395a-4b3b-ac09-e8e3484ca700	2dfe1d91-0394-4107-8309-b125d98840cc	\N	new package	{"package": {"author": "Ole Badelt, Julia Wiehe, Christina von Haaren", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "doi": "10.25835/0023628", "doi_date_published": "2022-01-06", "doi_publisher": "LUIS", "doi_status": "true", "domain": "https://data.uni-hannover.de", "have_copyright": "Yes", "id": "2dfe1d91-0394-4107-8309-b125d98840cc", "isopen": false, "license_id": "CC-BY-3.0", "license_title": "CC-BY-3.0", "maintainer": "Ole Badelt, Julia Wiehe, Christina von Haaren", "maintainer_email": "", "metadata_created": "2022-03-16T07:44:15.651760", "metadata_modified": "2022-03-16T07:44:15.651763", "name": "luh-areas-in-lower-saxony-with-low-and-medium-spatial-vulnerability-to-ground-mounted-photovoltaics", "notes": "#Niedersächsische Flächen mit geringem und mittlerem Raumwiderstand gegenüber Photovoltaik-Freiflächenanlagen (English version below)\\r\\n\\r\\nDie Shapefiles zeigen Flächen in Niedersachsen mit geringem und mittlerem Raumwiderstand gegenüber Photovoltaik-Freiflächenanlagen (Badelt et al. 2020), die als „räumliche Fahrrinne“ für eine nachhaltige Energiewende dienen können. Es kann davon ausgegangen werden, dass vor allem auf den Flächen mit geringem Raumwiderstand der Ausbau von Freiflächenphotovoltaik weitgehend ohne Konflikte mit dem Naturschutz oder der menschlichen Gesundheit gelingt.\\r\\n\\r\\nDie verwendeten __Grundlagendaten__ und ihre Einordnung in Raumwiderstandsklassen können aus Badelt et al. (2020) entnommen werden: GeoBasis-DE/BKG 2019 (Nutzungsbedingungen: https://sg.geodatenzentrum.de/web_public/nutzungsbedingungen.pdf), Atlas Deutscher Brutvogelarten 2014, LGLN 2019, MU 2019; NLWKN 2018; NLWKN 2019. Gegenüber der ursprünglichen Analyse wurden Aktualisierungen vorgenommen, die sich auf die exaktere Abgrenzung der Straßen und Bahnstrecken sowie landwirtschaftlicher Sonderkulturen beziehen. Flächen mit geringem Raumwiderstand gegenüber PV-Freiflächenanlagen umfassen damit in Niedersachsen 618.114 ha (ehemals 563.279 ha). Einem mittleren Raumwiderstand werden 860.195 ha (ehemals 766.107 ha) zugeordnet. \\r\\n\\r\\n__English version__\\r\\n\\r\\nThe shapefiles display areas with low and medium spatial vulnerability to ground-mounted photovoltaic systems (Badelt et al. 2020), which can serve as a \\"spatial fairway\\" for a sustainable energy transition. It can be assumed that the expansion of ground-mounted photovoltaics in areas with low spatial vulnerability is largely possible without conflicts with nature conservation or human well-being. \\r\\n\\r\\nThe basic data used and their classification into classes of spatial vulnerability can be taken from Badelt et al. (2020): GeoBasis-DE/BKG 2017(Terms of use: https://sg.geodatenzentrum.de/web_public/nutzungsbedingungen.pdf), Atlas of German Breeding Bird Species 2014, LGLN 2019, MU 2019; NLWKN 2018; NLWKN 2019. Compared to the original analysis, updates were made that relate to the more precise differentiation of roads and railroad lines as well as special agricultural crops. Areas with low spatial vulnerability to ground-mounted PV systems thus comprise 618,114 ha (formerly 563,279 ha) in Lower Saxony. A medium spatial vulnerability is assigned to 860,195 ha (formerly 766,107 ha).\\r\\n\\r\\n__Projected Coordinate System:__ ETRS_1989_UTM_Zone_32N_8stellen\\r\\n\\r\\n__Referenzen / References:__  \\r\\n\\r\\nBadelt, O.; Niepelt, R.; Wiehe, J.; Matthies, S.; Gewohn, T.; Stratmann, M.; Brendel, R. & Haaren, C. von (2020): Integration von Solarenergie in die niedersächsische Energielandschaft (INSIDE). Institut für Solarenergieforschung GmbH Hameln/Emmertal, Institut für Umweltplanung und Institut für Festkörperphysik der Leibniz Universität. Hannover. 128 Seiten, Anhang. \\r\\n\\r\\n__Förderung / Funding:__ Der Datensatz resultiert aus dem Forschungsprojekt „Integration von Solarenergie in die niedersächsische Energielandschaft (INSIDE)“, das vom Niedersächsischen Ministerium für Umwelt, Energie, Bauen und Klimaschutz gefördert wurde (Antragsnummern ZW6-80150424/ZW6-80150425).\\r\\n", "num_resources": 1, "num_tags": 5, "organization": {"id": "a6ac49d3-2eff-4f4d-bb17-709595cf72d7", "name": "institut-fur-umweltplanung", "title": "Institut für Umweltplanung ", "type": "organization", "description": "Institute of Environmental Planning\\r\\nHerrenhäuser Str. 2, 30419 Hannover", "image_url": "https://data.uni-hannover.de/uploads/group/2021-08-05-071444.382087IUPbildmarke.png", "created": "2022-03-16T07:44:15.535151", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "a6ac49d3-2eff-4f4d-bb17-709595cf72d7", "private": false, "repository_name": "Leibniz University Hannover", "source_metadata_created": "2022-01-06T14:28:00.373658", "source_metadata_modified": "2022-01-20T11:49:27.432645", "state": "active", "terms_of_usage": "Yes", "title": "Areas in Lower Saxony with low and medium spatial vulnerability to ground mounted photovoltaics", "type": "vdataset", "url": "https://data.uni-hannover.de/dataset/areas-in-lower-saxony-with-low-and-medium-spatial-vulnerability-to-ground-mounted-photovoltaics", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-01-06T14:52:34.143590", "datastore_active": false, "description": "The shapefiles display areas with low and medium spatial vulnerability ground-mounted photovoltaic systems.\\r\\n\\r\\n", "format": "shape", "hash": "", "id": "3bc88bf0-f6f6-49ab-ae08-e65e30883125", "last_modified": "2022-01-06T14:52:34.096407", "metadata_modified": "2022-03-16T07:44:15.643793", "mimetype": "application/zip", "mimetype_inner": null, "name": "Areas_with_low_and_medium_spatial_vulnerability_solar.zip", "package_id": "2dfe1d91-0394-4107-8309-b125d98840cc", "position": 0, "resource_type": null, "size": 64071883, "state": "active", "url": "https://data.uni-hannover.de/dataset/2dfe1d91-0394-4107-8309-b125d98840cc/resource/3bc88bf0-f6f6-49ab-ae08-e65e30883125/download/areas_with_low_and_medium_spatial_vulnerability_solar.zip", "url_type": ""}], "tags": [{"display_name": "GIS modeling", "id": "1cdda301-e396-4674-8dd9-f9e7b5b25524", "name": "GIS modeling", "state": "active", "vocabulary_id": null}, {"display_name": "energy transition", "id": "c1a56b00-65c8-4b91-8f17-69921799d700", "name": "energy transition", "state": "active", "vocabulary_id": null}, {"display_name": "nature protection", "id": "609026eb-7b35-4c38-9af2-02506b88a95b", "name": "nature protection", "state": "active", "vocabulary_id": null}, {"display_name": "renewable energy potentials", "id": "49a9cf01-df26-461c-819c-9772a76f62fc", "name": "renewable energy potentials", "state": "active", "vocabulary_id": null}, {"display_name": "solar power", "id": "370159b3-bb81-4d9b-902a-f080dc387e62", "name": "solar power", "state": "active", "vocabulary_id": null}], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "services_used_list": ""}, "actor": "admin"}
867236ee-b811-449f-8922-9a4d08c71c6f	2022-03-16 08:31:24.935092	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	new package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T08:31:24.461484", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 0, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "draft", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": false, "domain": "localhost:5000", "doi_date_published": null, "doi_publisher": "TIB"}, "actor": "admin"}
6c72124f-7904-4f06-82f0-ab562413b33e	2022-03-16 08:32:48.710415	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T08:32:47.480860", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 1, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
512c0ce5-f054-43fd-9103-c17f77270834	2022-03-16 08:54:45.922069	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T08:54:45.115928", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 5, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:54:45.118772", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:54:45.122641", "datastore_active": false, "description": "Just a GIF image for visualization.", "format": "GIF", "hash": "", "id": "3486d220-0c38-4449-96df-7d4d18b916a7", "last_modified": "2022-03-16T08:54:45.107385", "metadata_modified": "2022-03-16T08:54:45.118928", "mimetype": "image/gif", "mimetype_inner": null, "name": "GIF image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 4, "resource_type": null, "size": 3132208, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/3486d220-0c38-4449-96df-7d4d18b916a7/download/giphy.gif", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
8d3d2ab5-2f29-4320-89af-767c72403efa	2022-03-16 09:07:55.801418	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T09:07:55.532240", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:54:45.118772", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:54:45.122641", "datastore_active": false, "description": "Just a GIF image for visualization.", "format": "GIF", "hash": "", "id": "3486d220-0c38-4449-96df-7d4d18b916a7", "last_modified": "2022-03-16T08:54:45.107385", "metadata_modified": "2022-03-16T09:03:59.911887", "mimetype": "image/gif", "mimetype_inner": null, "name": "GIF image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 4, "resource_type": null, "size": 3132208, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/3486d220-0c38-4449-96df-7d4d18b916a7/download/giphy.gif", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:03:59.916552", "datastore_active": false, "description": "This is just an example for visualization.", "format": "ODT", "hash": "", "id": "95a1ebf6-d481-4940-923c-59b21921dfda", "last_modified": "2022-03-16T09:07:55.525141", "metadata_modified": "2022-03-16T09:07:55.535363", "mimetype": "application/vnd.oasis.opendocument.text", "mimetype_inner": null, "name": "OpenOffice Writer example (ODT) ", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 5, "resource_type": null, "size": 21423, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/95a1ebf6-d481-4940-923c-59b21921dfda/download/sample1.odt", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
6047f820-c5e5-4c3b-8af7-28a89112efbc	2022-03-16 09:13:03.390696	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T09:13:02.554776", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 7, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:54:45.118772", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:54:45.122641", "datastore_active": false, "description": "Just a GIF image for visualization.", "format": "GIF", "hash": "", "id": "3486d220-0c38-4449-96df-7d4d18b916a7", "last_modified": "2022-03-16T08:54:45.107385", "metadata_modified": "2022-03-16T09:03:59.911887", "mimetype": "image/gif", "mimetype_inner": null, "name": "GIF image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 4, "resource_type": null, "size": 3132208, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/3486d220-0c38-4449-96df-7d4d18b916a7/download/giphy.gif", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:03:59.916552", "datastore_active": false, "description": "This is just an example for visualization.", "format": "ODT", "hash": "", "id": "95a1ebf6-d481-4940-923c-59b21921dfda", "last_modified": "2022-03-16T09:07:55.525141", "metadata_modified": "2022-03-16T09:13:02.560479", "mimetype": "application/vnd.oasis.opendocument.text", "mimetype_inner": null, "name": "OpenOffice Writer example (ODT) ", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 5, "resource_type": null, "size": 21423, "state": "active", "url": "https://filesamples.com/samples/document/odt/sample1.odt", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:13:02.565493", "datastore_active": false, "description": "This is just an example file for visualization.", "format": "ODP", "hash": "", "id": "966e73d8-654f-4396-ad35-c2bd212e9afd", "last_modified": "2022-03-16T09:13:02.545995", "metadata_modified": "2022-03-16T09:13:02.560657", "mimetype": "application/vnd.oasis.opendocument.presentation", "mimetype_inner": null, "name": "Open Document Presentation (ODP)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 6, "resource_type": null, "size": 389789, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/966e73d8-654f-4396-ad35-c2bd212e9afd/download/sample1.odp", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
3e3e947b-4634-4a85-a35f-57c20aba7a69	2022-03-16 09:13:41.15164	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T09:13:40.783431", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 7, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:54:45.118772", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:54:45.122641", "datastore_active": false, "description": "Just a GIF image for visualization.", "format": "GIF", "hash": "", "id": "3486d220-0c38-4449-96df-7d4d18b916a7", "last_modified": "2022-03-16T08:54:45.107385", "metadata_modified": "2022-03-16T09:03:59.911887", "mimetype": "image/gif", "mimetype_inner": null, "name": "GIF image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 4, "resource_type": null, "size": 3132208, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/3486d220-0c38-4449-96df-7d4d18b916a7/download/giphy.gif", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:03:59.916552", "datastore_active": false, "description": "This is just an example for visualization.", "format": "ODT", "hash": "", "id": "95a1ebf6-d481-4940-923c-59b21921dfda", "last_modified": "2022-03-16T09:07:55.525141", "metadata_modified": "2022-03-16T09:13:02.560479", "mimetype": "application/vnd.oasis.opendocument.text", "mimetype_inner": null, "name": "OpenOffice Writer example (ODT) ", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 5, "resource_type": null, "size": 21423, "state": "active", "url": "https://filesamples.com/samples/document/odt/sample1.odt", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:13:02.565493", "datastore_active": false, "description": "This is just an example file for visualization.", "format": "ODP", "hash": "", "id": "966e73d8-654f-4396-ad35-c2bd212e9afd", "last_modified": "2022-03-16T09:13:02.545995", "metadata_modified": "2022-03-16T09:13:40.788864", "mimetype": "application/vnd.oasis.opendocument.presentation", "mimetype_inner": null, "name": "Open Document Presentation (ODP)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 6, "resource_type": null, "size": 389789, "state": "active", "url": "https://filesamples.com/samples/document/odp/sample1.odp", "url_type": ""}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
df84bc90-4d83-4910-8115-bf666f8ecee6	2022-03-16 09:17:57.671244	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	new package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:17:57.266755", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 0, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "draft", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": false, "domain": "localhost:5000", "doi_date_published": null, "doi_publisher": "TIB"}, "actor": "admin"}
4ab54521-8c0f-45a4-9ddf-37a419b870e9	2022-03-16 08:32:47.327558	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T08:32:47.300042", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 1, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "draft", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.302664", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": false, "domain": "localhost:5000", "doi_date_published": null, "doi_publisher": "TIB"}, "actor": "admin"}
e3b3aba9-ae82-4fe0-8d97-f889168f6fd2	2022-03-16 08:43:40.117141	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T08:43:39.001771", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 2, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:43:39.005209", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
42f43d50-1aa0-4dbe-be23-287753e824db	2022-03-16 08:45:49.828331	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T08:45:49.072135", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 3, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:45:49.062933", "metadata_modified": "2022-03-16T08:45:49.075279", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 4318, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
2471f0de-8e55-45fa-9bc1-8765b49609f0	2022-03-16 08:49:18.772667	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T08:49:17.925025", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 3, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:49:17.927958", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
2ea847dc-6554-4f26-a756-43106c6b7df3	2022-03-16 08:51:45.248132	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T08:51:44.362799", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 4, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:51:44.365786", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
b62d6a53-afee-46bc-bdfb-8e02f72c06b4	2022-03-16 09:04:00.899661	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T09:03:59.906154", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:54:45.118772", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:54:45.122641", "datastore_active": false, "description": "Just a GIF image for visualization.", "format": "GIF", "hash": "", "id": "3486d220-0c38-4449-96df-7d4d18b916a7", "last_modified": "2022-03-16T08:54:45.107385", "metadata_modified": "2022-03-16T09:03:59.911887", "mimetype": "image/gif", "mimetype_inner": null, "name": "GIF image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 4, "resource_type": null, "size": 3132208, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/3486d220-0c38-4449-96df-7d4d18b916a7/download/giphy.gif", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:03:59.916552", "datastore_active": false, "description": "This is just an example for visualization.", "format": "ODT", "hash": "", "id": "95a1ebf6-d481-4940-923c-59b21921dfda", "last_modified": "2022-03-16T09:03:59.896354", "metadata_modified": "2022-03-16T09:03:59.912073", "mimetype": "application/vnd.oasis.opendocument.text", "mimetype_inner": null, "name": "OpenOffice Writer example (ODT) ", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 5, "resource_type": null, "size": 21423, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/95a1ebf6-d481-4940-923c-59b21921dfda/download/sample1.odt", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
1557c210-1ebd-4c2a-8bc5-08839a18a595	2022-03-16 09:06:11.02996	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T09:06:10.770203", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:54:45.118772", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:54:45.122641", "datastore_active": false, "description": "Just a GIF image for visualization.", "format": "GIF", "hash": "", "id": "3486d220-0c38-4449-96df-7d4d18b916a7", "last_modified": "2022-03-16T08:54:45.107385", "metadata_modified": "2022-03-16T09:03:59.911887", "mimetype": "image/gif", "mimetype_inner": null, "name": "GIF image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 4, "resource_type": null, "size": 3132208, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/3486d220-0c38-4449-96df-7d4d18b916a7/download/giphy.gif", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:03:59.916552", "datastore_active": false, "description": "This is just an example for visualization.", "format": "ODT", "hash": "", "id": "95a1ebf6-d481-4940-923c-59b21921dfda", "last_modified": "2022-03-16T09:03:59.896354", "metadata_modified": "2022-03-16T09:06:10.775020", "mimetype": "application/vnd.oasis.opendocument.text", "mimetype_inner": null, "name": "OpenOffice Writer example (ODT) ", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 5, "resource_type": null, "size": 21423, "state": "active", "url": "https://filesamples.com/samples/document/odt/sample1.odt", "url_type": ""}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
705eb582-8b3a-4eab-b61d-30b24a5a92c1	2022-03-16 09:07:20.084642	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T09:07:19.811938", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:54:45.118772", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:54:45.122641", "datastore_active": false, "description": "Just a GIF image for visualization.", "format": "GIF", "hash": "", "id": "3486d220-0c38-4449-96df-7d4d18b916a7", "last_modified": "2022-03-16T08:54:45.107385", "metadata_modified": "2022-03-16T09:03:59.911887", "mimetype": "image/gif", "mimetype_inner": null, "name": "GIF image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 4, "resource_type": null, "size": 3132208, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/3486d220-0c38-4449-96df-7d4d18b916a7/download/giphy.gif", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:03:59.916552", "datastore_active": false, "description": "This is just an example for visualization.", "format": "ODT", "hash": "", "id": "95a1ebf6-d481-4940-923c-59b21921dfda", "last_modified": "2022-03-16T09:03:59.896354", "metadata_modified": "2022-03-16T09:06:10.775020", "mimetype": "application/vnd.oasis.opendocument.text", "mimetype_inner": null, "name": "OpenOffice Writer example (ODT) ", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 5, "resource_type": null, "size": 21423, "state": "active", "url": "https://filesamples.com/samples/document/odt/sample1.odt", "url_type": ""}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
5c84cdb3-bd6f-4c66-a74f-085864532337	2022-03-16 09:08:31.673531	17755db4-395a-4b3b-ac09-e8e3484ca700	86b5446b-092a-4467-870c-b61b055d763f	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "86b5446b-092a-4467-870c-b61b055d763f", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T08:31:24.461479", "metadata_modified": "2022-03-16T09:08:31.402694", "name": "example-documents-visualizations", "notes": "This is an example Dataset showing visualizations for documents in different formats. ", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Documents Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "cf631a59-4dca-4f90-8434-9a2b525336b2", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:32:47.306135", "datastore_active": false, "description": "To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\\r\\nPublished by Leibniz University Hannover.", "format": "PDF", "hash": "", "id": "4a7d7059-b168-4772-9b81-ffb11f0f6d70", "last_modified": "2022-03-16T08:32:47.294826", "metadata_modified": "2022-03-16T08:32:47.483091", "mimetype": "application/pdf", "mimetype_inner": null, "name": "Data Description (PDF)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 0, "resource_type": null, "size": 962808, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/4a7d7059-b168-4772-9b81-ffb11f0f6d70/download/data_description.pdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:43:39.008718", "datastore_active": false, "description": "This is just text for visualization.", "format": "TXT", "hash": "", "id": "ce24e635-7fef-47e2-9f70-a0b214805867", "last_modified": "2022-03-16T08:43:38.994979", "metadata_modified": "2022-03-16T08:45:49.075099", "mimetype": "text/plain", "mimetype_inner": null, "name": "Text file example (TXT)", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 1, "resource_type": null, "size": 2330, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/ce24e635-7fef-47e2-9f70-a0b214805867/download/text_example.txt", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:45:49.079082", "datastore_active": false, "description": "Intersection A with overlaid trajectory samples and background image.\\r\\nImage published by Leibniz University Hannover.", "format": "PNG", "hash": "", "id": "43670f2e-4bcc-4835-8f95-5eb6c8a0ace6", "last_modified": "2022-03-16T08:49:17.919665", "metadata_modified": "2022-03-16T08:51:44.365574", "mimetype": "image/png", "mimetype_inner": null, "name": "PNG image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 2, "resource_type": null, "size": 2085108, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/43670f2e-4bcc-4835-8f95-5eb6c8a0ace6/download/junctiona.png", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:51:44.369862", "datastore_active": false, "description": "Picture of the GTEM 1250 cell.\\r\\nImage published by Leibniz University Hannover.", "format": "JPEG", "hash": "", "id": "9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac", "last_modified": "2022-03-16T08:51:44.355645", "metadata_modified": "2022-03-16T08:54:45.118772", "mimetype": "image/jpeg", "mimetype_inner": null, "name": "JPG Image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 3, "resource_type": null, "size": 2437112, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac/download/gtem_1250.jpg", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T08:54:45.122641", "datastore_active": false, "description": "Just a GIF image for visualization.", "format": "GIF", "hash": "", "id": "3486d220-0c38-4449-96df-7d4d18b916a7", "last_modified": "2022-03-16T08:54:45.107385", "metadata_modified": "2022-03-16T09:03:59.911887", "mimetype": "image/gif", "mimetype_inner": null, "name": "GIF image example", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 4, "resource_type": null, "size": 3132208, "state": "active", "url": "http://localhost:5000/dataset/86b5446b-092a-4467-870c-b61b055d763f/resource/3486d220-0c38-4449-96df-7d4d18b916a7/download/giphy.gif", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:03:59.916552", "datastore_active": false, "description": "This is just an example for visualization.", "format": "ODT", "hash": "", "id": "95a1ebf6-d481-4940-923c-59b21921dfda", "last_modified": "2022-03-16T09:07:55.525141", "metadata_modified": "2022-03-16T09:08:31.407017", "mimetype": "application/vnd.oasis.opendocument.text", "mimetype_inner": null, "name": "OpenOffice Writer example (ODT) ", "package_id": "86b5446b-092a-4467-870c-b61b055d763f", "position": 5, "resource_type": null, "size": 21423, "state": "active", "url": "https://filesamples.com/samples/document/odt/sample1.odt", "url_type": ""}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/hxjs3epq", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
ca9d30d7-e0bc-400c-b973-ac64d183704c	2022-03-16 09:22:42.677321	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:22:41.489959", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 1, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:22:41.492695", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/fece58b1-1505-4ef0-befb-3f0edf59335d/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
5bc866c4-4568-4f10-882b-1a2ecc9c10fe	2022-03-16 09:26:48.585078	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:26:47.713110", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 2, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is an XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:26:47.716051", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
79290a8a-4ee7-43a7-b444-ac21bb994982	2022-03-16 09:29:09.601363	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:29:08.770805", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 3, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is an XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:29:08.774119", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:29:08.778126", "datastore_active": false, "description": "This is an JSON file published by Leibniz University Hannover. ", "format": "JSON", "hash": "", "id": "e3e6e6ef-e356-4005-af2e-2e8538ed3f58", "last_modified": "2022-03-16T09:29:08.762912", "metadata_modified": "2022-03-16T09:29:08.774300", "mimetype": "application/json", "mimetype_inner": null, "name": "JSON Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 2, "resource_type": null, "size": 6211, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/e3e6e6ef-e356-4005-af2e-2e8538ed3f58/download/2017-12-21_vnstat-export-br0.json", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
00a6b23b-c6ee-4187-ac6c-5797bd5dc86a	2022-03-16 09:33:31.447058	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:33:30.419369", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 5, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is an XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:29:08.774119", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:29:08.778126", "datastore_active": false, "description": "This is an JSON file published by Leibniz University Hannover. ", "format": "JSON", "hash": "", "id": "e3e6e6ef-e356-4005-af2e-2e8538ed3f58", "last_modified": "2022-03-16T09:29:08.762912", "metadata_modified": "2022-03-16T09:30:52.523411", "mimetype": "application/json", "mimetype_inner": null, "name": "JSON Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 2, "resource_type": null, "size": 6211, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/e3e6e6ef-e356-4005-af2e-2e8538ed3f58/download/2017-12-21_vnstat-export-br0.json", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:30:52.528628", "datastore_active": false, "description": "This is an RDF file example generated from data published by Leibniz University Hannover. ", "format": "RDF", "hash": "", "id": "5a139ebc-3076-47a5-a7d5-9b3c6505dd9e", "last_modified": "2022-03-16T09:30:52.511290", "metadata_modified": "2022-03-16T09:33:30.422722", "mimetype": "application/rdf+xml", "mimetype_inner": null, "name": "RDF Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 3, "resource_type": null, "size": 6203, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/5a139ebc-3076-47a5-a7d5-9b3c6505dd9e/download/luh-beispiel-netzwerkmessdaten.rdf", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:33:30.427169", "datastore_active": false, "description": "This is a XLSX file published by Leibniz University Hannover. ", "format": "XLSX", "hash": "", "id": "05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43", "last_modified": "2022-03-16T09:33:30.410841", "metadata_modified": "2022-03-16T09:33:30.422895", "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "mimetype_inner": null, "name": "XLSX Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 4, "resource_type": null, "size": 32536, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43/download/jcdl-2019-dils-2019-papers-orkg-overview.xlsx", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
e34738b1-4027-431e-9259-4fbf73c6447d	2022-03-16 09:36:29.842669	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:36:28.618348", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is an XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:29:08.774119", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:29:08.778126", "datastore_active": false, "description": "This is an JSON file published by Leibniz University Hannover. ", "format": "JSON", "hash": "", "id": "e3e6e6ef-e356-4005-af2e-2e8538ed3f58", "last_modified": "2022-03-16T09:29:08.762912", "metadata_modified": "2022-03-16T09:30:52.523411", "mimetype": "application/json", "mimetype_inner": null, "name": "JSON Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 2, "resource_type": null, "size": 6211, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/e3e6e6ef-e356-4005-af2e-2e8538ed3f58/download/2017-12-21_vnstat-export-br0.json", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:30:52.528628", "datastore_active": false, "description": "This is an RDF file example generated from data published by Leibniz University Hannover. ", "format": "RDF", "hash": "", "id": "5a139ebc-3076-47a5-a7d5-9b3c6505dd9e", "last_modified": "2022-03-16T09:30:52.511290", "metadata_modified": "2022-03-16T09:33:30.422722", "mimetype": "application/rdf+xml", "mimetype_inner": null, "name": "RDF Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 3, "resource_type": null, "size": 6203, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/5a139ebc-3076-47a5-a7d5-9b3c6505dd9e/download/luh-beispiel-netzwerkmessdaten.rdf", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:33:30.427169", "datastore_active": false, "description": "This is a XLSX file published by Leibniz University Hannover. ", "format": "XLSX", "hash": "", "id": "05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43", "last_modified": "2022-03-16T09:33:30.410841", "metadata_modified": "2022-03-16T09:36:28.621650", "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "mimetype_inner": null, "name": "XLSX Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 4, "resource_type": null, "size": 32536, "state": "active", "url": "https://data.uni-hannover.de/dataset/feff84ea-89ec-4ce6-95fa-70060af298ac/resource/2a217dfd-b313-41fb-836f-de0ec6610569/download/jcdl-2019-dils-2019-papers-orkg-overview.xlsx", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:36:28.626475", "datastore_active": false, "description": "This is just an example file of the format for visualization.", "format": "ODS", "hash": "", "id": "047da174-2caa-45db-bc43-36fd3523ee30", "last_modified": null, "metadata_modified": "2022-03-16T09:36:28.621811", "mimetype": "application/vnd.oasis.opendocument.spreadsheet", "mimetype_inner": null, "name": "Open Document Spreadsheet (ODS) Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 5, "resource_type": null, "size": null, "state": "active", "url": "https://filesamples.com/samples/document/ods/sample1.ods", "url_type": null}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
4396eaad-a8fc-44eb-82a4-42a66ebea066	2022-03-16 09:37:22.967394	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:37:22.692407", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is a XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:37:22.695414", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:29:08.778126", "datastore_active": false, "description": "This is an JSON file published by Leibniz University Hannover. ", "format": "JSON", "hash": "", "id": "e3e6e6ef-e356-4005-af2e-2e8538ed3f58", "last_modified": "2022-03-16T09:29:08.762912", "metadata_modified": "2022-03-16T09:30:52.523411", "mimetype": "application/json", "mimetype_inner": null, "name": "JSON Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 2, "resource_type": null, "size": 6211, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/e3e6e6ef-e356-4005-af2e-2e8538ed3f58/download/2017-12-21_vnstat-export-br0.json", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:30:52.528628", "datastore_active": false, "description": "This is an RDF file example generated from data published by Leibniz University Hannover. ", "format": "RDF", "hash": "", "id": "5a139ebc-3076-47a5-a7d5-9b3c6505dd9e", "last_modified": "2022-03-16T09:30:52.511290", "metadata_modified": "2022-03-16T09:33:30.422722", "mimetype": "application/rdf+xml", "mimetype_inner": null, "name": "RDF Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 3, "resource_type": null, "size": 6203, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/5a139ebc-3076-47a5-a7d5-9b3c6505dd9e/download/luh-beispiel-netzwerkmessdaten.rdf", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:33:30.427169", "datastore_active": false, "description": "This is a XLSX file published by Leibniz University Hannover. ", "format": "XLSX", "hash": "", "id": "05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43", "last_modified": "2022-03-16T09:33:30.410841", "metadata_modified": "2022-03-16T09:36:28.621650", "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "mimetype_inner": null, "name": "XLSX Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 4, "resource_type": null, "size": 32536, "state": "active", "url": "https://data.uni-hannover.de/dataset/feff84ea-89ec-4ce6-95fa-70060af298ac/resource/2a217dfd-b313-41fb-836f-de0ec6610569/download/jcdl-2019-dils-2019-papers-orkg-overview.xlsx", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:36:28.626475", "datastore_active": false, "description": "This is just an example file of the format for visualization.", "format": "ODS", "hash": "", "id": "047da174-2caa-45db-bc43-36fd3523ee30", "last_modified": null, "metadata_modified": "2022-03-16T09:37:22.695859", "mimetype": "application/vnd.oasis.opendocument.spreadsheet", "mimetype_inner": null, "name": "Open Document Spreadsheet (ODS) Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 5, "resource_type": null, "size": null, "state": "active", "url": "https://filesamples.com/samples/document/ods/sample1.ods", "url_type": null}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
7c227298-152a-43e0-800d-72be415b71e3	2022-03-16 09:37:41.078566	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:37:40.832731", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is a XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:37:22.695414", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:29:08.778126", "datastore_active": false, "description": "This is a JSON file published by Leibniz University Hannover. ", "format": "JSON", "hash": "", "id": "e3e6e6ef-e356-4005-af2e-2e8538ed3f58", "last_modified": "2022-03-16T09:29:08.762912", "metadata_modified": "2022-03-16T09:37:40.835838", "mimetype": "application/json", "mimetype_inner": null, "name": "JSON Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 2, "resource_type": null, "size": 6211, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/e3e6e6ef-e356-4005-af2e-2e8538ed3f58/download/2017-12-21_vnstat-export-br0.json", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:30:52.528628", "datastore_active": false, "description": "This is an RDF file example generated from data published by Leibniz University Hannover. ", "format": "RDF", "hash": "", "id": "5a139ebc-3076-47a5-a7d5-9b3c6505dd9e", "last_modified": "2022-03-16T09:30:52.511290", "metadata_modified": "2022-03-16T09:33:30.422722", "mimetype": "application/rdf+xml", "mimetype_inner": null, "name": "RDF Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 3, "resource_type": null, "size": 6203, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/5a139ebc-3076-47a5-a7d5-9b3c6505dd9e/download/luh-beispiel-netzwerkmessdaten.rdf", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:33:30.427169", "datastore_active": false, "description": "This is a XLSX file published by Leibniz University Hannover. ", "format": "XLSX", "hash": "", "id": "05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43", "last_modified": "2022-03-16T09:33:30.410841", "metadata_modified": "2022-03-16T09:36:28.621650", "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "mimetype_inner": null, "name": "XLSX Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 4, "resource_type": null, "size": 32536, "state": "active", "url": "https://data.uni-hannover.de/dataset/feff84ea-89ec-4ce6-95fa-70060af298ac/resource/2a217dfd-b313-41fb-836f-de0ec6610569/download/jcdl-2019-dils-2019-papers-orkg-overview.xlsx", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:36:28.626475", "datastore_active": false, "description": "This is just an example file of the format for visualization.", "format": "ODS", "hash": "", "id": "047da174-2caa-45db-bc43-36fd3523ee30", "last_modified": null, "metadata_modified": "2022-03-16T09:37:22.695859", "mimetype": "application/vnd.oasis.opendocument.spreadsheet", "mimetype_inner": null, "name": "Open Document Spreadsheet (ODS) Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 5, "resource_type": null, "size": null, "state": "active", "url": "https://filesamples.com/samples/document/ods/sample1.ods", "url_type": null}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
69a57ae0-0caf-4bb0-8316-98b98bbcbe2d	2022-03-16 09:38:08.920143	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:38:08.538479", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 6, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is a XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:37:22.695414", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:29:08.778126", "datastore_active": false, "description": "This is a JSON file published by Leibniz University Hannover. ", "format": "JSON", "hash": "", "id": "e3e6e6ef-e356-4005-af2e-2e8538ed3f58", "last_modified": "2022-03-16T09:29:08.762912", "metadata_modified": "2022-03-16T09:37:40.835838", "mimetype": "application/json", "mimetype_inner": null, "name": "JSON Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 2, "resource_type": null, "size": 6211, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/e3e6e6ef-e356-4005-af2e-2e8538ed3f58/download/2017-12-21_vnstat-export-br0.json", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:30:52.528628", "datastore_active": false, "description": "This is a RDF file example generated from data published by Leibniz University Hannover. ", "format": "RDF", "hash": "", "id": "5a139ebc-3076-47a5-a7d5-9b3c6505dd9e", "last_modified": "2022-03-16T09:30:52.511290", "metadata_modified": "2022-03-16T09:38:08.541710", "mimetype": "application/rdf+xml", "mimetype_inner": null, "name": "RDF Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 3, "resource_type": null, "size": 6203, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/5a139ebc-3076-47a5-a7d5-9b3c6505dd9e/download/luh-beispiel-netzwerkmessdaten.rdf", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:33:30.427169", "datastore_active": false, "description": "This is a XLSX file published by Leibniz University Hannover. ", "format": "XLSX", "hash": "", "id": "05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43", "last_modified": "2022-03-16T09:33:30.410841", "metadata_modified": "2022-03-16T09:36:28.621650", "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "mimetype_inner": null, "name": "XLSX Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 4, "resource_type": null, "size": 32536, "state": "active", "url": "https://data.uni-hannover.de/dataset/feff84ea-89ec-4ce6-95fa-70060af298ac/resource/2a217dfd-b313-41fb-836f-de0ec6610569/download/jcdl-2019-dils-2019-papers-orkg-overview.xlsx", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:36:28.626475", "datastore_active": false, "description": "This is just an example file of the format for visualization.", "format": "ODS", "hash": "", "id": "047da174-2caa-45db-bc43-36fd3523ee30", "last_modified": null, "metadata_modified": "2022-03-16T09:37:22.695859", "mimetype": "application/vnd.oasis.opendocument.spreadsheet", "mimetype_inner": null, "name": "Open Document Spreadsheet (ODS) Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 5, "resource_type": null, "size": null, "state": "active", "url": "https://filesamples.com/samples/document/ods/sample1.ods", "url_type": null}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
6c63171f-88fb-4d16-be73-04930229560e	2022-03-16 09:43:34.466589	17755db4-395a-4b3b-ac09-e8e3484ca700	ed56c026-3d32-41d5-9d11-2aa655cb8052	\N	new package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "datasets_served_list": "", "id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:43:34.017574", "metadata_modified": "2022-03-16T09:43:34.017588", "name": "data-service-example-jupyternotebook", "notes": "This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. ", "num_resources": 0, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "draft", "title": "Data-Service example (JupyterNotebook)", "type": "service", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "d12eb6f2-7c84-4e70-b656-0b55b9689125", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "state": "active"}, "key": "", "value": ""}], "resources": [], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/bbqqpmll", "doi_status": false, "domain": "localhost:5000", "doi_date_published": null, "doi_publisher": "TIB"}, "actor": "admin"}
808a9b80-213c-4a0b-8b8e-851e2e799886	2022-03-16 09:22:41.242461	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:22:41.207806", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 1, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "draft", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:22:41.210600", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/fece58b1-1505-4ef0-befb-3f0edf59335d/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": false, "domain": "localhost:5000", "doi_date_published": null, "doi_publisher": "TIB"}, "actor": "admin"}
c6e8c7e7-1f68-41f7-b33d-e2a917c56ac9	2022-03-16 09:23:50.543797	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:23:48.598842", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 1, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
0048a9c4-9631-4bb6-b511-5c147792842e	2022-03-16 09:30:53.450001	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:30:52.518951", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 4, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is an XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:29:08.774119", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:29:08.778126", "datastore_active": false, "description": "This is an JSON file published by Leibniz University Hannover. ", "format": "JSON", "hash": "", "id": "e3e6e6ef-e356-4005-af2e-2e8538ed3f58", "last_modified": "2022-03-16T09:29:08.762912", "metadata_modified": "2022-03-16T09:30:52.523411", "mimetype": "application/json", "mimetype_inner": null, "name": "JSON Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 2, "resource_type": null, "size": 6211, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/e3e6e6ef-e356-4005-af2e-2e8538ed3f58/download/2017-12-21_vnstat-export-br0.json", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:30:52.528628", "datastore_active": false, "description": "This is an RDF file example generated from data published by Leibniz University Hannover. ", "format": "RDF", "hash": "", "id": "5a139ebc-3076-47a5-a7d5-9b3c6505dd9e", "last_modified": "2022-03-16T09:30:52.511290", "metadata_modified": "2022-03-16T09:30:52.523802", "mimetype": "application/rdf+xml", "mimetype_inner": null, "name": "RDF Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 3, "resource_type": null, "size": 6203, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/5a139ebc-3076-47a5-a7d5-9b3c6505dd9e/download/luh-beispiel-netzwerkmessdaten.rdf", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
e4397401-b64e-434f-a185-c8ab57708a38	2022-03-16 09:34:19.981547	17755db4-395a-4b3b-ac09-e8e3484ca700	d5d29173-addc-4e4d-af7b-59e3b147c817	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:17:57.266750", "metadata_modified": "2022-03-16T09:34:19.523816", "name": "example-data-formats-visualizations", "notes": "This is an example Dataset showing visualizations for data in different formats.", "num_resources": 5, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Example Data Formats Visualizations", "type": "dataset", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "c7742f16-7299-48b5-88d5-324f501dfdfb", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:22:41.213753", "datastore_active": false, "description": "All data are analysed and published 2020 under the title \\"Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella\\".\\r\\nThis dataset was published by Leibniz University Hannover.", "format": "CSV", "hash": "", "id": "fece58b1-1505-4ef0-befb-3f0edf59335d", "last_modified": "2022-03-16T09:22:41.200122", "metadata_modified": "2022-03-16T09:23:48.601689", "mimetype": "text/csv", "mimetype_inner": null, "name": "CSV Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 0, "resource_type": null, "size": 2017, "state": "active", "url": "https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:26:47.719119", "datastore_active": false, "description": "This is an XML file published by Leibniz University Hannover.", "format": "XML", "hash": "", "id": "1fb543eb-9980-494e-bd3b-26aa99bc06ef", "last_modified": "2022-03-16T09:26:47.705015", "metadata_modified": "2022-03-16T09:29:08.774119", "mimetype": "application/xml", "mimetype_inner": null, "name": "XML Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 1, "resource_type": null, "size": 9610, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/1fb543eb-9980-494e-bd3b-26aa99bc06ef/download/2017-12-21_vnstat-export-br0.xml", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:29:08.778126", "datastore_active": false, "description": "This is an JSON file published by Leibniz University Hannover. ", "format": "JSON", "hash": "", "id": "e3e6e6ef-e356-4005-af2e-2e8538ed3f58", "last_modified": "2022-03-16T09:29:08.762912", "metadata_modified": "2022-03-16T09:30:52.523411", "mimetype": "application/json", "mimetype_inner": null, "name": "JSON Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 2, "resource_type": null, "size": 6211, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/e3e6e6ef-e356-4005-af2e-2e8538ed3f58/download/2017-12-21_vnstat-export-br0.json", "url_type": "upload"}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:30:52.528628", "datastore_active": false, "description": "This is an RDF file example generated from data published by Leibniz University Hannover. ", "format": "RDF", "hash": "", "id": "5a139ebc-3076-47a5-a7d5-9b3c6505dd9e", "last_modified": "2022-03-16T09:30:52.511290", "metadata_modified": "2022-03-16T09:33:30.422722", "mimetype": "application/rdf+xml", "mimetype_inner": null, "name": "RDF Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 3, "resource_type": null, "size": 6203, "state": "active", "url": "http://localhost:5000/dataset/d5d29173-addc-4e4d-af7b-59e3b147c817/resource/5a139ebc-3076-47a5-a7d5-9b3c6505dd9e/download/luh-beispiel-netzwerkmessdaten.rdf", "url_type": "upload"}, {"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:33:30.427169", "datastore_active": false, "description": "This is a XLSX file published by Leibniz University Hannover. ", "format": "XLSX", "hash": "", "id": "05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43", "last_modified": "2022-03-16T09:33:30.410841", "metadata_modified": "2022-03-16T09:34:19.527113", "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "mimetype_inner": null, "name": "XLSX Data Example", "package_id": "d5d29173-addc-4e4d-af7b-59e3b147c817", "position": 4, "resource_type": null, "size": 32536, "state": "active", "url": "https://data.uni-hannover.de/dataset/feff84ea-89ec-4ce6-95fa-70060af298ac/resource/2a217dfd-b313-41fb-836f-de0ec6610569/download/jcdl-2019-dils-2019-papers-orkg-overview.xlsx", "url_type": ""}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/u1grwt6s", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
d146657a-2a6c-45a8-aedb-cf10ddd2453e	2022-03-16 09:47:36.705397	17755db4-395a-4b3b-ac09-e8e3484ca700	ed56c026-3d32-41d5-9d11-2aa655cb8052	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "datasets_served_list": "", "id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:43:34.017574", "metadata_modified": "2022-03-16T09:47:36.678429", "name": "data-service-example-jupyternotebook", "notes": "This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. ", "num_resources": 1, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "draft", "title": "Data-Service example (JupyterNotebook)", "type": "service", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "d12eb6f2-7c84-4e70-b656-0b55b9689125", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:47:36.683662", "datastore_active": false, "description": "This is a sample dataset for demonstration purposes.", "format": "CSV", "hash": "", "id": "4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7", "last_modified": "2022-03-16T09:47:36.672500", "metadata_modified": "2022-03-16T09:47:36.680958", "mimetype": "text/csv", "mimetype_inner": null, "name": "Cars data", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 0, "resource_type": null, "size": 1475504, "state": "active", "url": "http://localhost:5000/dataset/ed56c026-3d32-41d5-9d11-2aa655cb8052/resource/4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7/download/data.csv", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/bbqqpmll", "doi_status": false, "domain": "localhost:5000", "doi_date_published": null, "doi_publisher": "TIB"}, "actor": "admin"}
8fb25fea-4d26-43df-b841-7ed245958e03	2022-03-16 09:51:38.606626	17755db4-395a-4b3b-ac09-e8e3484ca700	ed56c026-3d32-41d5-9d11-2aa655cb8052	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "datasets_served_list": "", "id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:43:34.017574", "metadata_modified": "2022-03-16T09:51:37.717123", "name": "data-service-example-jupyternotebook", "notes": "This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. ", "num_resources": 2, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Data-Service example (JupyterNotebook)", "type": "service", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "d12eb6f2-7c84-4e70-b656-0b55b9689125", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:47:36.683662", "datastore_active": false, "description": "This is a sample dataset for demonstration purposes.", "format": "CSV", "hash": "", "id": "4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7", "last_modified": "2022-03-16T09:47:36.672500", "metadata_modified": "2022-03-16T09:48:33.163961", "mimetype": "text/csv", "mimetype_inner": null, "name": "Cars data", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 0, "resource_type": null, "size": 1475504, "state": "active", "url": "https://service.tib.eu/ldmservice/dataset/672f2339-c57f-48f5-a681-b62acc50f488/resource/22312cbf-7a7a-4510-88b5-8a1a828f3064/download/data.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:50:33.036016", "datastore_active": false, "description": "This jupyter notebook runs live code over the cars.cvd data present in the same dataset.", "format": "ipybn", "hash": "", "id": "5c653296-8877-42f4-9dee-84de4784dcca", "last_modified": "2022-03-16T09:50:33.020919", "metadata_modified": "2022-03-16T09:51:37.720076", "mimetype": null, "mimetype_inner": null, "name": "Exploratory Data Analisys of Cars", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 1, "resource_type": null, "size": 199131, "state": "active", "url": "http://localhost:5000/dataset/ed56c026-3d32-41d5-9d11-2aa655cb8052/resource/5c653296-8877-42f4-9dee-84de4784dcca/download/exploratory_data_analysis.ipynb", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/bbqqpmll", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
8f9858eb-7d76-44c6-8e46-7c7b9a3c8daf	2022-03-16 09:52:17.456289	17755db4-395a-4b3b-ac09-e8e3484ca700	ed56c026-3d32-41d5-9d11-2aa655cb8052	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "datasets_served_list": "", "id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:43:34.017574", "metadata_modified": "2022-03-16T09:52:16.207230", "name": "data-service-example-jupyternotebook", "notes": "This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. ", "num_resources": 2, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Data-Service example (JupyterNotebook)", "type": "service", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "d12eb6f2-7c84-4e70-b656-0b55b9689125", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:47:36.683662", "datastore_active": false, "description": "This is a sample dataset for demonstration purposes.", "format": "CSV", "hash": "", "id": "4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7", "last_modified": "2022-03-16T09:47:36.672500", "metadata_modified": "2022-03-16T09:48:33.163961", "mimetype": "text/csv", "mimetype_inner": null, "name": "Cars data", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 0, "resource_type": null, "size": 1475504, "state": "active", "url": "https://service.tib.eu/ldmservice/dataset/672f2339-c57f-48f5-a681-b62acc50f488/resource/22312cbf-7a7a-4510-88b5-8a1a828f3064/download/data.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:50:33.036016", "datastore_active": false, "description": "This jupyter notebook runs live code over the cars.cvd data present in the same dataset.", "format": "ipynb", "hash": "", "id": "5c653296-8877-42f4-9dee-84de4784dcca", "last_modified": "2022-03-16T09:50:33.020919", "metadata_modified": "2022-03-16T09:52:16.210277", "mimetype": null, "mimetype_inner": null, "name": "Exploratory Data Analisys of Cars", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 1, "resource_type": null, "size": 199131, "state": "active", "url": "http://localhost:5000/dataset/ed56c026-3d32-41d5-9d11-2aa655cb8052/resource/5c653296-8877-42f4-9dee-84de4784dcca/download/exploratory_data_analysis.ipynb", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/bbqqpmll", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
d71a1af4-7ad0-4800-b485-85bbb3752306	2022-03-16 09:57:09.920277	17755db4-395a-4b3b-ac09-e8e3484ca700	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	\N	deleted package	{"package": {"author": "", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-11-24T13:36:15.887852", "metadata_modified": "2021-03-03T10:14:21.513141", "name": "example-cad-2", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "num_resources": 1, "num_tags": 5, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Pangaea CAD files", "type": "dataset", "url": "", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-11-24T13:37:06.599034", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "0ce74f0d-bf35-4627-9f69-92d5c1150dff", "last_modified": "2017-12-01T16:50:37.896845", "metadata_modified": null, "mimetype": "application/zip", "mimetype_inner": null, "name": "Example .dwg file", "package_id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "position": 0, "resource_type": null, "size": 3414733, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/gkg_steel_zinced.zip", "url_type": ""}], "tags": [{"display_name": "2D", "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D", "state": "active", "vocabulary_id": null}, {"display_name": "3D", "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D", "state": "active", "vocabulary_id": null}, {"display_name": "CAD", "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD", "state": "active", "vocabulary_id": null}, {"display_name": "example", "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example", "state": "active", "vocabulary_id": null}, {"display_name": "pangaea", "id": "816b2a52-8852-4298-803f-f34556cae9e0", "name": "pangaea", "state": "active", "vocabulary_id": null}], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
89a94267-5dfc-430e-8e8f-d6ce8ab01259	2022-03-16 09:47:38.258482	17755db4-395a-4b3b-ac09-e8e3484ca700	ed56c026-3d32-41d5-9d11-2aa655cb8052	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "datasets_served_list": "", "id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:43:34.017574", "metadata_modified": "2022-03-16T09:47:36.936909", "name": "data-service-example-jupyternotebook", "notes": "This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. ", "num_resources": 1, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Data-Service example (JupyterNotebook)", "type": "service", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "d12eb6f2-7c84-4e70-b656-0b55b9689125", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "state": "active"}, "key": "", "value": ""}], "resources": [{"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:47:36.683662", "datastore_active": false, "description": "This is a sample dataset for demonstration purposes.", "format": "CSV", "hash": "", "id": "4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7", "last_modified": "2022-03-16T09:47:36.672500", "metadata_modified": "2022-03-16T09:47:36.941618", "mimetype": "text/csv", "mimetype_inner": null, "name": "Cars data", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 0, "resource_type": null, "size": 1475504, "state": "active", "url": "http://localhost:5000/dataset/ed56c026-3d32-41d5-9d11-2aa655cb8052/resource/4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7/download/data.csv", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/bbqqpmll", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
65155b95-8537-43ca-9b0c-ac644919441f	2022-03-16 09:48:34.26916	17755db4-395a-4b3b-ac09-e8e3484ca700	ed56c026-3d32-41d5-9d11-2aa655cb8052	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "datasets_served_list": "", "id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:43:34.017574", "metadata_modified": "2022-03-16T09:48:33.161082", "name": "data-service-example-jupyternotebook", "notes": "This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. ", "num_resources": 1, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Data-Service example (JupyterNotebook)", "type": "service", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "d12eb6f2-7c84-4e70-b656-0b55b9689125", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:47:36.683662", "datastore_active": false, "description": "This is a sample dataset for demonstration purposes.", "format": "CSV", "hash": "", "id": "4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7", "last_modified": "2022-03-16T09:47:36.672500", "metadata_modified": "2022-03-16T09:48:33.163961", "mimetype": "text/csv", "mimetype_inner": null, "name": "Cars data", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 0, "resource_type": null, "size": 1475504, "state": "active", "url": "https://service.tib.eu/ldmservice/dataset/672f2339-c57f-48f5-a681-b62acc50f488/resource/22312cbf-7a7a-4510-88b5-8a1a828f3064/download/data.csv", "url_type": ""}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/bbqqpmll", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
9922b0ff-56e6-4022-a8b7-75d1d5aeddb9	2022-03-16 09:50:33.931048	17755db4-395a-4b3b-ac09-e8e3484ca700	ed56c026-3d32-41d5-9d11-2aa655cb8052	\N	changed package	{"package": {"author": "John Doe", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "datasets_served_list": "", "id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "isopen": false, "license_id": "notspecified", "license_title": "License not specified", "maintainer": "", "maintainer_email": "", "metadata_created": "2022-03-16T09:43:34.017574", "metadata_modified": "2022-03-16T09:50:33.028357", "name": "data-service-example-jupyternotebook", "notes": "This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. ", "num_resources": 2, "num_tags": 0, "orcid": "", "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "state": "active", "title": "Data-Service example (JupyterNotebook)", "type": "service", "url": "", "version": "", "extra_authors": [{"extra_author": "", "orcid": ""}], "extras": [{"__extras": {"id": "d12eb6f2-7c84-4e70-b656-0b55b9689125", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "state": "active"}, "key": "", "value": ""}], "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:47:36.683662", "datastore_active": false, "description": "This is a sample dataset for demonstration purposes.", "format": "CSV", "hash": "", "id": "4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7", "last_modified": "2022-03-16T09:47:36.672500", "metadata_modified": "2022-03-16T09:48:33.163961", "mimetype": "text/csv", "mimetype_inner": null, "name": "Cars data", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 0, "resource_type": null, "size": 1475504, "state": "active", "url": "https://service.tib.eu/ldmservice/dataset/672f2339-c57f-48f5-a681-b62acc50f488/resource/22312cbf-7a7a-4510-88b5-8a1a828f3064/download/data.csv", "url_type": ""}, {"auto_update": "No", "auto_update_url": "", "cache_last_updated": null, "cache_url": null, "created": "2022-03-16T09:50:33.036016", "datastore_active": false, "description": "This jupyter notebook runs live code over the cars.cvd data present in the same dataset.", "format": "", "hash": "", "id": "5c653296-8877-42f4-9dee-84de4784dcca", "last_modified": "2022-03-16T09:50:33.020919", "metadata_modified": "2022-03-16T09:50:33.031316", "mimetype": null, "mimetype_inner": null, "name": "Exploratory Data Analisys of Cars", "package_id": "ed56c026-3d32-41d5-9d11-2aa655cb8052", "position": 1, "resource_type": null, "size": 199131, "state": "active", "url": "http://localhost:5000/dataset/ed56c026-3d32-41d5-9d11-2aa655cb8052/resource/5c653296-8877-42f4-9dee-84de4784dcca/download/exploratory_data_analysis.ipynb", "url_type": "upload"}], "tags": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": [], "doi": "10.23680/bbqqpmll", "doi_status": true, "domain": "localhost:5000", "doi_date_published": "2022-03-16", "doi_publisher": "TIB"}, "actor": "admin"}
cb0c83ad-61d5-4513-9922-87e4b04bb45e	2022-03-16 09:57:31.771203	17755db4-395a-4b3b-ac09-e8e3484ca700	1abefb2e-6a83-4004-b7db-74c34b545d2e	\N	deleted package	{"package": {"author": "Lorena A. Barba", "author_email": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "isopen": true, "license_id": "cc-by", "license_title": "Creative Commons Attribution", "license_url": "http://www.opendefinition.org/licenses/cc-by", "maintainer": "", "maintainer_email": "", "metadata_created": "2017-12-01T12:51:12.218503", "metadata_modified": "2021-03-03T10:11:48.942065", "name": "jupyter-notebooks", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "num_resources": 5, "num_tags": 5, "organization": {"id": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "name": "tib", "title": "TIB", "type": "organization", "description": "The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.", "image_url": "https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png", "created": "2017-11-23T17:30:37.757128", "is_organization": true, "approval_status": "approved", "state": "active"}, "owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "private": false, "services_used_list": "", "state": "active", "title": "Jupyter notebooks", "type": "dataset", "url": "https://unidata.github.io/online-python-training/introduction.html", "version": "", "resources": [{"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:51:28.891625", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "last_modified": "2017-12-01T16:47:34.233655", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Example Machine Learning notebook", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 0, "resource_type": null, "size": 703819, "state": "active", "url": "https://raw.githubusercontent.com/guillermobet/files/master/Example%20Machine%20Learning%20Notebook.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:54:05.127144", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "last_modified": "2017-12-01T16:47:43.266081", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Labeled Faces in the Wild recognition", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 1, "resource_type": null, "size": 717993, "state": "active", "url": "https://raw.githubusercontent.com/ogrisel/notebooks/master/Labeled%2520Faces%2520in%2520the%2520Wild%2520recognition.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:55:06.673960", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "last_modified": "2017-12-01T16:47:54.872809", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "Satellite example", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 2, "resource_type": null, "size": 7216, "state": "active", "url": "http://unidata.github.io/python-gallery/_downloads/Satellite_Example.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:56:06.860736", "datastore_active": false, "description": "", "format": "", "hash": "", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "last_modified": "2017-12-01T16:48:04.508028", "metadata_modified": null, "mimetype": null, "mimetype_inner": null, "name": "GW150914 tutorial", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 3, "resource_type": null, "size": 2683661, "state": "active", "url": "https://losc.ligo.org/s/events/GW150914/GW150914_tutorial.ipynb", "url_type": ""}, {"cache_last_updated": null, "cache_url": null, "created": "2017-12-01T12:58:35.877330", "datastore_active": false, "description": "", "format": "TAR", "hash": "", "id": "ec1c5422-b8ab-4401-96fb-0792dacb8e40", "last_modified": "2017-12-01T16:48:21.527146", "metadata_modified": null, "mimetype": "application/x-tar", "mimetype_inner": null, "name": "12 steps to Navier-Stokes", "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "position": 4, "resource_type": null, "size": 5708395, "state": "active", "url": "https://github.com/guillermobet/files/raw/master/12%20steps%20to%20Navier-Stokes.tar.gz", "url_type": ""}], "tags": [{"display_name": "computer vision", "id": "f650b4e3-9955-49b0-ba7b-2d302a990978", "name": "computer vision", "state": "active", "vocabulary_id": null}, {"display_name": "imagery analysis", "id": "5581fcb2-a2b7-41aa-aa4e-822d8837fcfe", "name": "imagery analysis", "state": "active", "vocabulary_id": null}, {"display_name": "jupyter notebook", "id": "e2bb9482-6eb5-43c3-b14e-903c519d5e38", "name": "jupyter notebook", "state": "active", "vocabulary_id": null}, {"display_name": "machine learning", "id": "9e42784b-6ee7-47e8-a69a-28b8c510212b", "name": "machine learning", "state": "active", "vocabulary_id": null}, {"display_name": "satellite", "id": "c3ea41c3-899c-4b54-a4f4-caa50617b956", "name": "satellite", "state": "active", "vocabulary_id": null}], "extras": [], "groups": [], "relationships_as_subject": [], "relationships_as_object": []}, "actor": "admin"}
\.


--
-- Data for Name: activity_detail; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.activity_detail (id, activity_id, object_id, object_type, activity_type, data) FROM stdin;
3896ce97-a020-4edf-994e-396ec9113952	79cd60d9-b153-4584-8e8b-c2418b824b01	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	Package	new	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:26.707978", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "2b61e1eb-c56d-4852-b55c-47f0e7308c6e", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
13b8a5ff-9afa-4a92-87da-36bcd370d12a	79cd60d9-b153-4584-8e8b-c2418b824b01	7e0928b6-a479-4718-98fe-b18d8f63ae0f	tag	added	{"tag": {"vocabulary_id": null, "id": "013c0ce4-51f9-4946-94e3-8e8713360f16", "name": "users"}, "package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:26.707978", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "2b61e1eb-c56d-4852-b55c-47f0e7308c6e", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
3b752c99-214a-45ac-b65e-39263826340a	79cd60d9-b153-4584-8e8b-c2418b824b01	8a55bb6b-dc69-4622-a3fc-5bef515beac2	tag	added	{"tag": {"vocabulary_id": null, "id": "5564f2e8-9c79-4125-a2a8-077f38a246ef", "name": "event"}, "package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:26.707978", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "2b61e1eb-c56d-4852-b55c-47f0e7308c6e", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
a24e230f-d6ce-46bb-be5c-4b7e21eaa47b	ee660257-e306-4c18-adb7-721940032324	a42f0a61-e0de-4cf6-add8-4fe21c29676a	Resource	new	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "Gathered during the year 2017", "format": "CSV", "url": "http://download1815.mediafireuserdownload.com/edzj903mi86g/30c6acs902ing3x/samplespacelocationtrack.csv", "created": "2017-08-08T16:50:49.635222", "extras": {}, "cache_last_updated": null, "package_id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "3d4c3cf2-2604-49a3-b846-bcfca91c4b22", "size": null, "url_type": null, "id": "a42f0a61-e0de-4cf6-add8-4fe21c29676a", "resource_type": null, "name": "Data 2017"}}
b91befbc-a55f-4fdc-b8e6-93b873a8e914	c2459c06-478a-4893-98c9-c2bc1c9d8045	a42f0a61-e0de-4cf6-add8-4fe21c29676a	Resource	changed	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "Gathered during the year 2017", "format": "CSV", "url": "http://download1815.mediafireuserdownload.com/edzj903mi86g/30c6acs902ing3x/samplespacelocationtrack.csv", "created": "2017-08-08T16:50:49.635222", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "bffaa2dd-7e21-45e1-9c62-336b10a1381d", "size": null, "url_type": null, "id": "a42f0a61-e0de-4cf6-add8-4fe21c29676a", "resource_type": null, "name": "Data 2017"}}
3331e737-1b5d-4623-9f93-4693f46d11f4	c2459c06-478a-4893-98c9-c2bc1c9d8045	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	Package	changed	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:50.837755", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "bffaa2dd-7e21-45e1-9c62-336b10a1381d", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
eb2d8c09-31e1-4e51-a8bd-705f3a1641c1	d5c7c2f1-11ba-40e7-a9cf-387cfbe4f9da	903d964e-9c2c-47d2-8708-25363ef8d772	Package	new	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "services-information", "metadata_modified": "2017-08-08T16:52:29.614984", "author": "", "url": "", "notes": "Several services offered in our company", "title": "Services information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "65a08933-48aa-426b-bf8a-d11aa32dca95", "type": "dataset", "id": "903d964e-9c2c-47d2-8708-25363ef8d772", "metadata_created": "2017-08-08T16:52:29.614969"}}
0a685b5a-b1a4-478c-b492-5e5fa5c4f793	d5c7c2f1-11ba-40e7-a9cf-387cfbe4f9da	71bb7993-7b91-446a-a653-54b5543de071	tag	added	{"tag": {"vocabulary_id": null, "id": "cd8f07aa-76ab-4a1a-9567-ba2b7b19779b", "name": "services"}, "package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "services-information", "metadata_modified": "2017-08-08T16:52:29.614984", "author": "", "url": "", "notes": "Several services offered in our company", "title": "Services information", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "65a08933-48aa-426b-bf8a-d11aa32dca95", "type": "dataset", "id": "903d964e-9c2c-47d2-8708-25363ef8d772", "metadata_created": "2017-08-08T16:52:29.614969"}}
2200c786-fc71-4175-a74d-f07b7614c7e2	3e8e8301-501f-4e6f-9b5e-5ba0b4b47767	3c5d05d9-773a-4f1e-a4e8-59bb4bef00b3	Resource	new	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "Latest information of our services", "format": "CSV", "url": "http://download1640.mediafireuserdownload.com/hf6n735anfwg/k151xmpos9ojip9/samplespacenetfavor.csv", "created": "2017-08-08T16:52:48.427175", "extras": {}, "cache_last_updated": null, "package_id": "903d964e-9c2c-47d2-8708-25363ef8d772", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "15c99021-e05b-4678-b035-a1e8203dd9e1", "size": null, "url_type": null, "id": "3c5d05d9-773a-4f1e-a4e8-59bb4bef00b3", "resource_type": null, "name": "Latest"}}
cbffc7f4-fe55-4f8d-962c-5f690c006b86	ab5731ed-4566-4d86-a364-e1c8a3c7b6eb	4ee0ec1c-c72b-4bad-be73-364a735cea5c	Resource	new	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://autode.sk/2zsNALP", "created": "2017-11-23T17:37:19.897441", "extras": {}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "469f7ad0-8cce-4220-8859-7f640494206b", "size": null, "url_type": null, "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "resource_type": null, "name": "Example .dwg file"}}
e106735a-d0df-4643-89e8-c680ed2a8187	8d57bc35-165b-455c-bce7-202977427302	3c5d05d9-773a-4f1e-a4e8-59bb4bef00b3	Resource	changed	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "Latest information of our services", "format": "CSV", "url": "http://download1640.mediafireuserdownload.com/hf6n735anfwg/k151xmpos9ojip9/samplespacenetfavor.csv", "created": "2017-08-08T16:52:48.427175", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "903d964e-9c2c-47d2-8708-25363ef8d772", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "ba506755-adf8-4f97-bf70-90355c658dd7", "size": null, "url_type": null, "id": "3c5d05d9-773a-4f1e-a4e8-59bb4bef00b3", "resource_type": null, "name": "Latest"}}
d9b61d82-e47e-47fe-bbcc-9f842c003ecc	8d57bc35-165b-455c-bce7-202977427302	903d964e-9c2c-47d2-8708-25363ef8d772	Package	changed	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "services-information", "metadata_modified": "2017-08-08T16:52:49.648987", "author": "", "url": "", "notes": "Several services offered in our company", "title": "Services information", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "ba506755-adf8-4f97-bf70-90355c658dd7", "type": "dataset", "id": "903d964e-9c2c-47d2-8708-25363ef8d772", "metadata_created": "2017-08-08T16:52:29.614969"}}
a8263b58-533c-40c0-a18d-a4df5448ed58	856541dc-535f-4a05-aa53-6173b63b6c80	817668d7-be70-479e-92c6-c7e4e8182603	Package	new	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:54:35.136352", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "8b393d77-16b0-4e7c-b64e-63acf71345d5", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
57ecacf2-34e1-48e0-ac5f-0593fc560a70	856541dc-535f-4a05-aa53-6173b63b6c80	b0c0609f-0cd5-43b9-9e76-6fcab0907ecb	tag	added	{"tag": {"vocabulary_id": null, "id": "8c8c1220-8129-4a02-bd2f-8e9b6529c212", "name": "internet"}, "package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:54:35.136352", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "8b393d77-16b0-4e7c-b64e-63acf71345d5", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
5f431691-fb26-4ab0-b9b6-1cad9944aa00	856541dc-535f-4a05-aa53-6173b63b6c80	2b65bccf-ad8a-4ddd-86b6-65587312f176	tag	added	{"tag": {"vocabulary_id": null, "id": "a81cb4bd-b2c8-4fc9-9682-9be570d13072", "name": "dsl"}, "package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:54:35.136352", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "8b393d77-16b0-4e7c-b64e-63acf71345d5", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
258d52b6-f597-443d-95cb-40b7a0c818e9	977f7a94-cd3c-4284-9260-cd73d8b5ecc9	0b15b724-fe12-49c9-9b17-e114c025af24	Resource	new	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "Dataset with information from September 2018 to October 2018", "format": "CSV", "url": "http://download2230.mediafireuserdownload.com/gsxn969vw0mg/3h6uup3epq8sb70/samplespacenormalfeature.csv", "created": "2017-08-08T16:55:27.286294", "extras": {}, "cache_last_updated": null, "package_id": "817668d7-be70-479e-92c6-c7e4e8182603", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "4537cbb8-b49b-4611-9721-a775af0095fe", "size": null, "url_type": null, "id": "0b15b724-fe12-49c9-9b17-e114c025af24", "resource_type": null, "name": "SEPT - OCT 2018"}}
b5273d65-0b93-4f6f-8033-637336602765	a2db6a75-ed2e-40cf-8ec5-0a54cea6b228	817668d7-be70-479e-92c6-c7e4e8182603	Package	changed	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:55:28.497851", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "d2a0b75b-4856-4b6c-affc-729a99bbe985", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
483c0184-02ef-41a7-b57e-506f2ef1608f	a2db6a75-ed2e-40cf-8ec5-0a54cea6b228	0b15b724-fe12-49c9-9b17-e114c025af24	Resource	changed	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "Dataset with information from September 2018 to October 2018", "format": "CSV", "url": "http://download2230.mediafireuserdownload.com/gsxn969vw0mg/3h6uup3epq8sb70/samplespacenormalfeature.csv", "created": "2017-08-08T16:55:27.286294", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "817668d7-be70-479e-92c6-c7e4e8182603", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "d2a0b75b-4856-4b6c-affc-729a99bbe985", "size": null, "url_type": null, "id": "0b15b724-fe12-49c9-9b17-e114c025af24", "resource_type": null, "name": "SEPT - OCT 2018"}}
2b0da495-03cb-4a55-8c42-136a09da53e9	92ab1224-9afe-422a-9a03-5337c6805189	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	Package	new	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-08T16:57:30.243013", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "dd70f0dc-ac9d-4ea3-8888-ddb077b44502", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
678f6811-1274-4347-ab41-700da5133cc3	92ab1224-9afe-422a-9a03-5337c6805189	be82423d-7268-44af-8a1e-b9b47ff9480e	tag	added	{"tag": {"vocabulary_id": null, "id": "0f6bdfbd-7412-4e5c-a788-c5fec06b5dd8", "name": "mobile"}, "package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-08T16:57:30.243013", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "dd70f0dc-ac9d-4ea3-8888-ddb077b44502", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
e9205015-581f-4a4f-9b9c-676e9f3cb66c	92ab1224-9afe-422a-9a03-5337c6805189	5ff6ca59-1110-4e7c-a81f-41ea212eab2c	tag	added	{"tag": {"vocabulary_id": null, "id": "69a1e7a9-0a51-4267-9fb3-db0642f03959", "name": "4g"}, "package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-08T16:57:30.243013", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "dd70f0dc-ac9d-4ea3-8888-ddb077b44502", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
fb2e9499-dd5e-4835-ae35-e4dafd3fb1ab	0fd4c8b8-6bee-4b9b-a0ee-d17059501409	16f7cc6d-3d97-4072-836b-b5180ed980b5	Resource	new	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "CSV", "url": "http://download2158.mediafireuserdownload.com/e7sovkb1y3qg/6l4o6lv85foucxo/samplespaceproductreq.csv", "created": "2017-08-08T16:57:41.840862", "extras": {}, "cache_last_updated": null, "package_id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "1815b63f-6afc-43d0-aac9-d8a9daec8f93", "size": null, "url_type": null, "id": "16f7cc6d-3d97-4072-836b-b5180ed980b5", "resource_type": null, "name": "Mobile 001"}}
249a7b8d-6b97-4b4f-9423-8f70979eab10	667f1e21-dd0f-4c38-896b-81c6a3f80682	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	Package	changed	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-08T16:57:43.112965", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "18ca3b06-e9d5-4129-b12c-1eacc9c8de32", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
ab65dd11-f1da-4ac8-a779-056751ce6f7a	667f1e21-dd0f-4c38-896b-81c6a3f80682	16f7cc6d-3d97-4072-836b-b5180ed980b5	Resource	changed	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "CSV", "url": "http://download2158.mediafireuserdownload.com/e7sovkb1y3qg/6l4o6lv85foucxo/samplespaceproductreq.csv", "created": "2017-08-08T16:57:41.840862", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "18ca3b06-e9d5-4129-b12c-1eacc9c8de32", "size": null, "url_type": null, "id": "16f7cc6d-3d97-4072-836b-b5180ed980b5", "resource_type": null, "name": "Mobile 001"}}
8101ae04-27f8-485f-9405-b372a644b14d	af4d03ce-89ab-4aee-bf36-2180e3a461a2	16f7cc6d-3d97-4072-836b-b5180ed980b5	Resource	changed	{"resource": {"mimetype": "text/csv", "cache_url": null, "state": "active", "hash": "", "description": "Description of mobile phone users", "format": "CSV", "url": "http://download2158.mediafireuserdownload.com/e7sovkb1y3qg/6l4o6lv85foucxo/samplespaceproductreq.csv", "created": "2017-08-08T16:57:41.840862", "extras": {"datastore_active": true}, "cache_last_updated": null, "package_id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "9280682a-0335-4e81-85d6-52933a06e3c9", "size": null, "url_type": null, "id": "16f7cc6d-3d97-4072-836b-b5180ed980b5", "resource_type": null, "name": "Mobile 001"}}
d527fd00-f4d3-45aa-a5f4-e13314fb5607	95939c34-a48c-4b67-845b-034d3c67bf17	54f83106-f2bf-45a8-8523-53a415c99e47	Package	new	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:07:42.009865", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "1d7a208f-a535-4f6d-ad3c-18d8c9866feb", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
063feaba-c3f6-4c03-8a55-e1f224b3944c	29dde80c-6d54-45d6-b46c-513673c9592b	a011526b-bd2f-4f0b-ad32-fbcc419c1814	Resource	new	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "earth_zoom_in.mp4", "created": "2017-11-23T17:07:50.654379", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:07:50.637397", "position": 0, "revision_id": "d74a18d9-14a3-40a4-b848-d1d9148e2102", "size": 8399839, "url_type": "upload", "id": "a011526b-bd2f-4f0b-ad32-fbcc419c1814", "resource_type": null, "name": "aaaaa"}}
04e67fc2-30e6-480a-8abb-35e168d2baf8	fcdef847-909e-438e-bdf4-a31cdaf1f4c3	a011526b-bd2f-4f0b-ad32-fbcc419c1814	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "http://192.76.241.143:5000/dataset/54f83106-f2bf-45a8-8523-53a415c99e47/resource/a011526b-bd2f-4f0b-ad32-fbcc419c1814/download/earth_zoom_in.mp4", "created": "2017-11-23T17:07:50.654379", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:07:50.637397", "position": 0, "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "size": 8399839, "url_type": "upload", "id": "a011526b-bd2f-4f0b-ad32-fbcc419c1814", "resource_type": null, "name": "aaaaa"}}
6c214eee-d31c-4fd3-87b3-d900f4e18c9e	fcdef847-909e-438e-bdf4-a31cdaf1f4c3	54f83106-f2bf-45a8-8523-53a415c99e47	Package	changed	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:07:50.816957", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "76a15254-7ed3-4c64-94e0-4c93fd886a70", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
d36a8e1e-9a59-4681-b3f4-4d3f18a994f8	f1caf191-27d6-4fa1-9514-f5182198c9cb	a011526b-bd2f-4f0b-ad32-fbcc419c1814	Resource	deleted	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "deleted", "hash": "", "description": "", "format": "video/mp4", "url": "http://192.76.241.143:5000/dataset/54f83106-f2bf-45a8-8523-53a415c99e47/resource/a011526b-bd2f-4f0b-ad32-fbcc419c1814/download/earth_zoom_in.mp4", "created": "2017-11-23T17:07:50.654379", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:07:50.637397", "position": 0, "revision_id": "61558a1e-8f38-4eea-be11-4831ab21f9ab", "size": 8399839, "url_type": "upload", "id": "a011526b-bd2f-4f0b-ad32-fbcc419c1814", "resource_type": null, "name": "aaaaa"}}
d3f3456c-a203-430d-9bcd-786ce8ff8ebb	5427f274-8abe-4927-8d90-6c7dcd9fcb53	79820f1e-1f3d-4254-977a-860af37e456e	Resource	new	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "earth_zoom_in.mp4", "created": "2017-11-23T17:11:23.965466", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:11:23.949866", "position": 0, "revision_id": "4609ef6f-b90f-49f1-aef7-0381acb539ba", "size": 8399839, "url_type": "upload", "id": "79820f1e-1f3d-4254-977a-860af37e456e", "resource_type": null, "name": "ssfdfsfsd"}}
fafd2754-7960-4d29-adc3-dc8c38303872	b33f9a10-c386-4940-930a-6ff16982dccc	79820f1e-1f3d-4254-977a-860af37e456e	Resource	deleted	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "deleted", "hash": "", "description": "", "format": "video/mp4", "url": "earth_zoom_in.mp4", "created": "2017-11-23T17:11:23.965466", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:11:23.949866", "position": 0, "revision_id": "b832bb18-8732-45d7-858a-97f2a9f85006", "size": 8399839, "url_type": "upload", "id": "79820f1e-1f3d-4254-977a-860af37e456e", "resource_type": null, "name": "ssfdfsfsd"}}
ef611087-0efb-4fac-9956-dacefc2df9bb	c0ec79c3-71cf-4dc0-a210-6fd6433196c2	fea700ad-7abb-4dc9-8219-ec94e7d7f505	Resource	new	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "sadasd", "format": "video/mp4", "url": "earth_zoom_in.mp4", "created": "2017-11-23T17:13:31.399555", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:13:31.382671", "position": 0, "revision_id": "c84a2f2b-7aae-4ce0-9746-ed5ff839a497", "size": 8399839, "url_type": "upload", "id": "fea700ad-7abb-4dc9-8219-ec94e7d7f505", "resource_type": null, "name": "sdffsdfsd"}}
96dc7e22-0fbb-4a77-aa7d-adc8a4ab260e	3f35f708-51ee-4aeb-a4a1-20ca344c80fb	c49a76a9-4a48-4785-994e-9c991b32946e	Resource	new	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "", "created": "2017-11-23T17:15:23.485571", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": null, "position": 1, "revision_id": "be62d02b-aac3-4fa9-adda-5f7055efe684", "size": null, "url_type": null, "id": "c49a76a9-4a48-4785-994e-9c991b32946e", "resource_type": null, "name": "PRUEBAS"}}
42042033-5501-4a6e-b091-146ebea379c8	3f35f708-51ee-4aeb-a4a1-20ca344c80fb	fea700ad-7abb-4dc9-8219-ec94e7d7f505	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "sadasd", "format": "video/mp4", "url": "http://192.76.241.143:5000/dataset/54f83106-f2bf-45a8-8523-53a415c99e47/resource/fea700ad-7abb-4dc9-8219-ec94e7d7f505/download/earth_zoom_in.mp4", "created": "2017-11-23T17:13:31.399555", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:13:31.382671", "position": 0, "revision_id": "be62d02b-aac3-4fa9-adda-5f7055efe684", "size": 8399839, "url_type": "upload", "id": "fea700ad-7abb-4dc9-8219-ec94e7d7f505", "resource_type": null, "name": "sdffsdfsd"}}
59fb1905-52d9-4ef9-9e78-2d34b1aeaeac	6cfd936e-6149-4354-96a6-b1686928340c	c49a76a9-4a48-4785-994e-9c991b32946e	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "", "created": "2017-11-23T17:15:23.485571", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": null, "position": 1, "revision_id": "54de6fec-f172-4558-8292-950fa99f513a", "size": null, "url_type": null, "id": "c49a76a9-4a48-4785-994e-9c991b32946e", "resource_type": null, "name": "PRUEBAS"}}
fd216be9-06eb-404a-822c-926389955cde	8de8fc21-e9ab-4170-83b4-cedda5daf96c	c49a76a9-4a48-4785-994e-9c991b32946e	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "earth_zoom_in.mp4", "created": "2017-11-23T17:15:23.485571", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:16:10.374535", "position": 1, "revision_id": "99077077-577e-48cc-bd73-2f28656f45f5", "size": 8399839, "url_type": "upload", "id": "c49a76a9-4a48-4785-994e-9c991b32946e", "resource_type": null, "name": "PRUEBAS"}}
17037131-503f-467b-8d25-43d7f3c1cb02	5b3ccd7e-4d3e-429a-a469-09668048e259	c49a76a9-4a48-4785-994e-9c991b32946e	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "earth_zoom_in.mp4", "created": "2017-11-23T17:15:23.485571", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:23:12.517099", "position": 1, "revision_id": "cd6b8c3c-4df5-42a5-a76a-db925c99dbde", "size": 8399839, "url_type": "upload", "id": "c49a76a9-4a48-4785-994e-9c991b32946e", "resource_type": null, "name": "PRUEBAS"}}
a1abad92-9719-4440-969f-2c66dcbe40da	0e647a87-b993-44ad-8f2f-1290d2f3ba14	df517ee3-17b3-451e-afaf-98115f06aaef	Resource	new	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "earth_zoom_in.mp4", "created": "2017-11-23T17:23:33.228623", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:23:33.208929", "position": 2, "revision_id": "ad0c12ae-80f3-437a-8f31-ce5bef87b962", "size": 8399839, "url_type": "upload", "id": "df517ee3-17b3-451e-afaf-98115f06aaef", "resource_type": null, "name": "asdfadas"}}
dbe8166b-d4ef-4a9c-903c-e87ee1ac2dc7	0e647a87-b993-44ad-8f2f-1290d2f3ba14	c49a76a9-4a48-4785-994e-9c991b32946e	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "http://192.76.241.143:5000/dataset/54f83106-f2bf-45a8-8523-53a415c99e47/resource/c49a76a9-4a48-4785-994e-9c991b32946e/download/earth_zoom_in.mp4", "created": "2017-11-23T17:15:23.485571", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:23:12.517099", "position": 1, "revision_id": "ad0c12ae-80f3-437a-8f31-ce5bef87b962", "size": 8399839, "url_type": "upload", "id": "c49a76a9-4a48-4785-994e-9c991b32946e", "resource_type": null, "name": "PRUEBAS"}}
70fbafec-1bc3-48be-9dd2-4444bec0d7c4	2c31cc42-0ae9-487a-a7a6-bf1ebb4c38f8	e0b75bf6-e19e-4a05-b145-fcf770148a89	Resource	new	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "earth_zoom_in.mp4", "created": "2017-11-23T17:25:49.842967", "extras": {}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:25:49.820354", "position": 3, "revision_id": "2d0e5c97-33d8-47d3-9c65-f334df5365fc", "size": 8399839, "url_type": "upload", "id": "e0b75bf6-e19e-4a05-b145-fcf770148a89", "resource_type": null, "name": "Pruena 4"}}
d45b9915-9f18-496c-8fbf-01a393b8060d	2c31cc42-0ae9-487a-a7a6-bf1ebb4c38f8	df517ee3-17b3-451e-afaf-98115f06aaef	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "http://192.76.241.143:5000/dataset/54f83106-f2bf-45a8-8523-53a415c99e47/resource/df517ee3-17b3-451e-afaf-98115f06aaef/download/earth_zoom_in.mp4", "created": "2017-11-23T17:23:33.228623", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54f83106-f2bf-45a8-8523-53a415c99e47", "mimetype_inner": null, "last_modified": "2017-11-23T17:23:33.208929", "position": 2, "revision_id": "2d0e5c97-33d8-47d3-9c65-f334df5365fc", "size": 8399839, "url_type": "upload", "id": "df517ee3-17b3-451e-afaf-98115f06aaef", "resource_type": null, "name": "asdfadas"}}
24c20458-e59f-4bf7-8225-6d7becb0de86	931b2bed-223e-4fda-8843-eb51282d69d1	54f83106-f2bf-45a8-8523-53a415c99e47	Package	deleted	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "aaaa", "metadata_modified": "2017-11-23T17:25:49.828970", "author": "", "url": "", "notes": "", "title": "aaaa", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "b8777631-802d-4981-aa3a-b71e40e44ea9", "type": "dataset", "id": "54f83106-f2bf-45a8-8523-53a415c99e47", "metadata_created": "2017-11-23T17:07:42.009859"}}
dee862ae-bf36-4413-99d3-8bd0710f17d5	2766a7e7-4a1a-4992-b441-d78cdb584065	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	Package	deleted	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "event-information", "metadata_modified": "2017-08-08T16:50:50.837755", "author": "", "url": "", "notes": "Events where several users participated", "title": "Event information", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "78e33def-565f-45dc-b9a4-a1dda81e1ce1", "type": "dataset", "id": "611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc", "metadata_created": "2017-08-08T16:50:26.707962"}}
a38c8160-118d-4f2d-b271-ef6d1f121111	c6dad858-18de-4062-bbbc-d6aba021ebbd	817668d7-be70-479e-92c6-c7e4e8182603	Package	deleted	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "maintainer@email.com", "name": "internet-dataset", "metadata_modified": "2017-08-08T16:55:28.497851", "author": "Unicom", "url": "", "notes": "Information about the users of our internet services.", "title": "Internet dataset", "private": false, "maintainer_email": "maintainer@email.com", "author_email": "unicom@email.com", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "201d00c8-1f94-43d3-ac75-e9bfeb22a2f4", "type": "dataset", "id": "817668d7-be70-479e-92c6-c7e4e8182603", "metadata_created": "2017-08-08T16:54:35.136338"}}
ce0bbe29-97b5-4f6a-86cd-05e3b4bc86f0	11c1f4ab-cfef-4494-aff1-87562f0064ec	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	Package	deleted	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "mobile-plans", "metadata_modified": "2017-08-09T09:04:44.595145", "author": "", "url": "", "notes": "Users and their mobile plans", "title": "Mobile plans", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "19ac713d-48f0-48b9-9cd5-7061843bc62f", "type": "dataset", "id": "4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64", "metadata_created": "2017-08-08T16:57:30.243005"}}
8385428b-a5e7-4e59-b103-922d26c7be30	a4aa87f8-fa10-4f5f-844e-81529fa3a411	903d964e-9c2c-47d2-8708-25363ef8d772	Package	deleted	{"package": {"owner_org": "724ae83b-ae78-433c-8586-69e7202931c4", "maintainer": "", "name": "services-information", "metadata_modified": "2017-08-08T16:52:49.648987", "author": "", "url": "", "notes": "Several services offered in our company", "title": "Services information", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "7d60ea7c-29e6-447b-a3c6-e32ad2ccd4f9", "type": "dataset", "id": "903d964e-9c2c-47d2-8708-25363ef8d772", "metadata_created": "2017-08-08T16:52:29.614969"}}
98c66815-aacf-4905-a829-c407533bdf68	3647c32f-8a96-4c6a-8c4c-c4948e364f7f	acc9dc22-eff3-486b-a715-9a69ef93ade0	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-videos", "metadata_modified": "2017-11-23T17:35:47.357177", "author": "", "url": "", "notes": "", "title": "Example videos", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "00277d2f-879f-426e-98e9-39839776d89d", "type": "dataset", "id": "acc9dc22-eff3-486b-a715-9a69ef93ade0", "metadata_created": "2017-11-23T17:32:40.506721"}}
80c6a1e4-664d-4eb2-9a7e-03b6ae6bfede	4e28330a-cc18-4736-9e4a-71dbdada03a7	476cdf71-1048-4a6f-a28a-58fff547dae5	Package	new	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-11-23T17:37:00.362905", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "draft", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f732828b-2166-4541-9128-f838a260ae1b", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
485654b2-7b7c-4ef6-b4f3-b1f31cdad5c3	46fe0eca-6275-4d0b-8a5e-df73f411e7dc	4ee0ec1c-c72b-4bad-be73-364a735cea5c	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://autode.sk/2zsNALP", "created": "2017-11-23T17:37:19.897441", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "size": null, "url_type": null, "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "resource_type": null, "name": "Example .dwg file"}}
aa36a58c-46ea-48ff-9150-34bd28e571db	46fe0eca-6275-4d0b-8a5e-df73f411e7dc	476cdf71-1048-4a6f-a28a-58fff547dae5	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-11-23T17:37:20.059543", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
1f0cc475-4890-405d-8962-ebfdd8308f1d	505a69df-026a-4e8a-9484-855bd449580b	1342ec64-f18e-4860-93cc-f6dd194d56ec	Resource	new	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://autode.sk/2zZs3JO", "created": "2017-11-23T17:40:23.217872", "extras": {}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": null, "position": 1, "revision_id": "f4499856-fe22-47ba-9e93-ac6f2c547685", "size": null, "url_type": null, "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "resource_type": null, "name": "Example 3D .dwg file"}}
1ac71597-178d-4ab8-8a22-cfe909ee4047	399cb478-9920-4de7-9543-5e8792a122b7	1342ec64-f18e-4860-93cc-f6dd194d56ec	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://autode.sk/2zZs3JO", "created": "2017-11-23T17:40:23.217872", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": null, "position": 1, "revision_id": "40aaa8c6-d66d-4632-bfab-bf3daad5244d", "size": null, "url_type": null, "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "resource_type": null, "name": "Example 3D .dwg file"}}
8581090f-e7f8-4646-8480-15f372b0f45b	399cb478-9920-4de7-9543-5e8792a122b7	4ee0ec1c-c72b-4bad-be73-364a735cea5c	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://autode.sk/2zsNALP", "created": "2017-11-23T17:37:19.897441", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": null, "position": 0, "revision_id": "40aaa8c6-d66d-4632-bfab-bf3daad5244d", "size": null, "url_type": null, "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "resource_type": null, "name": "Example 2D .dwg file"}}
1d4197b6-9917-4f72-8951-1a8233bca7c6	b6b56eb0-bd29-4995-a1ec-e9d8bf056af0	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-01T11:56:50.590910", "author": "", "url": "", "notes": "", "title": "Example CAD 2", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c0d32fee-6737-4a91-920a-d8aab223e545", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
b808f7f2-b6da-45c7-b054-9a1360c32ba1	1c0cc55f-1748-43f3-91b4-977ff52f15d3	bf46d212-6fde-4670-ab59-52bb38c513bc	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "test-jupyter", "metadata_modified": "2017-12-01T11:57:19.351983", "author": "", "url": "", "notes": "", "title": "Test jupyter", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "78462af9-3e29-41e7-b739-815aa263ff3d", "type": "dataset", "id": "bf46d212-6fde-4670-ab59-52bb38c513bc", "metadata_created": "2017-11-28T19:31:59.868119"}}
24c9c949-d13e-48a8-a208-c0bf33da6fdc	c9b28971-06de-4022-a7c2-716558a8cd4c	54920aae-f322-4fca-bd09-cd091946632c	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T11:57:31.640981", "author": "", "url": "", "notes": "", "title": "Example video 2", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "beb04331-d499-485b-9369-1f57aa6f7395", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
42679f8a-3fa1-4e93-b92c-68d8347c2d44	b8806ae8-b2c3-4970-883f-040d37783bec	acc9dc22-eff3-486b-a715-9a69ef93ade0	Package	deleted	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-videos", "metadata_modified": "2017-11-23T17:35:47.357177", "author": "", "url": "", "notes": "", "title": "Example videos", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f8632874-e874-4ec3-97ce-c15bffe12f28", "type": "dataset", "id": "acc9dc22-eff3-486b-a715-9a69ef93ade0", "metadata_created": "2017-11-23T17:32:40.506721"}}
f332b8c5-0e89-4dd3-a65c-db9de2a34278	5f389a45-31ea-429b-9247-12758057a04b	54920aae-f322-4fca-bd09-cd091946632c	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T12:26:27.564010", "author": "", "url": "", "notes": "", "title": "Example video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f69e3832-0198-44c5-a4f2-f52a65fe3ca2", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
3685b034-8aba-4123-8115-dfeaf8ce3f5c	530af8ab-a4ac-46d0-9596-f2413d305e6a	bf46d212-6fde-4670-ab59-52bb38c513bc	Package	deleted	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "test-jupyter", "metadata_modified": "2017-12-01T11:57:19.351983", "author": "", "url": "", "notes": "", "title": "Test jupyter", "private": false, "maintainer_email": "", "author_email": "", "state": "deleted", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4c6cf89c-065e-4c3e-85a0-bd6c7ed30b75", "type": "dataset", "id": "bf46d212-6fde-4670-ab59-52bb38c513bc", "metadata_created": "2017-11-28T19:31:59.868119"}}
2afa222e-ce3b-43be-9788-1e338801eb54	13df1fff-32cf-4fd2-9abd-ef82e3d75593	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-01T12:27:24.137068", "author": "", "url": "", "notes": "", "title": "Example CAD Pangaea", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "f42bf4cf-a31c-4645-bb98-9ecbdf58d1ca", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
b59a6f44-94ac-46e8-a61b-f680d9840eee	c3354d91-317e-4469-be79-9bfe6b175946	8649545f-f1d0-49d2-b9cd-88f2593ec059	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "stf50_autocombustions_with_varying_phi_v2_hd.mp4", "created": "2017-11-24T13:42:36.237930", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "mimetype_inner": null, "last_modified": "2017-12-01T12:42:20.928656", "position": 0, "revision_id": "0489aebe-7484-4f6b-a051-9907f1b31b20", "size": 71194509, "url_type": "upload", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "resource_type": null, "name": "Video TIB"}}
d6fcb633-9fae-4829-9a48-7ae7a285c874	c351585b-0db7-47aa-a58f-7f2a8c01df3a	8649545f-f1d0-49d2-b9cd-88f2593ec059	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "stf50_autocombustions_with_varying_phi_v2_hd.mp4", "created": "2017-11-24T13:42:36.237930", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "mimetype_inner": null, "last_modified": "2017-12-01T12:42:20.928656", "position": 0, "revision_id": "29af1387-94a1-460f-b0d1-fdfb7de377e7", "size": 71194509, "url_type": "upload", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "resource_type": null, "name": "STF50 autocombustions with varying Phi"}}
6946c816-56b4-441d-acfe-ac4f4484623e	c28d5815-58c9-4a23-a270-b7e95f9dca25	1abefb2e-6a83-4004-b7db-74c34b545d2e	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-01T12:51:37.466460", "author": "", "url": "", "notes": "", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "3951536e-4b6f-4e7a-add1-b55c5002dcc0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
acb89038-b42a-4783-b765-f2ff8c050d0c	caf40a6b-9a5b-4a50-a544-09e2cb86e849	54920aae-f322-4fca-bd09-cd091946632c	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-01T12:51:49.532303", "author": "", "url": "", "notes": "", "title": "Video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "b0de1461-ba0a-4971-8682-f14af889ae40", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
45191cfd-0248-49c6-b8e7-a126145bb86f	284b516c-c10f-4133-81c5-918978e6d54d	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-01T12:52:07.397075", "author": "", "url": "", "notes": "", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "997a3d54-bb90-4c1e-88bf-417e4c95ba21", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
78e77292-51a0-4afb-bbac-73734b7a59e3	377f88b8-6a7e-4b6c-902f-9e90187aa41d	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "example-machine-learning-notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:51:28.875743", "position": 0, "revision_id": "6fc03502-641d-4cd0-96d6-e56dfb3caa62", "size": 703819, "url_type": "upload", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
a022417d-8878-421d-a7dd-c37bfa8ef9b9	bf856c8e-87f1-4191-93e3-4f728bcb6056	036bcac0-c857-4bf0-bc71-1c78ed35d93a	Resource	new	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "labeled-faces-in-the-wild-recognition.ipynb", "created": "2017-12-01T12:54:05.127144", "extras": {}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:54:05.110953", "position": 1, "revision_id": "2e56ef3c-2f4f-4f73-b213-4214ece22001", "size": 717993, "url_type": "upload", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "resource_type": null, "name": "Labeled Faces in the Wild recognition"}}
4429f538-9dc5-41b9-8de2-6d11e2168499	bf856c8e-87f1-4191-93e3-4f728bcb6056	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/1e335b61-123e-4ba4-9c5b-9d1d6309dba9/download/example-machine-learning-notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:51:28.875743", "position": 0, "revision_id": "2e56ef3c-2f4f-4f73-b213-4214ece22001", "size": 703819, "url_type": "upload", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
6b2b82c1-1c40-4926-a51a-a670f9290ed0	e2fa6206-3c5a-4427-9fb1-8ff54506186a	e4cc8bf6-5e32-4c1f-b22e-109d47340c96	Resource	new	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "satellite_example.ipynb", "created": "2017-12-01T12:55:06.673960", "extras": {}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:55:06.657141", "position": 2, "revision_id": "41602a5a-b63a-4104-ba15-52f0c1c35526", "size": 7216, "url_type": "upload", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "resource_type": null, "name": "Satellite example"}}
77db426d-060c-4fde-a8ff-f5f6b5a36b15	e2fa6206-3c5a-4427-9fb1-8ff54506186a	036bcac0-c857-4bf0-bc71-1c78ed35d93a	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/036bcac0-c857-4bf0-bc71-1c78ed35d93a/download/labeled-faces-in-the-wild-recognition.ipynb", "created": "2017-12-01T12:54:05.127144", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:54:05.110953", "position": 1, "revision_id": "41602a5a-b63a-4104-ba15-52f0c1c35526", "size": 717993, "url_type": "upload", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "resource_type": null, "name": "Labeled Faces in the Wild recognition"}}
c5b1e746-8f18-47c1-89a0-765f2cd5dcef	69c19d68-b662-4693-8d6a-c81d00649dc9	4577e551-96f8-4e13-ac81-012a866d00ac	Resource	new	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "gw150914_tutorial.ipynb", "created": "2017-12-01T12:56:06.860736", "extras": {}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:56:06.844366", "position": 3, "revision_id": "670dffd1-3172-40b8-8e0d-8956760a084a", "size": 2683661, "url_type": "upload", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "resource_type": null, "name": "GW150914 tutorial"}}
cd77c395-6447-407f-b5c1-dfc2389bbce1	69c19d68-b662-4693-8d6a-c81d00649dc9	e4cc8bf6-5e32-4c1f-b22e-109d47340c96	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/e4cc8bf6-5e32-4c1f-b22e-109d47340c96/download/satellite_example.ipynb", "created": "2017-12-01T12:55:06.673960", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:55:06.657141", "position": 2, "revision_id": "670dffd1-3172-40b8-8e0d-8956760a084a", "size": 7216, "url_type": "upload", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "resource_type": null, "name": "Satellite example"}}
a90dc818-c7f2-4a55-a97c-5fb36ff3a2b8	dc0f5775-5264-4f9e-9f88-e62031625f6a	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Resource	new	{"resource": {"mimetype": "application/x-tar", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "TAR", "url": "12-steps-to-navier-stokes.tar.gz", "created": "2017-12-01T12:58:35.877330", "extras": {}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:58:35.858976", "position": 4, "revision_id": "ec55548e-a397-4b9c-afac-2f24518f3991", "size": 5708395, "url_type": "upload", "id": "ec1c5422-b8ab-4401-96fb-0792dacb8e40", "resource_type": null, "name": "12 steps to Navier-Stokes"}}
cbe28ce5-78ee-4bf3-81ca-76ece6a344a4	dc0f5775-5264-4f9e-9f88-e62031625f6a	4577e551-96f8-4e13-ac81-012a866d00ac	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/4577e551-96f8-4e13-ac81-012a866d00ac/download/gw150914_tutorial.ipynb", "created": "2017-12-01T12:56:06.860736", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:56:06.844366", "position": 3, "revision_id": "ec55548e-a397-4b9c-afac-2f24518f3991", "size": 2683661, "url_type": "upload", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "resource_type": null, "name": "GW150914 tutorial"}}
a5ae08ca-d386-419d-9976-f3813378bcac	4a7e58d7-5bc8-40cb-8e00-5f0c2bbcc672	8649545f-f1d0-49d2-b9cd-88f2593ec059	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "stf50_autocombustions_with_varying_phi_v2_hd.mp4", "created": "2017-11-24T13:42:36.237930", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "mimetype_inner": null, "last_modified": "2017-12-01T16:35:53.307078", "position": 0, "revision_id": "6bbacefb-7a0e-47f0-b3b6-fe7f99b2fd4e", "size": 71194509, "url_type": "upload", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "resource_type": null, "name": "STF50 autocombustions with varying Phi"}}
91f3c41b-cfab-4c2e-aff5-b358186c0782	aed87a9d-a678-4378-8265-2da5fb4b08f3	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Resource	changed	{"resource": {"mimetype": "application/x-tar", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "TAR", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/ec1c5422-b8ab-4401-96fb-0792dacb8e40/download/12-steps-to-navier-stokes.tar.gz", "created": "2017-12-01T12:58:35.877330", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T12:58:35.858976", "position": 4, "revision_id": "f1e7cf9b-cca1-4e09-ae98-7433e34718ac", "size": 5708395, "url_type": "upload", "id": "ec1c5422-b8ab-4401-96fb-0792dacb8e40", "resource_type": null, "name": "12 steps to Navier-Stokes"}}
3b76cd87-8c2d-41aa-a83f-fb58d5ca54e6	aed87a9d-a678-4378-8265-2da5fb4b08f3	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "example-machine-learning-notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:34.233655", "position": 0, "revision_id": "f1e7cf9b-cca1-4e09-ae98-7433e34718ac", "size": 703819, "url_type": "upload", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
99ff4a2e-88c4-41c0-b3b1-1a7a812d4af7	a3bad026-3f24-411e-a614-c98ee4e0d684	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/1e335b61-123e-4ba4-9c5b-9d1d6309dba9/download/example-machine-learning-notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:34.233655", "position": 0, "revision_id": "ddb53a5e-f9ff-47c5-be50-657f6214d787", "size": 703819, "url_type": "upload", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
03d981f3-d569-4b0c-b675-741664ea1fe5	a3bad026-3f24-411e-a614-c98ee4e0d684	036bcac0-c857-4bf0-bc71-1c78ed35d93a	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "labeled-faces-in-the-wild-recognition.ipynb", "created": "2017-12-01T12:54:05.127144", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:43.266081", "position": 1, "revision_id": "ddb53a5e-f9ff-47c5-be50-657f6214d787", "size": 717993, "url_type": "upload", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "resource_type": null, "name": "Labeled Faces in the Wild recognition"}}
57d7f775-408e-4d30-8b60-9125c2f94de6	bf3c0672-19cc-4e7f-b94a-4b0d39bf8640	e4cc8bf6-5e32-4c1f-b22e-109d47340c96	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "satellite_example.ipynb", "created": "2017-12-01T12:55:06.673960", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:54.872809", "position": 2, "revision_id": "f41688c5-b4da-4fb5-9165-e5aa2783ba73", "size": 7216, "url_type": "upload", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "resource_type": null, "name": "Satellite example"}}
1e52d478-4fa2-4417-b2ec-b4f70de2d5d6	bf3c0672-19cc-4e7f-b94a-4b0d39bf8640	036bcac0-c857-4bf0-bc71-1c78ed35d93a	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/036bcac0-c857-4bf0-bc71-1c78ed35d93a/download/labeled-faces-in-the-wild-recognition.ipynb", "created": "2017-12-01T12:54:05.127144", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:43.266081", "position": 1, "revision_id": "f41688c5-b4da-4fb5-9165-e5aa2783ba73", "size": 717993, "url_type": "upload", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "resource_type": null, "name": "Labeled Faces in the Wild recognition"}}
6593ade1-e998-4dfa-8d15-8224c000554c	12eccb51-82e7-4bf9-83ad-483c5e6bf6f6	e4cc8bf6-5e32-4c1f-b22e-109d47340c96	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/e4cc8bf6-5e32-4c1f-b22e-109d47340c96/download/satellite_example.ipynb", "created": "2017-12-01T12:55:06.673960", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:54.872809", "position": 2, "revision_id": "9b14e4f2-5d5d-4693-b0b6-27bc2cd40e4a", "size": 7216, "url_type": "upload", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "resource_type": null, "name": "Satellite example"}}
dd021b84-a1f4-4add-8a53-774b5c9b0596	12eccb51-82e7-4bf9-83ad-483c5e6bf6f6	4577e551-96f8-4e13-ac81-012a866d00ac	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "gw150914_tutorial.ipynb", "created": "2017-12-01T12:56:06.860736", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:48:04.508028", "position": 3, "revision_id": "9b14e4f2-5d5d-4693-b0b6-27bc2cd40e4a", "size": 2683661, "url_type": "upload", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "resource_type": null, "name": "GW150914 tutorial"}}
60c5ba51-81ed-417e-8cc6-e9f5c13e2299	fec26c29-3670-499c-b1e6-406d71253bd4	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Resource	changed	{"resource": {"mimetype": "application/x-tar", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "TAR", "url": "12-steps-to-navier-stokes.tar.gz", "created": "2017-12-01T12:58:35.877330", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:48:21.527146", "position": 4, "revision_id": "83b264fc-0dd9-4270-9c2a-e3ec22ebafee", "size": 5708395, "url_type": "upload", "id": "ec1c5422-b8ab-4401-96fb-0792dacb8e40", "resource_type": null, "name": "12 steps to Navier-Stokes"}}
a2ebc59d-af21-477a-8677-55de4016e60e	fec26c29-3670-499c-b1e6-406d71253bd4	4577e551-96f8-4e13-ac81-012a866d00ac	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/4577e551-96f8-4e13-ac81-012a866d00ac/download/gw150914_tutorial.ipynb", "created": "2017-12-01T12:56:06.860736", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:48:04.508028", "position": 3, "revision_id": "83b264fc-0dd9-4270-9c2a-e3ec22ebafee", "size": 2683661, "url_type": "upload", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "resource_type": null, "name": "GW150914 tutorial"}}
3e6199da-6c90-455b-9703-ed605600ee70	bb6e0100-9f39-4fa2-9e0e-7a34ef431fa6	0ce74f0d-bf35-4627-9f69-92d5c1150dff	Resource	changed	{"resource": {"mimetype": "application/zip", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "gkg_steel_zinced.zip", "created": "2017-11-24T13:37:06.599034", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "mimetype_inner": null, "last_modified": "2017-12-01T16:50:37.896845", "position": 0, "revision_id": "ba4e1fea-9747-477a-adb7-82447b0e99a1", "size": 3414733, "url_type": "upload", "id": "0ce74f0d-bf35-4627-9f69-92d5c1150dff", "resource_type": null, "name": "Example .dwg file"}}
66de9fe5-066c-4b5b-94a0-d94ee6f14508	9a77c594-c442-4d5a-bde6-ea90bda29e6d	4ee0ec1c-c72b-4bad-be73-364a735cea5c	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "drive_shaft.dwg", "created": "2017-11-23T17:37:19.897441", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": "2017-12-01T16:52:30.511835", "position": 0, "revision_id": "36f8a864-0e03-43c8-a8d7-91ca0fe7ec1e", "size": 169807, "url_type": "upload", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "resource_type": null, "name": "Example 2D .dwg file"}}
9d3e8fc1-1329-4105-8f33-3f88b589b3ab	7377d7a7-62d6-4d2d-9b0c-494f137a2aa2	1342ec64-f18e-4860-93cc-f6dd194d56ec	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "visualization_-_aerial.dwg", "created": "2017-11-23T17:40:23.217872", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": "2017-12-01T16:53:23.693615", "position": 1, "revision_id": "1dfe4f70-fe22-4f93-b708-93d2166875e0", "size": 733036, "url_type": "upload", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "resource_type": null, "name": "Example 3D .dwg file"}}
aa761abf-b9a0-4667-ab27-f4d25d0dfdd0	7377d7a7-62d6-4d2d-9b0c-494f137a2aa2	4ee0ec1c-c72b-4bad-be73-364a735cea5c	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://10.116.33.2:5000/dataset/476cdf71-1048-4a6f-a28a-58fff547dae5/resource/4ee0ec1c-c72b-4bad-be73-364a735cea5c/download/drive_shaft.dwg", "created": "2017-11-23T17:37:19.897441", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": "2017-12-01T16:52:30.511835", "position": 0, "revision_id": "1dfe4f70-fe22-4f93-b708-93d2166875e0", "size": 169807, "url_type": "upload", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "resource_type": null, "name": "Example 2D .dwg file"}}
c56def7f-aa54-4e5b-a57e-4146393a57e4	e361bdcd-090d-4d3c-bf58-056e7de5e2b2	fbabaa88-ebd0-4758-9503-c32b0e628b29	tag	added	{"tag": {"vocabulary_id": null, "id": "f650b4e3-9955-49b0-ba7b-2d302a990978", "name": "computer vision"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:42:27.659128", "author": "Lorena A. Barba", "url": "", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "25711b9c-54ee-4629-ba88-03fbd139dda0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
f36a288a-8191-4973-a261-6756dcacd98a	e361bdcd-090d-4d3c-bf58-056e7de5e2b2	c273e895-9968-4ed6-9ffc-92585b788aa5	tag	added	{"tag": {"vocabulary_id": null, "id": "5581fcb2-a2b7-41aa-aa4e-822d8837fcfe", "name": "imagery analysis"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:42:27.659128", "author": "Lorena A. Barba", "url": "", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "25711b9c-54ee-4629-ba88-03fbd139dda0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
53bde4a8-907a-49b1-8961-f7ce152f42df	e361bdcd-090d-4d3c-bf58-056e7de5e2b2	f6ae04c4-15aa-4464-990a-41893be621e7	tag	added	{"tag": {"vocabulary_id": null, "id": "c3ea41c3-899c-4b54-a4f4-caa50617b956", "name": "satellite"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:42:27.659128", "author": "Lorena A. Barba", "url": "", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "25711b9c-54ee-4629-ba88-03fbd139dda0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
dfcb9036-0caf-4d79-a70a-e2b51c64c958	e361bdcd-090d-4d3c-bf58-056e7de5e2b2	a813bedb-0a06-4583-a249-ecc9c6967d03	tag	added	{"tag": {"vocabulary_id": null, "id": "9e42784b-6ee7-47e8-a69a-28b8c510212b", "name": "machine learning"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:42:27.659128", "author": "Lorena A. Barba", "url": "", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "25711b9c-54ee-4629-ba88-03fbd139dda0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
7fc4c77c-ec32-406c-b61b-e090f590f1e0	e361bdcd-090d-4d3c-bf58-056e7de5e2b2	bf7d7129-ce0d-480f-9c3a-ba9d0eb982d2	tag	added	{"tag": {"vocabulary_id": null, "id": "e2bb9482-6eb5-43c3-b14e-903c519d5e38", "name": "jupyter notebook"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:42:27.659128", "author": "Lorena A. Barba", "url": "", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "25711b9c-54ee-4629-ba88-03fbd139dda0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
1580fa2a-73bb-492c-b456-ad493ca440b7	e361bdcd-090d-4d3c-bf58-056e7de5e2b2	1abefb2e-6a83-4004-b7db-74c34b545d2e	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:42:27.659128", "author": "Lorena A. Barba", "url": "", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "25711b9c-54ee-4629-ba88-03fbd139dda0", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
06dfd07a-9fe9-43f0-98f7-b61418d80ef2	2ca1bac2-cebd-4d06-83f5-764cb45ff848	b2a50929-224a-4c9c-92c5-31a2a2fc149e	tag	added	{"tag": {"vocabulary_id": null, "id": "23f7f291-52c1-4942-aa23-008a9b23a5e1", "name": "Combustion"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
94873548-f4df-4055-bfd4-ffa09986651d	9af28f62-f4ab-447e-af25-59523c30c12f	1abefb2e-6a83-4004-b7db-74c34b545d2e	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "jupyter-notebooks", "metadata_modified": "2017-12-04T16:43:57.659289", "author": "Lorena A. Barba", "url": "https://unidata.github.io/online-python-training/introduction.html", "notes": "A collection of Jupyter Notebooks for science related projects\\r\\n\\r\\n1. LIGO Gravitational Wave Data\\r\\n2. Satellite Imagery Analysis\\r\\n3. 12 Steps to Navier-Stokes\\r\\n4. Computer Vision\\r\\n5. Machine Learning", "title": "Jupyter notebooks", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "4f99eafe-97a2-4b14-be62-63ad7cffc7be", "type": "dataset", "id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "metadata_created": "2017-12-01T12:51:12.218503"}}
308ddaff-878d-4d09-a0bf-45eab586306f	1622c60f-24bf-4a79-9d27-7f09705e8715	3408ac90-f31d-4591-b524-ff7b0aec6803	tag	added	{"tag": {"vocabulary_id": null, "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T11:07:10.618785", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
d354854a-3bdc-4fcf-b58f-3d8697d09624	1622c60f-24bf-4a79-9d27-7f09705e8715	3aa7c276-605e-4e8a-bb6b-173cf2e4b026	tag	added	{"tag": {"vocabulary_id": null, "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T11:07:10.618785", "author": "", "url": "", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
88260bcb-159a-477e-b85a-42898ce58f87	5245f777-f8d1-4712-a5b5-d80a045b60c2	96d247bf-4b11-4ab4-9144-9520516a7cf8	tag	added	{"tag": {"vocabulary_id": null, "id": "7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd", "name": "visualization"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T11:08:31.917600", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "41e8a326-3a0c-4ab2-af20-7427bd551504", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
ff3b599c-3373-40ca-a327-578142c78ddb	5245f777-f8d1-4712-a5b5-d80a045b60c2	85e712c8-745f-4edf-9865-2bae84c2bfa8	tag	added	{"tag": {"vocabulary_id": null, "id": "675a1366-8d81-4e07-ab30-8c492c34b91d", "name": "dwg"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T11:08:31.917600", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "41e8a326-3a0c-4ab2-af20-7427bd551504", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
b38cc0d7-db39-43f5-a28a-c12720e9f773	5245f777-f8d1-4712-a5b5-d80a045b60c2	476cdf71-1048-4a6f-a28a-58fff547dae5	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T11:08:31.917600", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "41e8a326-3a0c-4ab2-af20-7427bd551504", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
c4f337fb-e386-43b3-951d-43786adc4342	50a30a7a-f059-4f41-8abf-131e01b2ae64	adf12ac1-5e68-45ca-8adc-10a50e8f7deb	PackageExtra	new	{"package_extra": {"state": "active", "value": "baz", "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "key": "foobar", "revision_id": "7a7537ca-0c0c-4501-b244-a3d813e376d1", "id": "adf12ac1-5e68-45ca-8adc-10a50e8f7deb"}}
8df2fc2e-ce1e-41f2-b07a-3306f86afb29	2ca1bac2-cebd-4d06-83f5-764cb45ff848	e715d58c-d536-4278-8ee6-55f16980ee44	tag	added	{"tag": {"vocabulary_id": null, "id": "7d945dfc-6203-4ef8-8369-90704d7498ac", "name": "Video"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
ca027ae3-1862-4b51-a838-ca2a463d2b8a	2ca1bac2-cebd-4d06-83f5-764cb45ff848	8c80f201-690f-4d21-8f8f-7bc52fc898b6	tag	added	{"tag": {"vocabulary_id": null, "id": "53b4f8bd-5778-4ece-b3ac-78e8a60be011", "name": "STF50"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
62476a18-9aa4-4c15-812b-68c6d9dceaba	2ca1bac2-cebd-4d06-83f5-764cb45ff848	eb475d76-18fc-4ace-85c1-cbde3ddd2d16	tag	added	{"tag": {"vocabulary_id": null, "id": "a292a3c1-b272-4c02-bfb2-385e12ff6b66", "name": "Reactions"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
08e16463-130b-4557-8f3c-e0c471053ba6	2ca1bac2-cebd-4d06-83f5-764cb45ff848	09ab2d8a-1cc3-46ae-850b-c14478a12673	tag	added	{"tag": {"vocabulary_id": null, "id": "a6bbc1be-05c4-406c-8d13-b9e2018b311a", "name": "Experiment"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
b1bb7451-630b-433e-89d8-ff2e84d43b49	2ca1bac2-cebd-4d06-83f5-764cb45ff848	e7455a68-28aa-4859-a2d7-eb9c4b1eb836	tag	added	{"tag": {"vocabulary_id": null, "id": "5df7cf26-78df-4382-b27d-fad8237cf180", "name": "CA"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
176ae31d-bc8b-4483-ad90-b5fc9a21c71d	2ca1bac2-cebd-4d06-83f5-764cb45ff848	2eef4809-6dff-4926-b1ed-cf3e86c86d0a	tag	added	{"tag": {"vocabulary_id": null, "id": "9d0587af-aad0-4352-ab8f-fc7b90f7430b", "name": "EDTA"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
55eb2a19-ab3c-4777-996b-e04d4dea391e	2ca1bac2-cebd-4d06-83f5-764cb45ff848	54920aae-f322-4fca-bd09-cd091946632c	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T12:47:02.944695", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "959e1cc4-8271-4643-b3d5-4a6dd3e92074", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
81b82b97-7e5e-448a-8b20-f915b342c2b6	ccdc0d8b-9611-4752-9610-a68074350791	79d22f27-f47e-44d4-a82f-7a2d707a44cb	tag	added	{"tag": {"vocabulary_id": null, "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T12:49:18.579271", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "Example usage of CAD visualization in 2D and 3D.", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "778fcf5c-b993-40b3-ad2b-088dcb674c2e", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
e0ce367c-ad17-4d8b-b8e7-a2eb026d6871	ccdc0d8b-9611-4752-9610-a68074350791	cf5e6fe9-0896-4e9f-aada-117d05c04619	tag	added	{"tag": {"vocabulary_id": null, "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T12:49:18.579271", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "Example usage of CAD visualization in 2D and 3D.", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "778fcf5c-b993-40b3-ad2b-088dcb674c2e", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
619b359a-c926-486e-a4d6-36236c0d0cc5	ccdc0d8b-9611-4752-9610-a68074350791	476cdf71-1048-4a6f-a28a-58fff547dae5	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T12:49:18.579271", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "Example usage of CAD visualization in 2D and 3D.", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "778fcf5c-b993-40b3-ad2b-088dcb674c2e", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
4ce6a51b-af67-4d12-9a40-2d4b61c8c3b5	1e2298ea-a34e-4a01-8190-9147647c0697	476cdf71-1048-4a6f-a28a-58fff547dae5	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad", "metadata_modified": "2017-12-05T12:50:32.680631", "author": "Autodesk", "url": "https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html", "notes": "Example usage of CAD visualization in 2D and 3D using CKAN Views.", "title": "Example CAD", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "9c6d5cc2-06e9-46c9-acd2-77a99cf3ac8b", "type": "dataset", "id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "metadata_created": "2017-11-23T17:37:00.362900"}}
14220114-efb8-46e7-824f-fb092478509d	ae2b18f3-fdea-47a2-91a5-011843b41bde	3e45d558-8beb-41b3-84c4-672c3e6deba9	tag	added	{"tag": {"vocabulary_id": null, "id": "816b2a52-8852-4298-803f-f34556cae9e0", "name": "pangaea"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T12:53:47.896014", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
1405b68e-70bd-44a5-9695-a491b608eebd	ae2b18f3-fdea-47a2-91a5-011843b41bde	93bcbf69-6e91-486f-9b95-0e8e6e673d6f	tag	added	{"tag": {"vocabulary_id": null, "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T12:53:47.896014", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
67bed022-1aef-46a0-8f1a-4fc95f94b518	ae2b18f3-fdea-47a2-91a5-011843b41bde	4c1ed6cf-4b4d-482b-8c49-6ccb6b9fe9ec	tag	added	{"tag": {"vocabulary_id": null, "id": "73142a8e-6efc-400b-9215-3316931a4e66", "name": "example"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T12:53:47.896014", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
b9d5d51e-a068-4df9-b33e-f51e55d60d0e	ae2b18f3-fdea-47a2-91a5-011843b41bde	722e4151-8209-4643-bd71-5259e2dd7cc5	tag	added	{"tag": {"vocabulary_id": null, "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T12:53:47.896014", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
e7119e3d-8745-4f4c-a60d-56e54e38344f	ae2b18f3-fdea-47a2-91a5-011843b41bde	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T12:53:47.896014", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
feb04548-89ff-448a-9e41-0a872fbc408b	e16cfa90-314c-4694-9125-f91c699d1b6f	de332c20-57f1-4f31-a436-25d74c47f875	tag	added	{"tag": {"vocabulary_id": null, "id": "f5568899-687f-4fc9-a613-b5b3d8253fe3", "name": "2D CAD"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:10:44.629506", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
151791b2-b9ac-42fe-b3eb-6740ed2d9d93	e16cfa90-314c-4694-9125-f91c699d1b6f	722e4151-8209-4643-bd71-5259e2dd7cc5	tag	removed	{"tag": {"vocabulary_id": null, "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:10:44.629506", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
1c08f805-7215-4e89-a025-0469bcaf7d28	e16cfa90-314c-4694-9125-f91c699d1b6f	93bcbf69-6e91-486f-9b95-0e8e6e673d6f	tag	removed	{"tag": {"vocabulary_id": null, "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:10:44.629506", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
6b7d99b0-837d-4b47-945f-3a5a82ded7bd	3ceda134-8a0b-456e-bd2c-837d6d78eb29	08caad45-37a6-4ddf-abb4-d18ce8e8edc6	tag	added	{"tag": {"vocabulary_id": null, "id": "c98a3ca2-e5c9-4173-93fb-420e0b48e9d8", "name": "3D"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:11:18.467298", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
e88975f6-03d3-4a56-85d7-73609db7944f	3ceda134-8a0b-456e-bd2c-837d6d78eb29	722e4151-8209-4643-bd71-5259e2dd7cc5	tag	removed	{"tag": {"vocabulary_id": null, "id": "aa5643c3-51ea-4233-a672-6f5a2a7b174e", "name": "2D"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:11:18.467298", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
1f9051ef-513b-4de5-8bd8-7f5d58add5e4	3ceda134-8a0b-456e-bd2c-837d6d78eb29	93bcbf69-6e91-486f-9b95-0e8e6e673d6f	tag	removed	{"tag": {"vocabulary_id": null, "id": "80b88538-5f29-4c5f-af29-895228232a10", "name": "CAD"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:11:18.467298", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
ffc552b9-fe86-439f-98a8-8bb523a75cb0	3ceda134-8a0b-456e-bd2c-837d6d78eb29	de332c20-57f1-4f31-a436-25d74c47f875	tag	removed	{"tag": {"vocabulary_id": null, "id": "f5568899-687f-4fc9-a613-b5b3d8253fe3", "name": "2D CAD"}, "package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-cad-2", "metadata_modified": "2017-12-05T13:11:18.467298", "author": "", "url": "", "notes": "Example usage of CAD using Ckan View with information provided by PANGAEA.", "title": "Pangaea CAD files", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "c7cbaa34-461b-4cd7-932d-d70ae8e2254b", "type": "dataset", "id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "metadata_created": "2017-11-24T13:36:15.887852"}}
b1b5cc05-70eb-4c99-975b-53d7c06088df	ddc37615-8361-467b-9234-3aab5c04965c	54920aae-f322-4fca-bd09-cd091946632c	Package	changed	{"package": {"owner_org": "0c5362f5-b99e-41db-8256-3d0d7549bf4d", "maintainer": "", "name": "example-video-2", "metadata_modified": "2017-12-05T13:12:32.843326", "author": "", "url": "", "notes": "Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.", "title": "Autocombustion reactions STF50 video", "private": false, "maintainer_email": "", "author_email": "", "state": "active", "version": "", "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700", "license_id": "cc-by", "revision_id": "d325e2f3-8a4a-4b42-b99d-2d1152e093ea", "type": "dataset", "id": "54920aae-f322-4fca-bd09-cd091946632c", "metadata_created": "2017-11-24T13:42:19.407543"}}
39d44437-4d07-4c3c-afe3-7a82227dfdbf	90bbb19b-2c0b-4937-a724-3745a7606c83	8649545f-f1d0-49d2-b9cd-88f2593ec059	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "https://github.com/guillermobet/files/blob/master/STF50_autocombustions_with_varying_phi_v2_HD.mp4", "created": "2017-11-24T13:42:36.237930", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "mimetype_inner": null, "last_modified": "2017-12-01T16:35:53.307078", "position": 0, "revision_id": "606a0443-92eb-443b-8f03-5d342a4c53a7", "size": 71194509, "url_type": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "resource_type": null, "name": "STF50 autocombustions with varying Phi"}}
3cad8ccd-bff0-4309-974d-ac131ad12a4f	5c8b9bb2-c24e-4ded-b9b9-f6fe1e1d749a	8649545f-f1d0-49d2-b9cd-88f2593ec059	Resource	changed	{"resource": {"mimetype": "video/mp4", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "video/mp4", "url": "https://github.com/guillermobet/files/raw/master/STF50_autocombustions_with_varying_phi_v2_HD.mp4", "created": "2017-11-24T13:42:36.237930", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "54920aae-f322-4fca-bd09-cd091946632c", "mimetype_inner": null, "last_modified": "2017-12-01T16:35:53.307078", "position": 0, "revision_id": "1154ccc2-5934-43a5-99d8-fb903dde0691", "size": 71194509, "url_type": "", "id": "8649545f-f1d0-49d2-b9cd-88f2593ec059", "resource_type": null, "name": "STF50 autocombustions with varying Phi"}}
6b7a9dcf-eb8d-4363-a587-cc28625e1af9	da535949-1a1c-46c3-a86d-77a799fe450f	0ce74f0d-bf35-4627-9f69-92d5c1150dff	Resource	changed	{"resource": {"mimetype": "application/zip", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "https://github.com/guillermobet/files/raw/master/gkg_steel_zinced.zip", "created": "2017-11-24T13:37:06.599034", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "ca8c20ad-77b6-46d7-a940-1f6a351d7d0b", "mimetype_inner": null, "last_modified": "2017-12-01T16:50:37.896845", "position": 0, "revision_id": "690a634b-a609-4502-b01e-c1c08da7e478", "size": 3414733, "url_type": "", "id": "0ce74f0d-bf35-4627-9f69-92d5c1150dff", "resource_type": null, "name": "Example .dwg file"}}
eaeb7620-d49e-4f83-8d05-8f30e20df94f	54504cc7-9324-454b-9ee7-2c98e74eda0e	4ee0ec1c-c72b-4bad-be73-364a735cea5c	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "https://github.com/guillermobet/files/raw/master/Drive_shaft.dwg", "created": "2017-11-23T17:37:19.897441", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": "2017-12-01T16:52:30.511835", "position": 0, "revision_id": "38a2a6f3-e1b4-4bf0-be67-9570df5257ef", "size": 169807, "url_type": "", "id": "4ee0ec1c-c72b-4bad-be73-364a735cea5c", "resource_type": null, "name": "Example 2D .dwg file"}}
7b514c70-8481-4daa-930f-a14669c9bfd3	54504cc7-9324-454b-9ee7-2c98e74eda0e	1342ec64-f18e-4860-93cc-f6dd194d56ec	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://192.76.241.245:5000/dataset/476cdf71-1048-4a6f-a28a-58fff547dae5/resource/1342ec64-f18e-4860-93cc-f6dd194d56ec/download/visualization_-_aerial.dwg", "created": "2017-11-23T17:40:23.217872", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": "2017-12-01T16:53:23.693615", "position": 1, "revision_id": "38a2a6f3-e1b4-4bf0-be67-9570df5257ef", "size": 733036, "url_type": "upload", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "resource_type": null, "name": "Example 3D .dwg file"}}
cae6ef0e-3716-4aed-9742-086104fbc207	12e9dc99-5b6d-4d7f-afb7-b06252f73005	1342ec64-f18e-4860-93cc-f6dd194d56ec	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "https://github.com/guillermobet/files/raw/master/visualization_-_aerial.dwg", "created": "2017-11-23T17:40:23.217872", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "476cdf71-1048-4a6f-a28a-58fff547dae5", "mimetype_inner": null, "last_modified": "2017-12-01T16:53:23.693615", "position": 1, "revision_id": "d15e34ce-171d-4b7c-97fa-7f962f51bc54", "size": 733036, "url_type": "", "id": "1342ec64-f18e-4860-93cc-f6dd194d56ec", "resource_type": null, "name": "Example 3D .dwg file"}}
40ee25d7-9abf-4547-8c61-df984ef0c084	a188dce1-f8e6-466d-8508-c968d5341b3c	036bcac0-c857-4bf0-bc71-1c78ed35d93a	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://192.76.241.245:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/036bcac0-c857-4bf0-bc71-1c78ed35d93a/download/labeled-faces-in-the-wild-recognition.ipynb", "created": "2017-12-01T12:54:05.127144", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:43.266081", "position": 1, "revision_id": "5c1a7014-4c5e-46d7-bf6e-71c09d905edb", "size": 717993, "url_type": "upload", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "resource_type": null, "name": "Labeled Faces in the Wild recognition"}}
295796bb-0304-4b9d-8c86-31d0105478ce	a188dce1-f8e6-466d-8508-c968d5341b3c	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Resource	changed	{"resource": {"mimetype": "application/x-tar", "cache_url": null, "state": "active", "hash": "", "description": "", "format": "TAR", "url": "https://github.com/guillermobet/files/raw/master/12%20steps%20to%20Navier-Stokes.tar.gz", "created": "2017-12-01T12:58:35.877330", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:48:21.527146", "position": 4, "revision_id": "5c1a7014-4c5e-46d7-bf6e-71c09d905edb", "size": 5708395, "url_type": "", "id": "ec1c5422-b8ab-4401-96fb-0792dacb8e40", "resource_type": null, "name": "12 steps to Navier-Stokes"}}
55dc6c28-8dd3-4fc8-9e26-b2dcaf921643	a188dce1-f8e6-466d-8508-c968d5341b3c	4577e551-96f8-4e13-ac81-012a866d00ac	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://192.76.241.245:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/4577e551-96f8-4e13-ac81-012a866d00ac/download/gw150914_tutorial.ipynb", "created": "2017-12-01T12:56:06.860736", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:48:04.508028", "position": 3, "revision_id": "5c1a7014-4c5e-46d7-bf6e-71c09d905edb", "size": 2683661, "url_type": "upload", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "resource_type": null, "name": "GW150914 tutorial"}}
0f7e3381-1f9c-4f83-858b-805af2411e1e	a188dce1-f8e6-466d-8508-c968d5341b3c	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://192.76.241.245:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/1e335b61-123e-4ba4-9c5b-9d1d6309dba9/download/example-machine-learning-notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:34.233655", "position": 0, "revision_id": "5c1a7014-4c5e-46d7-bf6e-71c09d905edb", "size": 703819, "url_type": "upload", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
4ac9bc6e-cc01-4a74-bf84-7e4870cf12c1	a188dce1-f8e6-466d-8508-c968d5341b3c	e4cc8bf6-5e32-4c1f-b22e-109d47340c96	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://192.76.241.245:5000/dataset/1abefb2e-6a83-4004-b7db-74c34b545d2e/resource/e4cc8bf6-5e32-4c1f-b22e-109d47340c96/download/satellite_example.ipynb", "created": "2017-12-01T12:55:06.673960", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:54.872809", "position": 2, "revision_id": "5c1a7014-4c5e-46d7-bf6e-71c09d905edb", "size": 7216, "url_type": "upload", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "resource_type": null, "name": "Satellite example"}}
5e8aafec-0d88-4331-93a0-a3b55fb51a83	76e6f8f4-3797-41b4-8d33-521e6dd3e574	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "https://raw.githubusercontent.com/rhiever/Data-Analysis-and-Machine-Learning-Projects/master/example-data-science-notebook/Example%20Machine%20Learning%20Notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:34.233655", "position": 0, "revision_id": "a62f6486-cf27-4b3f-b739-207b5f69d06c", "size": 703819, "url_type": "", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
16f65ae1-fdc3-4b19-b103-d3139ca6a340	69d4f7f7-7581-4479-92a5-a3c2c7491272	036bcac0-c857-4bf0-bc71-1c78ed35d93a	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "https://raw.githubusercontent.com/ogrisel/notebooks/master/Labeled%2520Faces%2520in%2520the%2520Wild%2520recognition.ipynb", "created": "2017-12-01T12:54:05.127144", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:43.266081", "position": 1, "revision_id": "b9cbf887-ecb8-4874-bb03-1c62f312d158", "size": 717993, "url_type": "", "id": "036bcac0-c857-4bf0-bc71-1c78ed35d93a", "resource_type": null, "name": "Labeled Faces in the Wild recognition"}}
1393f7f7-288e-49ba-991b-abbf80e957d9	46cb05d4-2376-428a-a1cd-161b8b302c37	e4cc8bf6-5e32-4c1f-b22e-109d47340c96	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://unidata.github.io/python-gallery/_downloads/Satellite_Example.ipynb", "created": "2017-12-01T12:55:06.673960", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:54.872809", "position": 2, "revision_id": "92d37aae-e70c-40f9-ab15-028a15ae3991", "size": 7216, "url_type": "", "id": "e4cc8bf6-5e32-4c1f-b22e-109d47340c96", "resource_type": null, "name": "Satellite example"}}
4b7c1581-77d5-4eb3-a941-93beeda2670b	fb9e266b-cc51-41a2-acf4-2154af5bc381	4577e551-96f8-4e13-ac81-012a866d00ac	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "https://losc.ligo.org/s/events/GW150914/GW150914_tutorial.ipynb", "created": "2017-12-01T12:56:06.860736", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:48:04.508028", "position": 3, "revision_id": "065ffe84-177e-4e13-8319-20bce551300f", "size": 2683661, "url_type": "", "id": "4577e551-96f8-4e13-ac81-012a866d00ac", "resource_type": null, "name": "GW150914 tutorial"}}
89db4ca5-603e-49e5-ac90-f9dc13c8081b	d81f707e-48d7-463b-9b3d-fe0eeba390de	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/Example%20Machine%20Learning%20Notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:34.233655", "position": 0, "revision_id": "83811581-08a7-489a-952c-aa3eb3d14c05", "size": 703819, "url_type": "", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
79100e75-d0dc-4016-9ee7-3156f72de664	916b9b8f-1b27-4993-9af7-9759a84288c4	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "https://github.com/guillermobet/files/blob/master/Example%20Machine%20Learning%20Notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:34.233655", "position": 0, "revision_id": "f27b53aa-d2ec-4bf8-8344-e5d116e8eff9", "size": 703819, "url_type": "", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
e4e856e2-f348-40ec-85d1-829dc317b97a	59960add-1787-4215-a266-b50175f55050	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	Resource	changed	{"resource": {"mimetype": null, "cache_url": null, "state": "active", "hash": "", "description": "", "format": "", "url": "https://raw.githubusercontent.com/guillermobet/files/master/Example%20Machine%20Learning%20Notebook.ipynb", "created": "2017-12-01T12:51:28.891625", "extras": {"datastore_active": false}, "cache_last_updated": null, "package_id": "1abefb2e-6a83-4004-b7db-74c34b545d2e", "mimetype_inner": null, "last_modified": "2017-12-01T16:47:34.233655", "position": 0, "revision_id": "a55ac040-dcc7-4a52-89c8-7d6655c3d7a5", "size": 703819, "url_type": "", "id": "1e335b61-123e-4ba4-9c5b-9d1d6309dba9", "resource_type": null, "name": "Example Machine Learning notebook"}}
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.alembic_version (version_num) FROM stdin;
ccd38ad5fced
\.


--
-- Data for Name: api_token; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.api_token (id, name, user_id, created_at, last_access, plugin_extras) FROM stdin;
\.


--
-- Data for Name: dashboard; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.dashboard (user_id, activity_stream_last_viewed, email_last_sent) FROM stdin;
17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 07:05:22.6514	2017-08-08 16:45:41.143096
\.


--
-- Data for Name: dataset_service; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.dataset_service (dataset_id, service_id) FROM stdin;
\.


--
-- Data for Name: doi; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.doi (identifier, package_id, published) FROM stdin;
10.23680/243x4f8c	476cdf71-1048-4a6f-a28a-58fff547dae5	2022-03-16 07:46:04.924983
10.23680/d9c4ly9i	54920aae-f322-4fca-bd09-cd091946632c	2022-03-16 08:14:30.686062
10.23680/hxjs3epq	86b5446b-092a-4467-870c-b61b055d763f	2022-03-16 08:32:48.575136
10.23680/u1grwt6s	d5d29173-addc-4e4d-af7b-59e3b147c817	2022-03-16 09:22:42.553689
10.23680/bbqqpmll	ed56c026-3d32-41d5-9d11-2aa655cb8052	2022-03-16 09:47:38.14573
\.


--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public."group" (id, name, title, description, created, state, type, approval_status, image_url, is_organization) FROM stdin;
724ae83b-ae78-433c-8586-69e7202931c4	china-unicom	China UNICOM	China United Network Communications Group Co., Ltd. (Chinese: 中国联合网络通信集团有限公司) or China Unicom (Chinese: 中国联通) is a Chinese state-owned telecommunications operator in the People's Republic of China. China Unicom is the world's fourth-largest mobile service provider by subscriber base.	2017-08-08 16:46:26.164305	deleted	organization	approved	https://upload.wikimedia.org/wikipedia/en/thumb/f/fa/China_Unicom.svg/252px-China_Unicom.svg.png	t
0c5362f5-b99e-41db-8256-3d0d7549bf4d	tib	TIB	The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.	2017-11-23 17:30:37.757128	active	organization	approved	https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png	t
6284da8e-908c-4666-81c6-64a0fedf10e2	institut-fur-geologie	Institut für Geologie	Leibniz Universität Hannover\r\nCallinstr. 30\r\n30167 Hannover\r\n\r\nhttp://www.geologie.uni-hannover.de/\r\n	2022-03-16 07:42:06.633095	active	organization	approved	https://www.geologie.uni-hannover.de/typo3temp/_processed_/e/4/csm_cf132247a6b40f73102849c767bde47979deccba-fp-3-1-0-0_e2d52b6bf9.jpg	t
2d2ca2a7-26f5-497b-b5a4-a559a28f3042	ag-palm	AG PALM		2022-03-16 07:44:14.760944	active	organization	approved		t
a6ac49d3-2eff-4f4d-bb17-709595cf72d7	institut-fur-umweltplanung	Institut für Umweltplanung 	Institute of Environmental Planning\r\nHerrenhäuser Str. 2, 30419 Hannover	2022-03-16 07:44:15.535151	active	organization	approved	https://data.uni-hannover.de/uploads/group/2021-08-05-071444.382087IUPbildmarke.png	t
\.


--
-- Data for Name: group_extra; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.group_extra (id, group_id, key, value, state) FROM stdin;
\.


--
-- Data for Name: group_extra_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.group_extra_revision (id, group_id, key, value, state, revision_id, continuity_id, expired_id, revision_timestamp, expired_timestamp, current) FROM stdin;
\.


--
-- Data for Name: group_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.group_revision (id, name, title, description, created, state, revision_id, continuity_id, expired_id, revision_timestamp, expired_timestamp, current, type, approval_status, image_url, is_organization) FROM stdin;
724ae83b-ae78-433c-8586-69e7202931c4	china-unicom	China UNICOM	China United Network Communications Group Co., Ltd. (Chinese: 中国联合网络通信集团有限公司) or China Unicom (Chinese: 中国联通) is a Chinese state-owned telecommunications operator in the People's Republic of China. China Unicom is the world's fourth-largest mobile service provider by subscriber base.	2017-08-08 16:46:26.164305	deleted	ccfec652-355d-4640-b04e-9404427ece66	724ae83b-ae78-433c-8586-69e7202931c4	\N	2017-11-23 17:29:52.793785	9999-12-31 00:00:00	\N	organization	approved	https://upload.wikimedia.org/wikipedia/en/thumb/f/fa/China_Unicom.svg/252px-China_Unicom.svg.png	t
724ae83b-ae78-433c-8586-69e7202931c4	china-unicom	China UNICOM	China United Network Communications Group Co., Ltd. (Chinese: 中国联合网络通信集团有限公司) or China Unicom (Chinese: 中国联通) is a Chinese state-owned telecommunications operator in the People's Republic of China. China Unicom is the world's fourth-largest mobile service provider by subscriber base.	2017-08-08 16:46:26.164305	active	729f6192-b932-4413-904c-a72e21f8ef69	724ae83b-ae78-433c-8586-69e7202931c4	\N	2017-08-08 16:46:26.136217	2017-11-23 17:29:52.793785	\N	organization	approved	https://upload.wikimedia.org/wikipedia/en/thumb/f/fa/China_Unicom.svg/252px-China_Unicom.svg.png	t
0c5362f5-b99e-41db-8256-3d0d7549bf4d	tib-iasis	TIB iASiS		2017-11-23 17:30:37.757128	active	34c3de5f-7e58-4806-9177-733da1fca73c	0c5362f5-b99e-41db-8256-3d0d7549bf4d	\N	2017-11-23 17:30:37.750126	2017-11-23 17:31:36.655707	\N	organization	approved		t
0c5362f5-b99e-41db-8256-3d0d7549bf4d	tib-iasis	TIB iASiS		2017-11-23 17:30:37.757128	active	935c959c-8191-4dc4-81b0-50e9e829d325	0c5362f5-b99e-41db-8256-3d0d7549bf4d	\N	2017-11-23 17:31:36.655707	2017-11-23 17:32:08.010838	\N	organization	approved	https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png	t
0c5362f5-b99e-41db-8256-3d0d7549bf4d	tib-iasis	TIB	The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.	2017-11-23 17:30:37.757128	active	6d7701f6-3ad0-4073-a1a9-262f793ac188	0c5362f5-b99e-41db-8256-3d0d7549bf4d	\N	2017-11-24 13:40:21.970443	9999-12-31 00:00:00	\N	organization	approved	https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png	t
0c5362f5-b99e-41db-8256-3d0d7549bf4d	tib-iasis	TIB iASiS	The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.	2017-11-23 17:30:37.757128	active	6a333863-cac8-4957-9ed5-968dc91c74be	0c5362f5-b99e-41db-8256-3d0d7549bf4d	\N	2017-11-23 17:32:08.010838	2017-11-24 13:40:21.970443	\N	organization	approved	https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png	t
\.


--
-- Data for Name: member; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.member (id, group_id, table_id, state, table_name, capacity) FROM stdin;
2349c535-486b-4b4f-b74f-1e1a8ac355da	0c5362f5-b99e-41db-8256-3d0d7549bf4d	17755db4-395a-4b3b-ac09-e8e3484ca700	active	user	admin
6641f04b-0d64-4996-9618-cac9317168fa	0c5362f5-b99e-41db-8256-3d0d7549bf4d	476cdf71-1048-4a6f-a28a-58fff547dae5	active	package	organization
2b690504-675f-4169-b3ac-b8f40ad4ae42	0c5362f5-b99e-41db-8256-3d0d7549bf4d	54920aae-f322-4fca-bd09-cd091946632c	active	package	organization
2c81a645-97ed-4684-91d6-f4964e577fbe	0c5362f5-b99e-41db-8256-3d0d7549bf4d	689fe009-c731-4b3b-a6f2-f04ac1bf7885	active	package	organization
6b0297b6-d813-4f98-9668-cc925f3f4f89	0c5362f5-b99e-41db-8256-3d0d7549bf4d	0eb102b3-06a3-4e2a-b224-e1cc6099b96e	active	package	organization
b94d4d8c-40a4-4c12-86cf-c9bc9833897f	0c5362f5-b99e-41db-8256-3d0d7549bf4d	44892bd1-6fb7-477b-858e-483cb1290798	active	package	organization
312c8a78-d723-45dd-9f38-c0cfd538b154	6284da8e-908c-4666-81c6-64a0fedf10e2	17755db4-395a-4b3b-ac09-e8e3484ca700	active	user	admin
d8cf5e1f-ddad-4c54-9275-b9aec59a824a	6284da8e-908c-4666-81c6-64a0fedf10e2	0ddcfe50-9e31-4225-b68f-e777d72fb859	active	package	organization
af487d52-099b-40c9-aae4-acf7f50ae024	2d2ca2a7-26f5-497b-b5a4-a559a28f3042	17755db4-395a-4b3b-ac09-e8e3484ca700	active	user	admin
b19e894c-0457-48de-bd82-c09204e04310	2d2ca2a7-26f5-497b-b5a4-a559a28f3042	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	active	package	organization
53621450-660f-4476-a23c-6eb3912b6662	0c5362f5-b99e-41db-8256-3d0d7549bf4d	ef96d2db-9cbe-4738-b7bf-da556e12bdc2	active	package	organization
f4ca05fb-c324-48f6-8d7e-32e64f34a179	a6ac49d3-2eff-4f4d-bb17-709595cf72d7	17755db4-395a-4b3b-ac09-e8e3484ca700	active	user	admin
ab99cdd5-9825-486c-9bda-3987d224baaa	a6ac49d3-2eff-4f4d-bb17-709595cf72d7	2dfe1d91-0394-4107-8309-b125d98840cc	active	package	organization
af17bbe4-5acb-4f74-8807-83309f23081b	0c5362f5-b99e-41db-8256-3d0d7549bf4d	86b5446b-092a-4467-870c-b61b055d763f	active	package	organization
6606e7c8-ea1a-4e05-9796-4d74f2bfa01b	0c5362f5-b99e-41db-8256-3d0d7549bf4d	d5d29173-addc-4e4d-af7b-59e3b147c817	active	package	organization
b0aebe05-0c64-4c7d-a145-f56ed094556c	0c5362f5-b99e-41db-8256-3d0d7549bf4d	ed56c026-3d32-41d5-9d11-2aa655cb8052	active	package	organization
2ae80d7e-b440-4d08-950a-7cd64eb8e88b	0c5362f5-b99e-41db-8256-3d0d7549bf4d	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	deleted	package	organization
c9b0341e-4b50-4eb1-84d9-3f9500f57b07	0c5362f5-b99e-41db-8256-3d0d7549bf4d	1abefb2e-6a83-4004-b7db-74c34b545d2e	deleted	package	organization
\.


--
-- Data for Name: member_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.member_revision (id, table_id, group_id, state, revision_id, continuity_id, expired_id, revision_timestamp, expired_timestamp, current, table_name, capacity) FROM stdin;
d2b27305-ea4e-45d9-999d-e6d91d8fb620	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	724ae83b-ae78-433c-8586-69e7202931c4	active	2b61e1eb-c56d-4852-b55c-47f0e7308c6e	d2b27305-ea4e-45d9-999d-e6d91d8fb620	\N	2017-08-08 16:50:26.684564	2017-08-08 16:50:49.589423	\N	package	public
8623a263-c980-43b0-a44b-486b4234d014	903d964e-9c2c-47d2-8708-25363ef8d772	724ae83b-ae78-433c-8586-69e7202931c4	active	65a08933-48aa-426b-bf8a-d11aa32dca95	8623a263-c980-43b0-a44b-486b4234d014	\N	2017-08-08 16:52:29.604017	2017-08-08 16:52:48.401496	\N	package	public
a12d3530-7d39-440a-959d-0d50c8a96db4	817668d7-be70-479e-92c6-c7e4e8182603	724ae83b-ae78-433c-8586-69e7202931c4	active	8b393d77-16b0-4e7c-b64e-63acf71345d5	a12d3530-7d39-440a-959d-0d50c8a96db4	\N	2017-08-08 16:54:35.123783	2017-08-08 16:55:27.252098	\N	package	public
af91382a-f6df-4f5a-ad44-5d3a1f053a0c	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	724ae83b-ae78-433c-8586-69e7202931c4	active	dd70f0dc-ac9d-4ea3-8888-ddb077b44502	af91382a-f6df-4f5a-ad44-5d3a1f053a0c	\N	2017-08-08 16:57:30.229943	2017-08-08 16:57:41.818059	\N	package	public
93198c10-9de3-464d-bc9a-190ef299f80c	15589e3b-0b24-48de-b724-4216f1b28a9f	724ae83b-ae78-433c-8586-69e7202931c4	active	454d15f3-840e-4b08-939e-59a7b5419c85	93198c10-9de3-464d-bc9a-190ef299f80c	\N	2017-11-23 16:44:34.681607	2017-11-23 16:51:07.974293	\N	package	organization
6be6100e-8269-40c4-abd9-bbaf9b0e1f24	c5895f45-e257-4137-9310-5155f2ec2b22	724ae83b-ae78-433c-8586-69e7202931c4	active	82682f2c-fa0b-4c03-bb4e-b4b9688a30fe	6be6100e-8269-40c4-abd9-bbaf9b0e1f24	\N	2017-11-23 15:46:09.672312	2017-11-23 16:51:17.292185	\N	package	organization
c4a20d0e-dc53-496f-92ec-157dae4185cb	46a43786-223c-4bd8-b4d0-ca1997e78e70	724ae83b-ae78-433c-8586-69e7202931c4	active	0308d025-a61d-4912-927c-b83a259af206	c4a20d0e-dc53-496f-92ec-157dae4185cb	\N	2017-11-23 16:54:02.990389	2017-11-23 16:54:09.765566	\N	package	public
28d19ab4-6c8d-460d-90a2-55d8443425ac	46a43786-223c-4bd8-b4d0-ca1997e78e70	724ae83b-ae78-433c-8586-69e7202931c4	active	0308d025-a61d-4912-927c-b83a259af206	28d19ab4-6c8d-460d-90a2-55d8443425ac	\N	2017-11-23 16:54:02.990389	2017-11-23 16:55:10.759507	\N	package	organization
e385af4c-8676-4dd1-9c64-5c2cc034f8e2	3eafe76b-5d42-43ff-98cb-248a69d3e0cc	724ae83b-ae78-433c-8586-69e7202931c4	active	a40e9a0b-920d-4831-be14-2143eff3e1f5	e385af4c-8676-4dd1-9c64-5c2cc034f8e2	\N	2017-11-23 16:52:07.134719	2017-11-23 16:55:17.143128	\N	package	organization
ac6f2039-a306-4534-bcc6-0b9816adb655	54f83106-f2bf-45a8-8523-53a415c99e47	724ae83b-ae78-433c-8586-69e7202931c4	active	1d7a208f-a535-4f6d-ad3c-18d8c9866feb	ac6f2039-a306-4534-bcc6-0b9816adb655	\N	2017-11-23 17:07:42.003088	2017-11-23 17:07:50.644253	\N	package	public
e70bae4f-f333-4bc9-9f77-60613f9750ee	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	724ae83b-ae78-433c-8586-69e7202931c4	active	2b61e1eb-c56d-4852-b55c-47f0e7308c6e	e70bae4f-f333-4bc9-9f77-60613f9750ee	\N	2017-08-08 16:50:26.684564	2017-11-23 17:29:52.524044	\N	package	organization
73042b26-2536-4ce0-a73c-aee0f2803814	817668d7-be70-479e-92c6-c7e4e8182603	724ae83b-ae78-433c-8586-69e7202931c4	active	8b393d77-16b0-4e7c-b64e-63acf71345d5	73042b26-2536-4ce0-a73c-aee0f2803814	\N	2017-08-08 16:54:35.123783	2017-11-23 17:29:52.589459	\N	package	organization
aaef9a5e-97fb-42c5-bfd1-817d87f1d89c	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	724ae83b-ae78-433c-8586-69e7202931c4	active	dd70f0dc-ac9d-4ea3-8888-ddb077b44502	aaef9a5e-97fb-42c5-bfd1-817d87f1d89c	\N	2017-08-08 16:57:30.229943	2017-11-23 17:29:52.65148	\N	package	organization
435ee122-ae72-4742-b422-732604093dab	903d964e-9c2c-47d2-8708-25363ef8d772	724ae83b-ae78-433c-8586-69e7202931c4	active	65a08933-48aa-426b-bf8a-d11aa32dca95	435ee122-ae72-4742-b422-732604093dab	\N	2017-08-08 16:52:29.604017	2017-11-23 17:29:52.708328	\N	package	organization
b32880e4-f971-4093-ae9e-ee131df87fcc	17755db4-395a-4b3b-ac09-e8e3484ca700	724ae83b-ae78-433c-8586-69e7202931c4	active	729f6192-b932-4413-904c-a72e21f8ef69	b32880e4-f971-4093-ae9e-ee131df87fcc	\N	2017-08-08 16:46:26.136217	2017-11-23 17:29:52.793785	\N	user	admin
dbb6a2b2-30dd-43c3-88eb-d4d57443bd00	cc7e17a1-34c9-4cb5-80c9-ede21ee6c79d	724ae83b-ae78-433c-8586-69e7202931c4	active	2379ec08-54f7-4f8a-9cb8-a550f3535800	dbb6a2b2-30dd-43c3-88eb-d4d57443bd00	\N	2017-11-23 16:59:32.133562	2017-11-23 17:29:52.793785	\N	package	organization
3a6f7351-6fbb-45bb-a3c6-3e336741a5e0	54f83106-f2bf-45a8-8523-53a415c99e47	724ae83b-ae78-433c-8586-69e7202931c4	active	1d7a208f-a535-4f6d-ad3c-18d8c9866feb	3a6f7351-6fbb-45bb-a3c6-3e336741a5e0	\N	2017-11-23 17:07:42.003088	2017-11-23 17:28:58.690985	\N	package	organization
dc32aaff-4770-4835-b785-972587d83eb1	599fea7c-9744-4392-b9cb-5863b4e55756	724ae83b-ae78-433c-8586-69e7202931c4	active	b4332ffc-49c7-4942-bdcb-2c53f2229dc1	dc32aaff-4770-4835-b785-972587d83eb1	\N	2017-11-23 14:57:51.835359	2017-11-23 17:29:52.793785	\N	package	organization
2349c535-486b-4b4f-b74f-1e1a8ac355da	17755db4-395a-4b3b-ac09-e8e3484ca700	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	34c3de5f-7e58-4806-9177-733da1fca73c	2349c535-486b-4b4f-b74f-1e1a8ac355da	\N	2017-11-23 17:30:37.750126	9999-12-31 00:00:00	\N	user	admin
6641f04b-0d64-4996-9618-cac9317168fa	476cdf71-1048-4a6f-a28a-58fff547dae5	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	f732828b-2166-4541-9128-f838a260ae1b	6641f04b-0d64-4996-9618-cac9317168fa	\N	2017-11-23 17:37:00.356594	9999-12-31 00:00:00	\N	package	organization
60680459-ed13-4359-902b-4aec19c38343	476cdf71-1048-4a6f-a28a-58fff547dae5	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	f732828b-2166-4541-9128-f838a260ae1b	60680459-ed13-4359-902b-4aec19c38343	\N	2017-11-23 17:37:00.356594	2017-11-23 17:37:19.886163	\N	package	public
2ae80d7e-b440-4d08-950a-7cd64eb8e88b	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	39eb3d69-8ca4-477c-b7c6-7556c833986b	2ae80d7e-b440-4d08-950a-7cd64eb8e88b	\N	2017-11-24 13:36:15.8815	9999-12-31 00:00:00	\N	package	organization
26393b5a-1621-416b-b35c-0ab0c3e53c30	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	39eb3d69-8ca4-477c-b7c6-7556c833986b	26393b5a-1621-416b-b35c-0ab0c3e53c30	\N	2017-11-24 13:36:15.8815	2017-11-24 13:37:06.590149	\N	package	public
2b690504-675f-4169-b3ac-b8f40ad4ae42	54920aae-f322-4fca-bd09-cd091946632c	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	261614c5-63db-4f81-83d2-45690db30b97	2b690504-675f-4169-b3ac-b8f40ad4ae42	\N	2017-11-24 13:42:19.401789	9999-12-31 00:00:00	\N	package	organization
8ff5bbde-d923-46bf-8cde-21c4fbce0f57	54920aae-f322-4fca-bd09-cd091946632c	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	261614c5-63db-4f81-83d2-45690db30b97	8ff5bbde-d923-46bf-8cde-21c4fbce0f57	\N	2017-11-24 13:42:19.401789	2017-11-24 13:42:36.230296	\N	package	public
901a122c-ebc5-41d1-a7f9-e15f2a4171c7	acc9dc22-eff3-486b-a715-9a69ef93ade0	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	dea564f1-30b2-4e1a-85dc-f13abbd0803e	901a122c-ebc5-41d1-a7f9-e15f2a4171c7	\N	2017-11-23 17:32:40.502714	2017-12-01 12:26:03.416187	\N	package	organization
0ae88343-e605-4008-9778-c3151a7cec40	bf46d212-6fde-4670-ab59-52bb38c513bc	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	9c5af1cf-98c7-4a89-8c5d-4acc9a801b72	0ae88343-e605-4008-9778-c3151a7cec40	\N	2017-11-28 19:31:59.859318	2017-12-01 12:26:42.710983	\N	package	organization
c9b0341e-4b50-4eb1-84d9-3f9500f57b07	1abefb2e-6a83-4004-b7db-74c34b545d2e	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	91daa1ea-e394-4b70-a9e0-366b7c0b95fe	c9b0341e-4b50-4eb1-84d9-3f9500f57b07	\N	2017-12-01 12:51:12.212384	9999-12-31 00:00:00	\N	package	organization
1e801919-000a-48b7-855a-d1536eb3a808	1abefb2e-6a83-4004-b7db-74c34b545d2e	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	91daa1ea-e394-4b70-a9e0-366b7c0b95fe	1e801919-000a-48b7-855a-d1536eb3a808	\N	2017-12-01 12:51:12.212384	2017-12-01 12:51:28.881885	\N	package	public
2c81a645-97ed-4684-91d6-f4964e577fbe	689fe009-c731-4b3b-a6f2-f04ac1bf7885	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	4f894272-891f-42e2-a01b-184fe666f896	2c81a645-97ed-4684-91d6-f4964e577fbe	\N	2017-12-19 12:46:02.680685	9999-12-31 00:00:00	\N	package	organization
6b0297b6-d813-4f98-9668-cc925f3f4f89	0eb102b3-06a3-4e2a-b224-e1cc6099b96e	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	069046d5-6db8-459d-800b-e57a2c600588	6b0297b6-d813-4f98-9668-cc925f3f4f89	\N	2017-12-19 12:54:07.736735	9999-12-31 00:00:00	\N	package	organization
11c6c5ca-e09e-431e-8be1-4c4b61683818	0eb102b3-06a3-4e2a-b224-e1cc6099b96e	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	069046d5-6db8-459d-800b-e57a2c600588	11c6c5ca-e09e-431e-8be1-4c4b61683818	\N	2017-12-19 12:54:07.736735	2017-12-19 12:54:16.505959	\N	package	public
e17dac18-6b41-4ec2-a716-9bc21aacef23	c6e1f0f0-271c-454a-ac89-14f3b55211a4	0c5362f5-b99e-41db-8256-3d0d7549bf4d	active	e5f2392a-5484-48b4-bec3-f57fac558025	e17dac18-6b41-4ec2-a716-9bc21aacef23	\N	2017-12-19 12:46:52.491415	2018-01-09 11:21:47.915395	\N	package	organization
\.


--
-- Data for Name: package; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package (id, name, title, version, url, notes, author, author_email, maintainer, maintainer_email, state, license_id, type, owner_org, private, metadata_modified, creator_user_id, metadata_created) FROM stdin;
0ddcfe50-9e31-4225-b68f-e777d72fb859	luh-aftershocks-and-forearc-mechanics	Aftershocks of great megathrust earthquakes and the mechanics of forearcs		https://data.uni-hannover.de/dataset/aftershocks-and-forearc-mechanics	This data repository contains the data to the manuscript "Aftershocks of great megathrust earthquakes and the mechanics of forearcs" by A. Dielforder, G. M. Bocchini, K. Kemna, R. M. Harrington, A. Hampel, and O. Oncken (in prep).\r\n\r\nThe file reference-models-japan-chile.zip contains the ABAQUS ODBs for the models presented in the main text.\r\nThe file "alternative-models-japan-chile.zip" contains the ABAQUS ODBs for the models presented in the Supplementary Information.\r\n\r\nThe files "Catalogue-Chile.csv" and "Catalogue-Japan.csv" contain the filtered seismic catalogues and stress drop data. 	Armin Dielforder, Gian Maria Bocchini, Kilian B. Kemna, Rebecca M Harrington, Andrea Hampel, Onno Oncken	dielforder@geowi.uni-hannover.de	Armin Dielforder	dielforder@geowi.uni-hannover.de	active	CC-BY-NC-3.0	vdataset	6284da8e-908c-4666-81c6-64a0fedf10e2	f	2022-03-16 07:44:14.209154	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 07:44:14.209142
c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	luh-a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis	A generic gust definition and detection method based on wavelet-analysis		https://data.uni-hannover.de/dataset/a-generic-gust-definition-and-detection-method-based-on-wavelet-analysis	This dataset is associated with the paper Knoop et al. (2019) titled  "A generic gust definition and detection method based on wavelet-analysis" published in "Advances in Science and Research (ASR)" within the Special Issue: 18th EMS Annual Meeting: European Conference for Applied Meteorology and Climatology 2018. It contains the data and analysis software required to recreate all figures in the publication.	Knoop, H., F. Ament, B. Maronga	knoop@muk.uni-hannover.de	Helge Knoop	knoop@muk.uni-hannover.de	active	CC-BY-3.0	vdataset	2d2ca2a7-26f5-497b-b5a4-a559a28f3042	f	2022-03-16 07:44:14.935209	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 07:44:14.935203
ef96d2db-9cbe-4738-b7bf-da556e12bdc2	luh-a-neural-approach-for-text-extraction-from-scholarly-figures	A Neural Approach for Text Extraction from Scholarly Figures		https://data.uni-hannover.de/dataset/a-neural-approach-for-text-extraction-from-scholarly-figures	# A Neural Approach for Text Extraction from Scholarly Figures\r\nThis is the readme for the supplemental data for our ICDAR 2019 paper.\r\n\r\nYou can read our paper via IEEE here: https://ieeexplore.ieee.org/document/8978202\r\n\r\nIf you found this dataset useful, please consider citing our paper:\r\n\r\n\t@inproceedings{DBLP:conf/icdar/MorrisTE19,\r\n\t  author    = {David Morris and\r\n\t\t\t\t   Peichen Tang and\r\n\t\t\t\t   Ralph Ewerth},\r\n\t  title     = {A Neural Approach for Text Extraction from Scholarly Figures},\r\n\t  booktitle = {2019 International Conference on Document Analysis and Recognition,\r\n\t\t\t\t   {ICDAR} 2019, Sydney, Australia, September 20-25, 2019},\r\n\t  pages     = {1438--1443},\r\n\t  publisher = {{IEEE}},\r\n\t  year      = {2019},\r\n\t  url       = {https://doi.org/10.1109/ICDAR.2019.00231},\r\n\t  doi       = {10.1109/ICDAR.2019.00231},\r\n\t  timestamp = {Tue, 04 Feb 2020 13:28:39 +0100},\r\n\t  biburl    = {https://dblp.org/rec/conf/icdar/MorrisTE19.bib},\r\n\t  bibsource = {dblp computer science bibliography, https://dblp.org}\r\n\t}\r\n\r\nThis work was financially supported by the German Federal Ministry of Education and Research (BMBF) and European Social Fund (ESF) (InclusiveOCW project, no. 01PE17004).\r\n## Datasets\r\nWe used different sources of data for testing, validation, and training. Our testing set was assembled by the work we cited by Böschen et al. We excluded the DeGruyter dataset, and use it as our validation dataset.\r\n### Testing\r\nThese datasets contain a readme with license information. Further information about the associated project can be found in the authors' published work we cited: https://doi.org/10.1007/978-3-319-51811-4_2\r\n### Validation\r\nThe DeGruyter dataset does not include the labeled images due to license restrictions. As of writing, the images can still be downloaded from DeGruyter via the links in the readme. Note that depending on what program you use to strip the images out of the PDF they are provided in, you may have to re-number the images.\r\n### Training\r\nWe used [label_generator](https://github.com/domoritz/label_generator)'s  generated dataset, which the author made available on a requester-pays [amazon s3 bucket](s3://escience.washington.edu.viziometrics).\r\nWe also used the Multi-Type Web Images dataset, which is mirrored [here](https://tianchi.aliyun.com/competition/introduction.htm?spm=5176.100066.0.0.3bcad780oQ9Ce4&raceId=231651).\r\n## Code\r\nWe have made our code available in `code.zip`. We will upload code, announce further news, and field questions via the [github repo](https://github.com/david-morris/Neural-Figure-Text).\r\n\r\nOur text detection network is adapted from [Argman's EAST implementation](https://github.com/argman/EAST). The `EAST/checkpoints/ours` subdirectory contains the trained weights we used in the paper.\r\n\r\nWe used a tesseract script to run text extraction from detected text rows. This is inside our code `code.tar` as `text_recognition_multipro.py`.\r\n\r\nWe used a java script provided by Falk Böschen and adapted to our file structure.  We included this as `evaluator.jar`.\r\n\r\nParameter sweeps are automated by `param_sweep.rb`. This file also shows how to invoke all of these components.	David Morris, Peichen Tang, and Ralph Ewerth		David Morris, Peichen Tang, and Ralph Ewerth		active	CC-BY-3.0	vdataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-03-16 07:44:15.1663	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 07:44:15.166295
2dfe1d91-0394-4107-8309-b125d98840cc	luh-areas-in-lower-saxony-with-low-and-medium-spatial-vulnerability-to-ground-mounted-photovoltaics	Areas in Lower Saxony with low and medium spatial vulnerability to ground mounted photovoltaics		https://data.uni-hannover.de/dataset/areas-in-lower-saxony-with-low-and-medium-spatial-vulnerability-to-ground-mounted-photovoltaics	#Niedersächsische Flächen mit geringem und mittlerem Raumwiderstand gegenüber Photovoltaik-Freiflächenanlagen (English version below)\r\n\r\nDie Shapefiles zeigen Flächen in Niedersachsen mit geringem und mittlerem Raumwiderstand gegenüber Photovoltaik-Freiflächenanlagen (Badelt et al. 2020), die als „räumliche Fahrrinne“ für eine nachhaltige Energiewende dienen können. Es kann davon ausgegangen werden, dass vor allem auf den Flächen mit geringem Raumwiderstand der Ausbau von Freiflächenphotovoltaik weitgehend ohne Konflikte mit dem Naturschutz oder der menschlichen Gesundheit gelingt.\r\n\r\nDie verwendeten __Grundlagendaten__ und ihre Einordnung in Raumwiderstandsklassen können aus Badelt et al. (2020) entnommen werden: GeoBasis-DE/BKG 2019 (Nutzungsbedingungen: https://sg.geodatenzentrum.de/web_public/nutzungsbedingungen.pdf), Atlas Deutscher Brutvogelarten 2014, LGLN 2019, MU 2019; NLWKN 2018; NLWKN 2019. Gegenüber der ursprünglichen Analyse wurden Aktualisierungen vorgenommen, die sich auf die exaktere Abgrenzung der Straßen und Bahnstrecken sowie landwirtschaftlicher Sonderkulturen beziehen. Flächen mit geringem Raumwiderstand gegenüber PV-Freiflächenanlagen umfassen damit in Niedersachsen 618.114 ha (ehemals 563.279 ha). Einem mittleren Raumwiderstand werden 860.195 ha (ehemals 766.107 ha) zugeordnet. \r\n\r\n__English version__\r\n\r\nThe shapefiles display areas with low and medium spatial vulnerability to ground-mounted photovoltaic systems (Badelt et al. 2020), which can serve as a "spatial fairway" for a sustainable energy transition. It can be assumed that the expansion of ground-mounted photovoltaics in areas with low spatial vulnerability is largely possible without conflicts with nature conservation or human well-being. \r\n\r\nThe basic data used and their classification into classes of spatial vulnerability can be taken from Badelt et al. (2020): GeoBasis-DE/BKG 2017(Terms of use: https://sg.geodatenzentrum.de/web_public/nutzungsbedingungen.pdf), Atlas of German Breeding Bird Species 2014, LGLN 2019, MU 2019; NLWKN 2018; NLWKN 2019. Compared to the original analysis, updates were made that relate to the more precise differentiation of roads and railroad lines as well as special agricultural crops. Areas with low spatial vulnerability to ground-mounted PV systems thus comprise 618,114 ha (formerly 563,279 ha) in Lower Saxony. A medium spatial vulnerability is assigned to 860,195 ha (formerly 766,107 ha).\r\n\r\n__Projected Coordinate System:__ ETRS_1989_UTM_Zone_32N_8stellen\r\n\r\n__Referenzen / References:__  \r\n\r\nBadelt, O.; Niepelt, R.; Wiehe, J.; Matthies, S.; Gewohn, T.; Stratmann, M.; Brendel, R. & Haaren, C. von (2020): Integration von Solarenergie in die niedersächsische Energielandschaft (INSIDE). Institut für Solarenergieforschung GmbH Hameln/Emmertal, Institut für Umweltplanung und Institut für Festkörperphysik der Leibniz Universität. Hannover. 128 Seiten, Anhang. \r\n\r\n__Förderung / Funding:__ Der Datensatz resultiert aus dem Forschungsprojekt „Integration von Solarenergie in die niedersächsische Energielandschaft (INSIDE)“, das vom Niedersächsischen Ministerium für Umwelt, Energie, Bauen und Klimaschutz gefördert wurde (Antragsnummern ZW6-80150424/ZW6-80150425).\r\n	Ole Badelt, Julia Wiehe, Christina von Haaren		Ole Badelt, Julia Wiehe, Christina von Haaren		active	CC-BY-3.0	vdataset	a6ac49d3-2eff-4f4d-bb17-709595cf72d7	f	2022-03-16 07:44:15.651763	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 07:44:15.65176
476cdf71-1048-4a6f-a28a-58fff547dae5	example-cad	Example CAD Visualizations		https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html	Example usage of CAD visualization in 2D and 3D using CKAN Views.	Autodesk				active	cc-by	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-03-16 07:54:28.333206	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:37:00.3629
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Example Video Visualizations			Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.\r\nVideo about boundary value problem of a push rod. The video was published by Leibniz University Hannover.\r\nVideo about boundary value problem of a spring. The video was published by Leibniz University Hannover.	John Doe				active	cc-by	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-03-16 08:19:58.017397	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
1abefb2e-6a83-4004-b7db-74c34b545d2e	jupyter-notebooks	Jupyter notebooks		https://unidata.github.io/online-python-training/introduction.html	A collection of Jupyter Notebooks for science related projects\r\n\r\n1. LIGO Gravitational Wave Data\r\n2. Satellite Imagery Analysis\r\n3. 12 Steps to Navier-Stokes\r\n4. Computer Vision\r\n5. Machine Learning	Lorena A. Barba				deleted	cc-by	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2021-03-03 10:11:48.942065	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-01 12:51:12.218503
86b5446b-092a-4467-870c-b61b055d763f	example-documents-visualizations	Example Documents Visualizations			This is an example Dataset showing visualizations for documents in different formats. 	John Doe				active	notspecified	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-03-16 09:13:40.783431	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 08:31:24.461479
d5d29173-addc-4e4d-af7b-59e3b147c817	example-data-formats-visualizations	Example Data Formats Visualizations			This is an example Dataset showing visualizations for data in different formats.	John Doe				active	notspecified	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-03-16 09:38:08.538479	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 09:17:57.26675
ed56c026-3d32-41d5-9d11-2aa655cb8052	data-service-example-jupyternotebook	Data-Service example (JupyterNotebook)			This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. 	John Doe				active	notspecified	service	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-03-16 09:52:16.20723	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 09:43:34.017574
ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	example-cad-2	Pangaea CAD files			Example usage of CAD using Ckan View with information provided by PANGAEA.					deleted	cc-by	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2021-03-03 10:14:21.513141	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:36:15.887852
\.


--
-- Data for Name: package_extra; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package_extra (id, key, value, state, package_id) FROM stdin;
adf12ac1-5e68-45ca-8adc-10a50e8f7deb	foobar	baz	active	476cdf71-1048-4a6f-a28a-58fff547dae5
de4ce92a-db2e-4ff3-8f3e-6ec079712f9a	doi_publisher	LUIS	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
6517f79d-e53c-46aa-9e2a-046e55f5a9d5	source_metadata_created	2021-11-18T12:12:04.400313	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
50a8b328-dc08-4f3e-823b-4b5cc68a7295	source_metadata_modified	2022-01-20T10:58:45.613744	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
0a840db7-1041-4a3c-ad73-927aedcfa28a	doi	10.25835/0072357	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
4292fe23-f9a0-4db8-b302-f18f1a8a51d6	domain	https://data.uni-hannover.de	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
cdc49d9c-85d2-4bfa-be4c-f662608b7fa7	doi_status	true	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
ded882fd-3972-48bf-afc8-3651dcc681b9	terms_of_usage	Yes	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
4e8ae16b-220e-4803-89c9-267bf63bad6d	repository_name	Leibniz University Hannover	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
5998a6b5-16a6-4730-8ddb-675dafccb0b0	have_copyright	Yes	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
bfd603f9-be60-4f1c-9b73-f359848ea694	doi_date_published	2021-11-18	active	0ddcfe50-9e31-4225-b68f-e777d72fb859
9d565b6c-b3a6-4574-9ebe-0e43f008d549	doi_publisher	LUIS	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
703203f9-d749-44a4-883f-5f0e4b321d46	source_metadata_created	2019-07-09T17:21:22.824534	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
4e474ae6-0e37-4bcf-9b04-3fd9e5d9ba75	source_metadata_modified	2022-01-20T10:58:47.075885	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
fc3c7fdb-0fdc-41e1-ba8a-7b61bf70af0b	doi	10.25835/0067988	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
f174f331-0401-43d8-ac6a-0bf8357f565f	domain	https://data.uni-hannover.de	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
c0081d4c-5f5a-497e-aaf7-0f2046bcfcdc	doi_status	true	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
15d0fe74-9c1c-4621-a721-9f20a1f95fd4	terms_of_usage	Yes	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
75b1ff8c-09aa-492c-a3c2-d2349748bf45	repository_name	Leibniz University Hannover	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
8dad3c63-d00c-4fa2-a7c8-1b9452b3b7e3	have_copyright	Yes	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
dd89e296-4c59-4d5b-b05b-e1abb89de9a0	doi_date_published	2019-07-10	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033
2f5fbbbc-387d-4786-8367-ee06f195cf65	doi_publisher	LUIS	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
a285fc1f-c590-40f4-bfb0-1a0ca45b6f45	source_metadata_created	2019-06-27T16:29:02.921892	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
ca1edce9-379d-4e81-91de-60f86551da2d	source_metadata_modified	2022-01-20T13:48:50.142253	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
88018cec-1360-4030-9917-803e571ce7c7	doi	10.25835/0030443	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
003720ff-d29a-42f9-b538-e6b51862a153	domain	https://data.uni-hannover.de	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
86e0f905-2b16-47fe-8f90-39a7c8031c8b	doi_status	true	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
73cae240-5b13-479c-928a-4942ba81c086	terms_of_usage	Yes	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
2a819169-e728-4459-8df3-388db401cf69	repository_name	Leibniz University Hannover	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
c073247a-201f-4096-b2b1-a3eac727d750	have_copyright	Yes	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
2c3d7561-72fb-4eb6-9b74-f67c84ea57c4	doi_date_published	2019-06-27	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2
7e27f763-6649-4430-a7f2-4c95b278effa	doi_publisher	LUIS	active	2dfe1d91-0394-4107-8309-b125d98840cc
5b9c6f9b-96e3-4bf2-96fe-670a0710b30f	source_metadata_created	2022-01-06T14:28:00.373658	active	2dfe1d91-0394-4107-8309-b125d98840cc
34f7ea17-e534-40d4-a9d4-9a35addd9447	source_metadata_modified	2022-01-20T11:49:27.432645	active	2dfe1d91-0394-4107-8309-b125d98840cc
350ed61e-9f8b-46e8-93ec-b2e55a48b505	doi	10.25835/0023628	active	2dfe1d91-0394-4107-8309-b125d98840cc
394154b1-5c99-4485-aefa-44edfb259ae0	domain	https://data.uni-hannover.de	active	2dfe1d91-0394-4107-8309-b125d98840cc
c05d4868-5cf9-4c62-a9b3-5dcb0d7dc938	doi_status	true	active	2dfe1d91-0394-4107-8309-b125d98840cc
6fd51479-dd2f-40ee-87b5-9d6f1228387e	terms_of_usage	Yes	active	2dfe1d91-0394-4107-8309-b125d98840cc
a664468d-52aa-4ff5-883d-49065932fa8c	repository_name	Leibniz University Hannover	active	2dfe1d91-0394-4107-8309-b125d98840cc
997c244a-d330-4887-9811-50ff2d7c06a1	have_copyright	Yes	active	2dfe1d91-0394-4107-8309-b125d98840cc
60d85577-7530-442f-9b50-3d9b2c3e48da	doi_date_published	2022-01-06	active	2dfe1d91-0394-4107-8309-b125d98840cc
cf80de8f-3917-4b70-ad99-6391d62eb764	services_used_list		active	476cdf71-1048-4a6f-a28a-58fff547dae5
e9f58177-838d-4634-822a-7693b65b7b79	orcid		active	476cdf71-1048-4a6f-a28a-58fff547dae5
f6b00a93-184d-4c7e-9d2a-81f1b7970931	services_used_list		active	54920aae-f322-4fca-bd09-cd091946632c
1d827ade-5971-471a-919f-652e9519fff2	orcid		active	54920aae-f322-4fca-bd09-cd091946632c
cf631a59-4dca-4f90-8434-9a2b525336b2			active	86b5446b-092a-4467-870c-b61b055d763f
7fde9241-5061-4500-ae38-900993533762	services_used_list		active	86b5446b-092a-4467-870c-b61b055d763f
2b2b3aed-8ea8-4efe-9362-bb72a77987a0	orcid		active	86b5446b-092a-4467-870c-b61b055d763f
a01d1cf5-2b3f-4833-809b-4d0d9f1a3348	extra_authors	[{"extra_author": "", "orcid": ""}]	active	86b5446b-092a-4467-870c-b61b055d763f
c7742f16-7299-48b5-88d5-324f501dfdfb			active	d5d29173-addc-4e4d-af7b-59e3b147c817
0c37e456-0d12-4388-b67c-b09841895edf	services_used_list		active	d5d29173-addc-4e4d-af7b-59e3b147c817
67d3db5b-b6df-47f1-8034-b1c7b0300e56	orcid		active	d5d29173-addc-4e4d-af7b-59e3b147c817
d7222fa8-f933-4b25-a6f1-08a80d7e5228	extra_authors	[{"extra_author": "", "orcid": ""}]	active	d5d29173-addc-4e4d-af7b-59e3b147c817
d12eb6f2-7c84-4e70-b656-0b55b9689125			active	ed56c026-3d32-41d5-9d11-2aa655cb8052
56e5c8c4-2861-444f-930b-0983eeb2d6d8	datasets_served_list		active	ed56c026-3d32-41d5-9d11-2aa655cb8052
3baaa67d-22f1-4682-bac2-59db51ffe1d3	orcid		active	ed56c026-3d32-41d5-9d11-2aa655cb8052
45390c6c-0302-4ea6-9571-b9a97f2938d5	extra_authors	[{"extra_author": "", "orcid": ""}]	active	ed56c026-3d32-41d5-9d11-2aa655cb8052
\.


--
-- Data for Name: package_extra_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package_extra_revision (id, key, value, revision_id, state, package_id, continuity_id, expired_id, revision_timestamp, expired_timestamp, current) FROM stdin;
adf12ac1-5e68-45ca-8adc-10a50e8f7deb	foobar	baz	7a7537ca-0c0c-4501-b244-a3d813e376d1	active	476cdf71-1048-4a6f-a28a-58fff547dae5	adf12ac1-5e68-45ca-8adc-10a50e8f7deb	\N	2017-12-05 12:29:57.69185	9999-12-31 00:00:00	\N
\.


--
-- Data for Name: package_member; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package_member (package_id, user_id, capacity, modified) FROM stdin;
\.


--
-- Data for Name: package_relationship; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package_relationship (id, subject_package_id, object_package_id, type, comment, state) FROM stdin;
\.


--
-- Data for Name: package_relationship_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package_relationship_revision (id, subject_package_id, object_package_id, type, comment, revision_id, continuity_id, state, expired_id, revision_timestamp, expired_timestamp, current) FROM stdin;
\.


--
-- Data for Name: package_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package_revision (id, name, title, version, url, notes, author, author_email, maintainer, maintainer_email, revision_id, state, continuity_id, license_id, expired_id, revision_timestamp, expired_timestamp, current, type, owner_org, private, metadata_modified, creator_user_id, metadata_created) FROM stdin;
611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	event-information	Event information			Events where several users participated					2b61e1eb-c56d-4852-b55c-47f0e7308c6e	draft	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	cc-by	\N	2017-08-08 16:50:26.684564	2017-08-08 16:50:50.836029	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:50:26.707978	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:50:26.707962
903d964e-9c2c-47d2-8708-25363ef8d772	services-information	Services information			Several services offered in our company					65a08933-48aa-426b-bf8a-d11aa32dca95	draft	903d964e-9c2c-47d2-8708-25363ef8d772	cc-by	\N	2017-08-08 16:52:29.604017	2017-08-08 16:52:49.648027	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:52:29.614984	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:52:29.614969
817668d7-be70-479e-92c6-c7e4e8182603	internet-dataset	Internet dataset			Information about the users of our internet services.	Unicom	unicom@email.com	maintainer@email.com	maintainer@email.com	8b393d77-16b0-4e7c-b64e-63acf71345d5	draft	817668d7-be70-479e-92c6-c7e4e8182603	cc-by	\N	2017-08-08 16:54:35.123783	2017-08-08 16:55:28.496897	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:54:35.136352	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:54:35.136338
4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	mobile-plans	Mobile plans			Users and their mobile plans					dd70f0dc-ac9d-4ea3-8888-ddb077b44502	draft	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	cc-by	\N	2017-08-08 16:57:30.229943	2017-08-08 16:57:43.111847	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:57:30.243013	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:57:30.243005
599fea7c-9744-4392-b9cb-5863b4e55756	example	example								b4332ffc-49c7-4942-bdcb-2c53f2229dc1	draft	599fea7c-9744-4392-b9cb-5863b4e55756	cc-by	\N	2017-11-23 14:57:51.835359	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 14:57:51.841043	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 14:57:51.841037
c5895f45-e257-4137-9310-5155f2ec2b22	laala	laala								82682f2c-fa0b-4c03-bb4e-b4b9688a30fe	draft	c5895f45-e257-4137-9310-5155f2ec2b22	cc-by	\N	2017-11-23 15:46:09.672312	2017-11-23 15:46:18.641891	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 15:46:09.677974	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 15:46:09.677967
15589e3b-0b24-48de-b724-4216f1b28a9f	prueba	prueba								454d15f3-840e-4b08-939e-59a7b5419c85	draft	15589e3b-0b24-48de-b724-4216f1b28a9f	cc-by	\N	2017-11-23 16:44:34.681607	2017-11-23 16:44:55.762789	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:44:34.68718	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:44:34.687173
15589e3b-0b24-48de-b724-4216f1b28a9f	prueba	prueba								b5b9f114-0ecf-4d96-bda8-0b0cde5b04d6	active	15589e3b-0b24-48de-b724-4216f1b28a9f	cc-by	\N	2017-11-23 16:44:55.762789	2017-11-23 16:51:07.974293	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:44:55.763186	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:44:34.687173
c5895f45-e257-4137-9310-5155f2ec2b22	laala	laala								ac630955-9972-4f00-b6fa-13a3ca87a7dc	active	c5895f45-e257-4137-9310-5155f2ec2b22	cc-by	\N	2017-11-23 15:46:18.641891	2017-11-23 16:51:17.292185	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 15:46:18.642522	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 15:46:09.677967
c5895f45-e257-4137-9310-5155f2ec2b22	laala	laala								11460728-1a99-41d2-aa3e-21b670cecf88	deleted	c5895f45-e257-4137-9310-5155f2ec2b22	cc-by	\N	2017-11-23 16:51:17.292185	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:16:22.224683	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 15:46:09.677967
3eafe76b-5d42-43ff-98cb-248a69d3e0cc	http-autode-sk-2zzs3jo	http://autode.sk/2zZs3JO								a40e9a0b-920d-4831-be14-2143eff3e1f5	draft	3eafe76b-5d42-43ff-98cb-248a69d3e0cc	cc-by	\N	2017-11-23 16:52:07.134719	2017-11-23 16:52:15.890366	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:52:07.139258	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:52:07.139253
46a43786-223c-4bd8-b4d0-ca1997e78e70	http-www-imagen-com-mx-assets-img-imagen_share-png	http://www.imagen.com.mx/assets/img/imagen_share.png								0308d025-a61d-4912-927c-b83a259af206	draft	46a43786-223c-4bd8-b4d0-ca1997e78e70	cc-by	\N	2017-11-23 16:54:02.990389	2017-11-23 16:54:09.967897	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:54:02.995673	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:54:02.995668
46a43786-223c-4bd8-b4d0-ca1997e78e70	http-www-imagen-com-mx-assets-img-imagen_share-png	http://www.imagen.com.mx/assets/img/imagen_share.png								edc363a9-dcaa-4ad2-8d16-30c2cfd6ad5e	active	46a43786-223c-4bd8-b4d0-ca1997e78e70	cc-by	\N	2017-11-23 16:54:09.967897	2017-11-23 16:55:10.759507	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:54:09.968595	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:54:02.995668
46a43786-223c-4bd8-b4d0-ca1997e78e70	http-www-imagen-com-mx-assets-img-imagen_share-png	http://www.imagen.com.mx/assets/img/imagen_share.png								6b3e479d-9737-4ca7-b32d-b98bf437a60c	deleted	46a43786-223c-4bd8-b4d0-ca1997e78e70	cc-by	\N	2017-11-23 16:55:10.759507	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:54:59.028887	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:54:02.995668
3eafe76b-5d42-43ff-98cb-248a69d3e0cc	http-autode-sk-2zzs3jo	http://autode.sk/2zZs3JO								a35cfd73-4f2e-4fb3-aed5-a5b285bca02d	active	3eafe76b-5d42-43ff-98cb-248a69d3e0cc	cc-by	\N	2017-11-23 16:52:15.890366	2017-11-23 16:55:17.143128	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:52:15.890938	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:52:07.139253
3eafe76b-5d42-43ff-98cb-248a69d3e0cc	http-autode-sk-2zzs3jo	http://autode.sk/2zZs3JO								62396fd7-e314-4b1f-bdc8-cd3410ff795e	deleted	3eafe76b-5d42-43ff-98cb-248a69d3e0cc	cc-by	\N	2017-11-23 16:55:17.143128	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:52:15.890938	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:52:07.139253
611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	event-information	Event information			Events where several users participated					bffaa2dd-7e21-45e1-9c62-336b10a1381d	active	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	cc-by	\N	2017-08-08 16:50:50.836029	2017-11-23 17:29:52.524044	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:50:50.837755	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:50:26.707962
817668d7-be70-479e-92c6-c7e4e8182603	internet-dataset	Internet dataset			Information about the users of our internet services.	Unicom	unicom@email.com	maintainer@email.com	maintainer@email.com	d2a0b75b-4856-4b6c-affc-729a99bbe985	active	817668d7-be70-479e-92c6-c7e4e8182603	cc-by	\N	2017-08-08 16:55:28.496897	2017-11-23 17:29:52.589459	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:55:28.497851	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:54:35.136338
4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	mobile-plans	Mobile plans			Users and their mobile plans					18ca3b06-e9d5-4129-b12c-1eacc9c8de32	active	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	cc-by	\N	2017-08-08 16:57:43.111847	2017-11-23 17:29:52.65148	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:57:43.112965	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:57:30.243005
903d964e-9c2c-47d2-8708-25363ef8d772	services-information	Services information			Several services offered in our company					ba506755-adf8-4f97-bf70-90355c658dd7	active	903d964e-9c2c-47d2-8708-25363ef8d772	cc-by	\N	2017-08-08 16:52:49.648027	2017-11-23 17:29:52.708328	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:52:49.648987	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:52:29.614969
15589e3b-0b24-48de-b724-4216f1b28a9f	prueba	prueba								79e552b7-ddc1-4eea-b3af-94653149dc1b	deleted	15589e3b-0b24-48de-b724-4216f1b28a9f	cc-by	\N	2017-11-23 16:51:07.974293	2017-11-23 16:59:32.133562	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:44:55.763186	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:44:34.687173
15589e3b-0b24-48de-b724-4216f1b28a9f	15589e3b-0b24-48de-b724-4216f1b28a9f	prueba								2379ec08-54f7-4f8a-9cb8-a550f3535800	deleted	15589e3b-0b24-48de-b724-4216f1b28a9f	cc-by	\N	2017-11-23 16:59:32.133562	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:44:55.763186	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:44:34.687173
cc7e17a1-34c9-4cb5-80c9-ede21ee6c79d	prueba	prueba								2379ec08-54f7-4f8a-9cb8-a550f3535800	draft	cc7e17a1-34c9-4cb5-80c9-ede21ee6c79d	cc-by	\N	2017-11-23 16:59:32.133562	2017-11-23 16:59:46.590922	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:59:32.141736	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:59:32.14173
54f83106-f2bf-45a8-8523-53a415c99e47	aaaa	aaaa								1d7a208f-a535-4f6d-ad3c-18d8c9866feb	draft	54f83106-f2bf-45a8-8523-53a415c99e47	cc-by	\N	2017-11-23 17:07:42.003088	2017-11-23 17:07:50.816393	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-11-23 17:07:42.009865	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:07:42.009859
54f83106-f2bf-45a8-8523-53a415c99e47	aaaa	aaaa								b8777631-802d-4981-aa3a-b71e40e44ea9	deleted	54f83106-f2bf-45a8-8523-53a415c99e47	cc-by	\N	2017-11-23 17:28:58.690985	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-11-23 17:25:49.82897	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:07:42.009859
54f83106-f2bf-45a8-8523-53a415c99e47	aaaa	aaaa								76a15254-7ed3-4c64-94e0-4c93fd886a70	active	54f83106-f2bf-45a8-8523-53a415c99e47	cc-by	\N	2017-11-23 17:07:50.816393	2017-11-23 17:28:58.690985	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-11-23 17:07:50.816957	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:07:42.009859
611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	event-information	Event information			Events where several users participated					78e33def-565f-45dc-b9a4-a1dda81e1ce1	deleted	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	cc-by	\N	2017-11-23 17:29:52.524044	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:50:50.837755	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:50:26.707962
817668d7-be70-479e-92c6-c7e4e8182603	internet-dataset	Internet dataset			Information about the users of our internet services.	Unicom	unicom@email.com	maintainer@email.com	maintainer@email.com	201d00c8-1f94-43d3-ac75-e9bfeb22a2f4	deleted	817668d7-be70-479e-92c6-c7e4e8182603	cc-by	\N	2017-11-23 17:29:52.589459	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:55:28.497851	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:54:35.136338
4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	mobile-plans	Mobile plans			Users and their mobile plans					19ac713d-48f0-48b9-9cd5-7061843bc62f	deleted	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	cc-by	\N	2017-11-23 17:29:52.65148	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-09 09:04:44.595145	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:57:30.243005
903d964e-9c2c-47d2-8708-25363ef8d772	services-information	Services information			Several services offered in our company					7d60ea7c-29e6-447b-a3c6-e32ad2ccd4f9	deleted	903d964e-9c2c-47d2-8708-25363ef8d772	cc-by	\N	2017-11-23 17:29:52.708328	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	f	2017-08-08 16:52:49.648987	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-08-08 16:52:29.614969
acc9dc22-eff3-486b-a715-9a69ef93ade0	example-videos	Example videos								dea564f1-30b2-4e1a-85dc-f13abbd0803e	draft	acc9dc22-eff3-486b-a715-9a69ef93ade0	cc-by	\N	2017-11-23 17:32:40.502714	2017-11-23 17:33:31.668229	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-11-23 17:32:40.506726	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:32:40.506721
acc9dc22-eff3-486b-a715-9a69ef93ade0	example-videos	Example videos								ce2b7558-924a-445d-a0be-3cfad1f498c2	active	acc9dc22-eff3-486b-a715-9a69ef93ade0	cc-by	\N	2017-11-23 17:33:31.668229	2017-11-23 17:35:47.356658	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-11-23 17:33:31.668724	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:32:40.506721
476cdf71-1048-4a6f-a28a-58fff547dae5	example-cad	Example CAD								f732828b-2166-4541-9128-f838a260ae1b	draft	476cdf71-1048-4a6f-a28a-58fff547dae5	cc-by	\N	2017-11-23 17:37:00.356594	2017-11-23 17:37:20.059045	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-11-23 17:37:00.362905	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:37:00.3629
cc7e17a1-34c9-4cb5-80c9-ede21ee6c79d	prueba	prueba								4fc2baf4-0ca3-4ea1-9d25-597e6a6143eb	active	cc7e17a1-34c9-4cb5-80c9-ede21ee6c79d	cc-by	\N	2017-11-23 16:59:46.590922	2017-11-24 12:35:58.757075	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 16:59:46.591475	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:59:32.14173
cc7e17a1-34c9-4cb5-80c9-ede21ee6c79d	prueba	prueba								01835081-84bb-447b-92b7-cc793a8ec18a	deleted	cc7e17a1-34c9-4cb5-80c9-ede21ee6c79d	cc-by	\N	2017-11-24 12:35:58.757075	9999-12-31 00:00:00	\N	dataset	724ae83b-ae78-433c-8586-69e7202931c4	t	2017-11-23 17:06:26.176559	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 16:59:32.14173
ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	example-cad-2	Example CAD 2								39eb3d69-8ca4-477c-b7c6-7556c833986b	draft	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	cc-by	\N	2017-11-24 13:36:15.8815	2017-11-24 13:37:06.717505	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-11-24 13:36:15.887858	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:36:15.887852
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Example video 2								261614c5-63db-4f81-83d2-45690db30b97	draft	54920aae-f322-4fca-bd09-cd091946632c	cc-by	\N	2017-11-24 13:42:19.401789	2017-11-24 13:42:36.379722	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-11-24 13:42:19.407548	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	example-cad-2	Example CAD 2								07d39bd8-2ebc-4e4f-9018-6edc75251e06	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	cc-by	\N	2017-11-24 13:37:06.717505	2017-12-01 11:56:50.587446	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-11-24 13:37:06.718115	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:36:15.887852
bf46d212-6fde-4670-ab59-52bb38c513bc	test-jupyter	Test jupyter								d22239f4-6828-4fa1-be3f-4736fc8b354d	active	bf46d212-6fde-4670-ab59-52bb38c513bc	cc-by	\N	2017-11-28 19:32:29.449516	2017-12-01 11:57:19.351494	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-11-28 19:32:29.450007	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-28 19:31:59.868119
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Example video 2								1c58622d-c7db-4a68-8693-f42da07e9c4e	active	54920aae-f322-4fca-bd09-cd091946632c	cc-by	\N	2017-11-24 13:42:36.379722	2017-12-01 11:57:31.640309	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-11-24 13:42:36.380309	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
acc9dc22-eff3-486b-a715-9a69ef93ade0	example-videos	Example videos								00277d2f-879f-426e-98e9-39839776d89d	active	acc9dc22-eff3-486b-a715-9a69ef93ade0	cc-by	\N	2017-11-23 17:35:47.356658	2017-12-01 12:26:03.416187	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-11-23 17:35:47.357177	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:32:40.506721
bf46d212-6fde-4670-ab59-52bb38c513bc	test-jupyter	Test jupyter								9c5af1cf-98c7-4a89-8c5d-4acc9a801b72	draft	bf46d212-6fde-4670-ab59-52bb38c513bc	cc-by	\N	2017-11-28 19:31:59.859318	2017-11-28 19:32:29.449516	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-11-28 19:31:59.868127	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-28 19:31:59.868119
acc9dc22-eff3-486b-a715-9a69ef93ade0	example-videos	Example videos								f8632874-e874-4ec3-97ce-c15bffe12f28	deleted	acc9dc22-eff3-486b-a715-9a69ef93ade0	cc-by	\N	2017-12-01 12:26:03.416187	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-11-23 17:35:47.357177	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:32:40.506721
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Example video 2								beb04331-d499-485b-9369-1f57aa6f7395	active	54920aae-f322-4fca-bd09-cd091946632c	cc-by	\N	2017-12-01 11:57:31.640309	2017-12-01 12:26:27.563253	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 11:57:31.640981	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
bf46d212-6fde-4670-ab59-52bb38c513bc	test-jupyter	Test jupyter								78462af9-3e29-41e7-b739-815aa263ff3d	active	bf46d212-6fde-4670-ab59-52bb38c513bc	cc-by	\N	2017-12-01 11:57:19.351494	2017-12-01 12:26:42.710983	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 11:57:19.351983	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-28 19:31:59.868119
bf46d212-6fde-4670-ab59-52bb38c513bc	test-jupyter	Test jupyter								4c6cf89c-065e-4c3e-85a0-bd6c7ed30b75	deleted	bf46d212-6fde-4670-ab59-52bb38c513bc	cc-by	\N	2017-12-01 12:26:42.710983	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 11:57:19.351983	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-28 19:31:59.868119
ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	example-cad-2	Example CAD 2								c0d32fee-6737-4a91-920a-d8aab223e545	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	cc-by	\N	2017-12-01 11:56:50.587446	2017-12-01 12:27:24.136585	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 11:56:50.59091	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:36:15.887852
1abefb2e-6a83-4004-b7db-74c34b545d2e	jupyter-notebooks	Jupyter notebooks								91daa1ea-e394-4b70-a9e0-366b7c0b95fe	draft	1abefb2e-6a83-4004-b7db-74c34b545d2e	cc-by	\N	2017-12-01 12:51:12.212384	2017-12-01 12:51:29.035769	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-01 12:51:12.21851	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-01 12:51:12.218503
1abefb2e-6a83-4004-b7db-74c34b545d2e	jupyter-notebooks	Jupyter notebooks								9a2f4e77-4520-4878-b51b-359e8adcba17	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	cc-by	\N	2017-12-01 12:51:29.035769	2017-12-01 12:51:37.465931	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-01 12:51:29.036414	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-01 12:51:12.218503
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Example video								f69e3832-0198-44c5-a4f2-f52a65fe3ca2	active	54920aae-f322-4fca-bd09-cd091946632c	cc-by	\N	2017-12-01 12:26:27.563253	2017-12-01 12:51:49.531837	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 12:26:27.56401	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	example-cad-2	Example CAD Pangaea								f42bf4cf-a31c-4645-bb98-9ecbdf58d1ca	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	cc-by	\N	2017-12-01 12:27:24.136585	2017-12-01 12:52:07.396644	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 12:27:24.137068	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:36:15.887852
1abefb2e-6a83-4004-b7db-74c34b545d2e	jupyter-notebooks	Jupyter notebooks								3951536e-4b6f-4e7a-add1-b55c5002dcc0	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	cc-by	\N	2017-12-01 12:51:37.465931	2017-12-04 16:42:27.658484	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 12:51:37.46646	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-01 12:51:12.218503
1abefb2e-6a83-4004-b7db-74c34b545d2e	jupyter-notebooks	Jupyter notebooks		https://unidata.github.io/online-python-training/introduction.html	A collection of Jupyter Notebooks for science related projects\r\n\r\n1. LIGO Gravitational Wave Data\r\n2. Satellite Imagery Analysis\r\n3. 12 Steps to Navier-Stokes\r\n4. Computer Vision\r\n5. Machine Learning	Lorena A. Barba				4f99eafe-97a2-4b14-be62-63ad7cffc7be	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	cc-by	\N	2017-12-04 16:43:57.658681	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-04 16:43:57.659289	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-01 12:51:12.218503
1abefb2e-6a83-4004-b7db-74c34b545d2e	jupyter-notebooks	Jupyter notebooks			A collection of Jupyter Notebooks for science related projects\r\n\r\n1. LIGO Gravitational Wave Data\r\n2. Satellite Imagery Analysis\r\n3. 12 Steps to Navier-Stokes\r\n4. Computer Vision\r\n5. Machine Learning	Lorena A. Barba				25711b9c-54ee-4629-ba88-03fbd139dda0	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	cc-by	\N	2017-12-04 16:42:27.658484	2017-12-04 16:43:57.658681	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-04 16:42:27.659128	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-01 12:51:12.218503
476cdf71-1048-4a6f-a28a-58fff547dae5	example-cad	Example CAD								5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5	active	476cdf71-1048-4a6f-a28a-58fff547dae5	cc-by	\N	2017-11-23 17:37:20.059045	2017-12-05 11:08:31.916963	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-11-23 17:37:20.059543	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:37:00.3629
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Video								b0de1461-ba0a-4971-8682-f14af889ae40	active	54920aae-f322-4fca-bd09-cd091946632c	cc-by	\N	2017-12-01 12:51:49.531837	2017-12-05 12:47:02.943794	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 12:51:49.532303	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
476cdf71-1048-4a6f-a28a-58fff547dae5	example-cad	Example CAD		https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html		Autodesk				41e8a326-3a0c-4ab2-af20-7427bd551504	active	476cdf71-1048-4a6f-a28a-58fff547dae5	cc-by	\N	2017-12-05 11:08:31.916963	2017-12-05 12:49:18.578696	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-05 11:08:31.9176	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:37:00.3629
476cdf71-1048-4a6f-a28a-58fff547dae5	example-cad	Example CAD		https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html	Example usage of CAD visualization in 2D and 3D using CKAN Views.	Autodesk				9c6d5cc2-06e9-46c9-acd2-77a99cf3ac8b	active	476cdf71-1048-4a6f-a28a-58fff547dae5	cc-by	\N	2017-12-05 12:50:32.679984	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-05 12:50:32.680631	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:37:00.3629
476cdf71-1048-4a6f-a28a-58fff547dae5	example-cad	Example CAD		https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html	Example usage of CAD visualization in 2D and 3D.	Autodesk				778fcf5c-b993-40b3-ad2b-088dcb674c2e	active	476cdf71-1048-4a6f-a28a-58fff547dae5	cc-by	\N	2017-12-05 12:49:18.578696	2017-12-05 12:50:32.679984	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-05 12:49:18.579271	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:37:00.3629
ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	example-cad-2	Pangaea CAD files			Example usage of CAD using Ckan View with information provided by PANGAEA.					c7cbaa34-461b-4cd7-932d-d70ae8e2254b	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	cc-by	\N	2017-12-05 12:53:47.895125	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-05 12:53:47.896014	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:36:15.887852
ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	example-cad-2	Pangaea CAD files								997a3d54-bb90-4c1e-88bf-417e4c95ba21	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	cc-by	\N	2017-12-01 12:52:07.396644	2017-12-05 12:53:47.895125	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-01 12:52:07.397075	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:36:15.887852
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Autocombustion reactions STF50 video			Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.					d325e2f3-8a4a-4b42-b99d-2d1152e093ea	active	54920aae-f322-4fca-bd09-cd091946632c	cc-by	\N	2017-12-05 13:12:32.84258	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-05 13:12:32.843326	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Autocombustion reactions STF50 video			Video about auto combustion reactions of STF50 with EDTA+CA: variying qe.					959e1cc4-8271-4643-b3d5-4a6dd3e92074	active	54920aae-f322-4fca-bd09-cd091946632c	cc-by	\N	2017-12-05 12:47:02.943794	2017-12-05 13:12:32.84258	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2017-12-05 12:47:02.944695	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
689fe009-c731-4b3b-a6f2-f04ac1bf7885	foobar	foobar								4f894272-891f-42e2-a01b-184fe666f896	draft	689fe009-c731-4b3b-a6f2-f04ac1bf7885	cc-by	\N	2017-12-19 12:46:02.680685	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-19 12:46:02.691913	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-19 12:46:02.691896
c6e1f0f0-271c-454a-ac89-14f3b55211a4	foobarbaz	foobarbaz								e5f2392a-5484-48b4-bec3-f57fac558025	draft	c6e1f0f0-271c-454a-ac89-14f3b55211a4	cc-by	\N	2017-12-19 12:46:52.491415	2017-12-19 12:47:00.530533	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-19 12:46:52.496638	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-19 12:46:52.496632
0eb102b3-06a3-4e2a-b224-e1cc6099b96e	foopy	foopy								b66a5ad1-8a5b-4728-941f-efd168efed2f	active	0eb102b3-06a3-4e2a-b224-e1cc6099b96e	cc-by	\N	2017-12-19 12:54:16.688631	2018-01-09 11:21:40.88744	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-19 12:54:16.689222	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-19 12:54:07.744952
c6e1f0f0-271c-454a-ac89-14f3b55211a4	foobarbaz	foobarbaz								28f7833d-c40f-4339-8a53-4de36f72f886	active	c6e1f0f0-271c-454a-ac89-14f3b55211a4	cc-by	\N	2017-12-19 12:47:00.530533	2018-01-09 11:21:47.915395	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-19 12:47:00.530996	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-19 12:46:52.496632
0eb102b3-06a3-4e2a-b224-e1cc6099b96e	foopy	foopy								069046d5-6db8-459d-800b-e57a2c600588	draft	0eb102b3-06a3-4e2a-b224-e1cc6099b96e	cc-by	\N	2017-12-19 12:54:07.736735	2017-12-19 12:54:16.688631	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-19 12:54:07.744959	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-19 12:54:07.744952
0eb102b3-06a3-4e2a-b224-e1cc6099b96e	foopy	foopy								27fa139c-0952-465d-ac41-0029ebc16e44	deleted	0eb102b3-06a3-4e2a-b224-e1cc6099b96e	cc-by	\N	2018-01-09 11:21:40.88744	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-19 12:54:16.689222	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-19 12:54:07.744952
c6e1f0f0-271c-454a-ac89-14f3b55211a4	foobarbaz	foobarbaz								2440217d-b741-4192-89bf-0c478d41ea9d	deleted	c6e1f0f0-271c-454a-ac89-14f3b55211a4	cc-by	\N	2018-01-09 11:21:47.915395	9999-12-31 00:00:00	\N	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	t	2017-12-19 12:47:00.530996	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-19 12:46:52.496632
\.


--
-- Data for Name: package_tag; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package_tag (id, state, package_id, tag_id) FROM stdin;
c273e895-9968-4ed6-9ffc-92585b788aa5	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	5581fcb2-a2b7-41aa-aa4e-822d8837fcfe
f6ae04c4-15aa-4464-990a-41893be621e7	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	c3ea41c3-899c-4b54-a4f4-caa50617b956
fbabaa88-ebd0-4758-9503-c32b0e628b29	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	f650b4e3-9955-49b0-ba7b-2d302a990978
a813bedb-0a06-4583-a249-ecc9c6967d03	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	9e42784b-6ee7-47e8-a69a-28b8c510212b
bf7d7129-ce0d-480f-9c3a-ba9d0eb982d2	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	e2bb9482-6eb5-43c3-b14e-903c519d5e38
eb475d76-18fc-4ace-85c1-cbde3ddd2d16	active	54920aae-f322-4fca-bd09-cd091946632c	a292a3c1-b272-4c02-bfb2-385e12ff6b66
2eef4809-6dff-4926-b1ed-cf3e86c86d0a	active	54920aae-f322-4fca-bd09-cd091946632c	9d0587af-aad0-4352-ab8f-fc7b90f7430b
8c80f201-690f-4d21-8f8f-7bc52fc898b6	active	54920aae-f322-4fca-bd09-cd091946632c	53b4f8bd-5778-4ece-b3ac-78e8a60be011
e715d58c-d536-4278-8ee6-55f16980ee44	active	54920aae-f322-4fca-bd09-cd091946632c	7d945dfc-6203-4ef8-8369-90704d7498ac
09ab2d8a-1cc3-46ae-850b-c14478a12673	active	54920aae-f322-4fca-bd09-cd091946632c	a6bbc1be-05c4-406c-8d13-b9e2018b311a
e7455a68-28aa-4859-a2d7-eb9c4b1eb836	active	54920aae-f322-4fca-bd09-cd091946632c	5df7cf26-78df-4382-b27d-fad8237cf180
b2a50929-224a-4c9c-92c5-31a2a2fc149e	active	54920aae-f322-4fca-bd09-cd091946632c	23f7f291-52c1-4942-aa23-008a9b23a5e1
3408ac90-f31d-4591-b524-ff7b0aec6803	active	476cdf71-1048-4a6f-a28a-58fff547dae5	80b88538-5f29-4c5f-af29-895228232a10
3aa7c276-605e-4e8a-bb6b-173cf2e4b026	active	476cdf71-1048-4a6f-a28a-58fff547dae5	73142a8e-6efc-400b-9215-3316931a4e66
96d247bf-4b11-4ab4-9144-9520516a7cf8	active	476cdf71-1048-4a6f-a28a-58fff547dae5	7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd
85e712c8-745f-4edf-9865-2bae84c2bfa8	active	476cdf71-1048-4a6f-a28a-58fff547dae5	675a1366-8d81-4e07-ab30-8c492c34b91d
cf5e6fe9-0896-4e9f-aada-117d05c04619	active	476cdf71-1048-4a6f-a28a-58fff547dae5	c98a3ca2-e5c9-4173-93fb-420e0b48e9d8
79d22f27-f47e-44d4-a82f-7a2d707a44cb	active	476cdf71-1048-4a6f-a28a-58fff547dae5	aa5643c3-51ea-4233-a672-6f5a2a7b174e
4c1ed6cf-4b4d-482b-8c49-6ccb6b9fe9ec	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	73142a8e-6efc-400b-9215-3316931a4e66
3e45d558-8beb-41b3-84c4-672c3e6deba9	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	816b2a52-8852-4298-803f-f34556cae9e0
722e4151-8209-4643-bd71-5259e2dd7cc5	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	aa5643c3-51ea-4233-a672-6f5a2a7b174e
93bcbf69-6e91-486f-9b95-0e8e6e673d6f	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	80b88538-5f29-4c5f-af29-895228232a10
de332c20-57f1-4f31-a436-25d74c47f875	deleted	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	f5568899-687f-4fc9-a613-b5b3d8253fe3
08caad45-37a6-4ddf-abb4-d18ce8e8edc6	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	c98a3ca2-e5c9-4173-93fb-420e0b48e9d8
97c5b7ad-e2fe-4308-a513-130bf2452f05	active	44892bd1-6fb7-477b-858e-483cb1290798	5df7cf26-78df-4382-b27d-fad8237cf180
db9cec66-3b87-4f77-98c3-a4400165e97f	active	0ddcfe50-9e31-4225-b68f-e777d72fb859	5534061d-2eff-448a-8814-2d119df0e73e
f3e4eff6-b363-4a32-b725-8b31f867e44f	active	0ddcfe50-9e31-4225-b68f-e777d72fb859	e6d56045-9569-4230-93f4-699fb1b96f7e
7a736c40-754f-43d3-b3e0-0aa17e9841ad	active	0ddcfe50-9e31-4225-b68f-e777d72fb859	f94d461f-a9ee-4b35-91ce-5bdcfefa4a91
3c465dba-5660-47d6-bb88-af0997bacd65	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	e9c2218b-05ce-47d2-a936-a7185dafd264
6d285736-6125-479c-8b1b-3a46bd7afeca	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	417bc38b-82b2-45d9-9768-b420bbb413ee
0f4775df-7bfa-4ffc-87b3-b9822ec283dc	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	30f6129d-ce3e-413d-be1e-6b92dd9ed9ee
8b3b0555-2203-45b7-85bb-d43ba1ab3a99	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	8bd7857b-cc2b-46a8-ac2e-f73dcd46d659
1bfef0fa-442c-4f8e-b109-13286a3b0d28	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	418ade6e-6742-4a47-a6d7-d1c6546d6a4e
a397bd33-d86d-4fea-b7f5-8868169bc631	active	c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	18486445-68da-490e-b690-56f10770fac9
a6d50ec2-754c-4459-b60f-859c2a95439d	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2	9e42784b-6ee7-47e8-a69a-28b8c510212b
4c8dd71e-4af7-49eb-ad68-f4cc5f8ddcb1	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2	b5d28237-06f1-4ecb-9cf0-1ad354b0ff3f
d382edd8-4608-4c4f-9003-2cd1ee918e6c	active	ef96d2db-9cbe-4738-b7bf-da556e12bdc2	f650b4e3-9955-49b0-ba7b-2d302a990978
9c4c5283-1ac2-4d0b-b133-d2a3298ac78d	active	2dfe1d91-0394-4107-8309-b125d98840cc	1cdda301-e396-4674-8dd9-f9e7b5b25524
f4e5642e-7211-4af0-b8a0-81b90ee23f03	active	2dfe1d91-0394-4107-8309-b125d98840cc	609026eb-7b35-4c38-9af2-02506b88a95b
8c74c013-225b-460b-9a71-ff3e7c304f13	active	2dfe1d91-0394-4107-8309-b125d98840cc	49a9cf01-df26-461c-819c-9772a76f62fc
537b14b0-1049-4fda-a2da-8fcd11aa57b2	active	2dfe1d91-0394-4107-8309-b125d98840cc	c1a56b00-65c8-4b91-8f17-69921799d700
3162a6b7-22ba-4f80-bbdc-fa750ad41091	active	2dfe1d91-0394-4107-8309-b125d98840cc	370159b3-bb81-4d9b-902a-f080dc387e62
\.


--
-- Data for Name: package_tag_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.package_tag_revision (id, revision_id, state, package_id, tag_id, continuity_id, expired_id, revision_timestamp, expired_timestamp, current) FROM stdin;
7e0928b6-a479-4718-98fe-b18d8f63ae0f	2b61e1eb-c56d-4852-b55c-47f0e7308c6e	active	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	013c0ce4-51f9-4946-94e3-8e8713360f16	7e0928b6-a479-4718-98fe-b18d8f63ae0f	\N	2017-08-08 16:50:26.684564	9999-12-31 00:00:00	\N
8a55bb6b-dc69-4622-a3fc-5bef515beac2	2b61e1eb-c56d-4852-b55c-47f0e7308c6e	active	611ebb20-9b7b-40b5-8cdf-7cbd8657a1cc	5564f2e8-9c79-4125-a2a8-077f38a246ef	8a55bb6b-dc69-4622-a3fc-5bef515beac2	\N	2017-08-08 16:50:26.684564	9999-12-31 00:00:00	\N
71bb7993-7b91-446a-a653-54b5543de071	65a08933-48aa-426b-bf8a-d11aa32dca95	active	903d964e-9c2c-47d2-8708-25363ef8d772	cd8f07aa-76ab-4a1a-9567-ba2b7b19779b	71bb7993-7b91-446a-a653-54b5543de071	\N	2017-08-08 16:52:29.604017	9999-12-31 00:00:00	\N
b0c0609f-0cd5-43b9-9e76-6fcab0907ecb	8b393d77-16b0-4e7c-b64e-63acf71345d5	active	817668d7-be70-479e-92c6-c7e4e8182603	8c8c1220-8129-4a02-bd2f-8e9b6529c212	b0c0609f-0cd5-43b9-9e76-6fcab0907ecb	\N	2017-08-08 16:54:35.123783	9999-12-31 00:00:00	\N
2b65bccf-ad8a-4ddd-86b6-65587312f176	8b393d77-16b0-4e7c-b64e-63acf71345d5	active	817668d7-be70-479e-92c6-c7e4e8182603	a81cb4bd-b2c8-4fc9-9682-9be570d13072	2b65bccf-ad8a-4ddd-86b6-65587312f176	\N	2017-08-08 16:54:35.123783	9999-12-31 00:00:00	\N
be82423d-7268-44af-8a1e-b9b47ff9480e	dd70f0dc-ac9d-4ea3-8888-ddb077b44502	active	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	0f6bdfbd-7412-4e5c-a788-c5fec06b5dd8	be82423d-7268-44af-8a1e-b9b47ff9480e	\N	2017-08-08 16:57:30.229943	9999-12-31 00:00:00	\N
5ff6ca59-1110-4e7c-a81f-41ea212eab2c	dd70f0dc-ac9d-4ea3-8888-ddb077b44502	active	4bd09dc0-9ab9-4246-8cc1-e0fe9b708c64	69a1e7a9-0a51-4267-9fb3-db0642f03959	5ff6ca59-1110-4e7c-a81f-41ea212eab2c	\N	2017-08-08 16:57:30.229943	9999-12-31 00:00:00	\N
fbabaa88-ebd0-4758-9503-c32b0e628b29	25711b9c-54ee-4629-ba88-03fbd139dda0	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	f650b4e3-9955-49b0-ba7b-2d302a990978	fbabaa88-ebd0-4758-9503-c32b0e628b29	\N	2017-12-04 16:42:27.658484	9999-12-31 00:00:00	\N
c273e895-9968-4ed6-9ffc-92585b788aa5	25711b9c-54ee-4629-ba88-03fbd139dda0	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	5581fcb2-a2b7-41aa-aa4e-822d8837fcfe	c273e895-9968-4ed6-9ffc-92585b788aa5	\N	2017-12-04 16:42:27.658484	9999-12-31 00:00:00	\N
bf7d7129-ce0d-480f-9c3a-ba9d0eb982d2	25711b9c-54ee-4629-ba88-03fbd139dda0	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	e2bb9482-6eb5-43c3-b14e-903c519d5e38	bf7d7129-ce0d-480f-9c3a-ba9d0eb982d2	\N	2017-12-04 16:42:27.658484	9999-12-31 00:00:00	\N
f6ae04c4-15aa-4464-990a-41893be621e7	25711b9c-54ee-4629-ba88-03fbd139dda0	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	c3ea41c3-899c-4b54-a4f4-caa50617b956	f6ae04c4-15aa-4464-990a-41893be621e7	\N	2017-12-04 16:42:27.658484	9999-12-31 00:00:00	\N
a813bedb-0a06-4583-a249-ecc9c6967d03	25711b9c-54ee-4629-ba88-03fbd139dda0	active	1abefb2e-6a83-4004-b7db-74c34b545d2e	9e42784b-6ee7-47e8-a69a-28b8c510212b	a813bedb-0a06-4583-a249-ecc9c6967d03	\N	2017-12-04 16:42:27.658484	9999-12-31 00:00:00	\N
3aa7c276-605e-4e8a-bb6b-173cf2e4b026	e58c8491-4add-4147-b929-e12d05531f9d	active	476cdf71-1048-4a6f-a28a-58fff547dae5	73142a8e-6efc-400b-9215-3316931a4e66	3aa7c276-605e-4e8a-bb6b-173cf2e4b026	\N	2017-12-05 11:07:10.617313	9999-12-31 00:00:00	\N
3408ac90-f31d-4591-b524-ff7b0aec6803	e58c8491-4add-4147-b929-e12d05531f9d	active	476cdf71-1048-4a6f-a28a-58fff547dae5	80b88538-5f29-4c5f-af29-895228232a10	3408ac90-f31d-4591-b524-ff7b0aec6803	\N	2017-12-05 11:07:10.617313	9999-12-31 00:00:00	\N
85e712c8-745f-4edf-9865-2bae84c2bfa8	41e8a326-3a0c-4ab2-af20-7427bd551504	active	476cdf71-1048-4a6f-a28a-58fff547dae5	675a1366-8d81-4e07-ab30-8c492c34b91d	85e712c8-745f-4edf-9865-2bae84c2bfa8	\N	2017-12-05 11:08:31.916963	9999-12-31 00:00:00	\N
96d247bf-4b11-4ab4-9144-9520516a7cf8	41e8a326-3a0c-4ab2-af20-7427bd551504	active	476cdf71-1048-4a6f-a28a-58fff547dae5	7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd	96d247bf-4b11-4ab4-9144-9520516a7cf8	\N	2017-12-05 11:08:31.916963	9999-12-31 00:00:00	\N
e715d58c-d536-4278-8ee6-55f16980ee44	959e1cc4-8271-4643-b3d5-4a6dd3e92074	active	54920aae-f322-4fca-bd09-cd091946632c	7d945dfc-6203-4ef8-8369-90704d7498ac	e715d58c-d536-4278-8ee6-55f16980ee44	\N	2017-12-05 12:47:02.943794	9999-12-31 00:00:00	\N
eb475d76-18fc-4ace-85c1-cbde3ddd2d16	959e1cc4-8271-4643-b3d5-4a6dd3e92074	active	54920aae-f322-4fca-bd09-cd091946632c	a292a3c1-b272-4c02-bfb2-385e12ff6b66	eb475d76-18fc-4ace-85c1-cbde3ddd2d16	\N	2017-12-05 12:47:02.943794	9999-12-31 00:00:00	\N
2eef4809-6dff-4926-b1ed-cf3e86c86d0a	959e1cc4-8271-4643-b3d5-4a6dd3e92074	active	54920aae-f322-4fca-bd09-cd091946632c	9d0587af-aad0-4352-ab8f-fc7b90f7430b	2eef4809-6dff-4926-b1ed-cf3e86c86d0a	\N	2017-12-05 12:47:02.943794	9999-12-31 00:00:00	\N
8c80f201-690f-4d21-8f8f-7bc52fc898b6	959e1cc4-8271-4643-b3d5-4a6dd3e92074	active	54920aae-f322-4fca-bd09-cd091946632c	53b4f8bd-5778-4ece-b3ac-78e8a60be011	8c80f201-690f-4d21-8f8f-7bc52fc898b6	\N	2017-12-05 12:47:02.943794	9999-12-31 00:00:00	\N
b2a50929-224a-4c9c-92c5-31a2a2fc149e	959e1cc4-8271-4643-b3d5-4a6dd3e92074	active	54920aae-f322-4fca-bd09-cd091946632c	23f7f291-52c1-4942-aa23-008a9b23a5e1	b2a50929-224a-4c9c-92c5-31a2a2fc149e	\N	2017-12-05 12:47:02.943794	9999-12-31 00:00:00	\N
09ab2d8a-1cc3-46ae-850b-c14478a12673	959e1cc4-8271-4643-b3d5-4a6dd3e92074	active	54920aae-f322-4fca-bd09-cd091946632c	a6bbc1be-05c4-406c-8d13-b9e2018b311a	09ab2d8a-1cc3-46ae-850b-c14478a12673	\N	2017-12-05 12:47:02.943794	9999-12-31 00:00:00	\N
e7455a68-28aa-4859-a2d7-eb9c4b1eb836	959e1cc4-8271-4643-b3d5-4a6dd3e92074	active	54920aae-f322-4fca-bd09-cd091946632c	5df7cf26-78df-4382-b27d-fad8237cf180	e7455a68-28aa-4859-a2d7-eb9c4b1eb836	\N	2017-12-05 12:47:02.943794	9999-12-31 00:00:00	\N
cf5e6fe9-0896-4e9f-aada-117d05c04619	778fcf5c-b993-40b3-ad2b-088dcb674c2e	active	476cdf71-1048-4a6f-a28a-58fff547dae5	c98a3ca2-e5c9-4173-93fb-420e0b48e9d8	cf5e6fe9-0896-4e9f-aada-117d05c04619	\N	2017-12-05 12:49:18.578696	9999-12-31 00:00:00	\N
79d22f27-f47e-44d4-a82f-7a2d707a44cb	778fcf5c-b993-40b3-ad2b-088dcb674c2e	active	476cdf71-1048-4a6f-a28a-58fff547dae5	aa5643c3-51ea-4233-a672-6f5a2a7b174e	79d22f27-f47e-44d4-a82f-7a2d707a44cb	\N	2017-12-05 12:49:18.578696	9999-12-31 00:00:00	\N
3e45d558-8beb-41b3-84c4-672c3e6deba9	c7cbaa34-461b-4cd7-932d-d70ae8e2254b	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	816b2a52-8852-4298-803f-f34556cae9e0	3e45d558-8beb-41b3-84c4-672c3e6deba9	\N	2017-12-05 12:53:47.895125	9999-12-31 00:00:00	\N
4c1ed6cf-4b4d-482b-8c49-6ccb6b9fe9ec	c7cbaa34-461b-4cd7-932d-d70ae8e2254b	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	73142a8e-6efc-400b-9215-3316931a4e66	4c1ed6cf-4b4d-482b-8c49-6ccb6b9fe9ec	\N	2017-12-05 12:53:47.895125	9999-12-31 00:00:00	\N
722e4151-8209-4643-bd71-5259e2dd7cc5	fc2b5cb3-7333-4ac3-b707-2548a16d6e1a	deleted	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	aa5643c3-51ea-4233-a672-6f5a2a7b174e	722e4151-8209-4643-bd71-5259e2dd7cc5	\N	2017-12-05 13:10:44.627851	2017-12-05 13:11:18.466672	\N
722e4151-8209-4643-bd71-5259e2dd7cc5	c7cbaa34-461b-4cd7-932d-d70ae8e2254b	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	aa5643c3-51ea-4233-a672-6f5a2a7b174e	722e4151-8209-4643-bd71-5259e2dd7cc5	\N	2017-12-05 12:53:47.895125	2017-12-05 13:10:44.627851	\N
93bcbf69-6e91-486f-9b95-0e8e6e673d6f	c7cbaa34-461b-4cd7-932d-d70ae8e2254b	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	80b88538-5f29-4c5f-af29-895228232a10	93bcbf69-6e91-486f-9b95-0e8e6e673d6f	\N	2017-12-05 12:53:47.895125	2017-12-05 13:10:44.627851	\N
de332c20-57f1-4f31-a436-25d74c47f875	fc2b5cb3-7333-4ac3-b707-2548a16d6e1a	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	f5568899-687f-4fc9-a613-b5b3d8253fe3	de332c20-57f1-4f31-a436-25d74c47f875	\N	2017-12-05 13:10:44.627851	2017-12-05 13:11:18.466672	\N
de332c20-57f1-4f31-a436-25d74c47f875	74a74b6a-3df2-4d28-92dd-956bcdad2265	deleted	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	f5568899-687f-4fc9-a613-b5b3d8253fe3	de332c20-57f1-4f31-a436-25d74c47f875	\N	2017-12-05 13:11:18.466672	9999-12-31 00:00:00	\N
93bcbf69-6e91-486f-9b95-0e8e6e673d6f	fc2b5cb3-7333-4ac3-b707-2548a16d6e1a	deleted	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	80b88538-5f29-4c5f-af29-895228232a10	93bcbf69-6e91-486f-9b95-0e8e6e673d6f	\N	2017-12-05 13:10:44.627851	2017-12-05 13:11:18.466672	\N
93bcbf69-6e91-486f-9b95-0e8e6e673d6f	74a74b6a-3df2-4d28-92dd-956bcdad2265	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	80b88538-5f29-4c5f-af29-895228232a10	93bcbf69-6e91-486f-9b95-0e8e6e673d6f	\N	2017-12-05 13:11:18.466672	9999-12-31 00:00:00	\N
08caad45-37a6-4ddf-abb4-d18ce8e8edc6	74a74b6a-3df2-4d28-92dd-956bcdad2265	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	c98a3ca2-e5c9-4173-93fb-420e0b48e9d8	08caad45-37a6-4ddf-abb4-d18ce8e8edc6	\N	2017-12-05 13:11:18.466672	9999-12-31 00:00:00	\N
722e4151-8209-4643-bd71-5259e2dd7cc5	74a74b6a-3df2-4d28-92dd-956bcdad2265	active	ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	aa5643c3-51ea-4233-a672-6f5a2a7b174e	722e4151-8209-4643-bd71-5259e2dd7cc5	\N	2017-12-05 13:11:18.466672	9999-12-31 00:00:00	\N
\.


--
-- Data for Name: rating; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.rating (id, user_id, user_ip_address, rating, created, package_id) FROM stdin;
\.


--
-- Data for Name: resource; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.resource (id, url, format, description, "position", hash, state, extras, name, resource_type, mimetype, mimetype_inner, size, last_modified, cache_url, cache_last_updated, webstore_url, webstore_last_updated, created, url_type, package_id, metadata_modified) FROM stdin;
ec1c5422-b8ab-4401-96fb-0792dacb8e40	https://github.com/guillermobet/files/raw/master/12%20steps%20to%20Navier-Stokes.tar.gz	TAR		4		active	{"datastore_active": false}	12 steps to Navier-Stokes	\N	application/x-tar	\N	5708395	2017-12-01 16:48:21.527146	\N	\N	\N	\N	2017-12-01 12:58:35.87733		1abefb2e-6a83-4004-b7db-74c34b545d2e	\N
e4cc8bf6-5e32-4c1f-b22e-109d47340c96	http://unidata.github.io/python-gallery/_downloads/Satellite_Example.ipynb			2		active	{"datastore_active": false}	Satellite example	\N	\N	\N	7216	2017-12-01 16:47:54.872809	\N	\N	\N	\N	2017-12-01 12:55:06.67396		1abefb2e-6a83-4004-b7db-74c34b545d2e	\N
4577e551-96f8-4e13-ac81-012a866d00ac	https://losc.ligo.org/s/events/GW150914/GW150914_tutorial.ipynb			3		active	{"datastore_active": false}	GW150914 tutorial	\N	\N	\N	2683661	2017-12-01 16:48:04.508028	\N	\N	\N	\N	2017-12-01 12:56:06.860736		1abefb2e-6a83-4004-b7db-74c34b545d2e	\N
036bcac0-c857-4bf0-bc71-1c78ed35d93a	https://raw.githubusercontent.com/ogrisel/notebooks/master/Labeled%2520Faces%2520in%2520the%2520Wild%2520recognition.ipynb			1		active	{"datastore_active": false}	Labeled Faces in the Wild recognition	\N	\N	\N	717993	2017-12-01 16:47:43.266081	\N	\N	\N	\N	2017-12-01 12:54:05.127144		1abefb2e-6a83-4004-b7db-74c34b545d2e	\N
1e335b61-123e-4ba4-9c5b-9d1d6309dba9	https://raw.githubusercontent.com/guillermobet/files/master/Example%20Machine%20Learning%20Notebook.ipynb			0		active	{"datastore_active": false}	Example Machine Learning notebook	\N	\N	\N	703819	2017-12-01 16:47:34.233655	\N	\N	\N	\N	2017-12-01 12:51:28.891625		1abefb2e-6a83-4004-b7db-74c34b545d2e	\N
0ce74f0d-bf35-4627-9f69-92d5c1150dff	https://github.com/guillermobet/files/raw/master/gkg_steel_zinced.zip			0		active	{"datastore_active": false}	Example .dwg file	\N	application/zip	\N	3414733	2017-12-01 16:50:37.896845	\N	\N	\N	\N	2017-11-24 13:37:06.599034		ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	\N
822d5c4a-751b-457c-b5f8-22f9ac88f1e8	https://data.uni-hannover.de/dataset/0ddcfe50-9e31-4225-b68f-e777d72fb859/resource/822d5c4a-751b-457c-b5f8-22f9ac88f1e8/download/alternative-models-japan-chile.zip	ZIP		0		active	\N	alternative-models-japan-chile.zip	\N	application/zip	\N	80335372	2021-11-18 12:12:45.480716	\N	\N	\N	\N	2021-11-18 12:12:45.516111		0ddcfe50-9e31-4225-b68f-e777d72fb859	2022-03-16 07:44:14.184699
9d137f93-7576-4654-8256-4ae7897ee469	https://data.uni-hannover.de/dataset/0ddcfe50-9e31-4225-b68f-e777d72fb859/resource/9d137f93-7576-4654-8256-4ae7897ee469/download/reference-models-japan-chile.zip	ZIP		1		active	\N	reference-models-japan-chile.zip	\N	application/zip	\N	24943572	2021-11-18 12:13:01.056643	\N	\N	\N	\N	2021-11-18 12:13:01.091467		0ddcfe50-9e31-4225-b68f-e777d72fb859	2022-03-16 07:44:14.187228
cc05a1c2-948b-4965-aea7-de09abdad953	https://data.uni-hannover.de/dataset/0ddcfe50-9e31-4225-b68f-e777d72fb859/resource/cc05a1c2-948b-4965-aea7-de09abdad953/download/catalogue-japan.csv	CSV		2		active	\N	Catalogue-Japan.csv	\N	text/csv	\N	973437	2021-11-22 15:01:33.805133	\N	\N	\N	\N	2021-11-22 15:01:33.838702		0ddcfe50-9e31-4225-b68f-e777d72fb859	2022-03-16 07:44:14.190012
aad9e24e-1046-4b70-9bb8-7d17a8371969	https://data.uni-hannover.de/dataset/0ddcfe50-9e31-4225-b68f-e777d72fb859/resource/aad9e24e-1046-4b70-9bb8-7d17a8371969/download/catalogue-chile.csv	CSV		3		active	\N	Catalogue-Chile.csv	\N	text/csv	\N	349250	2021-11-22 15:03:16.67128	\N	\N	\N	\N	2021-11-22 15:03:16.704088		0ddcfe50-9e31-4225-b68f-e777d72fb859	2022-03-16 07:44:14.192871
bd5d8d95-b3e2-4f25-a928-d75df8faf462	https://data.uni-hannover.de/dataset/c76adf5a-9aa8-4ebe-bbbe-0e61436cf033/resource/bd5d8d95-b3e2-4f25-a928-d75df8faf462/download/wavelet_gust_analysis.zip	ZIP	Wind velocity data in netCDF format, a python script for data analysis and a requirements.txt file containing all python package dependencies.	0		active	\N	wavelet_gust_analysis.zip	\N	application/zip	\N	96112	2019-07-09 17:27:20.810267	\N	\N	\N	\N	2019-07-09 17:27:20.908781		c76adf5a-9aa8-4ebe-bbbe-0e61436cf033	2022-03-16 07:44:14.881407
106f7149-6161-4117-893a-44990c05cbe4	https://data.uni-hannover.de/dataset/ef96d2db-9cbe-4738-b7bf-da556e12bdc2/resource/106f7149-6161-4117-893a-44990c05cbe4/download/code.zip	ZIP		0		active	\N	code.zip	\N	application/zip	\N	798357692	2019-06-27 16:35:58.612669	\N	\N	\N	\N	2019-06-27 16:35:58.670413		ef96d2db-9cbe-4738-b7bf-da556e12bdc2	2022-03-16 07:44:15.159307
3bc88bf0-f6f6-49ab-ae08-e65e30883125	https://data.uni-hannover.de/dataset/2dfe1d91-0394-4107-8309-b125d98840cc/resource/3bc88bf0-f6f6-49ab-ae08-e65e30883125/download/areas_with_low_and_medium_spatial_vulnerability_solar.zip	shape	The shapefiles display areas with low and medium spatial vulnerability ground-mounted photovoltaic systems.\r\n\r\n	0		active	\N	Areas_with_low_and_medium_spatial_vulnerability_solar.zip	\N	application/zip	\N	64071883	2022-01-06 14:52:34.096407	\N	\N	\N	\N	2022-01-06 14:52:34.14359		2dfe1d91-0394-4107-8309-b125d98840cc	2022-03-16 07:44:15.643793
4ee0ec1c-c72b-4bad-be73-364a735cea5c	drive_shaft.dwg			0		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	Example 2D .dwg file	\N	\N	\N	169807	2022-03-16 07:53:55.475515	\N	\N	\N	\N	2017-11-23 17:37:19.897441	upload	476cdf71-1048-4a6f-a28a-58fff547dae5	2022-03-16 07:53:55.487806
ade79b5d-14e3-4d08-a556-2135fee359f4	gkg_steel_zinced.zip	ZIP	Example usage of CAD using Ckan View with information provided by PANGAEA.	2		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	PANGEA CAD example	\N	application/zip	\N	3414733	2022-03-16 07:50:19.38818	\N	\N	\N	\N	2022-03-16 07:50:19.425337	upload	476cdf71-1048-4a6f-a28a-58fff547dae5	2022-03-16 07:53:55.488104
1342ec64-f18e-4860-93cc-f6dd194d56ec	visualization_-_aerial.dwg			1		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	Example 3D .dwg file	\N	\N	\N	733036	2022-03-16 07:54:28.325436	\N	\N	\N	\N	2017-11-23 17:40:23.217872	upload	476cdf71-1048-4a6f-a28a-58fff547dae5	2022-03-16 07:54:28.336364
8649545f-f1d0-49d2-b9cd-88f2593ec059	stf50_autocombustions_with_varying_phi_v2_hd.mp4	MP4		0		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	STF50 autocombustions with varying Phi (MP4)	\N	video/mp4	\N	71194509	2022-03-16 08:15:16.584473	\N	\N	\N	\N	2017-11-24 13:42:36.23793	upload	54920aae-f322-4fca-bd09-cd091946632c	2022-03-16 08:16:23.472676
849a62dc-45fe-4f7e-9687-09543b7f8512	pushrod.webm	WebM	The video was published by Leibniz University Hannover.	1		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	Boundary value problem of a push rod (WEBM)	\N	video/webm	\N	369844	2022-03-16 08:18:38.610661	\N	\N	\N	\N	2022-03-16 08:18:38.634836	upload	54920aae-f322-4fca-bd09-cd091946632c	2022-03-16 08:19:58.022597
a86b71e3-c68a-421e-b995-b172d603df62	spring.ogg	OGG	The video was published by Leibniz University Hannover.	2		active	{"auto_update": "No", "auto_update_url": ""}	Boundary value problem of a spring (OGG)	\N	audio/ogg	\N	543985	2022-03-16 08:19:58.009932	\N	\N	\N	\N	2022-03-16 08:19:58.037751	upload	54920aae-f322-4fca-bd09-cd091946632c	2022-03-16 08:19:58.022788
4a7d7059-b168-4772-9b81-ffb11f0f6d70	data_description.pdf	PDF	To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\r\nPublished by Leibniz University Hannover.	0		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	Data Description (PDF)	\N	application/pdf	\N	962808	2022-03-16 08:32:47.294826	\N	\N	\N	\N	2022-03-16 08:32:47.306135	upload	86b5446b-092a-4467-870c-b61b055d763f	2022-03-16 08:32:47.483091
ce24e635-7fef-47e2-9f70-a0b214805867	text_example.txt	TXT	This is just text for visualization.	1		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	Text file example (TXT)	\N	text/plain	\N	2330	2022-03-16 08:43:38.994979	\N	\N	\N	\N	2022-03-16 08:43:39.008718	upload	86b5446b-092a-4467-870c-b61b055d763f	2022-03-16 08:45:49.075099
1fb543eb-9980-494e-bd3b-26aa99bc06ef	2017-12-21_vnstat-export-br0.xml	XML	This is a XML file published by Leibniz University Hannover.	1		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	XML Data Example	\N	application/xml	\N	9610	2022-03-16 09:26:47.705015	\N	\N	\N	\N	2022-03-16 09:26:47.719119	upload	d5d29173-addc-4e4d-af7b-59e3b147c817	2022-03-16 09:37:22.695414
43670f2e-4bcc-4835-8f95-5eb6c8a0ace6	junctiona.png	PNG	Intersection A with overlaid trajectory samples and background image.\r\nImage published by Leibniz University Hannover.	2		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	PNG image example	\N	image/png	\N	2085108	2022-03-16 08:49:17.919665	\N	\N	\N	\N	2022-03-16 08:45:49.079082	upload	86b5446b-092a-4467-870c-b61b055d763f	2022-03-16 08:51:44.365574
9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac	gtem_1250.jpg	JPEG	Picture of the GTEM 1250 cell.\r\nImage published by Leibniz University Hannover.	3		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	JPG Image example	\N	image/jpeg	\N	2437112	2022-03-16 08:51:44.355645	\N	\N	\N	\N	2022-03-16 08:51:44.369862	upload	86b5446b-092a-4467-870c-b61b055d763f	2022-03-16 08:54:45.118772
3486d220-0c38-4449-96df-7d4d18b916a7	giphy.gif	GIF	Just a GIF image for visualization.	4		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	GIF image example	\N	image/gif	\N	3132208	2022-03-16 08:54:45.107385	\N	\N	\N	\N	2022-03-16 08:54:45.122641	upload	86b5446b-092a-4467-870c-b61b055d763f	2022-03-16 09:03:59.911887
95a1ebf6-d481-4940-923c-59b21921dfda	https://filesamples.com/samples/document/odt/sample1.odt	ODT	This is just an example for visualization.	5		active	{"datastore_active": false}	OpenOffice Writer example (ODT) 	\N	application/vnd.oasis.opendocument.text	\N	21423	2022-03-16 09:07:55.525141	\N	\N	\N	\N	2022-03-16 09:03:59.916552		86b5446b-092a-4467-870c-b61b055d763f	2022-03-16 09:13:02.560479
05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43	https://data.uni-hannover.de/dataset/feff84ea-89ec-4ce6-95fa-70060af298ac/resource/2a217dfd-b313-41fb-836f-de0ec6610569/download/jcdl-2019-dils-2019-papers-orkg-overview.xlsx	XLSX	This is a XLSX file published by Leibniz University Hannover. 	4		active	{"datastore_active": false}	XLSX Data Example	\N	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	\N	32536	2022-03-16 09:33:30.410841	\N	\N	\N	\N	2022-03-16 09:33:30.427169		d5d29173-addc-4e4d-af7b-59e3b147c817	2022-03-16 09:36:28.62165
047da174-2caa-45db-bc43-36fd3523ee30	https://filesamples.com/samples/document/ods/sample1.ods	ODS	This is just an example file of the format for visualization.	5		active	{"datastore_active": false}	Open Document Spreadsheet (ODS) Example	\N	application/vnd.oasis.opendocument.spreadsheet	\N	\N	\N	\N	\N	\N	\N	2022-03-16 09:36:28.626475	\N	d5d29173-addc-4e4d-af7b-59e3b147c817	2022-03-16 09:37:22.695859
e3e6e6ef-e356-4005-af2e-2e8538ed3f58	2017-12-21_vnstat-export-br0.json	JSON	This is a JSON file published by Leibniz University Hannover. 	2		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	JSON Data Example	\N	application/json	\N	6211	2022-03-16 09:29:08.762912	\N	\N	\N	\N	2022-03-16 09:29:08.778126	upload	d5d29173-addc-4e4d-af7b-59e3b147c817	2022-03-16 09:37:40.835838
966e73d8-654f-4396-ad35-c2bd212e9afd	https://filesamples.com/samples/document/odp/sample1.odp	ODP	This is just an example file for visualization.	6		active	\N	Open Document Presentation (ODP)	\N	application/vnd.oasis.opendocument.presentation	\N	389789	2022-03-16 09:13:02.545995	\N	\N	\N	\N	2022-03-16 09:13:02.565493		86b5446b-092a-4467-870c-b61b055d763f	2022-03-16 09:13:40.788864
fece58b1-1505-4ef0-befb-3f0edf59335d	https://data.uni-hannover.de/dataset/f85549ff-c0ce-4cc0-a699-d551b21d6afb/resource/4f6cbe6b-4b68-482c-b42b-ac2e08cbb7e8/download/1-laurenz_meyhoefer_a.-proletella-performance.csv	CSV	All data are analysed and published 2020 under the title "Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella".\r\nThis dataset was published by Leibniz University Hannover.	0		active	{"datastore_active": false}	CSV Data Example	\N	text/csv	\N	2017	2022-03-16 09:22:41.200122	\N	\N	\N	\N	2022-03-16 09:22:41.213753		d5d29173-addc-4e4d-af7b-59e3b147c817	2022-03-16 09:23:48.601689
5a139ebc-3076-47a5-a7d5-9b3c6505dd9e	luh-beispiel-netzwerkmessdaten.rdf	RDF	This is a RDF file example generated from data published by Leibniz University Hannover. 	3		active	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	RDF Data Example	\N	application/rdf+xml	\N	6203	2022-03-16 09:30:52.51129	\N	\N	\N	\N	2022-03-16 09:30:52.528628	upload	d5d29173-addc-4e4d-af7b-59e3b147c817	2022-03-16 09:38:08.54171
4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7	https://service.tib.eu/ldmservice/dataset/672f2339-c57f-48f5-a681-b62acc50f488/resource/22312cbf-7a7a-4510-88b5-8a1a828f3064/download/data.csv	CSV	This is a sample dataset for demonstration purposes.	0		active	{"datastore_active": false}	Cars data	\N	text/csv	\N	1475504	2022-03-16 09:47:36.6725	\N	\N	\N	\N	2022-03-16 09:47:36.683662		ed56c026-3d32-41d5-9d11-2aa655cb8052	2022-03-16 09:48:33.163961
5c653296-8877-42f4-9dee-84de4784dcca	exploratory_data_analysis.ipynb	ipynb	This jupyter notebook runs live code over the cars.cvd data present in the same dataset.	1		active	{"auto_update": "No", "auto_update_url": ""}	Exploratory Data Analisys of Cars	\N	\N	\N	199131	2022-03-16 09:50:33.020919	\N	\N	\N	\N	2022-03-16 09:50:33.036016	upload	ed56c026-3d32-41d5-9d11-2aa655cb8052	2022-03-16 09:52:16.210277
\.


--
-- Data for Name: resource_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.resource_revision (id, url, format, description, "position", revision_id, hash, state, continuity_id, extras, expired_id, revision_timestamp, expired_timestamp, current, name, resource_type, mimetype, mimetype_inner, size, last_modified, cache_url, cache_last_updated, webstore_url, webstore_last_updated, created, url_type, package_id) FROM stdin;
\.


--
-- Data for Name: resource_view; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.resource_view (id, resource_id, title, description, view_type, "order", config) FROM stdin;
87b749f5-c526-4459-a6ce-2d20632ddf5a	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Quick_Python_Intro		webpage_view	0	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/00_Quick_Python_Intro.ipynb"}
0e3155e4-6ca5-4eb7-8241-858ac7890bc0	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_1		webpage_view	1	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/01_Step_1.ipynb"}
04b28583-eb58-4867-8d1f-bdcebf2ecb31	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_2		webpage_view	2	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/02_Step_2.ipynb"}
c2440d77-ca61-4ab0-b760-bc176a245361	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_3		webpage_view	4	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/04_Step_3.ipynb"}
c9b2715b-8e4e-4378-894c-c44f271e9b1b	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_4		webpage_view	5	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/05_Step_4.ipynb"}
3e6dcc07-9ffe-4b79-80cd-3f87cdff7375	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Array_Operations_with_NumPy		webpage_view	6	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/06_Array_Operations_with_NumPy.ipynb"}
63959a0d-6a34-4f67-9c40-a7557b750b57	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_5		webpage_view	7	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/07_Step_5.ipynb"}
c34f664a-b3b3-437b-af2c-c32b239e57f3	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_6		webpage_view	8	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/08_Step_6.ipynb"}
63960e24-5a18-426a-87df-a0dd2abaec4a	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_7		webpage_view	9	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/09_Step_7.ipynb"}
dcaf858c-fbb2-4393-9ec1-7335a8e68bfd	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_8		webpage_view	10	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/10_Step_8.ipynb"}
4aeae44e-5979-4dc3-bd21-66daf7244819	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Defining_Function_in_Python		webpage_view	11	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/11_Defining_Function_in_Python.ipynb"}
4a34d74e-8c98-4a03-a936-3a436f78e11e	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_9		webpage_view	12	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/12_Step_9.ipynb"}
c8740058-b25a-499a-a265-84050cfc54fb	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_10		webpage_view	13	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/13_Step_10.ipynb"}
eb28a98e-f096-48d3-9ec1-bd00f3a5e5f8	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_11		webpage_view	14	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/15_Step_11.ipynb"}
5c1a521b-f0f1-4ab0-be3e-a16025d38575	ec1c5422-b8ab-4401-96fb-0792dacb8e40	Step_12		webpage_view	15	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/16_Step_12.ipynb"}
78268b6c-c7ff-4d57-b95d-8cf8d4beee80	ec1c5422-b8ab-4401-96fb-0792dacb8e40	CFL_Condition		webpage_view	3	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/lessons/03_CFL_Condition.ipynb"}
f89a1a2e-9994-440b-b14f-d8749d61581a	e4cc8bf6-5e32-4c1f-b22e-109d47340c96	view		webpage_view	0	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/Satellite_Example.ipynb"}
ba5e8b5b-81f6-4561-80d1-1474f4818ff8	4577e551-96f8-4e13-ac81-012a866d00ac	view		webpage_view	0	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/GW150914_tutorial.ipynb"}
d9c34cef-7daa-46f4-a67d-32054d97662e	036bcac0-c857-4bf0-bc71-1c78ed35d93a	view		webpage_view	0	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/Labeled%20Faces%20in%20the%20Wild%20recognition.ipynb"}
c0442c6b-9d26-4f1d-9337-75b9fecb1f14	1e335b61-123e-4ba4-9c5b-9d1d6309dba9	view		webpage_view	0	{"page_url": "http://vocol.kbs.uni-hannover.de:8000/user/auer/notebooks/ckan22012018/ckan_tib/files/Example%20Machine%20Learning%20Notebook.ipynb"}
3ca5593a-c5f5-403b-bbab-1c6a03ca66f6	0ce74f0d-bf35-4627-9f69-92d5c1150dff	Example CAD		webpage_view	0	{"page_url": "https://myhub.autodesk360.com/ue2a46308/shares/public/SH7f1edQT22b515c761ee0288183ac670a79?mode=embed"}
112f0904-7337-49e3-8782-a868b5f906e5	1342ec64-f18e-4860-93cc-f6dd194d56ec	Example .dwg file		webpage_view	0	{"page_url": "https://myhub.autodesk360.com/ue2a46308/shares/public/SH7f1edQT22b515c761e6db7f4edd03f771f?mode=embed"}
1fc870fd-2759-4555-acbf-1faedacbe3f5	4ee0ec1c-c72b-4bad-be73-364a735cea5c	Example .dwg view		webpage_view	0	{"page_url": "https://myhub.autodesk360.com/ue2a46308/shares/public/SH7f1edQT22b515c761e9391076694b105bd?mode=embed"}
7d6f355f-ea2e-4f93-900f-abad36d4c10f	8649545f-f1d0-49d2-b9cd-88f2593ec059	Video		videoviewer	0	\N
e89ce4cd-f3a2-47a9-88be-b3867f2eda61	cc05a1c2-948b-4965-aea7-de09abdad953	Data Explorer		recline_view	0	\N
9cc3c0d7-3b0b-44d3-9811-8e4a41ac5267	aad9e24e-1046-4b70-9bb8-7d17a8371969	Data Explorer		recline_view	0	\N
f76542b2-938e-493f-ba66-166ba9bceafd	ade79b5d-14e3-4d08-a556-2135fee359f4	PANGEA CAD example		webpage_view	0	{"page_url": "https://myhub.autodesk360.com/ue2a46308/shares/public/SH7f1edQT22b515c761ee0288183ac670a79?mode=embed"}
5c21c0f1-637e-4898-814b-33df383bd92a	849a62dc-45fe-4f7e-9687-09543b7f8512	Video		videoviewer	0	\N
9f7bdf2b-e420-4c4a-9e9a-6cc14aad5516	a86b71e3-c68a-421e-b995-b172d603df62	Video		videoviewer	0	\N
44f9c2f8-439e-4b80-931f-13f4e4b86fff	ce24e635-7fef-47e2-9f70-a0b214805867	Text		text_view	0	\N
1eaddbb2-8a82-4c31-972c-c4028b71d138	4a7d7059-b168-4772-9b81-ffb11f0f6d70	PDF		pdf_view	0	{"pdf_url": "https://data.uni-hannover.de/dataset/bcdf26cd-3b02-4f15-80dd-3b3eb83de9dc/resource/abf53e9f-0e55-48fa-b2b2-6c211c22b72c/download/data_description.pdf"}
6c337624-8a4b-408b-98cc-11a5d3fa1a3a	43670f2e-4bcc-4835-8f95-5eb6c8a0ace6	Image		image_view	0	\N
ffaab2d6-258c-4dbb-b7d6-de593c4ef1ae	9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac	Image		image_view	0	\N
e97ef89d-d9ff-4521-9668-05ae9d6591b7	3486d220-0c38-4449-96df-7d4d18b916a7	Image		image_view	0	\N
c0ec4663-0696-49a5-808d-e6296f30ac3f	95a1ebf6-d481-4940-923c-59b21921dfda	Preview		officedocs_view	0	\N
53c0a30e-ce17-4151-bf04-45a12068789b	966e73d8-654f-4396-ad35-c2bd212e9afd	Preview		officedocs_view	0	\N
eaee70c2-3bcb-4aaf-9cbd-1a7102c875bb	fece58b1-1505-4ef0-befb-3f0edf59335d	Data Explorer		recline_view	0	\N
46aa5576-ee87-4924-b01c-851a5898c317	5a139ebc-3076-47a5-a7d5-9b3c6505dd9e	Text		text_view	0	\N
581c22b2-016b-4438-ab7b-4edcd422a91f	05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43	Preview		officedocs_view	1	\N
597a700c-ad5c-4930-b3ac-56c0b23148d6	047da174-2caa-45db-bc43-36fd3523ee30	Preview		officedocs_view	1	\N
c75144bc-11d0-4020-82da-ad8e9d7bf995	4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7	Data Explorer		recline_view	0	\N
6ab2a1bd-f823-4025-9bf0-1874de43ef1e	5c653296-8877-42f4-9dee-84de4784dcca	Jupyter Notebook		jupyternotebook	0	\N
ffd67852-5c8a-4219-b696-925cc7f6459e	1fb543eb-9980-494e-bd3b-26aa99bc06ef	Text		text_view	0	\N
320795c3-6441-4629-8216-5b16002e46f3	e3e6e6ef-e356-4005-af2e-2e8538ed3f58	Text		text_view	0	\N
\.


--
-- Data for Name: revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.revision (id, "timestamp", author, message, state, approved_timestamp) FROM stdin;
8d1097e3-7927-4a56-a0ca-7cf63bac290b	2017-08-08 16:45:27.162981	system	Add versioning to groups, group_extras and package_groups	active	2017-08-08 16:45:27.162981
afac2a9c-773c-4441-abd5-c45d7e5c9601	2017-08-08 16:45:28.557122	admin	Admin: make sure every object has a row in a revision table	active	2017-08-08 16:45:28.557122
729f6192-b932-4413-904c-a72e21f8ef69	2017-08-08 16:46:26.136217	admin		active	\N
214d1b21-6103-4c97-9fa3-145ca5d2f7c1	2017-08-08 16:46:26.246108	admin	REST API: Create member object 	active	\N
2b61e1eb-c56d-4852-b55c-47f0e7308c6e	2017-08-08 16:50:26.684564	admin		active	\N
3d4c3cf2-2604-49a3-b846-bcfca91c4b22	2017-08-08 16:50:49.589423	admin	REST API: Update object event-information	active	\N
bffaa2dd-7e21-45e1-9c62-336b10a1381d	2017-08-08 16:50:50.836029	admin	REST API: Update object event-information	active	\N
65a08933-48aa-426b-bf8a-d11aa32dca95	2017-08-08 16:52:29.604017	admin		active	\N
15c99021-e05b-4678-b035-a1e8203dd9e1	2017-08-08 16:52:48.401496	admin	REST API: Update object services-information	active	\N
ba506755-adf8-4f97-bf70-90355c658dd7	2017-08-08 16:52:49.648027	admin	REST API: Update object services-information	active	\N
8b393d77-16b0-4e7c-b64e-63acf71345d5	2017-08-08 16:54:35.123783	admin		active	\N
4537cbb8-b49b-4611-9721-a775af0095fe	2017-08-08 16:55:27.252098	admin	REST API: Update object internet-dataset	active	\N
d2a0b75b-4856-4b6c-affc-729a99bbe985	2017-08-08 16:55:28.496897	admin	REST API: Update object internet-dataset	active	\N
dd70f0dc-ac9d-4ea3-8888-ddb077b44502	2017-08-08 16:57:30.229943	admin		active	\N
1815b63f-6afc-43d0-aac9-d8a9daec8f93	2017-08-08 16:57:41.818059	admin	REST API: Update object mobile-plans	active	\N
18ca3b06-e9d5-4129-b12c-1eacc9c8de32	2017-08-08 16:57:43.111847	admin	REST API: Update object mobile-plans	active	\N
9280682a-0335-4e81-85d6-52933a06e3c9	2017-08-09 09:04:44.592668	admin	REST API: Update object mobile-plans	active	\N
b4332ffc-49c7-4942-bdcb-2c53f2229dc1	2017-11-23 14:57:51.835359	admin		active	\N
82682f2c-fa0b-4c03-bb4e-b4b9688a30fe	2017-11-23 15:46:09.672312	admin		active	\N
b92c6580-a7e2-4290-8714-6a929b069bce	2017-11-23 15:46:18.449887	admin	REST API: Update object laala	active	\N
ac630955-9972-4f00-b6fa-13a3ca87a7dc	2017-11-23 15:46:18.641891	admin	REST API: Update object laala	active	\N
c03ec2df-5924-4683-8187-ed089fc01bb8	2017-11-23 15:47:05.225944	admin	REST API: Update object laala	active	\N
fd421030-cb68-4de2-8f11-c5e96c173b98	2017-11-23 15:54:25.192438	admin	REST API: Update object laala	active	\N
d511ee78-7698-40f0-af4b-f77f2ebebe59	2017-11-23 16:16:03.560771	admin	REST API: Update object laala	active	\N
05868de0-c21f-4edd-8afb-40b218b9faf6	2017-11-23 16:16:22.224111	admin	REST API: Update object laala	active	\N
454d15f3-840e-4b08-939e-59a7b5419c85	2017-11-23 16:44:34.681607	admin		active	\N
62048bd6-7dec-4f73-b09b-e3a8e2ef38d1	2017-11-23 16:44:55.628241	admin	REST API: Update object prueba	active	\N
b5b9f114-0ecf-4d96-bda8-0b0cde5b04d6	2017-11-23 16:44:55.762789	admin	REST API: Update object prueba	active	\N
79e552b7-ddc1-4eea-b3af-94653149dc1b	2017-11-23 16:51:07.974293	admin	REST API: Delete Package: prueba	active	\N
11460728-1a99-41d2-aa3e-21b670cecf88	2017-11-23 16:51:17.292185	admin	REST API: Delete Package: laala	active	\N
a40e9a0b-920d-4831-be14-2143eff3e1f5	2017-11-23 16:52:07.134719	admin		active	\N
61319c01-1286-4756-8ee1-eb4d99eed635	2017-11-23 16:52:15.723322	admin	REST API: Update object http-autode-sk-2zzs3jo	active	\N
a35cfd73-4f2e-4fb3-aed5-a5b285bca02d	2017-11-23 16:52:15.890366	admin	REST API: Update object http-autode-sk-2zzs3jo	active	\N
0308d025-a61d-4912-927c-b83a259af206	2017-11-23 16:54:02.990389	admin		active	\N
d3d16ded-e5ec-4ca5-9710-cce9eaf61cff	2017-11-23 16:54:09.765566	admin	REST API: Update object http-www-imagen-com-mx-assets-img-imagen_share-png	active	\N
edc363a9-dcaa-4ad2-8d16-30c2cfd6ad5e	2017-11-23 16:54:09.967897	admin	REST API: Update object http-www-imagen-com-mx-assets-img-imagen_share-png	active	\N
b66ffafa-45f9-4548-87d0-6c706c736eeb	2017-11-23 16:54:59.028388	admin	REST API: Update object http-www-imagen-com-mx-assets-img-imagen_share-png	active	\N
6b3e479d-9737-4ca7-b32d-b98bf437a60c	2017-11-23 16:55:10.759507	admin	REST API: Delete Package: http-www-imagen-com-mx-assets-img-imagen_share-png	active	\N
62396fd7-e314-4b1f-bdc8-cd3410ff795e	2017-11-23 16:55:17.143128	admin	REST API: Delete Package: http-autode-sk-2zzs3jo	active	\N
2379ec08-54f7-4f8a-9cb8-a550f3535800	2017-11-23 16:59:32.133562	admin		active	\N
5f370a54-be5e-4668-bf78-b2b18fa2bc44	2017-11-23 16:59:46.402036	admin	REST API: Update object prueba	active	\N
4fc2baf4-0ca3-4ea1-9d25-597e6a6143eb	2017-11-23 16:59:46.590922	admin	REST API: Update object prueba	active	\N
87ab6ae0-0d32-41e4-8446-a648e652c8db	2017-11-23 17:06:26.17582	admin	REST API: Update object prueba	active	\N
1d7a208f-a535-4f6d-ad3c-18d8c9866feb	2017-11-23 17:07:42.003088	admin		active	\N
d74a18d9-14a3-40a4-b848-d1d9148e2102	2017-11-23 17:07:50.644253	admin	REST API: Update object aaaa	active	\N
76a15254-7ed3-4c64-94e0-4c93fd886a70	2017-11-23 17:07:50.816393	admin	REST API: Update object aaaa	active	\N
61558a1e-8f38-4eea-be11-4831ab21f9ab	2017-11-23 17:10:49.355305	admin	REST API: Update object aaaa	active	\N
4609ef6f-b90f-49f1-aef7-0381acb539ba	2017-11-23 17:11:23.956824	admin	REST API: Update object aaaa	active	\N
b832bb18-8732-45d7-858a-97f2a9f85006	2017-11-23 17:13:07.174286	admin	REST API: Update object aaaa	active	\N
c84a2f2b-7aae-4ce0-9746-ed5ff839a497	2017-11-23 17:13:31.389751	admin	REST API: Update object aaaa	active	\N
be62d02b-aac3-4fa9-adda-5f7055efe684	2017-11-23 17:15:23.474621	admin	REST API: Update object aaaa	active	\N
54de6fec-f172-4558-8292-950fa99f513a	2017-11-23 17:15:54.400598	admin	REST API: Update object aaaa	active	\N
99077077-577e-48cc-bd73-2f28656f45f5	2017-11-23 17:16:10.379915	admin	REST API: Update object aaaa	active	\N
cd6b8c3c-4df5-42a5-a76a-db925c99dbde	2017-11-23 17:23:12.523632	admin	REST API: Update object aaaa	active	\N
ad0c12ae-80f3-437a-8f31-ce5bef87b962	2017-11-23 17:23:33.216791	admin	REST API: Update object aaaa	active	\N
2d0e5c97-33d8-47d3-9c65-f334df5365fc	2017-11-23 17:25:49.828161	admin	REST API: Update object aaaa	active	\N
b8777631-802d-4981-aa3a-b71e40e44ea9	2017-11-23 17:28:58.690985	admin	REST API: Delete Package: aaaa	active	\N
78e33def-565f-45dc-b9a4-a1dda81e1ce1	2017-11-23 17:29:52.524044	admin	REST API: Delete Package: event-information	active	\N
201d00c8-1f94-43d3-ac75-e9bfeb22a2f4	2017-11-23 17:29:52.589459	admin	REST API: Delete Package: internet-dataset	active	\N
19ac713d-48f0-48b9-9cd5-7061843bc62f	2017-11-23 17:29:52.65148	admin	REST API: Delete Package: mobile-plans	active	\N
7d60ea7c-29e6-447b-a3c6-e32ad2ccd4f9	2017-11-23 17:29:52.708328	admin	REST API: Delete Package: services-information	active	\N
ccfec652-355d-4640-b04e-9404427ece66	2017-11-23 17:29:52.793785	admin	REST API: Delete Group: china-unicom	active	\N
34c3de5f-7e58-4806-9177-733da1fca73c	2017-11-23 17:30:37.750126	admin		active	\N
6d7701f6-3ad0-4073-a1a9-262f793ac188	2017-11-24 13:40:21.970443	admin		active	\N
5ef118d1-fedc-4799-9a83-c623048d3dc5	2017-11-23 17:30:37.776018	admin	REST API: Create member object 	active	\N
935c959c-8191-4dc4-81b0-50e9e829d325	2017-11-23 17:31:36.655707	admin		active	\N
261614c5-63db-4f81-83d2-45690db30b97	2017-11-24 13:42:19.401789	admin		active	\N
6a333863-cac8-4957-9ed5-968dc91c74be	2017-11-23 17:32:08.010838	admin		active	\N
dea564f1-30b2-4e1a-85dc-f13abbd0803e	2017-11-23 17:32:40.502714	admin		active	\N
5efbd00b-0986-4ceb-8b66-5a7dde3e1586	2017-11-24 13:42:36.230296	admin	REST API: Update object example-video-2	active	\N
f7063097-85a5-43cb-8b7b-c3cf3f86fe1e	2017-11-23 17:33:31.502991	admin	REST API: Update object example-videos	active	\N
ce2b7558-924a-445d-a0be-3cfad1f498c2	2017-11-23 17:33:31.668229	admin	REST API: Update object example-videos	active	\N
1c58622d-c7db-4a68-8693-f42da07e9c4e	2017-11-24 13:42:36.379722	admin	REST API: Update object example-video-2	active	\N
740de3d8-633c-4f40-a252-0085125239b2	2017-11-23 17:35:15.661653	admin	REST API: Update object example-videos	active	\N
00277d2f-879f-426e-98e9-39839776d89d	2017-11-23 17:35:47.356658	admin		active	\N
f732828b-2166-4541-9128-f838a260ae1b	2017-11-23 17:37:00.356594	admin		active	\N
469f7ad0-8cce-4220-8859-7f640494206b	2017-11-23 17:37:19.886163	admin	REST API: Update object example-cad	active	\N
9c5af1cf-98c7-4a89-8c5d-4acc9a801b72	2017-11-28 19:31:59.859318	admin		active	\N
5d3d4988-cbf0-43e0-bb1a-8c9aee0fccd5	2017-11-23 17:37:20.059045	admin	REST API: Update object example-cad	active	\N
f4499856-fe22-47ba-9e93-ac6f2c547685	2017-11-23 17:40:23.209452	admin	REST API: Update object example-cad	active	\N
da855841-187d-4983-a6fe-0c3701dfb68e	2017-11-28 19:32:29.309289	admin	REST API: Update object test-jupyter	active	\N
40aaa8c6-d66d-4632-bfab-bf3daad5244d	2017-11-23 17:40:57.416938	admin	REST API: Update object example-cad	active	\N
f4b8e39c-ebec-4108-b18e-146f213a6a3b	2017-11-24 12:31:07.784957	admin		active	\N
d22239f4-6828-4fa1-be3f-4736fc8b354d	2017-11-28 19:32:29.449516	admin	REST API: Update object test-jupyter	active	\N
01835081-84bb-447b-92b7-cc793a8ec18a	2017-11-24 12:35:58.757075	admin	REST API: Delete Package: prueba	active	\N
39eb3d69-8ca4-477c-b7c6-7556c833986b	2017-11-24 13:36:15.8815	admin		active	\N
b19c528c-268f-43f7-987a-77da686eef9d	2017-11-28 19:34:41.945993	admin	REST API: Update object test-jupyter	active	\N
31c7be31-940b-409d-91b1-7f665f3de66a	2017-11-24 13:37:06.590149	admin	REST API: Update object example-cad-2	active	\N
07d39bd8-2ebc-4e4f-9018-6edc75251e06	2017-11-24 13:37:06.717505	admin	REST API: Update object example-cad-2	active	\N
c0d32fee-6737-4a91-920a-d8aab223e545	2017-12-01 11:56:50.587446	admin		active	\N
78462af9-3e29-41e7-b739-815aa263ff3d	2017-12-01 11:57:19.351494	admin		active	\N
beb04331-d499-485b-9369-1f57aa6f7395	2017-12-01 11:57:31.640309	admin		active	\N
f8632874-e874-4ec3-97ce-c15bffe12f28	2017-12-01 12:26:03.416187	admin	REST API: Delete Package: example-videos	active	\N
f69e3832-0198-44c5-a4f2-f52a65fe3ca2	2017-12-01 12:26:27.563253	admin		active	\N
4c6cf89c-065e-4c3e-85a0-bd6c7ed30b75	2017-12-01 12:26:42.710983	admin	REST API: Delete Package: test-jupyter	active	\N
f42bf4cf-a31c-4645-bb98-9ecbdf58d1ca	2017-12-01 12:27:24.136585	admin		active	\N
0489aebe-7484-4f6b-a051-9907f1b31b20	2017-12-01 12:42:20.934054	admin	REST API: Update object example-video-2	active	\N
29af1387-94a1-460f-b0d1-fdfb7de377e7	2017-12-01 12:43:39.909055	admin	REST API: Update object example-video-2	active	\N
91daa1ea-e394-4b70-a9e0-366b7c0b95fe	2017-12-01 12:51:12.212384	admin		active	\N
971f6de4-cde5-4773-9196-fe7fccb4c9ac	2017-12-01 12:51:28.881885	admin	REST API: Update object jupyter-notebooks	active	\N
9a2f4e77-4520-4878-b51b-359e8adcba17	2017-12-01 12:51:29.035769	admin	REST API: Update object jupyter-notebooks	active	\N
3951536e-4b6f-4e7a-add1-b55c5002dcc0	2017-12-01 12:51:37.465931	admin		active	\N
b0de1461-ba0a-4971-8682-f14af889ae40	2017-12-01 12:51:49.531837	admin		active	\N
997a3d54-bb90-4c1e-88bf-417e4c95ba21	2017-12-01 12:52:07.396644	admin		active	\N
6fc03502-641d-4cd0-96d6-e56dfb3caa62	2017-12-01 12:52:47.135119	admin	REST API: Update object jupyter-notebooks	active	\N
2e56ef3c-2f4f-4f73-b213-4214ece22001	2017-12-01 12:54:05.117964	admin	REST API: Update object jupyter-notebooks	active	\N
b08fcb64-f1a0-4de2-8a84-5e28f3922b16	2017-12-01 12:54:30.52175	admin	REST API: Update object jupyter-notebooks	active	\N
41602a5a-b63a-4104-ba15-52f0c1c35526	2017-12-01 12:55:06.663794	admin	REST API: Update object jupyter-notebooks	active	\N
670dffd1-3172-40b8-8e0d-8956760a084a	2017-12-01 12:56:06.85125	admin	REST API: Update object jupyter-notebooks	active	\N
ec55548e-a397-4b9c-afac-2f24518f3991	2017-12-01 12:58:35.866871	admin	REST API: Update object jupyter-notebooks	active	\N
6bbacefb-7a0e-47f0-b3b6-fe7f99b2fd4e	2017-12-01 16:35:53.312882	admin	REST API: Update object example-video-2	active	\N
f1e7cf9b-cca1-4e09-ae98-7433e34718ac	2017-12-01 16:47:34.242126	admin	REST API: Update object jupyter-notebooks	active	\N
ddb53a5e-f9ff-47c5-be50-657f6214d787	2017-12-01 16:47:43.274081	admin	REST API: Update object jupyter-notebooks	active	\N
f41688c5-b4da-4fb5-9165-e5aa2783ba73	2017-12-01 16:47:54.883691	admin	REST API: Update object jupyter-notebooks	active	\N
9b14e4f2-5d5d-4693-b0b6-27bc2cd40e4a	2017-12-01 16:48:04.514889	admin	REST API: Update object jupyter-notebooks	active	\N
83b264fc-0dd9-4270-9c2a-e3ec22ebafee	2017-12-01 16:48:21.533485	admin	REST API: Update object jupyter-notebooks	active	\N
ba4e1fea-9747-477a-adb7-82447b0e99a1	2017-12-01 16:50:37.902486	admin	REST API: Update object example-cad-2	active	\N
36f8a864-0e03-43c8-a8d7-91ca0fe7ec1e	2017-12-01 16:52:30.518409	admin	REST API: Update object example-cad	active	\N
1dfe4f70-fe22-4f93-b708-93d2166875e0	2017-12-01 16:53:23.699673	admin	REST API: Update object example-cad	active	\N
25711b9c-54ee-4629-ba88-03fbd139dda0	2017-12-04 16:42:27.658484	admin		active	\N
4f99eafe-97a2-4b14-be62-63ad7cffc7be	2017-12-04 16:43:57.658681	admin		active	\N
e58c8491-4add-4147-b929-e12d05531f9d	2017-12-05 11:07:10.617313	admin		active	\N
41e8a326-3a0c-4ab2-af20-7427bd551504	2017-12-05 11:08:31.916963	admin		active	\N
7a7537ca-0c0c-4501-b244-a3d813e376d1	2017-12-05 12:29:57.69185	admin		active	\N
959e1cc4-8271-4643-b3d5-4a6dd3e92074	2017-12-05 12:47:02.943794	admin		active	\N
778fcf5c-b993-40b3-ad2b-088dcb674c2e	2017-12-05 12:49:18.578696	admin		active	\N
9c6d5cc2-06e9-46c9-acd2-77a99cf3ac8b	2017-12-05 12:50:32.679984	admin		active	\N
c7cbaa34-461b-4cd7-932d-d70ae8e2254b	2017-12-05 12:53:47.895125	admin		active	\N
fc2b5cb3-7333-4ac3-b707-2548a16d6e1a	2017-12-05 13:10:44.627851	admin		active	\N
74a74b6a-3df2-4d28-92dd-956bcdad2265	2017-12-05 13:11:18.466672	admin		active	\N
d325e2f3-8a4a-4b42-b99d-2d1152e093ea	2017-12-05 13:12:32.84258	admin		active	\N
606a0443-92eb-443b-8f03-5d342a4c53a7	2017-12-05 16:11:57.332922	admin	REST API: Update object example-video-2	active	\N
1154ccc2-5934-43a5-99d8-fb903dde0691	2017-12-05 16:12:30.327625	admin	REST API: Update object example-video-2	active	\N
690a634b-a609-4502-b01e-c1c08da7e478	2017-12-05 16:15:34.312042	admin	REST API: Update object example-cad-2	active	\N
71dc2312-5c40-4517-9e25-17b471fea2cb	2017-12-05 16:16:20.857252	admin	REST API: Update object example-cad-2	active	\N
38a2a6f3-e1b4-4bf0-be67-9570df5257ef	2017-12-05 16:16:53.012934	admin	REST API: Update object example-cad	active	\N
d15e34ce-171d-4b7c-97fa-7f962f51bc54	2017-12-05 16:17:38.097909	admin	REST API: Update object example-cad	active	\N
5c1a7014-4c5e-46d7-bf6e-71c09d905edb	2017-12-05 16:18:11.316604	admin	REST API: Update object jupyter-notebooks	active	\N
a62f6486-cf27-4b3f-b739-207b5f69d06c	2017-12-05 16:19:39.440513	admin	REST API: Update object jupyter-notebooks	active	\N
92d37aae-e70c-40f9-ab15-028a15ae3991	2017-12-05 16:20:10.269756	admin	REST API: Update object jupyter-notebooks	active	\N
b9cbf887-ecb8-4874-bb03-1c62f312d158	2017-12-05 16:19:56.237369	admin	REST API: Update object jupyter-notebooks	active	\N
065ffe84-177e-4e13-8319-20bce551300f	2017-12-05 16:20:26.498338	admin	REST API: Update object jupyter-notebooks	active	\N
4f894272-891f-42e2-a01b-184fe666f896	2017-12-19 12:46:02.680685	admin		active	\N
e5f2392a-5484-48b4-bec3-f57fac558025	2017-12-19 12:46:52.491415	admin		active	\N
f3f319b0-0606-4f64-9740-ba5ce3e8c244	2017-12-19 12:47:00.325384	admin	REST API: Update object foobarbaz	active	\N
28f7833d-c40f-4339-8a53-4de36f72f886	2017-12-19 12:47:00.530533	admin	REST API: Update object foobarbaz	active	\N
069046d5-6db8-459d-800b-e57a2c600588	2017-12-19 12:54:07.736735	admin		active	\N
4e1a80dc-54ed-4b83-bee8-87300ee6413f	2017-12-19 12:54:16.505959	admin	REST API: Update object foopy	active	\N
b66a5ad1-8a5b-4728-941f-efd168efed2f	2017-12-19 12:54:16.688631	admin	REST API: Update object foopy	active	\N
27fa139c-0952-465d-ac41-0029ebc16e44	2018-01-09 11:21:40.88744	admin	REST API: Delete Package: foopy	active	\N
2440217d-b741-4192-89bf-0c478d41ea9d	2018-01-09 11:21:47.915395	admin	REST API: Delete Package: foobarbaz	active	\N
83811581-08a7-489a-952c-aa3eb3d14c05	2018-02-01 19:02:42.566786	admin	REST API: Update object jupyter-notebooks	active	\N
f27b53aa-d2ec-4bf8-8344-e5d116e8eff9	2018-02-01 19:04:43.983092	admin	REST API: Update object jupyter-notebooks	active	\N
a55ac040-dcc7-4a52-89c8-7d6655c3d7a5	2018-02-01 19:05:19.817912	admin	REST API: Update object jupyter-notebooks	active	\N
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: system_info; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.system_info (id, key, value, state) FROM stdin;
\.


--
-- Data for Name: system_info_revision; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.system_info_revision (id, key, value, revision_id, continuity_id, state, expired_id, revision_timestamp, expired_timestamp, current) FROM stdin;
\.


--
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.tag (id, name, vocabulary_id) FROM stdin;
5564f2e8-9c79-4125-a2a8-077f38a246ef	event	\N
013c0ce4-51f9-4946-94e3-8e8713360f16	users	\N
cd8f07aa-76ab-4a1a-9567-ba2b7b19779b	services	\N
8c8c1220-8129-4a02-bd2f-8e9b6529c212	internet	\N
a81cb4bd-b2c8-4fc9-9682-9be570d13072	dsl	\N
0f6bdfbd-7412-4e5c-a788-c5fec06b5dd8	mobile	\N
69a1e7a9-0a51-4267-9fb3-db0642f03959	4g	\N
e2bb9482-6eb5-43c3-b14e-903c519d5e38	jupyter notebook	\N
c3ea41c3-899c-4b54-a4f4-caa50617b956	satellite	\N
5581fcb2-a2b7-41aa-aa4e-822d8837fcfe	imagery analysis	\N
9e42784b-6ee7-47e8-a69a-28b8c510212b	machine learning	\N
f650b4e3-9955-49b0-ba7b-2d302a990978	computer vision	\N
80b88538-5f29-4c5f-af29-895228232a10	CAD	\N
73142a8e-6efc-400b-9215-3316931a4e66	example	\N
675a1366-8d81-4e07-ab30-8c492c34b91d	dwg	\N
7ffd8f1d-b342-4349-aee9-a1d5aae5d2bd	visualization	\N
23f7f291-52c1-4942-aa23-008a9b23a5e1	Combustion	\N
a292a3c1-b272-4c02-bfb2-385e12ff6b66	Reactions	\N
53b4f8bd-5778-4ece-b3ac-78e8a60be011	STF50	\N
7d945dfc-6203-4ef8-8369-90704d7498ac	Video	\N
a6bbc1be-05c4-406c-8d13-b9e2018b311a	Experiment	\N
9d0587af-aad0-4352-ab8f-fc7b90f7430b	EDTA	\N
5df7cf26-78df-4382-b27d-fad8237cf180	CA	\N
aa5643c3-51ea-4233-a672-6f5a2a7b174e	2D	\N
c98a3ca2-e5c9-4173-93fb-420e0b48e9d8	3D	\N
816b2a52-8852-4298-803f-f34556cae9e0	pangaea	\N
f5568899-687f-4fc9-a613-b5b3d8253fe3	2D CAD	\N
e6d56045-9569-4230-93f4-699fb1b96f7e	aftershocks	\N
f94d461f-a9ee-4b35-91ce-5bdcfefa4a91	megathrust earthquakes	\N
5534061d-2eff-448a-8814-2d119df0e73e	subduction zones	\N
8bd7857b-cc2b-46a8-ac2e-f73dcd46d659	Gusts	\N
e9c2218b-05ce-47d2-a936-a7185dafd264	LES	\N
417bc38b-82b2-45d9-9768-b420bbb413ee	LES model	\N
18486445-68da-490e-b690-56f10770fac9	Meteorology	\N
418ade6e-6742-4a47-a6d7-d1c6546d6a4e	Wavelet Analysis	\N
30f6129d-ce3e-413d-be1e-6b92dd9ed9ee	large eddy simulation	\N
b5d28237-06f1-4ecb-9cf0-1ad354b0ff3f	document analysis	\N
1cdda301-e396-4674-8dd9-f9e7b5b25524	GIS modeling	\N
c1a56b00-65c8-4b91-8f17-69921799d700	energy transition	\N
609026eb-7b35-4c38-9af2-02506b88a95b	nature protection	\N
49a9cf01-df26-461c-819c-9772a76f62fc	renewable energy potentials	\N
370159b3-bb81-4d9b-902a-f080dc387e62	solar power	\N
\.


--
-- Data for Name: task_status; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.task_status (id, entity_id, entity_type, task_type, key, value, state, error, last_updated) FROM stdin;
4ee682be-f137-4df6-bb40-5ebd9ea7d42b	a42f0a61-e0de-4cf6-add8-4fe21c29676a	resource	datapusher	datapusher	{"job_id": "28dfd95d-bd63-41ef-87d9-8c8656bb7adb", "job_key": "d5851e36-0111-4d5e-a644-5d6bca85569d"}	complete	{}	2017-08-08 16:50:57.248282
ca174d85-770d-4f33-9e18-052ce47ed4db	3c5d05d9-773a-4f1e-a4e8-59bb4bef00b3	resource	datapusher	datapusher	{"job_id": "a6aabeef-ae87-4f09-9078-014dee28ddbe", "job_key": "fbf05172-1e69-4e29-9774-7d4c4697b144"}	complete	{}	2017-08-08 16:52:55.996468
fa10e43b-3b82-4ed8-887e-66b38f639200	0b15b724-fe12-49c9-9b17-e114c025af24	resource	datapusher	datapusher	{"job_id": "4332ca32-3d81-40eb-95ab-e0031359dc33", "job_key": "1b2df498-3248-41de-98f5-61743bb68eb5"}	complete	{}	2017-08-08 16:55:35.172834
306d446e-6b2b-443d-bb5d-62ec64960b8a	16f7cc6d-3d97-4072-836b-b5180ed980b5	resource	datapusher	datapusher	{"job_id": "60d5cfdc-51ce-48b1-8d3d-b236652a0112", "job_key": "a5c720be-e453-49db-8e86-3825677c281b"}	complete	{}	2017-08-08 16:57:49.137106
844b36f6-6432-4a45-96d6-cf33bfa55b7d	fece58b1-1505-4ef0-befb-3f0edf59335d	resource	datapusher	datapusher	{"job_id": "9bf601d4-5f2d-47be-88c4-6dccd25b7d1d", "job_key": "522b33ff-fc60-478e-b5e9-9feff1097687"}	pending	{}	2022-03-16 09:22:41.46752
e2075d4e-32cc-4e13-b17a-254e6c411366	05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43	resource	datapusher	datapusher	{"job_id": "26db580b-82ca-47be-9e09-4e4812ddf7ea", "job_key": "df6c1664-5536-4f79-8b00-9ed81c030849"}	pending	{}	2022-03-16 09:33:31.706347
749c134a-f228-42ee-9c8e-b74bf4e5a0b9	4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7	resource	datapusher	datapusher	{"job_id": "90332f76-b4d7-46b8-aeaf-a2a4e619d84e", "job_key": "33198cc7-600b-4e4a-9b2b-a7506f07575d"}	pending	{}	2022-03-16 09:47:36.917629
\.


--
-- Data for Name: term_translation; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.term_translation (term, term_translation, lang_code) FROM stdin;
\.


--
-- Data for Name: tracking_raw; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.tracking_raw (user_key, url, tracking_type, access_timestamp) FROM stdin;
\.


--
-- Data for Name: tracking_summary; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.tracking_summary (url, package_id, tracking_type, count, running_total, recent_views, tracking_date) FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public."user" (id, name, apikey, created, about, password, fullname, email, reset_key, sysadmin, activity_streams_email_notifications, state, plugin_extras, image_url) FROM stdin;
c8775ce0-12b1-43de-82fb-5f4d738dc6d5	default	2d8395a0-913b-40f3-87be-590f9f1681a4	2017-08-08 16:45:40.229019	\N	$pbkdf2-sha512$25000$GUMoZWwt5XyPcQ4BwLjXGg$.Y9cevb8ua1p7GYypkW.0d0MuGblaZTj6pvGe/9.WnWOedsnXNDTce0RFPJza1IIetLC0iW.4c.QpWy4CAgQIQ	\N	\N	\N	t	f	active	\N	\N
17755db4-395a-4b3b-ac09-e8e3484ca700	admin	65d55933-84a8-4739-b5a8-f3d718fd8cca	2017-08-08 16:45:41.109676	\N	$pbkdf2-sha512$25000$UurdW.v9H8O4957z3nuPEQ$lT/GEKzo24HZonqFZOlh9vHYPcsJpEEyRmr2Ichys1YU2j7yWbEdso/msnSaLN3bdW7HPBjEjogHiKXKL7qbDg	\N	admin@email.com	\N	t	f	active	\N	\N
\.


--
-- Data for Name: user_following_dataset; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.user_following_dataset (follower_id, object_id, datetime) FROM stdin;
\.


--
-- Data for Name: user_following_group; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.user_following_group (follower_id, object_id, datetime) FROM stdin;
\.


--
-- Data for Name: user_following_user; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.user_following_user (follower_id, object_id, datetime) FROM stdin;
\.


--
-- Data for Name: vocabulary; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.vocabulary (id, name) FROM stdin;
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: ckan
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: ckan
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: ckan
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: ckan
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: ckan
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: ckan
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: system_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ckan
--

SELECT pg_catalog.setval('public.system_info_id_seq', 1, false);


--
-- Name: activity_detail activity_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_pkey PRIMARY KEY (id);


--
-- Name: activity activity_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.activity
    ADD CONSTRAINT activity_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: api_token api_token_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.api_token
    ADD CONSTRAINT api_token_pkey PRIMARY KEY (id);


--
-- Name: dashboard dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT dashboard_pkey PRIMARY KEY (user_id);


--
-- Name: dataset_service dataset_service_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.dataset_service
    ADD CONSTRAINT dataset_service_pkey PRIMARY KEY (dataset_id, service_id);


--
-- Name: doi doi_package_id_key; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.doi
    ADD CONSTRAINT doi_package_id_key UNIQUE (package_id);


--
-- Name: doi doi_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.doi
    ADD CONSTRAINT doi_pkey PRIMARY KEY (identifier);


--
-- Name: group_extra group_extra_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.group_extra
    ADD CONSTRAINT group_extra_pkey PRIMARY KEY (id);


--
-- Name: group_extra_revision group_extra_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.group_extra_revision
    ADD CONSTRAINT group_extra_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: group group_name_key; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_name_key UNIQUE (name);


--
-- Name: group group_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);


--
-- Name: group_revision group_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.group_revision
    ADD CONSTRAINT group_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: member member_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- Name: member_revision member_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.member_revision
    ADD CONSTRAINT member_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: package_extra package_extra_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_extra
    ADD CONSTRAINT package_extra_pkey PRIMARY KEY (id);


--
-- Name: package_extra_revision package_extra_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_extra_revision
    ADD CONSTRAINT package_extra_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: package_member package_member_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_member
    ADD CONSTRAINT package_member_pkey PRIMARY KEY (package_id, user_id);


--
-- Name: package package_name_key; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_name_key UNIQUE (name);


--
-- Name: package package_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_pkey PRIMARY KEY (id);


--
-- Name: package_relationship package_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_relationship
    ADD CONSTRAINT package_relationship_pkey PRIMARY KEY (id);


--
-- Name: package_relationship_revision package_relationship_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_relationship_revision
    ADD CONSTRAINT package_relationship_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: package_revision package_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_revision
    ADD CONSTRAINT package_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: package_tag package_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_tag
    ADD CONSTRAINT package_tag_pkey PRIMARY KEY (id);


--
-- Name: package_tag_revision package_tag_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_tag_revision
    ADD CONSTRAINT package_tag_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: rating rating_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.rating
    ADD CONSTRAINT rating_pkey PRIMARY KEY (id);


--
-- Name: resource_revision resource_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.resource_revision
    ADD CONSTRAINT resource_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: resource_view resource_view_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.resource_view
    ADD CONSTRAINT resource_view_pkey PRIMARY KEY (id);


--
-- Name: revision revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.revision
    ADD CONSTRAINT revision_pkey PRIMARY KEY (id);


--
-- Name: system_info system_info_key_key; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.system_info
    ADD CONSTRAINT system_info_key_key UNIQUE (key);


--
-- Name: system_info system_info_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.system_info
    ADD CONSTRAINT system_info_pkey PRIMARY KEY (id);


--
-- Name: system_info_revision system_info_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.system_info_revision
    ADD CONSTRAINT system_info_revision_pkey PRIMARY KEY (id, revision_id);


--
-- Name: tag tag_name_vocabulary_id_key; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_name_vocabulary_id_key UNIQUE (name, vocabulary_id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: task_status task_status_entity_id_task_type_key_key; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.task_status
    ADD CONSTRAINT task_status_entity_id_task_type_key_key UNIQUE (entity_id, task_type, key);


--
-- Name: task_status task_status_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.task_status
    ADD CONSTRAINT task_status_pkey PRIMARY KEY (id);


--
-- Name: user_following_dataset user_following_dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_dataset
    ADD CONSTRAINT user_following_dataset_pkey PRIMARY KEY (follower_id, object_id);


--
-- Name: user_following_group user_following_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_group
    ADD CONSTRAINT user_following_group_pkey PRIMARY KEY (follower_id, object_id);


--
-- Name: user_following_user user_following_user_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_user
    ADD CONSTRAINT user_following_user_pkey PRIMARY KEY (follower_id, object_id);


--
-- Name: user user_name_key; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_name_key UNIQUE (name);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: vocabulary vocabulary_name_key; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.vocabulary
    ADD CONSTRAINT vocabulary_name_key UNIQUE (name);


--
-- Name: vocabulary vocabulary_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.vocabulary
    ADD CONSTRAINT vocabulary_pkey PRIMARY KEY (id);


--
-- Name: idx_activity_detail_activity_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_activity_detail_activity_id ON public.activity_detail USING btree (activity_id);


--
-- Name: idx_activity_object_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_activity_object_id ON public.activity USING btree (object_id, "timestamp");


--
-- Name: idx_activity_user_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_activity_user_id ON public.activity USING btree (user_id, "timestamp");


--
-- Name: idx_extra_grp_id_pkg_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_extra_grp_id_pkg_id ON public.member USING btree (group_id, table_id);


--
-- Name: idx_extra_id_pkg_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_extra_id_pkg_id ON public.package_extra USING btree (id, package_id);


--
-- Name: idx_extra_pkg_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_extra_pkg_id ON public.package_extra USING btree (package_id);


--
-- Name: idx_group_current; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_current ON public.group_revision USING btree (current);


--
-- Name: idx_group_extra_current; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_extra_current ON public.group_extra_revision USING btree (current);


--
-- Name: idx_group_extra_group_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_extra_group_id ON public.group_extra USING btree (group_id);


--
-- Name: idx_group_extra_period; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_extra_period ON public.group_extra_revision USING btree (revision_timestamp, expired_timestamp, id);


--
-- Name: idx_group_extra_period_group; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_extra_period_group ON public.group_extra_revision USING btree (revision_timestamp, expired_timestamp, group_id);


--
-- Name: idx_group_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_id ON public."group" USING btree (id);


--
-- Name: idx_group_name; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_name ON public."group" USING btree (name);


--
-- Name: idx_group_period; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_period ON public.group_revision USING btree (revision_timestamp, expired_timestamp, id);


--
-- Name: idx_group_pkg_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_group_pkg_id ON public.member USING btree (table_id);


--
-- Name: idx_member_continuity_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_member_continuity_id ON public.member_revision USING btree (continuity_id);


--
-- Name: idx_package_continuity_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_continuity_id ON public.package_revision USING btree (continuity_id);


--
-- Name: idx_package_creator_user_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_creator_user_id ON public.package USING btree (creator_user_id);


--
-- Name: idx_package_current; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_current ON public.package_revision USING btree (current);


--
-- Name: idx_package_extra_continuity_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_extra_continuity_id ON public.package_extra_revision USING btree (continuity_id);


--
-- Name: idx_package_extra_current; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_extra_current ON public.package_extra_revision USING btree (current);


--
-- Name: idx_package_extra_package_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_extra_package_id ON public.package_extra_revision USING btree (package_id, current);


--
-- Name: idx_package_extra_period; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_extra_period ON public.package_extra_revision USING btree (revision_timestamp, expired_timestamp, id);


--
-- Name: idx_package_extra_period_package; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_extra_period_package ON public.package_extra_revision USING btree (revision_timestamp, expired_timestamp, package_id);


--
-- Name: idx_package_extra_rev_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_extra_rev_id ON public.package_extra_revision USING btree (revision_id);


--
-- Name: idx_package_group_current; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_group_current ON public.member_revision USING btree (current);


--
-- Name: idx_package_group_group_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_group_group_id ON public.member USING btree (group_id);


--
-- Name: idx_package_group_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_group_id ON public.member USING btree (id);


--
-- Name: idx_package_group_period_package_group; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_group_period_package_group ON public.member_revision USING btree (revision_timestamp, expired_timestamp, table_id, group_id);


--
-- Name: idx_package_group_pkg_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_group_pkg_id ON public.member USING btree (table_id);


--
-- Name: idx_package_group_pkg_id_group_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_group_pkg_id_group_id ON public.member USING btree (group_id, table_id);


--
-- Name: idx_package_period; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_period ON public.package_revision USING btree (revision_timestamp, expired_timestamp, id);


--
-- Name: idx_package_relationship_current; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_relationship_current ON public.package_relationship_revision USING btree (current);


--
-- Name: idx_package_resource_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_resource_id ON public.resource USING btree (id);


--
-- Name: idx_package_resource_package_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_resource_package_id ON public.resource USING btree (package_id);


--
-- Name: idx_package_resource_rev_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_resource_rev_id ON public.resource_revision USING btree (revision_id);


--
-- Name: idx_package_resource_url; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_resource_url ON public.resource USING btree (url);


--
-- Name: idx_package_tag_continuity_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_continuity_id ON public.package_tag_revision USING btree (continuity_id);


--
-- Name: idx_package_tag_current; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_current ON public.package_tag_revision USING btree (current);


--
-- Name: idx_package_tag_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_id ON public.package_tag USING btree (id);


--
-- Name: idx_package_tag_pkg_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_pkg_id ON public.package_tag USING btree (package_id);


--
-- Name: idx_package_tag_pkg_id_tag_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_pkg_id_tag_id ON public.package_tag USING btree (tag_id, package_id);


--
-- Name: idx_package_tag_revision_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_revision_id ON public.package_tag_revision USING btree (id);


--
-- Name: idx_package_tag_revision_pkg_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_revision_pkg_id ON public.package_tag_revision USING btree (package_id);


--
-- Name: idx_package_tag_revision_pkg_id_tag_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_revision_pkg_id_tag_id ON public.package_tag_revision USING btree (tag_id, package_id);


--
-- Name: idx_package_tag_revision_rev_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_revision_rev_id ON public.package_tag_revision USING btree (revision_id);


--
-- Name: idx_package_tag_revision_tag_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_revision_tag_id ON public.package_tag_revision USING btree (tag_id);


--
-- Name: idx_package_tag_tag_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_package_tag_tag_id ON public.package_tag USING btree (tag_id);


--
-- Name: idx_period_package_relationship; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_period_package_relationship ON public.package_relationship_revision USING btree (revision_timestamp, expired_timestamp, object_package_id, subject_package_id);


--
-- Name: idx_period_package_tag; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_period_package_tag ON public.package_tag_revision USING btree (revision_timestamp, expired_timestamp, package_id, tag_id);


--
-- Name: idx_pkg_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_id ON public.package USING btree (id);


--
-- Name: idx_pkg_lname; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_lname ON public.package USING btree (lower((name)::text));


--
-- Name: idx_pkg_name; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_name ON public.package USING btree (name);


--
-- Name: idx_pkg_revision_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_revision_id ON public.package_revision USING btree (id);


--
-- Name: idx_pkg_revision_name; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_revision_name ON public.package_revision USING btree (name);


--
-- Name: idx_pkg_revision_rev_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_revision_rev_id ON public.package_revision USING btree (revision_id);


--
-- Name: idx_pkg_sid; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_sid ON public.package USING btree (id, state);


--
-- Name: idx_pkg_slname; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_slname ON public.package USING btree (lower((name)::text), state);


--
-- Name: idx_pkg_sname; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_sname ON public.package USING btree (name, state);


--
-- Name: idx_pkg_stitle; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_stitle ON public.package USING btree (title, state);


--
-- Name: idx_pkg_suname; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_suname ON public.package USING btree (upper((name)::text), state);


--
-- Name: idx_pkg_title; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_title ON public.package USING btree (title);


--
-- Name: idx_pkg_uname; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_pkg_uname ON public.package USING btree (upper((name)::text));


--
-- Name: idx_rating_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_rating_id ON public.rating USING btree (id);


--
-- Name: idx_rating_package_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_rating_package_id ON public.rating USING btree (package_id);


--
-- Name: idx_rating_user_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_rating_user_id ON public.rating USING btree (user_id);


--
-- Name: idx_resource_continuity_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_resource_continuity_id ON public.resource_revision USING btree (continuity_id);


--
-- Name: idx_resource_current; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_resource_current ON public.resource_revision USING btree (current);


--
-- Name: idx_resource_period; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_resource_period ON public.resource_revision USING btree (revision_timestamp, expired_timestamp, id);


--
-- Name: idx_rev_state; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_rev_state ON public.revision USING btree (state);


--
-- Name: idx_revision_author; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_revision_author ON public.revision USING btree (author);


--
-- Name: idx_tag_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_tag_id ON public.tag USING btree (id);


--
-- Name: idx_tag_name; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_tag_name ON public.tag USING btree (name);


--
-- Name: idx_user_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_user_id ON public."user" USING btree (id);


--
-- Name: idx_user_name; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_user_name ON public."user" USING btree (name);


--
-- Name: idx_user_name_index; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX idx_user_name_index ON public."user" USING btree ((
CASE
    WHEN ((fullname IS NULL) OR (fullname = ''::text)) THEN name
    ELSE fullname
END));


--
-- Name: term; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX term ON public.term_translation USING btree (term);


--
-- Name: term_lang; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX term_lang ON public.term_translation USING btree (term, lang_code);


--
-- Name: tracking_raw_access_timestamp; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX tracking_raw_access_timestamp ON public.tracking_raw USING btree (access_timestamp);


--
-- Name: tracking_raw_url; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX tracking_raw_url ON public.tracking_raw USING btree (url);


--
-- Name: tracking_raw_user_key; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX tracking_raw_user_key ON public.tracking_raw USING btree (user_key);


--
-- Name: tracking_summary_date; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX tracking_summary_date ON public.tracking_summary USING btree (tracking_date);


--
-- Name: tracking_summary_package_id; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX tracking_summary_package_id ON public.tracking_summary USING btree (package_id);


--
-- Name: tracking_summary_url; Type: INDEX; Schema: public; Owner: ckan
--

CREATE INDEX tracking_summary_url ON public.tracking_summary USING btree (url);


--
-- Name: activity_detail activity_detail_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(id);


--
-- Name: api_token api_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.api_token
    ADD CONSTRAINT api_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: dashboard dashboard_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT dashboard_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dataset_service dataset_service_dataset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.dataset_service
    ADD CONSTRAINT dataset_service_dataset_id_fkey FOREIGN KEY (dataset_id) REFERENCES public.package(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dataset_service dataset_service_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.dataset_service
    ADD CONSTRAINT dataset_service_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.package(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: doi doi_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.doi
    ADD CONSTRAINT doi_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_extra group_extra_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.group_extra
    ADD CONSTRAINT group_extra_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: group_extra_revision group_extra_revision_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.group_extra_revision
    ADD CONSTRAINT group_extra_revision_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: group_extra_revision group_extra_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.group_extra_revision
    ADD CONSTRAINT group_extra_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: group_revision group_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.group_revision
    ADD CONSTRAINT group_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: member member_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: member_revision member_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.member_revision
    ADD CONSTRAINT member_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: package_extra package_extra_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_extra
    ADD CONSTRAINT package_extra_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id);


--
-- Name: package_extra_revision package_extra_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_extra_revision
    ADD CONSTRAINT package_extra_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: package_member package_member_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_member
    ADD CONSTRAINT package_member_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id);


--
-- Name: package_member package_member_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_member
    ADD CONSTRAINT package_member_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: package_relationship package_relationship_object_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_relationship
    ADD CONSTRAINT package_relationship_object_package_id_fkey FOREIGN KEY (object_package_id) REFERENCES public.package(id);


--
-- Name: package_relationship_revision package_relationship_revision_continuity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_relationship_revision
    ADD CONSTRAINT package_relationship_revision_continuity_id_fkey FOREIGN KEY (continuity_id) REFERENCES public.package_relationship(id);


--
-- Name: package_relationship_revision package_relationship_revision_object_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_relationship_revision
    ADD CONSTRAINT package_relationship_revision_object_package_id_fkey FOREIGN KEY (object_package_id) REFERENCES public.package(id);


--
-- Name: package_relationship_revision package_relationship_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_relationship_revision
    ADD CONSTRAINT package_relationship_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: package_relationship_revision package_relationship_revision_subject_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_relationship_revision
    ADD CONSTRAINT package_relationship_revision_subject_package_id_fkey FOREIGN KEY (subject_package_id) REFERENCES public.package(id);


--
-- Name: package_relationship package_relationship_subject_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_relationship
    ADD CONSTRAINT package_relationship_subject_package_id_fkey FOREIGN KEY (subject_package_id) REFERENCES public.package(id);


--
-- Name: package_revision package_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_revision
    ADD CONSTRAINT package_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: package_tag_revision package_tag_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_tag_revision
    ADD CONSTRAINT package_tag_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: package_tag_revision package_tag_revision_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_tag_revision
    ADD CONSTRAINT package_tag_revision_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id);


--
-- Name: package_tag package_tag_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.package_tag
    ADD CONSTRAINT package_tag_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id);


--
-- Name: rating rating_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.rating
    ADD CONSTRAINT rating_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id);


--
-- Name: rating rating_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.rating
    ADD CONSTRAINT rating_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: resource_revision resource_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.resource_revision
    ADD CONSTRAINT resource_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: system_info_revision system_info_revision_continuity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.system_info_revision
    ADD CONSTRAINT system_info_revision_continuity_id_fkey FOREIGN KEY (continuity_id) REFERENCES public.system_info(id);


--
-- Name: system_info_revision system_info_revision_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.system_info_revision
    ADD CONSTRAINT system_info_revision_revision_id_fkey FOREIGN KEY (revision_id) REFERENCES public.revision(id);


--
-- Name: tag tag_vocabulary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_vocabulary_id_fkey FOREIGN KEY (vocabulary_id) REFERENCES public.vocabulary(id);


--
-- Name: user_following_dataset user_following_dataset_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_dataset
    ADD CONSTRAINT user_following_dataset_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_dataset user_following_dataset_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_dataset
    ADD CONSTRAINT user_following_dataset_object_id_fkey FOREIGN KEY (object_id) REFERENCES public.package(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_group user_following_group_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_group
    ADD CONSTRAINT user_following_group_group_id_fkey FOREIGN KEY (object_id) REFERENCES public."group"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_group user_following_group_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_group
    ADD CONSTRAINT user_following_group_user_id_fkey FOREIGN KEY (follower_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_user user_following_user_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_user
    ADD CONSTRAINT user_following_user_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_user user_following_user_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan
--

ALTER TABLE ONLY public.user_following_user
    ADD CONSTRAINT user_following_user_object_id_fkey FOREIGN KEY (object_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

