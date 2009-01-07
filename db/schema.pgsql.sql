CREATE TABLE customers (
  id bigserial NOT NULL,
  fname varchar(50) default NULL,
  lname varchar(50) default NULL,
  email varchar(100) NOT NULL,
  PRIMARY KEY (id)
);
CREATE UNIQUE INDEX customers_email_idx ON customers(email);

CREATE TABLE filters (
  id bigserial NOT NULL,
  name varchar(50) default NULL,
  destination_folder varchar(50) default NULL,
  customer_id bigint NOT NULL,
  order_num int default 1,
  PRIMARY KEY (id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
CREATE INDEX filters_customer_id_idx ON filters(customer_id);

CREATE TABLE expressions (
  id bigserial NOT NULL,
  field_name varchar(20) default '^Subject' NOT NULL,
  operator varchar(20) default 'contains' NOT NULL,
  expr_value varchar(100) default '' NOT NULL,
  case_sensitive bool default FALSE,
  filter_id bigint NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (filter_id) REFERENCES filters(id)
);
CREATE INDEX expressions_filter_id_idx ON expressions(filter_id);

CREATE TABLE mail_prefs (
  id serial NOT NULL,
  mail_type varchar(10) default 'text/plain',
  wm_rows int default '20',
  customer_id bigint default NULL,
  check_external_mail bool default false,
  PRIMARY KEY  (id)
);
CREATE UNIQUE INDEX mail_prefs_customer_id_idx ON mail_prefs(customer_id);

CREATE TABLE contacts (
  id bigserial NOT NULL,
  fname varchar(50) default NULL,
  lname varchar(50) default NULL,
  email varchar(100) default NULL,
  hphone varchar(20) default NULL,
  wphone varchar(20) default NULL,
  mobile varchar(20) default NULL,
  fax varchar(20) default NULL,
  notes text,
  create_date timestamp default NULL,
  delete_date timestamp default NULL,
  customer_id bigint default NULL,
  PRIMARY KEY  (id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
CREATE INDEX contacts_customer_id_idx ON contacts(customer_id);
CREATE INDEX contacts_customer_id_email_idx ON contacts(customer_id,email);
CREATE INDEX contacts_email_idx ON contacts(email);


CREATE TABLE contact_groups (
  id bigserial NOT NULL,
  name varchar(50) default NULL,
  customer_id bigint default NULL,
  PRIMARY KEY  (id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);
CREATE INDEX contact_groups_customer_id_idx ON contact_groups(customer_id);

CREATE TABLE contact_contact_groups (
  contact_id bigint NOT NULL,
  contact_group_id bigint NOT NULL,
  PRIMARY KEY  (contact_id, contact_group_id),
  FOREIGN KEY (contact_id) REFERENCES contacts(id),
  FOREIGN KEY (contact_group_id) REFERENCES contact_groups(id)
);
CREATE INDEX contact_contact_groups_contact_id_idx ON contact_contact_groups(contact_id);
CREATE INDEX contact_contact_groups_contact_group_id_idx ON contact_contact_groups(contact_group_id);

create table sessions ( 
	id 			BIGSERIAL NOT NULL,
	session_id 	VARCHAR(255) NULL, 
	data 		TEXT NULL, 
	updated_at 	TIMESTAMP default null, 
	PRIMARY KEY (id)
);
CREATE INDEX session_idx ON sessions(session_id);

CREATE TABLE imap_messages (
  id 			BIGSERIAL NOT NULL,
  folder_name 	        VARCHAR(100) NOT NULL,
  username 		VARCHAR(100) NOT NULL,
  msg_id 	       	VARCHAR(100),
  uid 			BIGINT NOT NULL,
  "from" 	        TEXT,
  "from_flat"           TEXT,
  "to"                  TEXT,
  "to_flat"             TEXT,
  "subject"             TEXT,
  "content_type"        VARCHAR(30),
  "date" 	        TIMESTAMP,
  "unread" 		BOOL default false,
  "size" 		BIGINT,
  PRIMARY KEY (id)
);

CREATE INDEX msg_cache_fu_idx ON imap_messages(folder_name, username);
CREATE INDEX msg_cache_fuui_idx ON imap_messages(folder_name, username, uid);
