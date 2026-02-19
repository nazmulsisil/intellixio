-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE zendolead.buyer_consents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  business_name text,
  consent_scope USER-DEFINED NOT NULL,
  consent_status USER-DEFINED NOT NULL,
  message_text text,
  message_id text,
  last_user_message_timestamp timestamp with time zone,
  source_id text,
  page_id text,
  ctwa_id text,
  revoked_at timestamp with time zone,
  conversation_id uuid,
  consent_asking text,
  category_id uuid NOT NULL,
  deleted_category_name text,
  deleted_buyer_id text,
  buyer_id uuid NOT NULL,
  seller_id uuid,
  workspace_id uuid,
  CONSTRAINT buyer_consents_pkey PRIMARY KEY (id),
  CONSTRAINT buyer_consents_category_id_fkey FOREIGN KEY (category_id) REFERENCES zendolead.product_categories(id)
);
CREATE TABLE zendolead.buyer_contact_methods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  buyer_id uuid NOT NULL,
  type USER-DEFINED NOT NULL,
  value text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT buyer_contact_methods_pkey PRIMARY KEY (id),
  CONSTRAINT buyer_contact_methods_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES zendolead.buyers(id)
);
CREATE TABLE zendolead.buyer_requirements (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  bedrooms numeric NOT NULL,
  min_price numeric NOT NULL,
  max_price numeric NOT NULL,
  location ARRAY NOT NULL,
  property_type text,
  payment_method text,
  floor numeric,
  bathrooms numeric,
  parking_space boolean,
  condition text,
  facing text,
  timeline text,
  government_gas_line boolean,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  buyer_id uuid NOT NULL,
  optional_requirement_count numeric NOT NULL DEFAULT '0'::numeric,
  query text NOT NULL,
  query_embeddings USER-DEFINED NOT NULL,
  min_area numeric NOT NULL,
  max_area numeric NOT NULL,
  is_verified boolean NOT NULL DEFAULT false,
  CONSTRAINT buyer_requirements_pkey PRIMARY KEY (id),
  CONSTRAINT buyer_requirements_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES zendolead.buyers(id)
);
CREATE TABLE zendolead.buyers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  buyer_source text,
  pain_point text,
  name text,
  gender text,
  age text,
  income_level text,
  occupation text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  match_with_test_products boolean NOT NULL DEFAULT false,
  CONSTRAINT buyers_pkey PRIMARY KEY (id)
);
CREATE TABLE zendolead.category_attributes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  category_id uuid NOT NULL,
  name text NOT NULL,
  data_type text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  description text,
  is_required boolean NOT NULL DEFAULT false,
  allowed_values jsonb,
  used_for_dedup boolean NOT NULL DEFAULT false,
  CONSTRAINT category_attributes_pkey PRIMARY KEY (id),
  CONSTRAINT category_attributes_category_id_fkey FOREIGN KEY (category_id) REFERENCES zendolead.product_categories(id)
);
CREATE TABLE zendolead.consent_ledgers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  buyer_id uuid NOT NULL,
  buyer_number text NOT NULL,
  seller_id uuid NOT NULL,
  prior_consent_id uuid,
  event_type USER-DEFINED NOT NULL,
  consent_snapshot jsonb NOT NULL,
  consent_hash text NOT NULL,
  ip_address inet,
  user_agent text,
  source text NOT NULL DEFAULT 'web'::text,
  locale text NOT NULL DEFAULT 'en'::text,
  version text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT consent_ledgers_pkey PRIMARY KEY (id)
);
CREATE TABLE zendolead.consent_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  buyer_id uuid NOT NULL,
  event_type USER-DEFINED NOT NULL DEFAULT 'asked'::consent_log_event,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL,
  CONSTRAINT consent_logs_pkey PRIMARY KEY (id),
  CONSTRAINT consent_logs_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES zendolead.buyers(id),
  CONSTRAINT consent_logs_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE zendolead.forced_match_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  match_count numeric NOT NULL DEFAULT '0'::numeric,
  seller_id uuid NOT NULL DEFAULT gen_random_uuid(),
  status text NOT NULL DEFAULT 'started'::text,
  updated_at timestamp with time zone,
  execution_id text,
  CONSTRAINT forced_match_logs_pkey PRIMARY KEY (id),
  CONSTRAINT forced_match_logs_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.internal_emails (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  email text NOT NULL UNIQUE,
  status USER-DEFINED DEFAULT 'ACTIVE'::zendolead.internal_email_status,
  sends_remaining numeric DEFAULT '0'::numeric,
  CONSTRAINT internal_emails_pkey PRIMARY KEY (id)
);
CREATE TABLE zendolead.lead_geo (
  lead_id uuid NOT NULL,
  region_key text NOT NULL,
  location_text_raw text,
  location_zone_id uuid,
  location_zone_candidates ARRAY NOT NULL DEFAULT '{}'::uuid[],
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT lead_geo_pkey PRIMARY KEY (lead_id),
  CONSTRAINT lead_geo_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES zendolead.leads(id)
);
CREATE TABLE zendolead.lead_offers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  lead_id uuid NOT NULL,
  product_id uuid NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'notified'::lead_offer_status,
  unlocked_at timestamp with time zone,
  revoked_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  consent_id uuid,
  to_del_refunded boolean NOT NULL DEFAULT false,
  requirement_summary text,
  match_metrics jsonb,
  CONSTRAINT lead_offers_pkey PRIMARY KEY (id),
  CONSTRAINT lead_offers_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES zendolead.leads(id),
  CONSTRAINT lead_offers_product_id_fkey FOREIGN KEY (product_id) REFERENCES zendolead.products(id),
  CONSTRAINT lead_offers_consent_id_fkey FOREIGN KEY (consent_id) REFERENCES zendolead.buyer_consents(id)
);
CREATE TABLE zendolead.leads (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  buyer_id uuid NOT NULL,
  category_id uuid NOT NULL,
  conversation_id uuid,
  status USER-DEFINED NOT NULL DEFAULT 'open'::lead_status,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  requirement_summary text,
  CONSTRAINT leads_pkey PRIMARY KEY (id),
  CONSTRAINT leads_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES zendolead.buyers(id),
  CONSTRAINT leads_category_id_fkey FOREIGN KEY (category_id) REFERENCES zendolead.product_categories(id),
  CONSTRAINT leads_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id)
);
CREATE TABLE zendolead.locations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  coordinate USER-DEFINED NOT NULL,
  map_link text NOT NULL,
  name text NOT NULL UNIQUE,
  lat double precision DEFAULT st_y((coordinate)::geometry) CHECK (lat >= '-90'::integer::double precision AND lat <= 90::double precision),
  lng double precision DEFAULT st_x((coordinate)::geometry) CHECK (lng >= '-180'::integer::double precision AND lng <= 180::double precision),
  CONSTRAINT locations_pkey PRIMARY KEY (id)
);
CREATE TABLE zendolead.outreach_stats (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  seller_id uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  emails numeric NOT NULL DEFAULT '0'::numeric,
  texts numeric NOT NULL DEFAULT '0'::numeric,
  unlocks numeric NOT NULL DEFAULT '0'::numeric,
  CONSTRAINT outreach_stats_pkey PRIMARY KEY (id),
  CONSTRAINT outreach_stats_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.payment_after_effect (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  seller_id uuid NOT NULL,
  credits numeric NOT NULL,
  reason USER-DEFINED NOT NULL,
  lead_offer_id uuid,
  amount_paid numeric,
  method USER-DEFINED,
  transaction_ref text,
  description text,
  CONSTRAINT payment_after_effect_pkey PRIMARY KEY (id),
  CONSTRAINT payment_after_effect_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id),
  CONSTRAINT payment_after_effect_lead_offer_id_fkey FOREIGN KEY (lead_offer_id) REFERENCES zendolead.lead_offers(id)
);
CREATE TABLE zendolead.product_assignments (
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  member_id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL DEFAULT gen_random_uuid(),
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT product_assignments_pkey PRIMARY KEY (id),
  CONSTRAINT product_assignments_product_id_fkey FOREIGN KEY (product_id) REFERENCES zendolead.products(id),
  CONSTRAINT product_assignments_member_id_fkey FOREIGN KEY (member_id) REFERENCES zendolead.seller_members(id)
);
CREATE TABLE zendolead.product_attribute_values (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL,
  attribute_id uuid NOT NULL,
  value_number numeric,
  value_text text,
  value_coordinate USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  value_bool boolean,
  CONSTRAINT product_attribute_values_pkey PRIMARY KEY (id),
  CONSTRAINT product_attribute_values_product_id_fkey FOREIGN KEY (product_id) REFERENCES zendolead.products(id),
  CONSTRAINT product_attribute_values_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES zendolead.category_attributes(id)
);
CREATE TABLE zendolead.product_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  name text NOT NULL UNIQUE,
  details text,
  category_status USER-DEFINED NOT NULL DEFAULT 'ACTIVE'::category_status,
  naming_prompt text,
  CONSTRAINT product_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE zendolead.product_data_chunks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  text text,
  metadata jsonb,
  product_id uuid NOT NULL,
  seller_id uuid NOT NULL,
  embedding USER-DEFINED,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT product_data_chunks_pkey PRIMARY KEY (id),
  CONSTRAINT product_data_chunks_product_id_fkey FOREIGN KEY (product_id) REFERENCES zendolead.products(id),
  CONSTRAINT product_data_chunks_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.product_data_embedding_failed (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  last_failed_at timestamp with time zone NOT NULL DEFAULT now(),
  product_id uuid NOT NULL UNIQUE,
  CONSTRAINT product_data_embedding_failed_pkey PRIMARY KEY (id),
  CONSTRAINT product_data_embedding_failed_product_id_fkey FOREIGN KEY (product_id) REFERENCES zendolead.products(id)
);
CREATE TABLE zendolead.product_geo (
  product_id uuid NOT NULL,
  geom USER-DEFINED,
  zone_ids ARRAY NOT NULL DEFAULT '{}'::uuid[],
  leaf_zone_id uuid,
  zone_fallback boolean NOT NULL DEFAULT false,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT product_geo_pkey PRIMARY KEY (product_id),
  CONSTRAINT product_geo_product_id_fkey FOREIGN KEY (product_id) REFERENCES zendolead.products(id)
);
CREATE TABLE zendolead.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  seller_id uuid NOT NULL,
  purchase_location text,
  product_name text,
  price_range text,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  product_url text,
  category_id uuid NOT NULL,
  fingerprint text,
  is_indexable boolean DEFAULT false,
  ai_attributes_verified boolean NOT NULL DEFAULT false,
  ai_location_verified boolean NOT NULL DEFAULT false,
  seller_paused boolean NOT NULL DEFAULT false,
  admin_paused boolean NOT NULL DEFAULT false,
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id),
  CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES zendolead.product_categories(id)
);
CREATE TABLE zendolead.refund_requests (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  seller_id uuid NOT NULL,
  lead_offer_id uuid NOT NULL,
  reason text NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::zendolead.refund_request_status,
  attachments jsonb CHECK (attachments IS NULL OR jsonb_typeof(attachments) = 'array'::text),
  admin_comment text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  requested_by uuid,
  CONSTRAINT refund_requests_pkey PRIMARY KEY (id),
  CONSTRAINT refund_requests_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id),
  CONSTRAINT refund_requests_lead_offer_id_fkey FOREIGN KEY (lead_offer_id) REFERENCES zendolead.lead_offers(id),
  CONSTRAINT fk_refund_requests_requested_by FOREIGN KEY (requested_by) REFERENCES zendolead.seller_members(id)
);
CREATE TABLE zendolead.scheduled_task_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  task_id text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  scheduled_at timestamp with time zone,
  lead_id uuid NOT NULL UNIQUE,
  status text,
  CONSTRAINT scheduled_task_logs_pkey PRIMARY KEY (id),
  CONSTRAINT scheduled_task_logs_lead_id_fkey FOREIGN KEY (lead_id) REFERENCES zendolead.leads(id)
);
CREATE TABLE zendolead.seller_contact_methods (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  seller_contact_id uuid NOT NULL,
  type USER-DEFINED NOT NULL,
  value text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  seller_id uuid NOT NULL,
  outreach_timestamps ARRAY NOT NULL DEFAULT '{}'::timestamp with time zone[],
  CONSTRAINT seller_contact_methods_pkey PRIMARY KEY (id),
  CONSTRAINT seller_contact_methods_seller_contact_id_fkey FOREIGN KEY (seller_contact_id) REFERENCES zendolead.seller_contacts(id),
  CONSTRAINT seller_contact_methods_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.seller_contacts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  seller_id uuid NOT NULL,
  name text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT seller_contacts_pkey PRIMARY KEY (id),
  CONSTRAINT seller_contacts_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.seller_credits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  seller_id uuid NOT NULL UNIQUE,
  credits numeric NOT NULL DEFAULT '0'::numeric,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  seat_limit numeric NOT NULL DEFAULT '10'::numeric,
  seat_count numeric NOT NULL DEFAULT '1'::numeric,
  active_lead_limit numeric NOT NULL DEFAULT '2'::numeric,
  lead_count numeric NOT NULL DEFAULT '0'::numeric,
  CONSTRAINT seller_credits_pkey PRIMARY KEY (id),
  CONSTRAINT seller_credits_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.seller_member_invitations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email text NOT NULL,
  seller_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  expires_at timestamp with time zone NOT NULL,
  token text,
  role USER-DEFINED NOT NULL DEFAULT 'member'::member_role,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::invite_status,
  CONSTRAINT seller_member_invitations_pkey PRIMARY KEY (id),
  CONSTRAINT seller_member_invitations_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.seller_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  seller_id uuid NOT NULL,
  email text NOT NULL,
  role USER-DEFINED NOT NULL DEFAULT 'member'::member_role,
  whatsapp_number text CHECK (whatsapp_number <> NULL::text),
  enable_wa_notification boolean NOT NULL DEFAULT false,
  enable_email_notification boolean NOT NULL DEFAULT true,
  CONSTRAINT seller_members_pkey PRIMARY KEY (id),
  CONSTRAINT seller_members_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.seller_outreach_events (
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  internal_email_id uuid NOT NULL,
  seller_id uuid NOT NULL,
  outreach_remaining numeric NOT NULL DEFAULT '4'::numeric CHECK (outreach_remaining >= 0::numeric),
  sent_at timestamp with time zone NOT NULL DEFAULT now(),
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT seller_outreach_events_pkey PRIMARY KEY (id),
  CONSTRAINT seller_outreach_events_internal_email_id_fkey FOREIGN KEY (internal_email_id) REFERENCES zendolead.internal_emails(id),
  CONSTRAINT seller_outreach_events_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES zendolead.sellers(id)
);
CREATE TABLE zendolead.sellers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  brand_name text NOT NULL,
  company_size text,
  country text,
  websites ARRAY,
  industry text,
  fb_page_url text,
  brand_positioning text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  primary_website text UNIQUE,
  affiliated boolean NOT NULL DEFAULT false,
  category_id uuid NOT NULL,
  is_test boolean NOT NULL DEFAULT false,
  CONSTRAINT sellers_pkey PRIMARY KEY (id),
  CONSTRAINT sellers_category_id_fkey FOREIGN KEY (category_id) REFERENCES zendolead.product_categories(id)
);
CREATE TABLE zendolead.workspace_category_join (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  category_id uuid NOT NULL DEFAULT gen_random_uuid(),
  is_test boolean NOT NULL DEFAULT false,
  CONSTRAINT workspace_category_join_pkey PRIMARY KEY (id),
  CONSTRAINT workspace_category_join_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id),
  CONSTRAINT workspace_category_join_category_id_fkey FOREIGN KEY (category_id) REFERENCES zendolead.product_categories(id)
);
CREATE TABLE zendolead.zones (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  normalized text NOT NULL,
  synonyms ARRAY NOT NULL DEFAULT '{}'::text[],
  country_code text NOT NULL,
  region_key text NOT NULL,
  admin_level integer NOT NULL,
  source text NOT NULL,
  source_version text NOT NULL DEFAULT ''::text,
  source_feature_id text NOT NULL,
  source_props jsonb NOT NULL DEFAULT '{}'::jsonb,
  boundary USER-DEFINED NOT NULL,
  area_m2 double precision NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT zones_pkey PRIMARY KEY (id)
);