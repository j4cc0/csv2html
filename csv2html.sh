#!/bin/bash
#Script: CSV2HTML.SH
#Descr: Small wrapper around sqlite3 to convert a CSV file (double quoted and comma seperated) to HTML with built-in search function.
#Synopsis: csv2html <csv-file> [generated-db-file] [tablename] [> myhtmloutput.html]
#Usage: ~/bin/csv2html.sh scan-2024-06-21.csv scan-2024-06-21.db scanresults > scan-2024-06-21.html
#- This will convert scan-2024-06-21.csv to scan-2024-06-21.html file, and leave a sqlite3 scan-2024-06-21.db file, containing a single table named "scanresults".
#Note1: Large HTML files will crash your browser.
#Note2: The intermediate Sqlite DB file will probably be the most useful, if you know a little SQL ;-)
#Author: Jacco van Buuren

FNAME="$1"
DB="${2:-mydb.db}"
TN="${3:-mytable}"
QUOTE='"'
SEP="$QUOTE,$QUOTE"

warn() {
        echo "$@" >&2
        return 0
}

die() {
        warn "$@. Aborted"
        exit 1
}

if [ "x${FNAME}x" = "xx" ]; then
        die "Missing parameter"
fi

if [ ! -r "$FNAME" ]; then
        die "Cannot read $FN"
fi

cat <<___EOF___
<!DOCTYPE html>
<html>
<head>
<title>$FNAME</title>
<style>
body, input {
  font-family: 'Helvetica', Arial, Lucida Grande, sans-serif;
  font-size: 10px;
  line-height: 1.0;
  color: #000000;
  background: white;
}
</style>
</head>
<body>
___EOF___

echo "<input id='myInput' type='text' onkeyup='myFunction()' placeholder='Search first column'>"
echo "<table id='myTable' border='1' width='100%' cellspacing='0' cellpadding='2' style='white-space:nowrap;'>"

cat <<___EOF___ | sqlite3 "${DB}"
.import --csv $FNAME $TN
.mode html
.headers on
select * from $TN;
.quit
___EOF___

echo "</table>"

cat <<___EOF___
<script>
function myFunction() {
  var input, filter, table, tr, td, i, txtValue;
  input = document.getElementById("myInput");
  filter = input.value.toUpperCase();
  table = document.getElementById("myTable");
  tr = table.getElementsByTagName("tr");
  for (i = 0; i < tr.length; i++) {
    td = tr[i].getElementsByTagName("td")[0];
    if (td) {
      txtValue = td.textContent || td.innerText;
      if (txtValue.toUpperCase().indexOf(filter) > -1) {
        tr[i].style.display = "";
      } else {
        tr[i].style.display = "none";
      }
    }
  }
}
</script>

</body>
</html>
___EOF___