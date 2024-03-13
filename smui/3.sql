# --- !Ups

-- Add tag table.
-- Tags can be assigned to a single solr index or they can be global to all solr indexes (solr_index_id = null).
-- Exported tags must have a property (e.g. "tenant") and a value (e.g. "MO") so that the full tag would be "tenant:MO".
-- Tags that are not exported can have a value only without a property.
--
-- exported: 1 = is exported to querqy
--           0 = is not exported to querqy and only used for tagging purposes in SMUI itself
create table input_tag (
	id varchar(36) not null primary key,
	solr_index_id varchar(36),
	property varchar(1000),
	tag_value varchar(1000) not null,
	exported int not null,
	predefined int not null,
	last_update timestamp not null
);

create unique index input_tag_property_value_index on input_tag (solr_index_id, property (100), tag_value (100));
create index input_tag_predefined_index on input_tag (predefined);

-- Add table tag_2_input

create table tag_2_input (
  tag_id varchar(36) not null,
  input_id varchar(36) not null,
  last_update timestamp not null,
  primary key (tag_id, input_id)
);

create index tag_2_input_input_id_index on tag_2_input (input_id);

# --- !Downs

drop table input_tag;
drop table tag_2_input;
