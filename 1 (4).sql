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
