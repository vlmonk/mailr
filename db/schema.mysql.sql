CREATE TABLE customers (
  id bigint(20) NOT NULL auto_increment,
  fname varchar(50) default NULL,
  lname varchar(50) default NULL,
  email varchar(100) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE INDEX (email)
) TYPE=MyISAM;

CREATE TABLE filters (
  id bigint(20) NOT NULL auto_increment,
  name varchar(50) default NULL,
  destination_folder varchar(50) default NULL,
  customer_id bigint(20) NOT NULL,
  order_num int default 1,
  PRIMARY KEY (id),
  INDEX (customer_id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) TYPE=MyISAM;

CREATE TABLE expressions (
  id bigint(20) NOT NULL auto_increment,
  field_name varchar(20) default '^Subject' NOT NULL,
  operator varchar(20) default 'contains' NOT NULL,
  expr_value varchar(100) default '' NOT NULL,
  case_sensitive bool default 0,
  filter_id bigint(20) NOT NULL,
  PRIMARY KEY (id),
  INDEX (filter_id),
  FOREIGN KEY (filter_id) REFERENCES filters(id)
) TYPE=MyISAM;

CREATE TABLE `mail_prefs` (
  `id` int(11) NOT NULL auto_increment,
  `mail_type` varchar(10) default 'text/plain',
  `wm_rows` int(11) default '20',
  `customer_id` bigint(20) default NULL,
  `check_external_mail` tinyint(1) default '0',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `customer_id` (`customer_id`)
) TYPE=MyISAM;

CREATE TABLE contacts (
  id bigint(20) NOT NULL auto_increment,
  fname varchar(50) default NULL,
  lname varchar(50) default NULL,
  email varchar(100) default NULL,
  hphone varchar(20) default NULL,
  wphone varchar(20) default NULL,
  mobile varchar(20) default NULL,
  fax varchar(20) default NULL,
  notes text,
  create_date datetime default NULL,
  delete_date datetime default NULL,
  customer_id bigint(20) default NULL,
  PRIMARY KEY  (id),
  INDEX (customer_id),
  INDEX (customer_id, email),
  INDEX (email),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) TYPE=MyISAM;

CREATE TABLE contact_groups (
  id bigint(20) NOT NULL auto_increment,
  name varchar(50) default NULL,
  customer_id bigint(20) default NULL,
  PRIMARY KEY  (id),
  INDEX (customer_id),
  FOREIGN KEY (customer_id) REFERENCES customers(id)
) TYPE=MyISAM;

CREATE TABLE contact_contact_groups (
  contact_id bigint(20) NOT NULL,
  contact_group_id bigint(20) NOT NULL,
  PRIMARY KEY  (contact_id, contact_group_id),
  INDEX (contact_id),
  INDEX (contact_group_id),
  FOREIGN KEY (contact_id) REFERENCES contacts(id),
  FOREIGN KEY (contact_group_id) REFERENCES contact_groups(id)
) TYPE=MyISAM;

-- Mysql Sessions
create table sessions ( 
	id bigint(20) NOT NULL auto_increment, 
	session_id varchar(255), 
	data text, 
	updated_at timestamp, 
	primary key(id), 
	index(session_id)
);

-- Cache
CREATE TABLE imap_messages (
  id bigint(20) NOT NULL auto_increment,
  folder_name varchar(100) NOT NULL,
  username varchar(100) NOT NULL,
  msg_id varchar(100),
  uid bigint(20) NOT NULL,
  `from` varchar(255),
  `from_flat` varchar(255),
  `to` varchar(255),
  `to_flat` varchar(255),
  `subject` varchar(255),
  `content_type` varchar(30),
  `date` timestamp,
  `unread` tinyint(1),
  `size` bigint(20),
  PRIMARY KEY (id),
  INDEX (folder_name, username),
  INDEX (folder_name, username,uid)
) TYPE=MyISAM;