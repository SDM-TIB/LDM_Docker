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


--
-- Data for Name: activity_detail; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.activity_detail (id, activity_id, object_id, object_type, activity_type, data) FROM stdin;
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
17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:06:30.03628	2017-08-08 16:45:41.143096
\.


--
-- Data for Name: dataset_service; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public.dataset_service (dataset_id, service_id) FROM stdin;
\.


--
-- Data for Name: doi; Type: TABLE DATA; Schema: public; Owner: ckan
--



--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: ckan
--

COPY public."group" (id, name, title, description, created, state, type, approval_status, image_url, is_organization) FROM stdin;
724ae83b-ae78-433c-8586-69e7202931c4	china-unicom	China UNICOM	China United Network Communications Group Co., Ltd. (Chinese: 中国联合网络通信集团有限公司) or China Unicom (Chinese: 中国联通) is a Chinese state-owned telecommunications operator in the People's Republic of China. China Unicom is the world's fourth-largest mobile service provider by subscriber base.	2017-08-08 16:46:26.164305	deleted	organization	approved	https://upload.wikimedia.org/wikipedia/en/thumb/f/fa/China_Unicom.svg/252px-China_Unicom.svg.png	t
0c5362f5-b99e-41db-8256-3d0d7549bf4d	tib	TIB	The German National Library of Science and Technology, abbreviated TIB, is the national library of the Federal Republic of Germany for all fields of engineering, technology, and the natural sciences.	2017-11-23 17:30:37.757128	active	organization	approved	https://www.tib.eu/typo3conf/ext/tib_tmpl_bootstrap/Resources/Public/images/TIB_Logo_en.png	t
6284da8e-908c-4666-81c6-64a0fedf10e2	institut-fur-geologie	Institut für Geologie	Leibniz Universität Hannover\r\nCallinstr. 30\r\n30167 Hannover\r\n\r\nhttp://www.geologie.uni-hannover.de/\r\n	2022-03-16 07:42:06.633095	active	organization	approved	https://www.geologie.uni-hannover.de/typo3temp/_processed_/e/4/csm_cf132247a6b40f73102849c767bde47979deccba-fp-3-1-0-0_e2d52b6bf9.jpg	t
2d2ca2a7-26f5-497b-b5a4-a559a28f3042	ag-palm	AG PALM		2022-03-16 07:44:14.760944	active	organization	approved		t
a6ac49d3-2eff-4f4d-bb17-709595cf72d7	institut-fur-umweltplanung	Institut für Umweltplanung 	Institute of Environmental Planning\r\nHerrenhäuser Str. 2, 30419 Hannover	2022-03-16 07:44:15.535151	active	organization	approved	https://data.uni-hannover.de/uploads/group/2021-08-05-071444.382087IUPbildmarke.png	t
abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	radar	RADAR	RADAR (Research Data Repository) is a cross-disciplinary repository for archiving and publishing research data from completed scientific studies and projects. The focus is on research data from subjects that do not yet have their own discipline-specific infrastructures for research data management. 	2022-12-27 10:03:29.771612	active	organization	approved	radar-logo.svg	t
d9a007f6-bde0-420d-8a03-3c652ed698ab	pangea	PANGEA (Agriculture)	PANGEA (Data Publisher for Earth & Environmental Science): The information system PANGAEA is operated as an Open Access library aimed at archiving, publishing and distributing georeferenced data from earth system research. PANGAEA guarantees long-term availability (greater than 10 years) of its content. PANGAEA is open to any project, institution, or individual scientist to use or to archive and publish data. PANGAEA focuses on georeferenced observational data, experimental data, and models/simulations. Citability, comprehensive metadata descriptions, interoperability of data and metadata, a high degree of structural and semantic harmonization of the data inventory as well as the commitment of the hosting institutions ensures FAIRness of archived data.	2022-12-27 10:03:44.38415	active	organization	approved	pangea-logo.png	t
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
6f2e5027-d0b3-4ddb-bfa4-dd19833a53a1	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	17755db4-395a-4b3b-ac09-e8e3484ca700	active	user	admin
9417954c-6581-4af0-93b0-fc95c45ab01f	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	3b91f44d-ee1c-4ccd-a880-e7260adc68d2	active	package	organization
dcfc436d-a887-460d-b617-8bbdc729180b	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42	active	package	organization
b2f61430-5455-4d3c-9937-e723c1188687	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	01155add-e61e-4d6b-89a2-e59aa03d4ce9	active	package	organization
0e5c8846-1d54-4870-b4fd-af883e1fb12f	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0	active	package	organization
144eb901-e37a-4fc6-a1c5-053cf1ce57a9	d9a007f6-bde0-420d-8a03-3c652ed698ab	17755db4-395a-4b3b-ac09-e8e3484ca700	active	user	admin
0b957298-1292-4d65-a4a7-0e6c6a373968	d9a007f6-bde0-420d-8a03-3c652ed698ab	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f	active	package	organization
39e8785a-7d2c-4f7e-8a72-0dbb59074bd8	d9a007f6-bde0-420d-8a03-3c652ed698ab	08643811-14ae-4177-991d-a0cf6acb4971	active	package	organization
f4a95e2c-2666-4912-8297-18e0ee063329	d9a007f6-bde0-420d-8a03-3c652ed698ab	58d7e04e-9f14-48e3-bc39-66eb40541e51	active	package	organization
a00a5fcb-95e1-4e6e-b2bd-3b097e4fca67	d9a007f6-bde0-420d-8a03-3c652ed698ab	ad0e3518-619f-4cda-9d87-a055bca68d4c	active	package	organization
12aab445-1bbb-432c-8d73-a5856202f8f2	0c5362f5-b99e-41db-8256-3d0d7549bf4d	69008361-5ce3-4662-aab6-2132bebd818c	active	package	organization
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
1abefb2e-6a83-4004-b7db-74c34b545d2e	jupyter-notebooks	Jupyter notebooks		https://unidata.github.io/online-python-training/introduction.html	A collection of Jupyter Notebooks for science related projects\r\n\r\n1. LIGO Gravitational Wave Data\r\n2. Satellite Imagery Analysis\r\n3. 12 Steps to Navier-Stokes\r\n4. Computer Vision\r\n5. Machine Learning	Lorena A. Barba				deleted	cc-by	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2021-03-03 10:11:48.942065	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-12-01 12:51:12.218503
ca8c20ad-77b6-46d7-a940-1f6a351d7d0b	example-cad-2	Pangaea CAD files			Example usage of CAD using Ckan View with information provided by PANGAEA.					deleted	cc-by	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2021-03-03 10:14:21.513141	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:36:15.887852
86b5446b-092a-4467-870c-b61b055d763f	example-documents-visualizations	Example Documents Visualizations			This is an example Dataset showing visualizations for documents in different formats. 	John Doe				active	notspecified	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-06-13 07:04:36.920112	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 08:31:24.461479
54920aae-f322-4fca-bd09-cd091946632c	example-video-2	Example Video Visualizations			Video about auto combustion reactions of STF50 with EDTA+CA: variying phi.\r\nVideo about boundary value problem of a push rod. The video was published by Leibniz University Hannover.\r\nVideo about boundary value problem of a spring. The video was published by Leibniz University Hannover.	John Doe				active	cc-by	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-06-13 07:14:39.42121	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-24 13:42:19.407543
476cdf71-1048-4a6f-a28a-58fff547dae5	example-cad	Example CAD Visualizations		https://knowledge.autodesk.com/support/autocad/downloads/caas/downloads/content/autocad-sample-files.html	Example usage of CAD visualization in 2D and 3D using CKAN Views.	Autodesk				active	cc-by	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-06-13 06:54:09.827455	17755db4-395a-4b3b-ac09-e8e3484ca700	2017-11-23 17:37:00.3629
ed56c026-3d32-41d5-9d11-2aa655cb8052	data-service-example-jupyternotebook	Data-Service example (JupyterNotebook)			This is a Data-Service example performing a data exploration process using a jupyter notebook running live code over the CSV file inside the same dataset. 	John Doe				active	notspecified	service	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-06-13 07:05:36.730841	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 09:43:34.017574
d5d29173-addc-4e4d-af7b-59e3b147c817	example-data-formats-visualizations	Example Data Formats Visualizations			This is an example Dataset showing visualizations for data in different formats.	John Doe				active	notspecified	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-06-13 06:58:55.023676	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-03-16 09:17:57.26675
3b91f44d-ee1c-4ccd-a880-e7260adc68d2	rdr-doi-10-22000-152	Data and codes for publication tang et al 2019	\N	https://doi.org/10.22000/152		Schughart, Klaus		\N	\N	active	CC BY 4.0 Attribution	vdataset	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	f	2022-12-27 10:03:29.844287	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:03:29.84428
b9d4d1b3-7269-43cf-a6e4-a9013c26ae42	rdr-doi-10-22000-155	Turning observed founder alleles into expected relationships - example programs	\N	https://doi.org/10.22000/155	Method: Example programs are presented that can be used to compute expected relationships in a two-way cross where the founders have been genotyped. Theory is described in very detail in the article of Meng et al. "Turning Observed Founder Alleles into Expected Relationships in an Intercross Population", published in G3: Genes, Genomes, Genetics (2019 vol. 9 no. 3 889-899) and accessible under  https://doi.org/10.1534/g3.118.200752 . Together with the programs example data are provided. A further detailed description is given in the readme-file that is included.	Meng, Jilun		\N	\N	active	CC BY 4.0 Attribution	vdataset	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	f	2022-12-27 10:03:30.309317	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:03:30.309311
1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0	rdr-doi-10-22000-237	Md-simulation-of-twinned-nanowires	\N	https://doi.org/10.22000/237	Abstract: Molecular Dynamics Simulation of tensile tests on twinned and non-twinned <110>-oriented Au nano wires	 Bitzek, Erik		\N	\N	active	CC BY 4.0 Attribution	vdataset	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	f	2022-12-27 10:03:30.875261	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:03:30.875255
01155add-e61e-4d6b-89a2-e59aa03d4ce9	rdr-doi-10-22000-156	Supplemental data to publication "selection signatures in four german warmblood horse breeds: tracing breeding history in the modern sport horse" (plos one)	\N	https://doi.org/10.22000/156	Abstract: The study of selection signatures helps to find genomic regions that have been under selective pressure and might host genes or variants that modulate important phenotypes. Such knowledge improves our understanding of how breeding programmes have shaped the genomes of livestock. In this study, 942 stallions were included from four, exemplarily chosen, German warmblood breeds with divergent historical and recent selection focus and different crossbreeding policies: Trakehner (N=44), Holsteiner (N=358), Hanoverian (N=319) and Oldenburger (N=221).  Blood samples were collected during the health exams of the stallion preselections before licensing and were genotyped with the Illumina EquineSNP50 BeadChip. Autosomal markers were used for a multi-method search for signals of positive selection. Analyses within and across breeds were conducted by using the integrated Haplotype Score (iHS), cross-population Extended Haplotype Homozygosity (xpEHH) and Runs of Homozygosity (ROH). Oldenburger and Hanoverian showed very similar iHS signatures, but breed specificities were detected on multiple chromosomes with the xpEHH. 	Thaller, Georg		\N	\N	active	CC BY 4.0 Attribution	vdataset	abfcc7b9-cba5-4a5a-ad3c-019c2f5a4d69	f	2022-12-27 10:03:30.605426	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:03:30.60542
08643811-14ae-4177-991d-a0cf6acb4971	png-doi-10-1594-pangaea-786598	Topsoil properties and abundance of Acari and Collembola species in northern Victoria Land, Antarctica	\N	https://doi.org/10.1594/PANGAEA.786598	Soil fauna in the extreme conditions of Antarctica consists of a few microinvertebrate species patchily distributed at different spatial scales. Populations of the prostigmatic mite Stereotydeus belli and the collembolan Gressittacantha terranova from northern Victoria Land (Antarctica) were used as models to study the effect of soil properties on microarthropod distributions. In agreement with the general assumption that the development and distribution of life in these ecosystems is mainly controlled by abiotic factors, we found that the probability of occurrence of S. belli depends on soil moisture and texture and on the sampling period (which affects the general availability of water); surprisingly, none of the analysed variables were significantly related to the G. terranova distribution. Based on our results and literature data, we propose a theoretical model that introduces biotic interactions among the major factors driving the local distribution of collembolans in Antarctic terrestrial ecosystems.	Caruso Tancredi		\N	\N	active	CC-BY-3.0	vdataset	d9a007f6-bde0-420d-8a03-3c652ed698ab	f	2022-12-27 10:03:44.690359	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:03:44.690354
ad0e3518-619f-4cda-9d87-a055bca68d4c	png-doi-10-1594-pangaea-787168	Pedogeomorphology, geochronology and paleobotany of soil profiles obtained in the Nagqu area, central Tibet	\N	https://doi.org/10.1594/PANGAEA.787168	Vast areas on the Tibetan Plateau are covered by alpine sedge mats consisting of different species of the genus Kobresia. These mats have topsoil horizons rich in rhizogenic organic matter which creates turfs. As the turfs have recently been affected by a complex destruction process, knowledge concerning their soil properties, age and pedogenesis are needed. In the core area of Kobresia pygmaea mats around Nagqu (central Tibetan Plateau, ca. 4500 m a.s.l.), four profiles were subjected to pedological, paleobotanical and geochronological analyses concentrating on soil properties, phytogenic composition and dating of the turf. The turf of both dry K. pygmaea sites and wet Kobresia schoenoides sites is characterised by an enrichment of living (dominant portion) and dead root biomass. In terms of humus forms, K. pygmaea turfs can be classified as Rhizomulls mainly developed from Cambisols. Wet-site K. schoenoides turfs, however, can be classified as Rhizo-Hydromors developed from Histic Gleysols. At the dry sites studied, the turnover of soil organic matter is controlled by a non-permafrost cold thermal regime. Below-ground remains from sedges are the most frequent macroremains in the turf. Only a few pollen types of vascular plants occur, predominantly originating from sedges and grasses. Large amounts of microscopic charcoal (indeterminate) are present. Macroremains and pollen extracted from the turfs predominantly have negative AMS 14C ages, giving evidence of a modern turf genesis. Bulk-soil datings from the lowermost part of the turfs have a Late Holocene age comprising the last ca. 2000 years. The development of K. pygmaea turfs was most probably caused by an anthropo(zoo)-genetically initiated growth of sedge mats replacing former grass-dominated vegetation ('steppe'). Thus the turfs result from the transformation of pre-existing topsoils comprising a secondary penetration and accumulation of roots. K. schoenoides turfs, however, are characterised by a combined process of peat formation and penetration/accumulation of roots probably representing a (quasi) natural wetland vegetation.	Kaiser Knut		\N	\N	active	CC-BY-3.0	vdataset	d9a007f6-bde0-420d-8a03-3c652ed698ab	f	2022-12-27 10:03:45.188076	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:03:45.188071
69008361-5ce3-4662-aab6-2132bebd818c	example-ldm-api-implementation	Example LDM-API implementation			This dataset documents LDM’s API (CKAN), for developers who want to write code that interacts with LDM sites and their data.	John Doe				active	notspecified	dataset	0c5362f5-b99e-41db-8256-3d0d7549bf4d	f	2022-12-27 11:22:23.443555	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:11:21.562241
13b1f7b4-fc9b-4060-a814-5a8a2e7d333f	png-doi-10-1594-pangaea-786524	Floral and faunal characteristics and content of photosynthetic pigment in soils of northern Victoria Land, Antarctica	\N	https://doi.org/10.1594/PANGAEA.786524	Although soil algae are among the main primary producers in most terrestrial ecosystems of continental Antarctica, there are very few quantitative studies on their relative proportion in the main algal groups and on how their distribution is affected by biotic and abiotic factors. Such knowledge is essential for understanding the functioning of Antarctic terrestrial ecosystems. We therefore analyzed biological soil crusts from northern Victoria Land to determine their pH, electrical conductivity (EC), water content (W), total and organic C (TC and TOC) and total N (TN) contents, and the presence and abundance of photosynthetic pigments. In particular, the latter were tested as proxies for biomass and coarse-resolution community structure. Soil samples were collected from five sites with known soil algal communities and the distribution of pigments was shown to reflect differences in the relative proportions of Chlorophyta, Cyanophyta and Bacillariophyta in these sites. Multivariate and univariate models strongly indicated that almost all soil variables (EC, W, TOC and TN) were important environmental correlates of pigment distribution. However, a significant amount of variation is independent of these soil variables and may be ascribed to local variability such as changes in microclimate at varying spatial and temporal scales. There are at least five possible sources of local variation: pigment preservation, temporal variations in water availability, temporal and spatial interactions among environmental and biological components, the local-scale patchiness of organism distribution, and biotic interactions.	Colacevich Andrea		\N	\N	active	CC-BY-3.0	vdataset	d9a007f6-bde0-420d-8a03-3c652ed698ab	f	2022-12-27 10:03:44.455446	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:03:44.45544
58d7e04e-9f14-48e3-bc39-66eb40541e51	png-doi-10-1594-pangaea-787132	Granulometry, calcium carbonate content and radiocarbon ages of soil profiles obtained in Quinghai Province, northeast Tibet	\N	https://doi.org/10.1594/PANGAEA.787132	Colluvial deposits consisting of silts and loams were detected in several climatologically different areas of NE Tibet (3200-3700 m a.s.l.). Layering, distinct organic content and low content of coarse matter as well as location in the relief revealed an origin from low-energy slope erosion (hillwash). Underlying and intercalated paleosols were classified as Chernozems, Phaeozems, Regosols and Fluvisols. Fifteen radiocarbon datings predominant on charcoal from both colluvial layers and paleosols yielded ages between 8988 ± 66 and 3512 ± 56 uncal BP. Natural or anthropogenic factors could have been the triggers of the erosional processes derived. It remains unclear which reason was mainly responsible, due to controversial paleoclimatic and geomorphic records as well as insufficient archaeological knowledge from this region. Determinations of charcoal and fossil wood revealed the Holocene occurrence of tree species (spruce, juniper) for areas which nowadays have no trees or only few forest islands. Thus large areas of NE Tibet which are at present steppes and alpine pastures were forested in the past.	Kaiser Knut		\N	\N	active	CC-BY-3.0	vdataset	d9a007f6-bde0-420d-8a03-3c652ed698ab	f	2022-12-27 10:03:44.914675	17755db4-395a-4b3b-ac09-e8e3484ca700	2022-12-27 10:03:44.91467
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
7289e6eb-2a88-4d58-aeac-c86ed6e34e51	publication_year	2019	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
0e1ab871-a50a-43df-a06b-19752b0d8c63	publishers	[{"publisher": "Klaus Schughart"}]	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
6dbee2d9-70ff-46c6-a5d6-da82217e8390	source_metadata_created	2019	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
689d92d0-9be0-4296-a0e6-699d22af3fc3	repository_name	RADAR (Research Data Repository)	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
96978602-5765-4219-abaf-a8b818df134c	doi_status	True	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
9219db37-6904-43c0-8027-f2e25cd40666	resource_type	Dataset - Data and R codes	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
9c7f8f18-5879-4195-847e-6f30fc8eea1f	source_metadata_modified		active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
7ad58f63-d00f-416b-b0e5-64cdcd9fd0f8	subject_areas	[{"subject_area_additional": "", "subject_area_name": "Medicine"}]	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
e6d7e8d4-1ed2-4611-bf0a-18105ed2f6ef	doi	10.22000/152	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
73a5a9fd-16fd-42cb-8b54-429c653d02ec	doi_publisher		active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
9b8fc874-a97b-48ba-afbb-187e4d502937	orcid	0000-0002-6824-7523	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
4e91f8d5-5519-4bfe-a161-b121fda13f4f	production_year	2019	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
a5f05404-bd22-4f88-951d-c9d912fdc80c	doi_date_published	2019	active	3b91f44d-ee1c-4ccd-a880-e7260adc68d2
27e87df7-6378-401a-8eac-89542165106f	publication_year	2019	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
a60987fb-c897-4eea-a974-db4a995c979e	publishers	[{"publisher": "Leibniz Institute for Farm Animal Biology (FBN)"}]	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
4bf319de-115d-4934-95d6-81c749e96c8f	source_metadata_created	2019	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
916f6a97-34a9-47f8-8817-9f947c59a85f	repository_name	RADAR (Research Data Repository)	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
17610e42-19e0-4f62-a44a-782d877b63a4	extra_authors	[{"extra_author": "Mayer, Manfred", "orcid": "0000-0002-6382-2533"}, {"extra_author": "Reinsch, Norbert", "orcid": "0000-0001-7435-4088"}]	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
3249b442-6f6e-4359-98e3-f7fc2b651f9c	doi_status	True	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
228f3457-5a1a-427a-8a20-cee1d32ed504	resource_type	Software - example program, input and output examples	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
87643401-2cc0-41ce-9a22-513f0d7c5beb	source_metadata_modified		active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
51e8892c-544d-4908-bda0-68051dbb3c0b	subject_areas	[{"subject_area_additional": "", "subject_area_name": "Agriculture"}, {"subject_area_additional": "", "subject_area_name": "Life Science"}]	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
310c9cf2-fd83-48dc-89dd-e6db23a4bde9	doi	10.22000/155	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
52a24c83-2c1a-4889-928d-2b1c6247a3c9	doi_publisher		active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
a1c6e55d-2922-4de7-bfab-f21fbd19931d	orcid	0000-0003-0665-7655	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
1f8df0a1-1774-4614-b2fe-38000f3683bc	production_year	2019	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
6f0a0948-a26a-412f-aedf-5b3f09fdb221	doi_date_published	2019	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42
0045704d-76fe-4381-8b21-9397dcb0a41c	publication_year	2019	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
13d0da2f-04c3-4177-b12f-3e38822d5515	publishers	[{"publisher": "Leibniz Institute for Farm Animal Biology (FBN), Wilhelm-Stahl-Allee 2, 18196 Dummerstorf, Germany"}]	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
7e567ef5-9a6f-4f44-ba40-91f69e776abb	source_metadata_created	2019	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
7ec11e4f-a25d-472b-afcf-61379fc4a114	repository_name	RADAR (Research Data Repository)	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
daa15fa6-a53a-41fc-b052-7e317ee41e32	extra_authors	[{"extra_author": "Kuehn, Christa", "orcid": "0000-0002-0216-424X"}, {"extra_author": "Nolte, Wietje", "orcid": "0000-0001-7987-9780"}]	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
b50dc8d9-f873-4396-a8f6-9dc81f7c1e7a	doi_status	True	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
a6f9600a-f691-4352-9330-1855e2dd26cd	source_metadata_modified		active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
09115505-23b3-411c-a262-e853bfc72914	subject_areas	[{"subject_area_additional": "", "subject_area_name": "Agriculture"}, {"subject_area_additional": "Animal Genetics", "subject_area_name": "Other"}]	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
e330f8e4-55f1-4aa7-b867-ddf206c60093	doi	10.22000/156	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
02d09b35-4b5f-4075-860e-71d1c4a0e435	doi_publisher		active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
757ff9d4-829f-4287-839b-fe622322ef7c	orcid	0000-0002-6782-2039	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
c2b5774d-f260-4f4b-8998-baae7da04827	production_year	2016-2018	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
0597fcf6-0d79-439d-9fdb-4effea64b823	doi_date_published	2019	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9
f4364b06-6b0a-428f-ba96-387e590414cb	publication_year	2019	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
3fe1268d-ed0a-4bae-8af1-8a05fc8ec4f4	publishers	[{"publisher": "Bitzek, Erik"}]	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
5135d98f-3261-42e3-8b5a-cd2be40db981	source_metadata_created	2019	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
e96580cd-ea4a-4bfa-a4a6-30189aa29118	repository_name	RADAR (Research Data Repository)	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
b15939b1-6ede-4c12-8768-03d3fd9ab802	extra_authors	[{"extra_author": "Xie, Zhuocheng ", "orcid": ""}]	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
e3f42326-8ece-45d6-8fe0-9468df9d18d2	doi_status	True	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
060d3f97-6bbd-4fd6-9b0f-f4ccb2bebc5b	source_metadata_modified		active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
c77177bf-b298-43fd-b2ff-ee073fcd30ca	subject_areas	[{"subject_area_additional": "", "subject_area_name": "Materials Science"}]	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
c8ce97e7-4f9b-44f0-870f-c454ee9f02fd	doi	10.22000/237	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
ea257cb4-5bfd-40bb-93e9-26044e0cf8c4	doi_publisher		active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
00931a2c-a758-42ca-9cb8-284cbf81b607	orcid	0000-0001-7430-3694	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
65e68b28-6a58-4fbf-8cb3-46cc30ec2e83	production_year	2018	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
301d9c74-6ed0-4c1f-8885-0ff9c54fcf3f	doi_date_published	2019	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0
cff1b628-6ba4-4be7-b776-1f31000c3af7	publication_year	2009	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
0a34e80e-4bd8-45a9-8d5e-c161c06f38cf	source_metadata_created	2009	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
d52db722-3556-49a6-b83d-e19f9bad3285	repository_name	PANGEA (Data Publisher for Earth & Environmental Science)	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
f88bb9a4-852c-4e13-ab2b-efc1ec08d26a	extra_authors	[{"extra_author": "Caruso Tancredi", "orcid": "0000-0002-3607-9609"}, {"extra_author": "Borghini Francesca", "orcid": ""}, {"extra_author": "Bargagli Roberto", "orcid": ""}]	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
d2f5c2d9-8019-4006-9a19-dbed0695c680	doi_status	True	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
ceab66e9-31b6-41bf-a061-477a06ba8600	resource_type	application/zip - filename: Colacevich_2009	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
0fc8a365-a843-4992-9734-92b6ace30a5e	source_metadata_modified		active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
7f959a7e-59e4-412e-988e-09cc330caa8f	subject_areas	[{"subject_area_additional": "", "subject_area_name": "Agriculture"}, {"subject_area_additional": "", "subject_area_name": "Lithosphere"}]	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
1f032084-532e-4f89-a736-445068c71268	doi	10.1594/PANGAEA.786524	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
b2eb3e28-7d36-4239-8f2c-aba306eab7f3	doi_publisher		active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
fff70fc6-032c-4533-8fa3-d2da19e4ba50	orcid		active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
1a489c7b-b005-4477-96a9-53c823e54c24	doi_date_published	2009	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f
da75cd6f-0a42-49f4-93b7-fc939f6fd446	publication_year	2007	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
4781b1e9-8312-4751-8cbb-da785f3b807c	source_metadata_created	2007	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
f4039215-245b-4174-97bf-0ab38ef75384	repository_name	PANGEA (Data Publisher for Earth & Environmental Science)	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
58480da9-37d0-418c-a860-84274a672510	extra_authors	[{"extra_author": "Schoch Werner H", "orcid": "0000-0003-1364-0958"}, {"extra_author": "Miehe Georg", "orcid": ""}]	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
6c81d85c-b828-4823-8a88-682765ba4fdb	doi_status	True	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
ecb963b0-d5fc-4e14-acf0-e12dfa3a62c5	resource_type	application/zip - filename: Kaiser_2007	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
5957caaa-46db-4038-8612-64c5c62ffd8d	source_metadata_modified		active	58d7e04e-9f14-48e3-bc39-66eb40541e51
0104bb65-247a-4053-9af9-eec843247b89	subject_areas	[{"subject_area_additional": "", "subject_area_name": "Agriculture"}, {"subject_area_additional": "", "subject_area_name": "LakesRivers"}, {"subject_area_additional": "", "subject_area_name": "Lithosphere"}]	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
d171aed7-0f47-44d6-9b9f-82c11461596e	doi	10.1594/PANGAEA.787132	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
2efae3a4-3ce4-4632-8e3b-46a8c711dc1d	doi_publisher		active	58d7e04e-9f14-48e3-bc39-66eb40541e51
615c3ba2-819e-41fc-8232-8b697ee7b522	orcid	0000-0002-5080-6075	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
4d900b50-c676-4d15-971e-746fc5778471	doi_date_published	2007	active	58d7e04e-9f14-48e3-bc39-66eb40541e51
13e0d889-25df-4a0f-96af-d7e810b68eb5	publication_year	2007	active	08643811-14ae-4177-991d-a0cf6acb4971
14ec8e8e-5a38-4cca-acf0-201b5b0623e6	source_metadata_created	2007	active	08643811-14ae-4177-991d-a0cf6acb4971
74d9572c-d54e-4043-86d6-c73875966711	repository_name	PANGEA (Data Publisher for Earth & Environmental Science)	active	08643811-14ae-4177-991d-a0cf6acb4971
e72b2cb3-9dea-41b5-968f-945684c3d369	extra_authors	[{"extra_author": "Borghini Francesca", "orcid": ""}, {"extra_author": "Bucci Charlie", "orcid": ""}, {"extra_author": "Colacevich Andrea", "orcid": ""}, {"extra_author": "Bargagli Roberto", "orcid": ""}]	active	08643811-14ae-4177-991d-a0cf6acb4971
a0fe562a-027f-44f2-b659-a83f2a6f153c	doi_status	True	active	08643811-14ae-4177-991d-a0cf6acb4971
0dff8183-a7e5-4942-be28-58e0cccecfcd	resource_type	application/zip - filename: Caruso_2007	active	08643811-14ae-4177-991d-a0cf6acb4971
f5000571-ea36-4054-a8e0-9fb8ea2925a4	source_metadata_modified		active	08643811-14ae-4177-991d-a0cf6acb4971
30faa33d-c158-4eb3-8741-1188ba7329d5	subject_areas	[{"subject_area_additional": "", "subject_area_name": "Agriculture"}, {"subject_area_additional": "", "subject_area_name": "Lithosphere"}]	active	08643811-14ae-4177-991d-a0cf6acb4971
23febcb3-4fd2-48ca-bd24-252aff1a911e	doi	10.1594/PANGAEA.786598	active	08643811-14ae-4177-991d-a0cf6acb4971
f6afcd04-1fcf-4f86-9a78-61a493e834b2	doi_publisher		active	08643811-14ae-4177-991d-a0cf6acb4971
20edf948-ebf9-4f94-8dd2-5a4c8a33e30a	orcid	0000-0002-3607-9609	active	08643811-14ae-4177-991d-a0cf6acb4971
ae9ede43-8d64-4112-9690-c240430c8c71	doi_date_published	2007	active	08643811-14ae-4177-991d-a0cf6acb4971
a6b63bca-ed3c-4e27-8640-2a8c46bbbe6a	publication_year	2008	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
d97182b3-23e7-4a3b-be6f-889f322a72ae	source_metadata_created	2008	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
fd806dcf-9d57-425d-9267-37a0294f1912	repository_name	PANGEA (Data Publisher for Earth & Environmental Science)	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
709de677-0b99-4eb9-bf93-7deba45d1790	extra_authors	[{"extra_author": "Miehe Georg", "orcid": ""}, {"extra_author": "Barthelmes Alexandra", "orcid": ""}, {"extra_author": "Ehrmann Otto", "orcid": ""}, {"extra_author": "Scharf Andreas", "orcid": ""}, {"extra_author": "Schult Manuela", "orcid": ""}, {"extra_author": "Schl\\u00fctz Frank", "orcid": "0000-0003-2114-8146"}, {"extra_author": "Adamczyk Sonja", "orcid": ""}, {"extra_author": "Frenzel Burkhard", "orcid": ""}]	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
49a9c951-b7c1-4564-92e7-e329cf69f0fe	doi_status	True	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
be8af53d-ef26-4033-a894-0b20f8527657	resource_type	application/zip - filename: Kaiser_2008	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
ed4b60b4-3111-44a3-95f1-372899c3eeba	source_metadata_modified		active	ad0e3518-619f-4cda-9d87-a055bca68d4c
7bb70fe4-b027-4eda-b68e-aa617e855fe9	subject_areas	[{"subject_area_additional": "", "subject_area_name": "Agriculture"}, {"subject_area_additional": "", "subject_area_name": "LakesRivers"}, {"subject_area_additional": "", "subject_area_name": "Lithosphere"}]	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
f5e34b87-0468-4413-93c4-4548a3c60536	doi	10.1594/PANGAEA.787168	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
fbfa7029-67b2-448e-9ce0-9a82e92b2dfb	doi_publisher		active	ad0e3518-619f-4cda-9d87-a055bca68d4c
cc5da3a7-6b8f-4f9f-9045-cf4557b98969	orcid	0000-0002-5080-6075	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
f8b40afd-a1f5-4311-8a47-6c16ed3fdd46	doi_date_published	2008	active	ad0e3518-619f-4cda-9d87-a055bca68d4c
4ebfaac1-c4f9-4da2-b99e-625e84c5c45b			active	69008361-5ce3-4662-aab6-2132bebd818c
5173ee7e-c135-42b9-9296-81040603318d	extra_authors	[{"extra_author": "", "orcid": ""}]	active	69008361-5ce3-4662-aab6-2132bebd818c
d9729c30-244b-4d59-b575-c8427112a309	orcid		active	69008361-5ce3-4662-aab6-2132bebd818c
dc98f529-8415-4e9b-8c0f-a9bff3c16735	services_used_list		active	69008361-5ce3-4662-aab6-2132bebd818c
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
9374ffd5-ed59-472a-8f76-431512e88238	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42	5aa5a211-5299-4e21-9f15-1dd67bfe9901
96107bf5-8cd7-438d-94f6-e1c481c8b1ce	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42	cbca0a25-25b1-4bd4-b009-4329f73adb0d
a209837b-b1e5-4baa-8955-96b8bd48f3c2	active	b9d4d1b3-7269-43cf-a6e4-a9013c26ae42	4ebf873e-84e9-4087-816f-019d6c98e242
53d06530-cb67-40ff-9eb4-0a38d99bdc0e	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9	0478f10f-a29f-4626-a00d-399c0556e456
698b184a-8376-4859-8c7f-6eed0b6b68cf	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9	f99310d9-4787-4366-aa6d-f133b6c4178e
544f29d9-f943-49c0-87cf-92e4f99d055d	active	01155add-e61e-4d6b-89a2-e59aa03d4ce9	b8f8e7b7-358e-4c6b-b864-60244b89080c
cc1e17f9-b943-4f5e-890f-e72367b57301	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0	e3117ce2-93fe-42a6-bdcd-a1cf41cbe404
921374c2-6a20-4782-863b-da42fb5c5550	active	1b90cad6-75a3-4c2b-b12d-b7ab0b2317a0	904d851c-e46a-4786-9b34-79a688b11f8e
061c4334-5ec3-4828-92c9-02fa87c92228	active	13b1f7b4-fc9b-4060-a814-5a8a2e7d333f	01fac1a6-bdf3-47ea-be2b-4843b5afdc38
5ab3bfce-1e7b-4754-88da-146016aba07d	active	08643811-14ae-4177-991d-a0cf6acb4971	01fac1a6-bdf3-47ea-be2b-4843b5afdc38
0cff9e6c-472e-4c5e-807c-3d825c970b7f	active	69008361-5ce3-4662-aab6-2132bebd818c	9bd47a6d-e23d-4ca3-9d1d-d1fa3a244087
ca7cdd91-a094-4310-917f-8def9279629b	active	69008361-5ce3-4662-aab6-2132bebd818c	ada45459-2635-4ba6-8501-58de5903b220
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
1342ec64-f18e-4860-93cc-f6dd194d56ec	https://service.tib.eu/ldmservice/dataset/c31c9ff2-0ea9-43d8-8f93-2af0eaade9d4/resource/6b12f482-7693-4e36-9f47-fa0d4e03a5dc/download/visualization_-_aerial.dwg			1		active	{"datastore_active": false}	Example 3D .dwg file	\N	\N	\N	733036	2022-03-16 07:54:28.325436	\N	\N	\N	\N	2017-11-23 17:40:23.217872		476cdf71-1048-4a6f-a28a-58fff547dae5	2022-05-10 06:16:58.409296
ce24e635-7fef-47e2-9f70-a0b214805867	https://service.tib.eu/ldmservice/dataset/416b1441-cac9-4f9a-bb30-db1fb160ea65/resource/998f246f-2e3e-42c8-87cd-dc9241148e83/download/text_example.txt	TXT	This is just text for visualization.	1		active	{"datastore_active": false}	Text file example (TXT)	\N	text/plain	\N	2330	2022-03-16 08:43:38.994979	\N	\N	\N	\N	2022-03-16 08:43:39.008718		86b5446b-092a-4467-870c-b61b055d763f	2022-06-13 07:02:23.336229
43670f2e-4bcc-4835-8f95-5eb6c8a0ace6	https://service.tib.eu/ldmservice/dataset/416b1441-cac9-4f9a-bb30-db1fb160ea65/resource/e3bf9e67-3bec-4696-ab04-86c2bcc64355/download/junctiona.png	PNG	Intersection A with overlaid trajectory samples and background image.\r\nImage published by Leibniz University Hannover.	2		active	{"datastore_active": false}	PNG image example	\N	image/png	\N	2085108	2022-03-16 08:49:17.919665	\N	\N	\N	\N	2022-03-16 08:45:49.079082		86b5446b-092a-4467-870c-b61b055d763f	2022-06-13 07:02:48.812178
9fc8ae68-7b34-4a48-a083-1ed4f71ad5ac	https://service.tib.eu/ldmservice/dataset/416b1441-cac9-4f9a-bb30-db1fb160ea65/resource/6ef14c56-8de5-41f8-8333-e6428cc561ef/download/gtem_1250.jpg	JPEG	Picture of the GTEM 1250 cell.\r\nImage published by Leibniz University Hannover.	3		active	{"datastore_active": false}	JPG Image example	\N	image/jpeg	\N	2437112	2022-03-16 08:51:44.355645	\N	\N	\N	\N	2022-03-16 08:51:44.369862		86b5446b-092a-4467-870c-b61b055d763f	2022-06-13 07:03:10.334766
8649545f-f1d0-49d2-b9cd-88f2593ec059	https://service.tib.eu/ldmservice/dataset/30bb224e-7474-4495-bd8e-96c7d3f1b22e/resource/ed5a1c08-e020-442a-a4ad-0a715a89805f/download/stf50_autocombustions_with_varying_phi_v2_hd.mp4	MP4		0		active	{"datastore_active": false}	STF50 autocombustions with varying Phi (MP4)	\N	video/mp4	\N	71194509	2022-03-16 08:15:16.584473	\N	\N	\N	\N	2017-11-24 13:42:36.23793		54920aae-f322-4fca-bd09-cd091946632c	2022-06-13 07:13:24.142422
849a62dc-45fe-4f7e-9687-09543b7f8512	https://service.tib.eu/ldmservice/dataset/30bb224e-7474-4495-bd8e-96c7d3f1b22e/resource/82451693-de7a-4275-8c18-22484d7b12c1/download/pushrod.webm	WebM	The video was published by Leibniz University Hannover.	1		active	{"datastore_active": false}	Boundary value problem of a push rod (WEBM)	\N	video/webm	\N	369844	2022-03-16 08:18:38.610661	\N	\N	\N	\N	2022-03-16 08:18:38.634836		54920aae-f322-4fca-bd09-cd091946632c	2022-06-13 07:14:04.990353
a86b71e3-c68a-421e-b995-b172d603df62	https://service.tib.eu/ldmservice/dataset/30bb224e-7474-4495-bd8e-96c7d3f1b22e/resource/1554f1ee-0425-4efd-94fb-8c16d6757702/download/spring.ogg	OGG	The video was published by Leibniz University Hannover.	2		active	\N	Boundary value problem of a spring (OGG)	\N	audio/ogg	\N	543985	2022-03-16 08:19:58.009932	\N	\N	\N	\N	2022-03-16 08:19:58.037751		54920aae-f322-4fca-bd09-cd091946632c	2022-06-13 07:14:39.424674
4d288ebb-9f2f-40fb-9feb-d0dbffa2f4b7	https://service.tib.eu/ldmservice/dataset/672f2339-c57f-48f5-a681-b62acc50f488/resource/22312cbf-7a7a-4510-88b5-8a1a828f3064/download/data.csv	CSV	This is a sample dataset for demonstration purposes.	0		active	{"datastore_active": false}	Cars data	\N	text/csv	\N	1475504	2022-03-16 09:47:36.6725	\N	\N	\N	\N	2022-03-16 09:47:36.683662		ed56c026-3d32-41d5-9d11-2aa655cb8052	2022-03-16 09:48:33.163961
5c653296-8877-42f4-9dee-84de4784dcca	exploratory_data_analysis.ipynb	ipynb	This jupyter notebook runs live code over the cars.cvd data present in the same dataset.	1		active	{"auto_update": "No", "auto_update_url": ""}	Exploratory Data Analisys of Cars	\N	\N	\N	199131	2022-03-16 09:50:33.020919	\N	\N	\N	\N	2022-03-16 09:50:33.036016	upload	ed56c026-3d32-41d5-9d11-2aa655cb8052	2022-03-16 09:52:16.210277
4ee0ec1c-c72b-4bad-be73-364a735cea5c	https://service.tib.eu/ldmservice/dataset/c31c9ff2-0ea9-43d8-8f93-2af0eaade9d4/resource/4c0009c0-69f2-49ec-831c-181f97d624a5/download/drive_shaft.dwg			0		active	{"datastore_active": false}	Example 2D .dwg file	\N	\N	\N	169807	2022-03-16 07:53:55.475515	\N	\N	\N	\N	2017-11-23 17:37:19.897441		476cdf71-1048-4a6f-a28a-58fff547dae5	2022-05-10 06:16:16.473844
ade79b5d-14e3-4d08-a556-2135fee359f4	https://service.tib.eu/ldmservice/dataset/c31c9ff2-0ea9-43d8-8f93-2af0eaade9d4/resource/3f429389-27fa-4bac-a677-1c989882b06f/download/g12_0020_100_5_5_grosskaste.dwg	ZIP	Example usage of CAD using Ckan View with information provided by PANGAEA.	2		active	{"datastore_active": false}	PANGEA CAD example	\N	\N	\N	3414733	2022-03-16 07:50:19.38818	\N	\N	\N	\N	2022-03-16 07:50:19.425337		476cdf71-1048-4a6f-a28a-58fff547dae5	2022-05-10 06:19:53.347017
fd0b6a02-811f-4010-b0ca-d86d7a744ec6	exploratory_data_analysis.ipynb	ipynb		0		deleted	{"auto_update": "No", "auto_update_url": ""}	test new	\N	\N	\N	199131	2022-06-09 10:03:10.044349	\N	\N	\N	\N	2022-06-09 10:03:10.064219	upload	ed56c026-3d32-41d5-9d11-2aa655cb8052	2022-06-09 10:03:10.058765
a423df49-5bca-4652-b343-4fa12ccaddc2	g12_0020_100_5_5_grosskaste.dwg			0		deleted	{"auto_update": "No", "auto_update_url": "", "datastore_active": false}	3d 	\N	\N	\N	942674	2022-05-10 06:11:11.647841	\N	\N	\N	\N	2022-05-10 06:11:11.720454	upload	476cdf71-1048-4a6f-a28a-58fff547dae5	2022-05-10 06:16:16.474575
fece58b1-1505-4ef0-befb-3f0edf59335d	https://service.tib.eu/ldmservice/dataset/abe34d5b-89dc-45a6-ace3-edef03a98e25/resource/0e5f5646-65a4-42af-a4e5-92f5dbbf4f96/download/1-laurenz_meyhoefer_a.-proletella-performance.csv	CSV	All data are analysed and published 2020 under the title "Banker plants promote functional biodiversity and decrease populations of the cabbage whitefly Aleyrodes proletella".\r\nThis dataset was published by Leibniz University Hannover.	0		active	{"datastore_active": false}	CSV Data Example	\N	text/csv	\N	2017	2022-03-16 09:22:41.200122	\N	\N	\N	\N	2022-03-16 09:22:41.213753		d5d29173-addc-4e4d-af7b-59e3b147c817	2022-06-13 06:56:06.862691
1fb543eb-9980-494e-bd3b-26aa99bc06ef	https://service.tib.eu/ldmservice/dataset/abe34d5b-89dc-45a6-ace3-edef03a98e25/resource/5ab0c3ad-0086-4fae-b206-3954a4b147cd/download/2017-12-21_vnstat-export-br0.xml	XML	This is a XML file published by Leibniz University Hannover.	1		active	{"datastore_active": false}	XML Data Example	\N	application/xml	\N	9610	2022-03-16 09:26:47.705015	\N	\N	\N	\N	2022-03-16 09:26:47.719119		d5d29173-addc-4e4d-af7b-59e3b147c817	2022-06-13 06:56:58.327548
e3e6e6ef-e356-4005-af2e-2e8538ed3f58	https://service.tib.eu/ldmservice/dataset/abe34d5b-89dc-45a6-ace3-edef03a98e25/resource/8b27c588-9ca1-451f-8d22-86df37613355/download/2017-12-21_vnstat-export-br0.json	JSON	This is a JSON file published by Leibniz University Hannover. 	2		active	{"datastore_active": false}	JSON Data Example	\N	application/json	\N	6211	2022-03-16 09:29:08.762912	\N	\N	\N	\N	2022-03-16 09:29:08.778126		d5d29173-addc-4e4d-af7b-59e3b147c817	2022-06-13 06:57:33.204803
5a139ebc-3076-47a5-a7d5-9b3c6505dd9e	https://service.tib.eu/ldmservice/dataset/abe34d5b-89dc-45a6-ace3-edef03a98e25/resource/75d19a29-b1fe-4327-b09c-dcf8b828df9c/download/luh-beispiel-netzwerkmessdaten.rdf	RDF	This is a RDF file example generated from data published by Leibniz University Hannover. 	3		active	{"datastore_active": false}	RDF Data Example	\N	application/rdf+xml	\N	6203	2022-03-16 09:30:52.51129	\N	\N	\N	\N	2022-03-16 09:30:52.528628		d5d29173-addc-4e4d-af7b-59e3b147c817	2022-06-13 06:57:58.324036
05fcf73d-3fbf-4dec-9ea4-3fc9537ffa43	https://service.tib.eu/ldmservice/dataset/abe34d5b-89dc-45a6-ace3-edef03a98e25/resource/4a8809e3-7452-4e4a-9108-223c6bdb7102/download/jcdl-2019-dils-2019-papers-orkg-overview.xlsx	XLSX	This is a XLSX file published by Leibniz University Hannover. 	4		active	{"datastore_active": false}	XLSX Data Example	\N	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	\N	32536	2022-03-16 09:33:30.410841	\N	\N	\N	\N	2022-03-16 09:33:30.427169		d5d29173-addc-4e4d-af7b-59e3b147c817	2022-06-13 06:58:28.762699
047da174-2caa-45db-bc43-36fd3523ee30	https://service.tib.eu/ldmservice/dataset/abe34d5b-89dc-45a6-ace3-edef03a98e25/resource/6fe73326-888d-4190-9a5d-09e65cd5d58b/download/sample1.ods	ODS	This is just an example file of the format for visualization.	5		active	{"datastore_active": false}	Open Document Spreadsheet (ODS) Example	\N	application/vnd.oasis.opendocument.spreadsheet	\N	\N	\N	\N	\N	\N	\N	2022-03-16 09:36:28.626475		d5d29173-addc-4e4d-af7b-59e3b147c817	2022-06-13 06:58:55.028252
4a7d7059-b168-4772-9b81-ffb11f0f6d70	https://service.tib.eu/ldmservice/dataset/416b1441-cac9-4f9a-bb30-db1fb160ea65/resource/ad15ee0f-8501-43ca-8188-798550b60dec/download/data_description.pdf	PDF	To analyse the stochastic properties of the laser tracker Leica AT960-LR, five fix points spatially distributed were continuously observed from three different positions in the 3D.\r\nPublished by Leibniz University Hannover.	0		active	{"datastore_active": false}	Data Description (PDF)	\N	application/pdf	\N	962808	2022-03-16 08:32:47.294826	\N	\N	\N	\N	2022-03-16 08:32:47.306135		86b5446b-092a-4467-870c-b61b055d763f	2022-06-13 07:01:41.379254
3486d220-0c38-4449-96df-7d4d18b916a7	https://service.tib.eu/ldmservice/dataset/416b1441-cac9-4f9a-bb30-db1fb160ea65/resource/f30297a2-6127-4f32-b83e-45abd460bf10/download/giphy.gif	GIF	Just a GIF image for visualization.	4		active	{"datastore_active": false}	GIF image example	\N	image/gif	\N	3132208	2022-03-16 08:54:45.107385	\N	\N	\N	\N	2022-03-16 08:54:45.122641		86b5446b-092a-4467-870c-b61b055d763f	2022-06-13 07:03:35.960962
95a1ebf6-d481-4940-923c-59b21921dfda	https://service.tib.eu/ldmservice/dataset/416b1441-cac9-4f9a-bb30-db1fb160ea65/resource/19d40f31-d2c3-4900-8402-7458251d9b6e/download/sample1.odt	ODT	This is just an example for visualization.	5		active	{"datastore_active": false}	OpenOffice Writer example (ODT) 	\N	application/vnd.oasis.opendocument.text	\N	21423	2022-03-16 09:07:55.525141	\N	\N	\N	\N	2022-03-16 09:03:59.916552		86b5446b-092a-4467-870c-b61b055d763f	2022-06-13 07:04:04.920609
966e73d8-654f-4396-ad35-c2bd212e9afd	https://service.tib.eu/ldmservice/dataset/416b1441-cac9-4f9a-bb30-db1fb160ea65/resource/3ecda15f-bcb6-49e3-98fe-ea3b354ec06f/download/sample1.odp	ODP	This is just an example file for visualization.	6		active	\N	Open Document Presentation (ODP)	\N	application/vnd.oasis.opendocument.presentation	\N	389789	2022-03-16 09:13:02.545995	\N	\N	\N	\N	2022-03-16 09:13:02.565493		86b5446b-092a-4467-870c-b61b055d763f	2022-06-13 07:04:36.923681
2a68ba5b-e5a2-4a33-8e1e-2420cae4b121	token_creation.png	PNG	Image used inside the notebook	16		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	token_creation_img	\N	image/png	\N	476982	2022-12-27 10:17:17.891777	\N	\N	\N	\N	2022-12-27 10:17:17.923145	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:17:17.913912
4fe20c68-ecb6-4f8a-82c4-13eb43dace4d	download_dataset2.png	PNG	Image used inside the notebook	10		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	download_dataset_img2	\N	image/png	\N	113050	2022-12-27 10:15:44.256308	\N	\N	\N	\N	2022-12-27 10:15:44.287873	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:15:44.278743
53c4f88b-8316-427a-bf54-e7c839ef4e4e	download_dataset4.png	PNG	Image used inside the notebook	12		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	download_dataset_img4	\N	image/png	\N	57839	2022-12-27 10:16:14.844029	\N	\N	\N	\N	2022-12-27 10:16:14.871382	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:16:14.862231
88d7e54d-e4c1-406e-a10f-d510d3bfa435	dataset_created.png	PNG	Image used inside the notebook	8		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	dataset_created_img	\N	image/png	\N	471814	2022-12-27 10:15:14.890737	\N	\N	\N	\N	2022-12-27 10:15:14.912415	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:15:14.905237
89b0bd98-32e0-424c-b077-5a022ec76d78	upload_dataset10.png	PNG	Image used inside the notebook	26		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img10	\N	image/png	\N	99938	2022-12-27 10:19:44.687084	\N	\N	\N	\N	2022-12-27 10:19:44.732748	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:19:44.719951
934e411e-7b8f-4d78-a5a2-4de2fb7301e2	upload_dataset4.png	PNG	Image used inside the notebook	20		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img4	\N	image/png	\N	58128	2022-12-27 10:18:20.833898	\N	\N	\N	\N	2022-12-27 10:18:20.870445	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:18:20.859681
a8782a4c-c8b8-4ff8-9afe-160bf573540e	upload_dataset8.png	PNG	Image used inside the notebook	24		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img8	\N	image/png	\N	74433	2022-12-27 10:19:18.760226	\N	\N	\N	\N	2022-12-27 10:19:18.803446	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:19:18.791186
bbfb6eb3-ec9a-49c1-bfc2-f4d7c8a1a014	upload_dataset6.png	PNG	Image used inside the notebook	22		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img6	\N	image/png	\N	141879	2022-12-27 10:18:48.413096	\N	\N	\N	\N	2022-12-27 10:18:48.453603	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:18:48.44168
ce5861dd-7e85-4d17-b22c-2d1a01beb05c	create_org2.png	PNG	Image used inside the notebook	6		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	create_org_img2	\N	image/png	\N	44229	2022-12-27 10:14:44.339566	\N	\N	\N	\N	2022-12-27 10:14:44.359419	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:14:44.352213
d45b05ce-c776-432b-a37d-23014c3f994c	upload_dataset2.png	PNG	Image used inside the notebook	18		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img2	\N	image/png	\N	51181	2022-12-27 10:17:55.916409	\N	\N	\N	\N	2022-12-27 10:17:55.950162	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:17:55.93819
f4a02fc6-f426-4be8-9a19-e939e7809af1	show_private_dataset1.png	PNG	Image used inside the notebook	14		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	show_private_dataset_img1	\N	image/png	\N	63035	2022-12-27 10:16:45.932474	\N	\N	\N	\N	2022-12-27 10:16:45.963239	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:16:45.954801
15c0434a-a3ba-49c2-83d3-a30c2a8deff5	upload_dataset5.png	PNG	Image used inside the notebook	21		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img5	\N	image/png	\N	93830	2022-12-27 10:18:34.288853	\N	\N	\N	\N	2022-12-27 10:18:34.324576	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:18:34.313332
1e479203-d713-4943-b42f-2bcc8c71dd1f	upload_dataset7.png	PNG	Image used inside the notebook	23		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img7	\N	image/png	\N	72073	2022-12-27 10:19:02.317794	\N	\N	\N	\N	2022-12-27 10:19:02.356045	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:19:02.344559
31614c67-8577-4cef-bd55-a6a18d58d02c	ldm_api-localhost.ipynb	ipynb	This is a jupyter notebook showing by examples running python3 how to access and use the LDM-API.	0		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	LDM-API implementation (JupyterNotebook)	\N	\N	\N	73696	2022-12-27 11:20:11.140519	\N	\N	\N	\N	2022-12-27 11:20:11.190976	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 11:20:11.176425
38c7526e-8b57-494a-a8f4-fc4e6f40fa13	create_dataset1.png	PNG	Image used inside the notebook	2		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	create_dataset_img1	\N	image/png	\N	46408	2022-12-27 10:13:04.364651	\N	\N	\N	\N	2022-12-27 10:13:04.387575	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:13:04.376335
53dd67ec-e720-4dfd-9b05-4cce7ae37b88	show_private_dataset2.png	PNG	Image used inside the notebook	15		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	show_private_dataset_img2	\N	image/png	\N	50178	2022-12-27 10:17:00.550346	\N	\N	\N	\N	2022-12-27 10:17:00.581016	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:17:00.571652
54a42c73-0fa4-45e8-a699-fd9631ad0155	download_dataset3.png	PNG	Image used inside the notebook	11		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	download_dataset_img3	\N	image/png	\N	108652	2022-12-27 10:15:55.990178	\N	\N	\N	\N	2022-12-27 10:15:56.018954	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:15:56.009624
55b0bfee-3b7d-4595-8f0e-a912a4178c61	upload_dataset3.png	PNG	Image used inside the notebook	19		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img3	\N	image/png	\N	130349	2022-12-27 10:18:08.225419	\N	\N	\N	\N	2022-12-27 10:18:08.259381	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:18:08.248923
59f35bf0-9cc5-425e-8cac-14c9112a111a	create_user.png	PNG	Image used inside the notebook	7		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	create_user_img	\N	image/png	\N	63210	2022-12-27 10:14:58.607865	\N	\N	\N	\N	2022-12-27 10:14:58.627807	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:14:58.621021
622ea2c9-e960-40f4-9514-ced3232c5e7d	create_dataset2.png	PNG	Image used inside the notebook	3		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	create_dataset_img2	\N	image/png	\N	122026	2022-12-27 10:13:48.574898	\N	\N	\N	\N	2022-12-27 10:13:48.592784	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:13:48.584228
6620d1c8-971d-490e-99c2-0a5749a2ae86	user_created.png	PNG	Image used inside the notebook	27		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	user_created_img	\N	image/png	\N	104787	2022-12-27 10:20:06.985906	\N	\N	\N	\N	2022-12-27 10:20:07.031012	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:20:07.018013
841d652b-4fd5-4c24-ac11-62381b0dead3	upload_dataset1.png	PNG	Image used inside the notebook	17		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img1	\N	image/png	\N	63350	2022-12-27 10:17:41.35548	\N	\N	\N	\N	2022-12-27 10:17:41.389672	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:17:41.379172
99d953ae-3e3d-4dee-b5e9-656746a215f1	download_dataset1.png	PNG	Image used inside the notebook	9		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	download_dataset_img1	\N	image/png	\N	114005	2022-12-27 10:15:31.086292	\N	\N	\N	\N	2022-12-27 10:15:31.108895	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:15:31.101426
a087cd32-70ee-458f-96f8-001faf4cacb9	upload_dataset9.png	PNG	Image used inside the notebook	25		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	upload_dataset_img9	\N	image/png	\N	72299	2022-12-27 10:19:31.176644	\N	\N	\N	\N	2022-12-27 10:19:31.219027	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:19:31.207381
b12d4dab-45ae-4ef3-938c-e12096652e00	create_org1.png	PNG	Image used inside the notebook	5		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	create_org_img1	\N	image/png	\N	56995	2022-12-27 10:14:30.141663	\N	\N	\N	\N	2022-12-27 10:14:30.161219	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:14:30.154325
c81e916b-a5d9-4e2a-9f4e-06bb4d8e77a9	create_dataset3.png	PNG	Image used inside the notebook	4		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	create_dataset_img3	\N	image/png	\N	86177	2022-12-27 10:14:10.150955	\N	\N	\N	\N	2022-12-27 10:14:10.171238	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:14:10.163229
ca8a5477-1cd1-40f9-809c-5f9c0023f3f5	ldm_api-localhost.pdf	PDF	This is the printed version of the jupyter notebook as PDF file.	1		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	LDM-API implementation (PDF)	\N	application/pdf	\N	2148815	2022-12-27 11:21:30.257507	\N	\N	\N	\N	2022-12-27 11:21:30.302997	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 11:21:30.289829
dbdfa7bd-f874-4053-8f32-adf7c4272929	organization_created.png	PNG	Image used inside the notebook	13		active	{"auto_update": "No", "auto_update_last_update": "", "auto_update_url": ""}	organization_created_img	\N	image/png	\N	496150	2022-12-27 10:16:28.563381	\N	\N	\N	\N	2022-12-27 10:16:28.592192	upload	69008361-5ce3-4662-aab6-2132bebd818c	2022-12-27 10:16:28.583069
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
7d6f355f-ea2e-4f93-900f-abad36d4c10f	8649545f-f1d0-49d2-b9cd-88f2593ec059	Video		videoviewer	0	\N
e89ce4cd-f3a2-47a9-88be-b3867f2eda61	cc05a1c2-948b-4965-aea7-de09abdad953	Data Explorer		recline_view	0	\N
9cc3c0d7-3b0b-44d3-9811-8e4a41ac5267	aad9e24e-1046-4b70-9bb8-7d17a8371969	Data Explorer		recline_view	0	\N
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
5e9f425e-5fa8-4f2b-b615-0efff8e46444	a423df49-5bca-4652-b343-4fa12ccaddc2	CAD		tib_cadviewer	0	\N
de8a46d9-0f46-4bae-b9a5-743cc51c6dec	4ee0ec1c-c72b-4bad-be73-364a735cea5c	CAD 2D Preview		tib_cadviewer	0	\N
c7137eb8-7b70-4392-a438-c39a4e4b2836	1342ec64-f18e-4860-93cc-f6dd194d56ec	CAD 3D Preview		tib_cadviewer	0	\N
65a7d967-ea94-48cd-91b1-176ee620e84a	ade79b5d-14e3-4d08-a556-2135fee359f4	CAD PANGEA Preview		tib_cadviewer	0	\N
ac8664cf-4b37-4405-9de8-51c5f22b1a96	fd0b6a02-811f-4010-b0ca-d86d7a744ec6	test jn		jupyternotebook	0	\N
3c9e2c3e-442f-4f18-a366-14ac0b4a95c3	38c7526e-8b57-494a-a8f4-fc4e6f40fa13	Image		image_view	0	\N
68533602-49b6-4c17-9110-5b8de315ecee	622ea2c9-e960-40f4-9514-ced3232c5e7d	Image		image_view	0	\N
1dc8e438-ad56-4d45-9f48-9438475bb815	c81e916b-a5d9-4e2a-9f4e-06bb4d8e77a9	Image		image_view	0	\N
2cc747bf-8791-4d0a-847a-15fc069b54e4	b12d4dab-45ae-4ef3-938c-e12096652e00	Image		image_view	0	\N
f4770e8b-d0d4-4e99-b4b4-3f1056d15a68	ce5861dd-7e85-4d17-b22c-2d1a01beb05c	Image		image_view	0	\N
f5e661f3-2d40-435b-887c-943f26d2bf49	59f35bf0-9cc5-425e-8cac-14c9112a111a	Image		image_view	0	\N
de95da03-2a99-40a3-8881-89250217f2d4	88d7e54d-e4c1-406e-a10f-d510d3bfa435	Image		image_view	0	\N
a915ed61-8146-454a-812f-927d34c55054	99d953ae-3e3d-4dee-b5e9-656746a215f1	Image		image_view	0	\N
d53d6100-b133-4e71-8d91-5a66d1a25dae	4fe20c68-ecb6-4f8a-82c4-13eb43dace4d	Image		image_view	0	\N
9f6323ba-3bfb-444e-9520-bd48d03c9187	54a42c73-0fa4-45e8-a699-fd9631ad0155	Image		image_view	0	\N
ba29af0d-88e5-4fa8-ad52-4d8948f68481	53c4f88b-8316-427a-bf54-e7c839ef4e4e	Image		image_view	0	\N
456ee49c-54b4-4385-92d8-3da56c4ea870	dbdfa7bd-f874-4053-8f32-adf7c4272929	Image		image_view	0	\N
f40129d1-53c6-4e38-91c7-522ddd35db13	f4a02fc6-f426-4be8-9a19-e939e7809af1	Image		image_view	0	\N
a9c83d31-3d79-4c08-a792-d685ad6ebe5f	53dd67ec-e720-4dfd-9b05-4cce7ae37b88	Image		image_view	0	\N
e1f2c5df-0249-4d36-bb86-f1902e74aca7	2a68ba5b-e5a2-4a33-8e1e-2420cae4b121	Image		image_view	0	\N
5938b5b4-12ed-4954-9f88-5b8ddf0cf628	841d652b-4fd5-4c24-ac11-62381b0dead3	Image		image_view	0	\N
0d417a6c-4f5f-47be-ae69-12a22e04d37e	d45b05ce-c776-432b-a37d-23014c3f994c	Image		image_view	0	\N
ea47306a-8d22-4307-aa7f-32bd0ee3e6d5	55b0bfee-3b7d-4595-8f0e-a912a4178c61	Image		image_view	0	\N
ffa90011-6444-4d51-bc0d-791f2455be31	934e411e-7b8f-4d78-a5a2-4de2fb7301e2	Image		image_view	0	\N
baf0f6aa-06c5-4391-baa7-8391f0797137	15c0434a-a3ba-49c2-83d3-a30c2a8deff5	Image		image_view	0	\N
5f18910e-9cae-4ad5-a979-5587f368d1ab	bbfb6eb3-ec9a-49c1-bfc2-f4d7c8a1a014	Image		image_view	0	\N
bb4647fa-e495-43b9-ab6b-2df496089deb	1e479203-d713-4943-b42f-2bcc8c71dd1f	Image		image_view	0	\N
85d244f4-ac66-4a72-9779-d7df2404a790	a8782a4c-c8b8-4ff8-9afe-160bf573540e	Image		image_view	0	\N
ebfd43a3-c346-4eed-a711-d7566e7cd4b9	a087cd32-70ee-458f-96f8-001faf4cacb9	Image		image_view	0	\N
68619368-0c9a-40f3-af81-4c603e5d6e0f	89b0bd98-32e0-424c-b077-5a022ec76d78	Image		image_view	0	\N
b8c0128c-c499-4408-8ae5-6cff2382db1f	6620d1c8-971d-490e-99c2-0a5749a2ae86	Image		image_view	0	\N
f8c11571-943b-4361-a6f0-4aec1e113d92	31614c67-8577-4cef-bd55-a6a18d58d02c	Jupyter Notebook Preview		jupyternotebook	0	\N
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
5aa5a211-5299-4e21-9f15-1dd67bfe9901	relationship matrix	\N
cbca0a25-25b1-4bd4-b009-4329f73adb0d	expected relationships	\N
4ebf873e-84e9-4087-816f-019d6c98e242	founder relationships	\N
b8f8e7b7-358e-4c6b-b864-60244b89080c	selection signatures	\N
0478f10f-a29f-4626-a00d-399c0556e456	animal population genetics	\N
f99310d9-4787-4366-aa6d-f133b6c4178e	horse	\N
e3117ce2-93fe-42a6-bdcd-a1cf41cbe404	Molecular dynamics	\N
904d851c-e46a-4786-9b34-79a688b11f8e	nanowires	\N
01fac1a6-bdf3-47ea-be2b-4843b5afdc38	ipy	\N
9bd47a6d-e23d-4ca3-9d1d-d1fa3a244087	API	\N
ada45459-2635-4ba6-8501-58de5903b220	LDM	\N
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

