/*
[PL/SQL 블록 제목]
영화사·영화·배우 정보 랜덤 생성 및 StudioInfo 테이블 삽입 프로그램

[코드 동작 흐름 설명]
1) 영화사 이름과 영화 제목 후보를 컬렉션(s_ty)으로 정의하고 초기화한다.
2) 각 영화사에 대해 이름, 주소, 사장 이름을 난수를 이용해 생성한다.
3) 각 영화사마다 임의 개수의 영화를 생성하여 영화 제목, 연도, 제작비, 제작자 정보를 컬렉션에 저장한다.
4) MovieStar 테이블에서 난수 기반으로 배우를 선택하여 출연 배우 목록을 생성한다.
5) 생성된 영화 목록과 배우 목록을 포함한 정보를 StudioInfo 테이블에 한 행으로 INSERT한다.
6) 각 영화사 등록 완료 시 처리 결과를 출력하고, 모든 작업이 끝난 후 COMMIT을 수행한다.
7) 다중 행 예외 및 기타 예외 발생 시 적절한 오류 메시지를 출력한다.
*/

declare
    type s_ty is table of varchar2(30);
    studio_names s_ty := s_ty('FOX', 'MGM', 'DISNEY', 'WARNER', 'MARVEL');
    movie_titles s_ty := s_ty('catch me if you can', 'lala land', 'undertale', 'five night at freddy',
    'life of pie', 'just of two', 'final dance');

    name varchar2(30);
    address varchar2(255);
    president varchar2(30);
    movies movie_tab := movie_tab();
    stars star_tab := star_tab();
    i integer;
    j integer;
    cursor star_cur is select name from MovieStar 
    order by dbms_random.value;
    too_many exception;
    pragma exception_init(too_many, -1422);
begin
    for i in studio_names.first .. studio_names.last loop
        name := studio_names(i);
        address := dbms_random.string('U', 5) || ' Street, Seoul';
        president := 'PRES_' || substr(name, 1, 3);
        movies.delete;
        for j in 1 .. trunc(dbms_random.value(3, 6)) loop
         movies.extend;
         movies(j) := mv_ty(
                movie_titles(trunc(dbms_random.value(1, movie_titles.last+1))),
                trunc(dbms_random.value(1990, 2025)),
                trunc(dbms_random.value(1000000, 50000000)),
                'Prod_' || to_char(j) || '_' || substr(name,1,2)
            );
        end loop;
        stars.delete;
        declare
            star_count integer := trunc(dbms_random.value(5, 12));
            idx integer := 0;
        begin
            for s in (select name from (select name from MovieStar order by dbms_random.value) where rownum <= star_count)
            loop
               idx := idx + 1;
               stars.extend;
          stars(idx) := star_ty(
                    s.name,
                       trunc(dbms_random.value(1000, 100000)),
                    trunc(dbms_random.value(1, 11))
                );
         end loop;
        end;

        insert into StudioInfo values(name, address, president, movies, stars);
        dbms_output.put_line('영화사 ' || name || ' 등록 완료 (' || stars.count || '명 배우, ' || movies.count || '편 영화)');
    end loop;

    commit;
exception
    when too_many then
        dbms_output.put_line('다중 행 예외 발생');
    when others then
        dbms_output.put_line('오류 발생: ' || sqlerrm);
end;
/

