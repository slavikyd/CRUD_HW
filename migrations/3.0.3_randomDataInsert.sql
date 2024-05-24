-- migrate:up

insert into api_data.conferences (title, held_date, address)
select md5(random()::text),
timestamp '2024-01-10' + random() * (timestamp '2024-03-20' - timestamp '2024-05-10'), 
md5(random()::text)
from generate_series(1, 1000000);

-- migrate:down