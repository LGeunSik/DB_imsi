<?php
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
