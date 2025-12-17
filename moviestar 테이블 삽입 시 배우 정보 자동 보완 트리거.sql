/*
[Trigger 제목]
moviestar 테이블 삽입 시 배우 정보 자동 보완 트리거

[코드 동작 흐름 설명]
1) moviestar 테이블에 새로운 레코드가 INSERT되기 전에 실행되는 BEFORE INSERT 트리거이다.
2) birthdate가 NULL인 경우, 1980-01-01을 기준으로 약 45년 범위 내의 임의 날짜를 생성하여 설정한다.
3) address가 NULL인 경우, 서울시 내 구·동·번지를 난수로 조합하여 임의의 주소를 생성한다.
4) gender가 NULL인 경우, 해당 배우보다 생년이 늦은 기존 배우들의 성별 분포를 조회한다.
5) 남녀 수가 더 많은 쪽의 성별을 선택하며, 동일한 경우 난수를 이용해 성별을 결정한다.
6) 계산된 birthdate, address, gender 값을 :NEW 레코드에 반영한 후 INSERT를 수행한다.
*/

create or replace trigger star_insert
before insert on moviestar
for each row
declare
    birth    date;
    addr     varchar2(100);
    male_cnt number := 0;
    fem_cnt  number := 0;
    gender   varchar2(100);
begin
    if :new.birthdate is null then
        birth := date '1980-01-01' + trunc(dbms_random.value(0, 365*45));
        :new.birthdate := birth;
    else
        birth := :new.birthdate;
    end if;

    if :new.address is null then
        addr := '서울시 ' ||
                case trunc(dbms_random.value(1, 6))
                    when 1 then '강남구'
                    when 2 then '서초구'
                    when 3 then '송파구'
                    when 4 then '강서구'
                    else '마포구'
                end ||
                ' ' ||
                case trunc(dbms_random.value(1, 6))
                    when 1 then '역삼동'
                    when 2 then '논현동'
                    when 3 then '잠실동'
                    when 4 then '방배동'
                    else '상암동'
                end ||
                ' ' ||
                trunc(dbms_random.value(1, 999)) || '번지';
        :new.address := addr;
    end if;

    if :new.gender is null then
        select count(*)
        into male_cnt
        from moviestar
        where birthdate > birth
          and gender = 'male';

        select count(*)
        into fem_cnt
        from moviestar
        where birthdate > birth
          and gender = 'female';

        if male_cnt > fem_cnt then
            gender := 'male';
        elsif fem_cnt > male_cnt then
            gender := 'female';
        else
            if dbms_random.value < 0.5 then
                gender := 'male';
            else
                gender := 'female';
            end if;
        end if;

        :new.gender := gender;
    end if;
end;
/
