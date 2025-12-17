<?php
/*
[PHP 프로그램 제목]
영화사별 제작 영화 수 조회 및 상세 페이지 연결 프로그램

[코드 동작 흐름 설명]
1) Oracle DB에 접속한 뒤 영화사별 제작 영화 수를 조회하는 SQL을 준비한다.
2) studio와 movie 테이블을 조인하여 영화사별로 제작한 영화 개수를 집계한다.
3) 영화가 1편 이상 존재하는 영화사만 HAVING 절로 필터링한다.
4) 조회 결과를 영화사 이름 기준으로 정렬하여 HTML 테이블로 출력한다.
5) 각 영화사 이름과 영화 개수는 링크로 제공되어 상세 정보 페이지로 이동할 수 있다.
6) 모든 결과 출력 후 statement와 DB 연결을 해제하고 프로그램을 종료한다.
*/

function p_error($id=null) {
    if($id == null) $e = oci_error();
    else $e = oci_error($id);
    print htmlentities($e['message']);
    exit();
}

$conn = oci_connect("scott","tiger", "localhost/lecture");
if (!$conn) p_error();

$stmt = oci_parse($conn,
    "SELECT s.name, COUNT(m.title) AS movie_count
     FROM studio s, movie m
WHERE s.name = m.studioname
     GROUP BY s.name
     HAVING COUNT(m.title) >= 1
     ORDER BY s.name");

if (!$stmt) p_error($conn);

$r = oci_execute($stmt);
if (!$r) p_error($stmt);

print "<TABLE bgcolor=linen border=2 cellspacing=3>\n";
print "<TR bgcolor=tan align=center>
<TH> 영화사 
        <TH> 제작한 영화수 
       </TR>\n";

while ($row = oci_fetch_array($stmt, OCI_ASSOC)) {
    $studio_name = $row['NAME'];
    $movie_count = $row['MOVIE_COUNT'];
    $studio_encoded = urlencode($studio_name);
    
    print "<TR bgcolor=wheat>";
    print "<TD><a href='studio_detail.php?name={$studio_encoded}'>{$studio_name}</a>";
    print "<TD><a href='studio_movies.php?name={$studio_encoded}'>{$movie_count}</a>";
    print "</TR>\n";
}

print "</TABLE>\n";

oci_free_statement($stmt);
oci_close($conn);

?>
