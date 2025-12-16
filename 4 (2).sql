create or replace trigger starplays_trigger
instead of insert on starplays
for each row
declare
    movie_cnt   number;
    star_cnt    number;
    youngest_bd date;
    pick_gen    varchar2(6);
    addr        varchar2(200);
    prod        number;
    prod_cnt    number;
begin
    select count(*) into movie_cnt
    from movie
    where title = :new.title
      and year = :new.year;

    if movie_cnt = 0 then
        select count(*) into prod_cnt
        from movie
        where producerno is not null;

        if prod_cnt > 0 then
            select producerno
              into prod
              from (
                    select producerno
                    from movie
                    where producerno is not null
                    group by producerno
                    order by count(*) desc, dbms_random.value
                   )
             where rownum = 1;
        else
            select certno
              into prod
              from (
                    select certno
                    from movieexec
                    order by dbms_random.value
                   )
             where rownum = 1;
        end if;

        insert into movie(title, year, length, incolor, studioname, producerno)
        values (:new.title, :new.year, null, null, null, prod);
    end if;

    select count(*) into star_cnt
    from moviestar
    where name = :new.name;

    if star_cnt = 0 then
        begin
            select birthdate
              into youngest_bd
              from (
                    select birthdate
                    from moviestar
                    order by birthdate desc
                   )
             where rownum = 1;

            select gender
              into pick_gen
              from (
                    select gender
                    from moviestar
                    where birthdate = youngest_bd
                    order by dbms_random.value
                   )
             where rownum = 1;
        exception
            when no_data_found then
                youngest_bd := null;
                pick_gen := case when dbms_random.value < 0.5 then 'male' else 'female' end;
        end;

        addr := my_package.get_addr('city') || ' ' ||
                my_package.get_addr('gu')   || ' ' ||
                my_package.get_addr('dong');

        insert into moviestar(name, address, gender, birthdate)
        values (:new.name,
                addr,
                pick_gen,
                date '1980-01-01' + trunc(dbms_random.value(0, 365*45)));
    end if;

    insert into starsin(movietitle, movieyear, starname)
    values (:new.title, :new.year, :new.name);
end;
/
