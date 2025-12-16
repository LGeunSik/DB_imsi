<?php
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