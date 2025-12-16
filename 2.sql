
declare
    type s_ty is table of varchar2(30);
    movies movie_tab := movie_tab();
    studios studio_tab := studio_tab();
    name varchar2(30);
    address varchar2(255);
    networth number(20);
    i integer;
    j integer;
    cursor exec_cur is select name, address, networth, certno from MovieExec;
begin
    for e in exec_cur loop
        name := e.name;
        address := e.address;
        networth := e.networth;
        movies.delete;
        for m in (select title, year from Movie where producerno = e.certno) loop
            movies.extend;
            movies(movies.last) := movie_ty(
                m.title,
                m.year,
                to_date(trunc(dbms_random.value(to_number(to_char(to_date('1900','YYYY'),'J'))
                , to_number(to_char(to_date(m.year||'-01-01','YYYY-MM-DD'),'J')))), 'J'),
                trunc(dbms_random.value(1000000, 100000000))
            );
        end loop;
        studios.delete;
        for s in (select name from Studio where presno = e.certno) loop
            studios.extend;
            studios(studios.last) := studio_ty(
                s.name,
                trunc(dbms_random.value(50, 5000))
            );
        end loop;
        insert into MovieExecInfo values(name, address, networth, movies, studios);

        dbms_output.put_line('임원 ' || name || ' 등록 완료 (' || movies.count || '편 영화, '
        || studios.count || '개 영화사)');
    end loop;

commit;
exception
    when others then
        dbms_output.put_line('오류 발생: ' || sqlerrm);
end;
/
