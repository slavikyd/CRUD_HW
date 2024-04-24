-- migrate:up
create extension if not exists "uuid-ossp";

create schema api_data;

drop table if exists api_data.conferences, api_data.participants, api_data.conference_to_participant, api_data.performances cascade;

create table api_data.conferences
(
    id         uuid primary key default uuid_generate_v4(),
    title text,
    held_date  date,
    address text
);

create table api_data.participants
(
    id          uuid primary key default uuid_generate_v4(),
    first_name text,
    last_name text,
    birth_date date
);

create table api_data.conference_to_participant
(
    conference_id uuid references api_data.conferences,
    participant_id  uuid references api_data.participants,
    primary key (conference_id, participant_id)
);

create table api_data.performances
(
	id uuid primary key default uuid_generate_v4(),
	title text,
	held_date date,
	theme text,
	conference_id uuid references api_data.conferences
);


insert into api_data.conferences(title, held_date, address)
values ('WYF', '2024.03.01', 'Sochi Sirius'),
       ('Nauka 0+', '2024.10.05', 'Moscow VDNH (ENEA)'),
       ('Youth Scientists Congress', '2024.11.03', 'Sochi Sirius');

insert into api_data.participants (first_name, last_name, birth_date)
values ('Anthony', 'Pots', '1969.11.04'), ('Jimmy', 'Bill-Bob', '1999.12.31'), ('Dmitry', 'Nagiev', '1995.12.27');

insert into api_data.conference_to_participant(conference_id, participant_id)
values
    ((select id from api_data.conferences where title = 'WYF'),
     (select id from api_data.participants where last_name = 'Nagiev')),
    ((select id from api_data.conferences where title = 'WYF'),
     (select id from api_data.participants where last_name = 'Bill-Bob')),
    ((select id from api_data.conferences where title = 'WYF'),
     (select id from api_data.participants where last_name = 'Pots')),
    ((select id from api_data.conferences where title = 'Nauka 0+'),
     (select id from api_data.participants where last_name = 'Pots')),
    ((select id from api_data.conferences where title = 'Nauka 0+'),
     (select id from api_data.participants where last_name = 'Bill-Bob')),
    ((select id from api_data.conferences where title = 'Youth Scientists Congress'),
     (select id from api_data.participants where last_name = 'Pots')),
    ((select id from api_data.conferences where title = 'Youth Scientists Congress'),
     (select id from api_data.participants where last_name = 'Nagiev')),
    ((select id from api_data.conferences where title = 'Youth Scientists Congress'),
     (select id from api_data.participants where last_name = 'Bill-Bob'));

insert into api_data.performances(title, held_date, theme, conference_id)
values
('Pitch session', '2024.10.05', 'Project pithces', (select id from api_data.conferences where title = 'Nauka 0+')),
('Nagiev Lecture', '2024.03.02', 'QA lecture with legendary artist', (select id from api_data.conferences where title = 'WYF')),
('Aeroflot quiz', '2024.03.01', 'Quiz about airplanes and liveries', (select id from api_data.conferences where title = 'WYF')),
('Alexander Pushnoy lecture', '2024.11.03', 'The Man, The Myth, The Legend!', (select id from api_data.conferences where title = 'Youth Scientists Congress'));


    
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


-- migrate:down