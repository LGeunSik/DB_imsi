/*
[PL/SQL 실습 제목]
제약조건 위반 상황 테스트 및 예외 처리 실습 프로그램

[코드 동작 흐름 설명]
1) test, temp 테이블을 삭제 후 재생성하여 기본 키, CHECK, 외래키 제약조건을 설정한다.
2) 초기 데이터를 test와 temp 테이블에 삽입하여 참조 관계를 만든다.
3) 여러 개의 이름과 나이 값을 컬렉션으로 준비하여 반복 삽입을 시도한다.
4) 동적 SQL을 사용해 test와 temp 테이블에 데이터를 삽입하고, 특정 조건에서 DELETE 및 UPDATE를 수행한다.
5) 중복 키, NULL 값, CHECK 제약조건, 외래키 제약조건 위반을 각각 예외로 처리한다.
6) 각 예외 발생 시 인덱스 번호와 함께 원인을 출력한다.
7) 모든 처리가 끝난 후 test와 temp 테이블의 최종 데이터를 출력하여 결과를 확인한다.
*/

drop table temp cascade constraints
/
drop table test cascade constraints
/
create table test (
    name    varchar(100) primary key,
    age     number(3) not null,
    address varchar(200),
    check(age > 10 and age < 110)
)
/
create table temp (
    num     number(3) primary key,
    name    varchar(100) references test(name)
)
/
insert into test values ('H0', 23, '부산시 남구');
insert into temp values (0, 'H0');

declare
    type    n_type is table of test.name%type;
    type    a_type is table of test.age%type;
    test_n   n_type := n_type('H1', 'H2', 'H3', 'H3', 'H4');
    test_a   a_type := a_type(30, NULL, 28, 40, 5);
    temp_n  n_type := n_type();
    
    sql_str     varchar(200) := 'insert into test values (:1, :2, :3)';
    sql_str1     varchar(200) := 'insert into temp values (:1, :2)';

    dup_val exception;
    null_val exception;
    check_err exception;
    fk_err exception;

    pragma exception_init(dup_val, -00001);
    pragma exception_init(null_val, -01400);
    pragma exception_init(check_err, -02290);
    pragma exception_init(fk_err, -02291);
begin
    temp_n := test_n;
    for i in test_n.first..test_n.last loop
        begin
            execute immediate sql_str using test_n(i), test_a(i), 
            dbms_random.string('x',5)||' '||dbms_random.string('a',10);
            execute immediate sql_str1 using i, temp_n(i);
            if i = test_n.first then
                delete from test
                where name = test_n(i);
            elsif i = 3 then
                update temp
                set name = 'H5'
                where num = 3;
            end if;
        exception
            when dup_val then
                dbms_output.put_line(i||' : 중복된 값 삽입 오류');
            when null_val then
                dbms_output.put_line(i||' : NULL 값 삽입 오류');
            when check_err then
                dbms_output.put_line(i||' : CHECK 제약조건 위반');
            when fk_err then
                dbms_output.put_line(i||' : 외래키 제약조건 위반');
            when no_data_found then
                dbms_output.put_line(i||' : 존재하지 않는 데이터 참조');
            when others then
