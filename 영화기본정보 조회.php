<?php
/*
[코드 동작 흐름 설명]
1) Oracle DB(scott/tiger, localhost/lecture)에 접속한다.
2) movie + movieexec(제작자) + studio + movieexec(영화사 사장)을 LEFT JOIN하여 영화 기본 정보를 연도/상영시간 순으로 조회한다.
3) 조회된 각 영화 행마다, 해당 영화(title, year)에 출연한 배우들을 starsin + moviestar에서 다시 조회하여(생일 내림차순) 배우 목록을 만든다.
4) 배우 목록이 없으면 '정보없음', 있으면 'N명'과 '배우1, 배우2, ...' 형태로 가공한다.
5) 영화 기본 정보 + 배우 수 + 배우 리스트를 HTML TABLE 한 행으로 출력한다.
6) 사용한 statement와 DB 연결을 해제하고 종료한다.
*/

function p_error($id = null) {
    if ($id == null) $e = oci_error();
    else $e = oci_error($id);
    print htmlentities($e['message']);
    exit();
}

$conn = oci_connect("scott", "tiger", "localhost/lecture");
if (!$conn) p_error();

$stmt = oci_parse($conn,
    "SELECT 
        m.title,m.year,m.length, p.name AS producer,e.name AS boss
     FROM movie m
     LEFT JOIN movieexec p ON m.producerno = p.certno
LEFT JOIN studio s ON m.studioname = s.name
     LEFT JOIN movieexec e ON s.presno = e.certno
     ORDER BY m.year, m.length"
);

if (!$stmt) p_error($conn);

$r = oci_execute($stmt);
if (!$r) p_error($stmt);

print "<TABLE bgcolor=ivory border=2 cellspacing=3>\n";
print "<TR bgcolor=sandybrown align=center>
        <TH> 제목 
        <TH> 년도 
        <TH> 상영시간 
        <TH> 제작자
        <TH> 영화사사장
        <TH> 출연배우수
        <TH> 출연배우진
       </TR>\n";

while ($row = oci_fetch_array($stmt, OCI_ASSOC)) {
    $title_esc = str_replace("'", "''", $row['TITLE']);
    $year = $row['YEAR'];
    
    $stmt2 = oci_parse($conn,
        "SELECT st.starname, s.birthdate
         FROM starsin st, moviestar s
         WHERE st.movietitle = '$title_esc'
           AND st.movieyear = $year
AND st.starname = s.name
         ORDER BY s.birthdate DESC"
    );
    
    if (!$stmt2) p_error($conn);
    oci_execute($stmt2);
    
    $actors = [];
    while ($r2 = oci_fetch_array($stmt2, OCI_ASSOC)) {
        $actors[] = $r2['STARNAME'];
    }
    
    if (count($actors) == 0) {
        $actor_count = '정보없음';
        $actor_list  = '정보없음';
    } else {
        $actor_count = count($actors) . '명';
        $actor_list  = implode(", ", $actors);
    }
    
    print "<TR bgcolor=peachpuff>";
    print "<TD> {$row['TITLE']}";
    print "<TD> {$row['YEAR']}년";
    print "<TD> {$row['LENGTH']}분";
    print "<TD> {$row['PRODUCER']}";
    print "<TD> {$row['BOSS']}";
    print "<TD> {$actor_count}";
    print "<TD> {$actor_list}";
    print "</TR>\n";
    
    oci_free_statement($stmt2);
}

print "</TABLE>\n";

oci_free_statement($stmt);
oci_close($conn);
?>
