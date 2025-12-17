/*
[Trigger 제목]
starplays 뷰 INSERT 시 영화·배우 자동 생성 및 출연 관계 등록 트리거

[코드 동작 흐름 설명]
1) starplays 뷰에 INSERT가 발생했을 때 실행되는 INSTEAD OF INSERT 트리거이다.
2) 입력된 영화(title, year)가 실제 movie 테이블에 존재하는지 먼저 확인한다.
3) 영화가 존재하지 않으면, 기존 영화들의 제작자 분포를 기준으로 제작자를 선택해 새 영화를 생성한다.
4) 입력된 배우(name)가 moviestar 테이블에 존재하는지 확인한다.
5) 배우가 없으면 가장 최근 출생 배우의 성별 분포를 참고하거나 난수를 이용해 성별을 결정한다.
6) 주소는 my_package의 함수를 이용해 자동 생성하고, 배우 정보를 moviestar 테이블에 삽입한다.
7) 최종적으로 영화와 배우가 준비된 상태에서 starsin 테이블에 출연 관계를 등록한다.
*/

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
