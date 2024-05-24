-- migrate:up

create index date_conference_idx on api_data.conferences using btree(held_date, address);
create extension pg_trgm;
create index conf_title_idx on api_data.conferences using gist(title gist_trgm_ops);

-- migrate:down