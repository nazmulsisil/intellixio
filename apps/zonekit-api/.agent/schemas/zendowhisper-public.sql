-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.conversation_assignments (
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  member_id uuid NOT NULL DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL DEFAULT gen_random_uuid(),
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  CONSTRAINT conversation_assignments_pkey PRIMARY KEY (id),
  CONSTRAINT conversation_assignments_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.workspace_members(id),
  CONSTRAINT conversation_assignments_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id)
);
CREATE TABLE public.conversation_summaries (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL UNIQUE,
  message_count integer NOT NULL DEFAULT 0,
  summary text NOT NULL DEFAULT 'not available'::text,
  CONSTRAINT conversation_summaries_pkey PRIMARY KEY (id),
  CONSTRAINT conversation_summaries_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id)
);
CREATE TABLE public.conversations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL,
  current_state text NOT NULL DEFAULT 'AI_ACTIVE'::text CHECK (current_state = ANY (ARRAY['AI_ACTIVE'::text, 'HUMAN_ACTIVE'::text, 'HUMAN_ACTIVE_TAKEOVER'::text, 'AI_PAUSED'::text])),
  has_read boolean NOT NULL DEFAULT false,
  last_received_msg_timestamp timestamp with time zone NOT NULL DEFAULT now(),
  handover_at timestamp with time zone,
  reminder_sent_at timestamp with time zone,
  intent_analysis text,
  buyer_id uuid NOT NULL,
  is_preview boolean NOT NULL DEFAULT false,
  source_id text,
  conditional_prompt_value text,
  CONSTRAINT conversations_pkey PRIMARY KEY (id),
  CONSTRAINT conversations_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public.zw_buyers(id),
  CONSTRAINT conversations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.conversations_tags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL,
  tag_id uuid NOT NULL,
  CONSTRAINT conversations_tags_pkey PRIMARY KEY (id),
  CONSTRAINT conversations_tags_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id),
  CONSTRAINT conversations_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id)
);
CREATE TABLE public.data_deletion (
  id integer NOT NULL DEFAULT nextval('data_deletion_id_seq'::regclass),
  uuid text,
  status text,
  CONSTRAINT data_deletion_pkey PRIMARY KEY (id)
);
CREATE TABLE public.document_chunks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT now(),
  workspace_id uuid,
  document_name text,
  chunk_text text NOT NULL,
  embedding USER-DEFINED,
  metadata jsonb,
  workspace_file_id uuid,
  CONSTRAINT document_chunks_pkey PRIMARY KEY (id),
  CONSTRAINT document_chunks_workspace_file_id_fkey FOREIGN KEY (workspace_file_id) REFERENCES public.workspace_files(id),
  CONSTRAINT document_chunks_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.failed_webhook_log (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  http_status numeric NOT NULL,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  request jsonb NOT NULL,
  response jsonb NOT NULL,
  status USER-DEFINED NOT NULL DEFAULT 'failed'::webhook_retry_status,
  CONSTRAINT failed_webhook_log_pkey PRIMARY KEY (id)
);
CREATE TABLE public.n8n_chat_histories (
  session_id uuid NOT NULL,
  message jsonb NOT NULL,
  timestamp timestamp with time zone DEFAULT now(),
  id uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  is_preview boolean NOT NULL DEFAULT false,
  CONSTRAINT n8n_chat_histories_pkey PRIMARY KEY (id),
  CONSTRAINT n8n_chat_histories_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.conversations(id)
);
CREATE TABLE public.subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL UNIQUE,
  message_count numeric DEFAULT '0'::numeric,
  message_limit numeric DEFAULT '100'::numeric,
  package_type USER-DEFINED,
  gateway_subscription_id text,
  trial_ends_at timestamp with time zone,
  message_quota_status USER-DEFINED NOT NULL DEFAULT 'OK'::message_quota_status,
  seat_limit numeric NOT NULL DEFAULT '1'::numeric CHECK (seat_limit > 0::numeric),
  seat_count numeric NOT NULL DEFAULT '1'::numeric CHECK (seat_count > 0::numeric),
  one_time_addons numeric NOT NULL DEFAULT '0'::numeric CHECK (one_time_addons >= 0::numeric),
  CONSTRAINT subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT subscriptions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.tags (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tag_name text NOT NULL,
  workspace_id uuid NOT NULL,
  CONSTRAINT tags_pkey PRIMARY KEY (id),
  CONSTRAINT tags_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.track_ad_page_email (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  source_id text NOT NULL,
  page_id text NOT NULL,
  email text NOT NULL,
  CONSTRAINT track_ad_page_email_pkey PRIMARY KEY (id)
);
CREATE TABLE public.workspace_conditional_prompts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL DEFAULT gen_random_uuid(),
  prompt text NOT NULL,
  path text NOT NULL,
  value text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT workspace_conditional_prompts_pkey PRIMARY KEY (id),
  CONSTRAINT workspace_conditional_prompts_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.workspace_files (
  workspace_id uuid DEFAULT gen_random_uuid(),
  gdrive_id text,
  file_name text,
  deleted boolean NOT NULL DEFAULT false,
  last_processed timestamp with time zone,
  createdTime timestamp with time zone NOT NULL DEFAULT now(),
  file_type text DEFAULT ''::text,
  modifiedTime timestamp with time zone DEFAULT now(),
  id uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE,
  CONSTRAINT workspace_files_pkey PRIMARY KEY (id),
  CONSTRAINT workspace_files_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.workspace_invitations (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email text NOT NULL,
  workspace_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  expires_at timestamp with time zone NOT NULL,
  token text,
  role USER-DEFINED NOT NULL DEFAULT 'member'::member_role,
  status USER-DEFINED NOT NULL DEFAULT 'pending'::invite_status,
  CONSTRAINT workspace_invitations_pkey PRIMARY KEY (id),
  CONSTRAINT workspace_invitations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.workspace_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  workspace_id uuid NOT NULL,
  email text NOT NULL,
  role USER-DEFINED NOT NULL DEFAULT 'member'::member_role,
  whatsapp_number text CHECK (whatsapp_number <> NULL::text),
  enable_wa_notification boolean NOT NULL DEFAULT false,
  enable_email_notification boolean NOT NULL DEFAULT true,
  CONSTRAINT workspace_members_pkey PRIMARY KEY (id),
  CONSTRAINT workspace_members_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.workspace_prompts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  workspace_id uuid NOT NULL UNIQUE,
  agent_role text,
  agent_type USER-DEFINED DEFAULT 'chatbot_only'::agent_type,
  primary_objective text,
  personality_traits text,
  forbidden_topics text,
  response_length text,
  generated_prompt text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT workspace_prompts_pkey PRIMARY KEY (id),
  CONSTRAINT workspace_prompts_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id)
);
CREATE TABLE public.workspaces (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  onboarding_status USER-DEFINED DEFAULT 'PENDING_PAYMENT'::onboarding_status,
  twilio_subaccount_sid text UNIQUE,
  twilio_auth_token text,
  ai_whatsapp text,
  gdrive_folder_url text,
  workspace_name text NOT NULL,
  d360_api_key text,
  messaging_platform USER-DEFINED NOT NULL DEFAULT '360D'::messaging_service,
  d360_client_id text UNIQUE,
  ai_agent_identity text,
  remaining_setup_steps ARRAY NOT NULL DEFAULT '{}'::text[],
  is_internal boolean NOT NULL DEFAULT false,
  is_zendolead boolean NOT NULL DEFAULT false,
  cloud_api_phone_id text UNIQUE,
  CONSTRAINT workspaces_pkey PRIMARY KEY (id)
);
CREATE TABLE public.zw_buyers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  name text,
  number text UNIQUE,
  source_url text,
  source_id text,
  source_type text,
  ctwa_clid text,
  is_preview boolean NOT NULL DEFAULT false,
  CONSTRAINT zw_buyers_pkey PRIMARY KEY (id)
);
CREATE TABLE public.zw_mql_numbers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  number text NOT NULL,
  conversation_id uuid NOT NULL UNIQUE,
  CONSTRAINT zw_mql_numbers_pkey PRIMARY KEY (id)
);