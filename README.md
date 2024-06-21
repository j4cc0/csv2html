# csv2html
Convert a CSV file to HTML using SQLite.

## Description

Small wrapper around sqlite3 to convert a CSV file (double quoted and comma seperated) to HTML with built-in search function.

## Synopsis

`csv2html <csv-file> [generated-db-file] [tablename] [> myhtmloutput.html]`

## Usage

```
~/bin/csv2html.sh scan-2024-06-21.csv scan-2024-06-21.db scanresults > scan-2024-06-21.html
```

This will convert scan-2024-06-21.csv to scan-2024-06-21.html file, and leave a sqlite3 scan-2024-06-21.db file, containing a single table named "scanresults".

## Notes

1. Large HTML files will crash your browser.
2. The intermediate Sqlite DB file will probably be the most useful, if you know a little SQL ;-)
3. USE WITH CAUTION, THIS IS NOT THOUROUGHLY TESTED.


