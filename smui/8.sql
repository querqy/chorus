# --- !Ups

-- Ensure that we do not allow duplicate solr indexes with same name.
create unique index solr_index_field_name on solr_index (name (500));

-- Ensure that we do not allow duplicate suggested solr fields for the same solr index.
create unique index suggested_solr_field_name_solr_index on suggested_solr_field (solr_index_id, name (500));



# --- !Downs

drop index solr_index_field_name
drop index suggested_solr_field_name_solr_index;
