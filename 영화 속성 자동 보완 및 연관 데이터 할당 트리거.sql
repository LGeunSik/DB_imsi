/*
[Trigger 제목]
movie 테이블 INSERT 시 영화 속성 자동 보완 및 연관 데이터 할당 트리거

[코드 동작 흐름 설명]
1) movie 테이블에 새로운 레코드가 INSERT되기 전에 실행되는 BEFORE INSERT 트리거이다.
2) 상영시간(length)이 NULL인 경우, 기존 영화들의 평균 상영시간을 계산해 자동으로 설정한다.
3) incolor 값이 NULL이면 기본값으로 'true'를 설정한다.
4) studioname이 NULL인 경우, 기존 영화가 가장 적은 영화사를 선택해 균형 있게 배정한다.
5) 아직 영화 데이터가 하나도 없는 경우에는 studio 테이블에서 임의의 영화사를 선택한다.
6) producerno가 NULL이면 movieexec 테이블에서 임의의 제작자를 선택해 자동 할당한다.
7) 이를 통해 영화 삽입 시 필수 속성과 연관 정보가 누락되지 않도록 보장한다.
*/

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
