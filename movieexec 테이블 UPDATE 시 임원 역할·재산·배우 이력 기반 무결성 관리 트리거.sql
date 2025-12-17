/*
[Trigger 제목]
movieexec 테이블 UPDATE 시 임원 역할·재산·배우 이력 기반 무결성 관리 트리거

[코드 동작 흐름 설명]
1) movieexec 테이블의 레코드가 UPDATE되기 전에 실행되는 BEFORE UPDATE 트리거이다.
2) 수정 대상 임원이 영화사 사장 또는 영화 제작자인 경우 이름 변경을 허용하지 않는다.
3) networth가 NULL로 변경되면 기존 임원들 중 최대 재산값으로 자동 보정한다.
4) networth가 증가하고 평균 재산보다 큰 경우, 사장·제작자 역할이 없으면 임의의 영화사 사장으로 지정한다.
5) 해당 임원이 배우로 출연한 기록이 있으면 주소 필드에 안내 문구를 추가한다.
6) 이러한 규칙을 통해 임원 정보 변경 시 데이터 일관성과 비즈니스 규칙을 유지한다.
*/

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
