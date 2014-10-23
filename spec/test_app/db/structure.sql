CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE TABLE "delayed_jobs" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "priority" integer DEFAULT 0 NOT NULL, "attempts" integer DEFAULT 0 NOT NULL, "handler" text NOT NULL, "last_error" text, "run_at" datetime, "locked_at" datetime, "failed_at" datetime, "locked_by" varchar(255), "queue" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE INDEX "delayed_jobs_priority" ON "delayed_jobs" ("priority", "run_at");
CREATE TABLE "mail_manager_bounces" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "message_id" integer, "mailing_id" integer, "status" varchar(255), "status_changed_at" datetime, "bounce_message" text, "comments" text, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "mail_manager_contacts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "contactable_id" integer, "contactable_type" varchar(255), "email_address" varchar(255), "first_name" varchar(255), "last_name" varchar(255), "upated_by" integer, "created_by" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "deleted_at" datetime);
CREATE TABLE "mail_manager_mailables" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255) NOT NULL, "email_html" text, "email_text" text, "reusable" boolean, "updated_by" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "mail_manager_mailing_lists" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "description" text, "status" varchar(255), "status_changed_at" datetime, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "deleted_at" datetime, "defaults_to_active" boolean);
CREATE TABLE "mail_manager_mailing_lists_mail_manager_mailings" ("mailing_id" integer, "mailing_list_id" integer);
CREATE TABLE "mail_manager_mailings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subject" varchar(255), "from_email_address" varchar(255), "mailable_type" varchar(255), "mailable_id" integer, "status" varchar(255), "status_changed_at" datetime, "scheduled_at" datetime, "include_images" boolean, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "mail_manager_messages" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "type" varchar(255), "test_email_address" varchar(255), "subscription_id" integer, "mailing_id" integer, "guid" varchar(255), "status" varchar(255), "status_changed_at" datetime, "result" text, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "contact_id" integer, "from_email_address" varchar(255));
CREATE TABLE "mail_manager_subscriptions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "mailing_list_id" integer, "status" varchar(255), "status_changed_at" datetime, "updated_by" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "contact_id" integer);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "first_name" varchar(255), "last_name" varchar(255), "email" varchar(255), "phone" varchar(255), "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
INSERT INTO schema_migrations (version) VALUES ('20131217101010');

INSERT INTO schema_migrations (version) VALUES ('20131221064151');

INSERT INTO schema_migrations (version) VALUES ('20131221064152');

INSERT INTO schema_migrations (version) VALUES ('20131221064153');

INSERT INTO schema_migrations (version) VALUES ('20131221064154');

INSERT INTO schema_migrations (version) VALUES ('20131221064155');

INSERT INTO schema_migrations (version) VALUES ('20131221064156');

INSERT INTO schema_migrations (version) VALUES ('20131221064157');

INSERT INTO schema_migrations (version) VALUES ('20131221072600');