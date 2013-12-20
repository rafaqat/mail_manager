CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE TABLE "mailing_lists" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "description" text, "status" varchar(255), "status_changed_at" datetime, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "deleted_at" datetime, "defaults_to_active" boolean);
CREATE TABLE "mailings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "subject" varchar(255), "from_email_address" varchar(255), "mailable_type" varchar(255), "mailable_id" integer, "status" varchar(255), "status_changed_at" datetime, "scheduled_at" datetime, "include_images" boolean, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "mailing_lists_mailings" ("mailing_id" integer, "mailing_list_id" integer);
CREATE TABLE "messages" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "type" varchar(255), "test_email_address" varchar(255), "subscription_id" integer, "mailing_id" integer, "guid" varchar(255), "status" varchar(255), "status_changed_at" datetime, "result" text, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "contact_id" integer, "from_email_address" varchar(255));
CREATE TABLE "bounces" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "message_id" integer, "mailing_id" integer, "status" varchar(255), "status_changed_at" datetime, "bounce_message" text, "comments" text, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "mailables" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255) NOT NULL, "email_html" text, "email_text" text, "reusable" boolean, "updated_by" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "contacts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "contactable_id" integer, "contactable_type" varchar(255), "email_address" varchar(255), "first_name" varchar(255), "last_name" varchar(255), "upated_by" integer, "created_by" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "deleted_at" datetime);
CREATE TABLE "subscriptions" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "mailing_list_id" integer, "status" varchar(255), "status_changed_at" datetime, "updated_by" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "contact_id" integer);
INSERT INTO schema_migrations (version) VALUES ('20131220180915');

INSERT INTO schema_migrations (version) VALUES ('20131220180916');

INSERT INTO schema_migrations (version) VALUES ('20131220180917');

INSERT INTO schema_migrations (version) VALUES ('20131220180918');

INSERT INTO schema_migrations (version) VALUES ('20131220180919');

INSERT INTO schema_migrations (version) VALUES ('20131220180920');

INSERT INTO schema_migrations (version) VALUES ('20131220180921');