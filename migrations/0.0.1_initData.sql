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



-- migrate:down