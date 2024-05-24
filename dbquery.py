"""Consts of queries for database."""
QUERY_GET_CONFS = """
with confs_with_participants as (select
  c.id,
  c.title,
  c.held_date,
  c.address,
  coalesce(jsonb_agg(jsonb_build_object(
    'id', p.id, 'first_name', p.first_name, 'last_name', p.last_name))
      filter (where p.id is not null), '[]') as participants
from api_data.conferences c
left join api_data.conference_to_participant cp on c.id = cp.conference_id
left join api_data.participants p on p.id = cp.participant_id
group by c.id),
confs_with_perfs as (select
	  c.id,
	  c.title,
	  c.held_date,
	  c.address,
	  coalesce(json_agg(json_build_object(
	    'id', pf.id, 'title', pf.title, 'held_date', pf.held_date, 'theme', pf.theme, 'conference_id', pf.conference_id))
	      filter (where pf.id is not null), '[]')
	        as performances
	from api_data.conferences c
	left join api_data.performances pf on c.id = pf.conference_id
	group by c.id)

select cwp.id, cwp.title, cwp.held_date, cwp.address, participants, performances
from confs_with_participants cwp
join confs_with_perfs cwpf on cwp.id = cwpf.id;


"""
QUERY_GET_PARTICS = 'select * from participants'

QUERY_CONFS_CREATE = """
insert into api_data.conferences(title, held_date, address)
values ({title}, {held_date}, {address})
returning id
"""

QUERY_UPDATE_CONFS = """
update api_data.conferences
set
  title = {title},
  held_date = {held_date},
  address = {address}
where id = {id}
returning id

"""

QUERY_DELETE_CONF = 'delete from api_data.conferences where id = {id} returning id'
QUERY_DELETE_CONF_LINKS = 'delete from api_data.conference_to_participant where conference_id = {id}'
FIND_BY_TITLE_QUERY = """
select id, title, held_date, address
from api_data.conferences
where title ilike {title}
"""
FIND_BY_DATE_QUERY = """
select id, title, held_date, address
from api_data.conferences
where held_date = {held_date}
"""