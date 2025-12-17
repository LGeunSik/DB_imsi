/*
[PL/SQL 블록 제목]
영화사 임원별 영화·영화사 정보 객체화 및 MovieExecInfo 테이블 삽입 프로그램

[코드 동작 흐름 설명]
1) MovieExec 테이블의 모든 임원을 커서(exec_cur)를 통해 하나씩 순회한다.
2) 각 임원의 기본 정보(이름, 주소, 재산)를 변수에 저장한다.
3) 해당 임원이 제작한 영화들을 조회하여 movie_tab 컬렉션에 객체(movie_ty) 형태로 저장한다.
4) 영화 정보에는 제목, 연도, 임의의 날짜, 임의의 제작비를 포함한다.
5) 해당 임원이 사장으로 있는 영화사를 조회하여 studio_tab 컬렉션에 객체(studio_ty) 형태로 저장한다.
6) 임원 정보와 함께 영화·영화사 컬렉션을 MovieExecInfo 테이블에 한 행으로 INSERT한다.
7) 각 임원 처리 결과를 출력하고, 모든 작업 완료 후 COMMIT을 수행한다.
8) 예외 발생 시 오류 메시지를 출력한다.
*/

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

