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
