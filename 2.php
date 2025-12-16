<?php
function p_error($id=null){
    if($id==null) $e = oci_error();
    else $e = oci_error($id);
    print htmlentities($e['message']);
    exit();
}

$conn = oci_connect("db2021563047","db32308121","localhost/lecture");
if(!$conn) p_error();

$sql = "SELECT name, address, certno FROM movieexec ORDER BY name";
$st = oci_parse($conn, $sql);
oci_execute($st);
oci_fetch_all($st, $execs, 0, -1, OCI_FETCHSTATEMENT_BY_ROW + OCI_ASSOC);

print "<TABLE bgcolor=lightgreen border=1 cellpadding=5 cellspacing=0>";
print "<TR bgcolor=Red align=center>
<TH>순번<TH>이름<TH>주소<TH>영화사<TH>제작 영화<TH>출연 영화</TR>";

$idx = 1;

foreach($execs as $e){

    $cert = $e['CERTNO'];

    $q1 = "SELECT name FROM studio WHERE presNo = $cert";
    $s1 = oci_parse($conn, $q1);
    oci_execute($s1);
    oci_fetch_all($s1, $studio, 0, -1, OCI_FETCHSTATEMENT_BY_ROW + OCI_ASSOC);
    $studio_list = ($studio) ? array_column($studio,"NAME") : ["없음"];

    $q2 = "SELECT title, year FROM movie WHERE producerno = $cert ORDER BY year";
    $s2 = oci_parse($conn, $q2);
    oci_execute($s2);
    oci_fetch_all($s2, $prod, 0, -1, OCI_FETCHSTATEMENT_BY_ROW + OCI_ASSOC);

    $prod_list = [];
    if($prod){
        foreach($prod as $p) $prod_list[] = $p['TITLE']."(".$p['YEAR'].")";
    } else $prod_list = ["없음"];

    $q3 = "SELECT movietitle AS title, movieyear AS year
           FROM starsin WHERE starname = '{$e['NAME']}' ORDER BY movieyear";
    $s3 = oci_parse($conn, $q3);
    oci_execute($s3);
    oci_fetch_all($s3, $act, 0, -1, OCI_FETCHSTATEMENT_BY_ROW + OCI_ASSOC);

    $act_list = [];
    if($act){
        foreach($act as $a) $act_list[] = $a['TITLE']."(".$a['YEAR'].")";
    } else $act_list = ["없음"];

    $max_rows = max(count($studio_list), count($prod_list), count($act_list));

    $rows = [];
    for($i=0; $i<$max_rows; $i++){
        $rows[$i] = [
            'studio' => $studio_list[$i] ?? "",
            'prod'   => $prod_list[$i] ?? "",
            'act'    => $act_list[$i] ?? ""
        ];
    }

    print "<TR>";
    print "<TD rowspan='$max_rows'>$idx";
    print "<TD rowspan='$max_rows'>{$e['NAME']}";
    print "<TD rowspan='$max_rows'>{$e['ADDRESS']}";

    $cols = ['studio','prod','act'];
    $rowspan_info = [];

    foreach($cols as $c){
        $rowspan = 1;
        for($i=1; $i<$max_rows; $i++){
            if($rows[$i][$c] === $rows[0][$c] && $rows[0][$c] !== ""){
                $rowspan++;
                $rows[$i][$c] = null;
            } else break;
        }
        $rowspan_info[$c] = $rowspan;
    }

    print "<TD".($rowspan_info['studio']>1?" rowspan='{$rowspan_info['studio']}'":"").">".$rows[0]['studio']."</TD>";
    print "<TD".($rowspan_info['prod']>1?" rowspan='{$rowspan_info['prod']}'":"").">".$rows[0]['prod']."</TD>";
    print "<TD".($rowspan_info['act']>1?" rowspan='{$rowspan_info['act']}'":"").">".$rows[0]['act']."</TD>";
    print "</TR>";

    for($i=1; $i<$max_rows; $i++){
        print "<TR>";
        foreach($cols as $c){
            if($rows[$i][$c] !== null)
                print "<TD>".$rows[$i][$c]."</TD>";
        }
        print "</TR>";
    }

    $idx++;
}

print "</TABLE>";

oci_close($conn);
?>
