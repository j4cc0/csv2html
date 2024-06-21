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

echo "<input id='myInput' type='text' onkeyup='Search()' placeholder='Search'>"
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
function Search() {
        var input, filter, table, tr, td, i, txtValue;
        input = document.getElementById("mySearch");
        filter = input.value.toUpperCase();
        table = document.getElementById("Results");
        tr = table.getElementsByTagName("tr");
        rows = tr.length;
        cols = tr[1].getElementsByTagName("td").length;
        // console.log("Rows: " + rows + ", Columns: " + cols);
        for (i = 0; i < rows; i++) {
                holdoff = 0;
                for (j = 0; j < cols; j++) {
                        td = tr[i].getElementsByTagName("td")[j];
                        if (td) {
                                txtValue = td.textContent || td.innerText;
                                found = txtValue.toUpperCase().indexOf(filter);
                                if (found > -1) {
                                        // console.log("Found: '" + filter + "' in row: " + i);
                                        tr[i].style.display = "";
                                        holdoff = 1;
                                        regex = new RegExp(input, 'gi');
                                        text = td.innerHTML;
                                        text = text.replace(/(<mark class="highlight">|<\/mark>)/gim, '');
                                        newtext = text.replace(regex, '<mark class="highlight">$&</mark>');
                                        td.innetHTML = newtext;
                                }
                                else {
                                        if ( holdoff == 0 ) {
                                                tr[i].style.display = "none";
                                        }
                                }
                        }
                }
        }
}
</script>


</body>
</html>
___EOF___
