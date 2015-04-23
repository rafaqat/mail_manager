CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) NOT NULL DEFAULT '0',
  `attempts` int(11) NOT NULL DEFAULT '0',
  `handler` text NOT NULL,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `queue` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mail_manager_bounces` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11) DEFAULT NULL,
  `mailing_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `status_changed_at` datetime DEFAULT NULL,
  `bounce_message` text,
  `comments` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_manager_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contactable_id` int(11) DEFAULT NULL,
  `contactable_type` varchar(255) DEFAULT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `upated_by` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `login_token` varchar(255) DEFAULT NULL,
  `login_token_created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_manager_mailables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email_html` text,
  `email_text` text,
  `reusable` tinyint(1) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_manager_mailing_lists` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `status` varchar(255) DEFAULT NULL,
  `status_changed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `defaults_to_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_manager_mailing_lists_mail_manager_mailings` (
  `mailing_id` int(11) DEFAULT NULL,
  `mailing_list_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mail_manager_mailings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT NULL,
  `from_email_address` varchar(255) DEFAULT NULL,
  `mailable_type` varchar(255) DEFAULT NULL,
  `mailable_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `status_changed_at` datetime DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `include_images` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `bounces_count` int(11) DEFAULT '0',
  `messages_count` int(11) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_manager_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `test_email_address` varchar(255) DEFAULT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  `mailing_id` int(11) DEFAULT NULL,
  `guid` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `status_changed_at` datetime DEFAULT NULL,
  `result` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `contact_id` int(11) DEFAULT NULL,
  `from_email_address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_manager_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mailing_list_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `status_changed_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `contact_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20131217101010');

INSERT INTO schema_migrations (version) VALUES ('20131221064151');

INSERT INTO schema_migrations (version) VALUES ('20131221064152');

INSERT INTO schema_migrations (version) VALUES ('20131221064153');

INSERT INTO schema_migrations (version) VALUES ('20131221064154');

INSERT INTO schema_migrations (version) VALUES ('20131221064155');

INSERT INTO schema_migrations (version) VALUES ('20131221064156');

INSERT INTO schema_migrations (version) VALUES ('20131221064157');

INSERT INTO schema_migrations (version) VALUES ('20131221072600');

INSERT INTO schema_migrations (version) VALUES ('20150420163235');

INSERT INTO schema_migrations (version) VALUES ('20150420163804');

INSERT INTO schema_migrations (version) VALUES ('20150421151457');

INSERT INTO schema_migrations (version) VALUES ('20150423143754');