--
-- PostgreSQL database dump
--

\restrict RnlmeFBKZf2Wh9S297g2XzxRX6RaT9zWcezpywEERugsD6ymDU1iNsmKeNgdLLe

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name text NOT NULL,
    legal_name text,
    domain text,
    industry text,
    company_size text,
    employee_count_min integer,
    employee_count_max integer,
    headquarters_location text,
    founded_year integer,
    stock_symbol text,
    company_type text,
    glassdoor_rating numeric(3,2),
    linkedin_url text,
    website_url text,
    description text,
    extraction_confidence numeric(3,2),
    extraction_source text,
    extraction_notes text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT valid_name_length CHECK ((length(name) > 0))
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: email_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_attachments (
    id integer NOT NULL,
    email_id integer,
    filename text,
    content_type text,
    size_bytes bigint,
    attachment_data bytea
);


--
-- Name: email_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_attachments_id_seq OWNED BY public.email_attachments.id;


--
-- Name: email_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_categories (
    id integer NOT NULL,
    category_name character varying(50),
    description text,
    keywords text[],
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: email_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_categories_id_seq OWNED BY public.email_categories.id;


--
-- Name: email_hashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_hashes (
    email_id integer NOT NULL,
    body_hash text NOT NULL,
    composite_key text,
    content_length integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id integer NOT NULL,
    uid bigint,
    folder_name text,
    message_id text,
    subject text,
    sender text,
    recipients text,
    date_sent timestamp with time zone,
    date_received timestamp with time zone,
    body_text text,
    body_html text,
    size_bytes bigint,
    has_attachments boolean DEFAULT false,
    account_id integer,
    processed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    email_type text DEFAULT 'unknown'::text,
    analysis_status text DEFAULT 'pending'::text,
    analysis_attempts integer DEFAULT 0,
    last_analysis_error text,
    email_category text,
    category_confidence numeric(3,2)
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- Name: extraction_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.extraction_attempts (
    id integer NOT NULL,
    email_id integer,
    session_epoch bigint,
    extraction_type text NOT NULL,
    llm_prompt text,
    llm_response text,
    processing_time_ms integer,
    success boolean DEFAULT false,
    error_message text,
    extracted_data jsonb,
    confidence_score numeric(3,2),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: extraction_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.extraction_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: extraction_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.extraction_attempts_id_seq OWNED BY public.extraction_attempts.id;


--
-- Name: extraction_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.extraction_errors (
    id integer NOT NULL,
    email_id integer,
    error_type character varying(50),
    error_details text,
    confidence_score numeric(3,2),
    extraction_method character varying(50),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: extraction_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.extraction_errors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: extraction_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.extraction_errors_id_seq OWNED BY public.extraction_errors.id;


--
-- Name: extraction_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.extraction_sessions (
    id integer NOT NULL,
    session_epoch bigint NOT NULL,
    model_name text NOT NULL,
    session_start timestamp with time zone DEFAULT now(),
    session_end timestamp with time zone,
    total_emails integer DEFAULT 0,
    processed_emails integer DEFAULT 0,
    failed_emails integer DEFAULT 0,
    recruiter_emails_found integer DEFAULT 0,
    recruiters_extracted integer DEFAULT 0,
    companies_extracted integer DEFAULT 0,
    positions_extracted integer DEFAULT 0,
    avg_processing_time_ms numeric(10,2),
    total_processing_time_ms bigint DEFAULT 0,
    status_file_path text,
    config_snapshot jsonb,
    error_summary jsonb,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: extraction_progress; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.extraction_progress AS
 SELECT extraction_sessions.session_epoch,
    extraction_sessions.model_name,
    extraction_sessions.session_start,
    extraction_sessions.processed_emails,
    extraction_sessions.total_emails,
        CASE
            WHEN (extraction_sessions.total_emails > 0) THEN round((((extraction_sessions.processed_emails)::numeric / (extraction_sessions.total_emails)::numeric) * (100)::numeric), 2)
            ELSE (0)::numeric
        END AS progress_percentage,
    extraction_sessions.recruiter_emails_found,
    extraction_sessions.recruiters_extracted,
    extraction_sessions.companies_extracted,
    extraction_sessions.positions_extracted,
    extraction_sessions.avg_processing_time_ms,
    (EXTRACT(epoch FROM (COALESCE(extraction_sessions.session_end, now()) - extraction_sessions.session_start)) / (60)::numeric) AS runtime_minutes
   FROM public.extraction_sessions
  ORDER BY extraction_sessions.session_epoch DESC;


--
-- Name: extraction_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.extraction_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: extraction_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.extraction_sessions_id_seq OWNED BY public.extraction_sessions.id;


--
-- Name: learned_patterns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.learned_patterns (
    id integer NOT NULL,
    data_type character varying(50),
    pattern text,
    confidence_score numeric(3,2),
    success_count integer DEFAULT 0,
    failure_count integer DEFAULT 0,
    last_used timestamp without time zone DEFAULT now(),
    created_from_correction boolean DEFAULT false
);


--
-- Name: learned_patterns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.learned_patterns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: learned_patterns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.learned_patterns_id_seq OWNED BY public.learned_patterns.id;


--
-- Name: manual_corrections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.manual_corrections (
    id integer NOT NULL,
    extraction_id integer,
    original_value text,
    corrected_value text,
    correction_type character varying(50),
    corrector_notes text,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: manual_corrections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.manual_corrections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manual_corrections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.manual_corrections_id_seq OWNED BY public.manual_corrections.id;


--
-- Name: positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.positions (
    id integer NOT NULL,
    recruiter_id integer,
    external_job_id text,
    job_title text NOT NULL,
    recruiting_company_id integer,
    client_company_id integer,
    department text,
    seniority_level text,
    location text,
    remote_type text,
    remote_percentage integer,
    job_type text,
    duration_months integer,
    status text DEFAULT 'new'::text,
    priority_level integer DEFAULT 3,
    salary_min numeric(12,2),
    salary_max numeric(12,2),
    salary_currency text DEFAULT 'USD'::text,
    hourly_rate_min numeric(8,2),
    hourly_rate_max numeric(8,2),
    compensation_type text,
    structure_type text,
    required_skills text[],
    preferred_skills text[],
    key_technologies text[],
    extraction_confidence numeric(3,2),
    extraction_source text,
    source_email_id integer,
    first_contacted timestamp with time zone,
    last_updated timestamp with time zone DEFAULT now(),
    closes_date timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    employment_type character varying(10),
    title character varying(200),
    CONSTRAINT valid_job_title CHECK ((length(job_title) > 1))
);


--
-- Name: recruiters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recruiters (
    id integer NOT NULL,
    name text NOT NULL,
    email text,
    company_id integer,
    phone text,
    linkedin_url text,
    title text,
    years_experience integer,
    timezone text,
    preferred_contact_method text,
    name_variations text[],
    email_variations text[],
    phone_variations text[],
    extraction_confidence numeric(3,2),
    extraction_source text,
    first_seen_email_id integer,
    last_seen_email_id integer,
    interaction_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT valid_recruiter_data CHECK (((length(COALESCE(name, ''::text)) > 0) OR (length(COALESCE(email, ''::text)) > 0)))
);


--
-- Name: position_opportunities; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.position_opportunities AS
 SELECT p.id,
    p.job_title,
    p.salary_min,
    p.salary_max,
    p.compensation_type,
    p.structure_type,
    p.location,
    p.remote_type,
    p.job_type,
    r.name AS recruiter_name,
    r.email AS recruiter_email,
    rc.name AS recruiting_company,
    cc.name AS client_company,
    p.extraction_confidence,
    p.created_at
   FROM (((public.positions p
     LEFT JOIN public.recruiters r ON ((p.recruiter_id = r.id)))
     LEFT JOIN public.companies rc ON ((p.recruiting_company_id = rc.id)))
     LEFT JOIN public.companies cc ON ((p.client_company_id = cc.id)))
  ORDER BY p.extraction_confidence DESC, p.created_at DESC;


--
-- Name: positions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.positions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.positions_id_seq OWNED BY public.positions.id;


--
-- Name: recruiter_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.recruiter_summary AS
 SELECT r.id,
    r.name,
    r.email,
    r.phone,
    c.name AS company_name,
    r.title,
    count(p.id) AS positions_offered,
    r.extraction_confidence,
    r.interaction_count,
    r.created_at
   FROM ((public.recruiters r
     LEFT JOIN public.companies c ON ((r.company_id = c.id)))
     LEFT JOIN public.positions p ON ((r.id = p.recruiter_id)))
  GROUP BY r.id, r.name, r.email, r.phone, c.name, r.title, r.extraction_confidence, r.interaction_count, r.created_at
  ORDER BY r.extraction_confidence DESC, r.interaction_count DESC;


--
-- Name: recruiters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recruiters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recruiters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recruiters_id_seq OWNED BY public.recruiters.id;


--
-- Name: structured_extractions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.structured_extractions (
    id integer NOT NULL,
    email_id integer,
    data_type character varying(50),
    extracted_value text,
    confidence_score numeric(3,2),
    extraction_method character varying(50),
    needs_review boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: structured_extractions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.structured_extractions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: structured_extractions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.structured_extractions_id_seq OWNED BY public.structured_extractions.id;


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: email_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_attachments ALTER COLUMN id SET DEFAULT nextval('public.email_attachments_id_seq'::regclass);


--
-- Name: email_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_categories ALTER COLUMN id SET DEFAULT nextval('public.email_categories_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- Name: extraction_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_attempts ALTER COLUMN id SET DEFAULT nextval('public.extraction_attempts_id_seq'::regclass);


--
-- Name: extraction_errors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_errors ALTER COLUMN id SET DEFAULT nextval('public.extraction_errors_id_seq'::regclass);


--
-- Name: extraction_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_sessions ALTER COLUMN id SET DEFAULT nextval('public.extraction_sessions_id_seq'::regclass);


--
-- Name: learned_patterns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.learned_patterns ALTER COLUMN id SET DEFAULT nextval('public.learned_patterns_id_seq'::regclass);


--
-- Name: manual_corrections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manual_corrections ALTER COLUMN id SET DEFAULT nextval('public.manual_corrections_id_seq'::regclass);


--
-- Name: positions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions ALTER COLUMN id SET DEFAULT nextval('public.positions_id_seq'::regclass);


--
-- Name: recruiters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruiters ALTER COLUMN id SET DEFAULT nextval('public.recruiters_id_seq'::regclass);


--
-- Name: structured_extractions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structured_extractions ALTER COLUMN id SET DEFAULT nextval('public.structured_extractions_id_seq'::regclass);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: email_attachments email_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_attachments
    ADD CONSTRAINT email_attachments_pkey PRIMARY KEY (id);


--
-- Name: email_categories email_categories_category_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_categories
    ADD CONSTRAINT email_categories_category_name_key UNIQUE (category_name);


--
-- Name: email_categories email_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_categories
    ADD CONSTRAINT email_categories_pkey PRIMARY KEY (id);


--
-- Name: email_hashes email_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_hashes
    ADD CONSTRAINT email_hashes_pkey PRIMARY KEY (email_id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: extraction_attempts extraction_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_attempts
    ADD CONSTRAINT extraction_attempts_pkey PRIMARY KEY (id);


--
-- Name: extraction_errors extraction_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_errors
    ADD CONSTRAINT extraction_errors_pkey PRIMARY KEY (id);


--
-- Name: extraction_sessions extraction_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_sessions
    ADD CONSTRAINT extraction_sessions_pkey PRIMARY KEY (id);


--
-- Name: extraction_sessions extraction_sessions_session_epoch_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_sessions
    ADD CONSTRAINT extraction_sessions_session_epoch_key UNIQUE (session_epoch);


--
-- Name: learned_patterns learned_patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.learned_patterns
    ADD CONSTRAINT learned_patterns_pkey PRIMARY KEY (id);


--
-- Name: manual_corrections manual_corrections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manual_corrections
    ADD CONSTRAINT manual_corrections_pkey PRIMARY KEY (id);


--
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: recruiters recruiters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruiters
    ADD CONSTRAINT recruiters_pkey PRIMARY KEY (id);


--
-- Name: structured_extractions structured_extractions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structured_extractions
    ADD CONSTRAINT structured_extractions_pkey PRIMARY KEY (id);


--
-- Name: idx_companies_confidence; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_companies_confidence ON public.companies USING btree (extraction_confidence DESC);


--
-- Name: idx_companies_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_companies_industry ON public.companies USING btree (industry);


--
-- Name: idx_companies_name_dedup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_companies_name_dedup ON public.companies USING btree (lower(TRIM(BOTH FROM name))) WHERE (length(TRIM(BOTH FROM name)) > 2);


--
-- Name: idx_companies_size; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_companies_size ON public.companies USING btree (company_size);


--
-- Name: idx_email_hashes_body_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_hashes_body_hash ON public.email_hashes USING btree (body_hash);


--
-- Name: idx_email_hashes_length; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_email_hashes_length ON public.email_hashes USING btree (content_length);


--
-- Name: idx_emails_analysis_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_analysis_status ON public.emails USING btree (analysis_status);


--
-- Name: idx_emails_date_received; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_date_received ON public.emails USING btree (date_received DESC);


--
-- Name: idx_emails_sender; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_sender ON public.emails USING btree (sender);


--
-- Name: idx_emails_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_type ON public.emails USING btree (email_type);


--
-- Name: idx_extraction_attempts_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_extraction_attempts_email ON public.extraction_attempts USING btree (email_id);


--
-- Name: idx_extraction_attempts_session; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_extraction_attempts_session ON public.extraction_attempts USING btree (session_epoch);


--
-- Name: idx_extraction_attempts_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_extraction_attempts_type ON public.extraction_attempts USING btree (extraction_type);


--
-- Name: idx_extraction_sessions_epoch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_extraction_sessions_epoch ON public.extraction_sessions USING btree (session_epoch);


--
-- Name: idx_positions_client_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_positions_client_company ON public.positions USING btree (client_company_id);


--
-- Name: idx_positions_confidence; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_positions_confidence ON public.positions USING btree (extraction_confidence DESC);


--
-- Name: idx_positions_job_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_positions_job_type ON public.positions USING btree (job_type);


--
-- Name: idx_positions_recruiter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_positions_recruiter ON public.positions USING btree (recruiter_id);


--
-- Name: idx_positions_remote_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_positions_remote_type ON public.positions USING btree (remote_type);


--
-- Name: idx_positions_salary_range; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_positions_salary_range ON public.positions USING btree (salary_min, salary_max);


--
-- Name: idx_recruiters_company; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recruiters_company ON public.recruiters USING btree (company_id);


--
-- Name: idx_recruiters_confidence; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recruiters_confidence ON public.recruiters USING btree (extraction_confidence DESC);


--
-- Name: idx_recruiters_email_dedup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_recruiters_email_dedup ON public.recruiters USING btree (lower(TRIM(BOTH FROM email))) WHERE ((email IS NOT NULL) AND (email ~~ '%@%.%'::text) AND (length(email) > 5));


--
-- Name: idx_recruiters_interaction_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recruiters_interaction_count ON public.recruiters USING btree (interaction_count DESC);


--
-- Name: email_attachments email_attachments_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_attachments
    ADD CONSTRAINT email_attachments_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id) ON DELETE CASCADE;


--
-- Name: email_hashes email_hashes_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_hashes
    ADD CONSTRAINT email_hashes_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id) ON DELETE CASCADE;


--
-- Name: extraction_attempts extraction_attempts_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_attempts
    ADD CONSTRAINT extraction_attempts_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id) ON DELETE CASCADE;


--
-- Name: extraction_attempts extraction_attempts_session_epoch_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_attempts
    ADD CONSTRAINT extraction_attempts_session_epoch_fkey FOREIGN KEY (session_epoch) REFERENCES public.extraction_sessions(session_epoch);


--
-- Name: extraction_errors extraction_errors_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.extraction_errors
    ADD CONSTRAINT extraction_errors_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id);


--
-- Name: manual_corrections manual_corrections_extraction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.manual_corrections
    ADD CONSTRAINT manual_corrections_extraction_id_fkey FOREIGN KEY (extraction_id) REFERENCES public.structured_extractions(id);


--
-- Name: positions positions_client_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_client_company_id_fkey FOREIGN KEY (client_company_id) REFERENCES public.companies(id) ON DELETE SET NULL;


--
-- Name: positions positions_recruiter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_recruiter_id_fkey FOREIGN KEY (recruiter_id) REFERENCES public.recruiters(id) ON DELETE SET NULL;


--
-- Name: positions positions_recruiting_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_recruiting_company_id_fkey FOREIGN KEY (recruiting_company_id) REFERENCES public.companies(id) ON DELETE SET NULL;


--
-- Name: positions positions_source_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_source_email_id_fkey FOREIGN KEY (source_email_id) REFERENCES public.emails(id);


--
-- Name: recruiters recruiters_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruiters
    ADD CONSTRAINT recruiters_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE SET NULL;


--
-- Name: recruiters recruiters_first_seen_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruiters
    ADD CONSTRAINT recruiters_first_seen_email_id_fkey FOREIGN KEY (first_seen_email_id) REFERENCES public.emails(id);


--
-- Name: recruiters recruiters_last_seen_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recruiters
    ADD CONSTRAINT recruiters_last_seen_email_id_fkey FOREIGN KEY (last_seen_email_id) REFERENCES public.emails(id);


--
-- Name: structured_extractions structured_extractions_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structured_extractions
    ADD CONSTRAINT structured_extractions_email_id_fkey FOREIGN KEY (email_id) REFERENCES public.emails(id);


--
-- PostgreSQL database dump complete
--

\unrestrict RnlmeFBKZf2Wh9S297g2XzxRX6RaT9zWcezpywEERugsD6ymDU1iNsmKeNgdLLe

