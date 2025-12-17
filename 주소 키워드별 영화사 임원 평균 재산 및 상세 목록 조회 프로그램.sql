/*
[PL/SQL 블록 제목]
주소 키워드별 영화사 임원 평균 재산 및 상세 목록 조회 프로그램

[코드 동작 흐름 설명]
1) 주소 검색에 사용할 키워드 목록을 컬렉션(key_tab)으로 정의하고 초기화한다.
2) 각 키워드에 대해 movieexec 테이블에서 해당 주소를 포함하는 임원들의 평균 재산을 동적 SQL로 계산한다.
3) 평균값이 NULL인 경우 해당 키워드에 대한 정보가 없음을 출력한다.
4) 평균값이 존재하면 동일한 조건의 동적 SQL을 이용해 REF CURSOR를 OPEN하여 상세 목록을 조회한다.
5) REF CURSOR를 이용해 조회 결과를 한 행씩 FETCH하며 번호를 매겨 출력한다.
6) 모든 키워드에 대해 위 과정을 반복한 후 PL/SQL 블록을 종료한다.
*/

declare
    type key_tab is table of varchar2(50);
    keywords key_tab := key_tab('uk','_','california','zzz','new york','texas','chicago');

    type refcur is ref cursor;
    cur refcur;

    name movieexec.name%type;
    addr movieexec.address%type;
    worth movieexec.networth%type;

    result varchar2(500);
    avg_sql varchar2(500);
    avg_val number;
    n integer := 1;
begin
    for i in 1..keywords.count loop
        avg_sql := 'select avg(networth) from movieexec '||
                   'where lower(address) like ''%''||lower(:kw)||''%''';
        execute immediate avg_sql into avg_val using keywords(i);

        if avg_val is null then
            dbms_output.put_line('['||i||'] '||keywords(i)||' 가 주소에 있는 임원들: 해당정보없음.');
        else
            dbms_output.put_line('['||i||'] '||keywords(i)||' 가 주소에 있는 임원들: 평균재산액수-'
                || to_char(avg_val, '999,999,999,999.00') || '원');

        result := 'select name, address, networth from movieexec '||
                    'where lower(address) like ''%''||lower(:kw)||''%''';

            open cur for result using keywords(i);
            n := 1;
            loop
                fetch cur into name, addr, worth;
                exit when cur%notfound;
                dbms_output.put_line('('||n||') '||name||'('||addr||'에 거주) : 재산 : '
                    || to_char(worth, '999,999,999,999.00') || '원');
                n := n + 1;
        end loop;
            close cur;
    end if;
    end loop;
end;
/
