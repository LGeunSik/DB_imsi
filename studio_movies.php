<?php
function p_error($id=null) {
    if($id == null) $e = oci_error();
    else $e = oci_error($id);
    print htmlentities($e['message']);
    exit();
}

$conn = oci_connect("db2021563047","db32308121", "localhost/lecture");
if (!$conn) p_error();

$studio_name = $_GET['name'];
$studio_escaped = str_replace("'", "''", $studio_name);

$stmt = oci_parse($conn,
    "SELECT m.title, m.year, m.length, e.name AS producer
     FROM movie m, movieexec e
     WHERE m.studioname = '$studio_escaped' AND m.producerno = e.certno
ORDER BY m.year, m.title");

if (!$stmt) p_error($conn);

$r = oci_execute($stmt);
if (!$r) p_error($stmt);

print "<TABLE bgcolor=oldlace border=2 cellspacing=3>\n";
print "<TR bgcolor=peru align=center>
        <TH colspan=4> {$studio_name} 제작 영화 목록
       </TR>\n";
print "<TR bgcolor=goldenrod align=center>
<TH> 제목 
        <TH> 개봉년도 
        <TH> 상영시간 
        <TH> 제작자
       </TR>\n";

while ($row = oci_fetch_array($stmt, OCI_ASSOC)) {
    print "<TR bgcolor=bisque>";
    print "<TD>{$row['TITLE']}";
    print "<TD>{$row['YEAR']}년";
    print "<TD>{$row['LENGTH']}분";
    print "<TD>{$row['PRODUCER']}";
    print "</TR>\n";
}

print "</TABLE>\n";
print "<br><a href='2.php'>목록으로 돌아가기</a>";

oci_free_statement($stmt);
oci_close($conn);
?>t this template
 */

