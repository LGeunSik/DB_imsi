create or replace trigger movie_insert
before insert on movie
for each row
declare
    avg_len   number;
    pick_stu  varchar2(100);
    min_cnt   number;
    prod      number;
    movie_cnt number;
begin
    if :new.length is null then
        select avg(length) into avg_len
        from movie;
        :new.length := trunc(avg_len);
    end if;

    if :new.incolor is null then
        :new.incolor := 'true';
    end if;

    if :new.studioname is null then
        select count(*) into movie_cnt
        from movie;

        if movie_cnt > 0 then
            select min(cnt)
              into min_cnt
              from (
                    select studioname as s, count(*) as cnt
                    from movie
                    group by studioname
                   );

            select studioname
              into pick_stu
              from (
                    select studioname
                    from movie
                    group by studioname
                    having count(*) = min_cnt
                    order by dbms_random.value
                   )
             where rownum = 1;

            :new.studioname := pick_stu;
        else
            select name
              into pick_stu
              from (select name from studio order by dbms_random.value)
             where rownum = 1;

            :new.studioname := pick_stu;
        end if;
    end if;

    if :new.producerno is null then
        select certno
          into prod
          from (
                select certno
                from movieexec
                order by dbms_random.value
               )
         where rownum = 1;

        :new.producerno := prod;
    end if;
end;
/
