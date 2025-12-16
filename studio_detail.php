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
    "SELECT s.name, s.address AS studio_addr, 
            e.name AS president, e.address AS pres_addr, e.networth
     FROM studio s, movieexec e
WHERE s.name = '$studio_escaped' AND s.presno = e.certno");

if (!$stmt) p_error($conn);

$r = oci_execute($stmt);
if (!$r) p_error($stmt);

$row = oci_fetch_array($stmt, OCI_ASSOC);

print "<TABLE bgcolor=cornsilk border=2 cellspacing=3>\n";
print "<TR bgcolor=burlywood align=center>
        <TH colspan=2> {$row['NAME']} 상세 정보
       </TR>\n";

print "<TR bgcolor=moccasin>";
print "<TD width=200><b>영화사 이름</b>";
print "<TD>{$row['NAME']}";
print "</TR>\n";

print "<TR bgcolor=moccasin>";
print "<TD><b>영화사 주소</b>";
print "<TD>{$row['STUDIO_ADDR']}";
print "</TR>\n";

print "<TR bgcolor=moccasin>";
print "<TD><b>사장</b>";
print "<TD>{$row['PRESIDENT']}";
print "</TR>\n";

print "<TR bgcolor=moccasin>";
print "<TD><b>사장 주소</b>";
print "<TD>{$row['PRES_ADDR']}";
print "</TR>\n";

print "<TR bgcolor=moccasin>";
print "<TD><b>재산액수</b>";
print "<TD>$" . number_format($row['NETWORTH']);
print "</TR>\n";

print "</TABLE>\n";
print "<br><a href='2.php'>목록으로 돌아가기</a>";

oci_free_statement($stmt);
oci_close($conn);
?>