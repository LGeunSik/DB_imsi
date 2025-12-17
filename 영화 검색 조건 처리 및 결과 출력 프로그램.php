<?php
/*
[PHP 프로그램 제목]
영화 검색 조건 처리 및 결과 출력 프로그램

[코드 동작 흐름 설명]
1) POST 방식으로 전달된 영화 검색 조건(제목, LIKE 여부, 대소문자 구별, 상영시간, 배우 조건)을 입력받는다.
2) 입력된 값에 따라 SQL WHERE 절에 추가할 조건들을 배열 형태로 구성한다.
3) 제목 검색 시 LIKE/일치 검색과 대소문자 구별 여부를 반영하여 조건을 생성한다.
4) 상영시간 범위 조건과 출생년도·성별 조건은 EXISTS 서브쿼리를 이용해 배우 조건으로 처리한다.
5) 완성된 조건을 movie, movieexec, studio 테이블에 적용하여 최종 SQL 문을 생성한다.
6) 검색 결과가 존재하면 HTML 테이블로 출력하고, LIKE 검색 시 제목 부분을 강조 표시한다.
7) 결과가 없는 경우에는 검색 결과가 없음을 출력한 후 DB 연결을 종료한다.
*/

function p_error($id=null){
    if($id==null) $e = oci_error();
    else $e = oci_error($id);
    print htmlentities($e['message']);
    exit();
}

$conn = oci_connect("db2021563047","db32308121","localhost/lecture");
if(!$conn) p_error();

$title = $_POST["title"] ?? "";
$use_like = isset($_POST["use_like"]);
$case_sensitive = isset($_POST["case_sensitive"]);
$length_from = $_POST["length_from"] ?? "";
$length_to = $_POST["length_to"] ?? "";
$birth_year = $_POST["birth_year"] ?? "";
$gender = $_POST["gender"] ?? "";

$conditions = [];

if($title!=""){
    $t = str_replace("'", "''", $title);
    if($use_like){
        if($case_sensitive)
            $conditions[] = "m.title LIKE '%' || '$t' || '%'";
        else
            $conditions[] = "UPPER(m.title) LIKE UPPER('%$t%')";
    } else {
        if($case_sensitive)
            $conditions[] = "m.title = '$t'";
        else
            $conditions[] = "UPPER(m.title) = UPPER('$t')";
    }
}

if($length_from!="" && $length_to!="")
    $conditions[] = "m.length BETWEEN $length_from AND $length_to";
else if($length_from!="")
    $conditions[] = "m.length >= $length_from";
else if($length_to!="")
    $conditions[] = "m.length <= $length_to";

if($birth_year!=""){
    $actor = "EXISTS (
        SELECT 1 
        FROM starsin si, moviestar ms
        WHERE UPPER(si.movietitle) = UPPER(m.title)
        AND si.movieyear = m.year
        AND si.starname = ms.name
        AND EXTRACT(YEAR FROM ms.birthdate) > $birth_year";

    if($gender!="")
        $actor .= " AND ms.gender = '$gender'";

    $actor .= ")";
    $conditions[] = $actor;
}

$where = "WHERE m.producerno = e.certno AND m.studioname = s.name";

if(count($conditions)>0)
    $where .= " AND " . implode(" AND ", $conditions);

$sql = "
SELECT m.title, m.year, e.name AS producer, m.studioname, s.address
FROM movie m, movieexec e, studio s
$where
ORDER BY m.title, m.year
";

$st = oci_parse($conn, $sql);
oci_execute($st);

$n = oci_fetch_all($st, $rows, 0, -1, OCI_FETCHSTATEMENT_BY_ROW + OCI_ASSOC);

if($n>0){
    print "<TABLE bgcolor=lightyellow border=1 cellspacing=2>\n";
    print "<TR bgcolor=lightgreen align=center>
           <TH>영화제목<TH>개봉년도<TH>제작자<TH>영화사<TH>영화사 주소</TR>\n";

    foreach($rows as $r){
        $display = htmlentities($r['TITLE']);
        if($use_like && $title!=""){
            $escaped = preg_quote($title,'/');
            if($case_sensitive)
                $display = str_replace($title,"<span style='background-color:yellow'>$title</span>",$display);
            else
                $display = preg_replace("/($escaped)/i","<span style='background-color:yellow'>$1</span>",$display);
        }

        print "<TR>";
        print "<TD>$display";
        print "<TD>{$r['YEAR']}";
        print "<TD>{$r['PRODUCER']}";
        print "<TD>{$r['STUDIONAME']}";
        print "<TD>{$r['ADDRESS']}";
        print "</TR>\n";
    }

    print "</TABLE>\n<p>총 $n 개의 영화가 검색되었습니다.</p>";
} else {
    print "검색 결과가 없습니다.<br>";
}

oci_close($conn);
?>
