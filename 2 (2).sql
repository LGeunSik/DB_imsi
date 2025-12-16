create or replace trigger exec_update
before update on movieexec
for each row
declare
    is_pres   number;
    is_prod   number;
    avgworth  number;
    maxworth  number;
    actor_cnt number;
    pick      varchar2(100);
begin
    select count(*) into is_pres
    from studio
    where presno = :old.certno;

    select count(*) into is_prod
    from movie
    where producerno = :old.certno;

    if :old.name <> :new.name then
        if is_pres > 0 or is_prod > 0 then
            :new.name := :old.name;
        end if;
    end if;

    if :new.networth is null then
        select max(networth) into maxworth
        from movieexec;
        :new.networth := maxworth;
    end if;

    if :new.networth > :old.networth then
        select avg(networth) into avgworth
        from movieexec;

        if is_pres = 0 and is_prod = 0 then
            if :new.networth > avgworth then
                select name
                  into pick
                  from (
                        select name
                        from studio
                        order by dbms_random.value
                       )
                 where rownum = 1;

                update studio
                   set presno = :old.certno
                 where name = pick;
            end if;
        end if;
    end if;

    select count(*) into actor_cnt
    from starsin
    where starname = :old.name;

    if actor_cnt > 0 then
        :new.address := '[' || :old.address || ']에 배우가 삽니다!';
    end if;
end;
/
