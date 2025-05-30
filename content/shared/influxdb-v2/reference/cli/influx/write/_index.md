
The `influx write` command writes data to InfluxDB via stdin or from a specified file.
Write data using [line protocol](/influxdb/version/reference/syntax/line-protocol),
[annotated CSV](/influxdb/version/reference/syntax/annotated-csv), or
[extended annotated CSV](/influxdb/version/reference/syntax/annotated-csv/extended/).
If you write CSV data, CSV annotations determine how the data translates into line protocol.


## Usage
```
influx write [flags]
influx write [command]
```

{{% note %}}
### Required data
To write data to InfluxDB, you must provide the following for each row:

- **measurement**
- **field**
- **value**

#### Line protocol
In **line protocol**, the [structure of the line data](/influxdb/version/reference/syntax/line-protocol/#elements-of-line-protocol)
determines the measurement, field, and value.

#### Annotated CSV
In **annotated CSV**, measurements, fields, and values are represented by the
`_measurement`, `_field`, and `_value` columns.
Their types are determined by CSV annotations.
To successfully write annotated CSV to InfluxDB, include all
[annotation rows](/influxdb/version/reference/syntax/annotated-csv/#annotations).

#### Extended annotated CSV
In **extended annotated CSV**, measurements, fields, and values and their types are determined by
[CSV annotations](/influxdb/version/reference/syntax/annotated-csv/extended/#csv-annotations).
{{% /note %}}

## Subcommands
| Subcommand                                                 | Description                         |
|:----------                                                 |:-----------                         |
| [dryrun](/influxdb/version/reference/cli/influx/write/dryrun) | Write to stdout instead of InfluxDB |

## Flags
| Flag |                     | Description                                                                                  | Input type  | {{< cli/mapped >}}    |
| :--- | :------------------ | :------------------------------------------------------------------------------------------- | :---------: | :-------------------- |
| `-c` | `--active-config`   | CLI configuration to use for command                                                         |   string    |                       |
| `-b` | `--bucket`          | Bucket name (mutually exclusive with `--bucket-id`)                                          |   string    | `INFLUX_BUCKET_NAME`  |
|      | `--bucket-id`       | Bucket ID (mutually exclusive with `--bucket`)                                               |   string    | `INFLUX_BUCKET_ID`    |
|      | `--configs-path`    | Path to `influx` CLI configurations (default `~/.influxdbv2/configs`)                        |   string    | `INFLUX_CONFIGS_PATH` |
|      | `--compression`     | Input compression (`none` or `gzip`, default is `none` unless input file ends with `.gz`.)   |   string    |                       |
|      | `--debug`           | Output errors to stderr                                                                      |             |                       |
|      | `--encoding`        | Character encoding of input (default `UTF-8`)                                                |   string    |                       |
|      | `--errors-file`      | Path to a file used for recording rejected row errors                                        |   string    |                       |
| `-f` | `--file`            | File to import                                                                               | stringArray |                       |
|      | `--format`          | Input format (`lp` or `csv`, default `lp`)                                                   |   string    |                       |
|      | `--header`          | Prepend header line to CSV input data                                                        |   string    |                       |
| `-h` | `--help`            | Help for the `write` command                                                                 |             |                       |
|      | `--host`            | HTTP address of InfluxDB (default `http://localhost:8086`)                                   |   string    | `INFLUX_HOST`         |
|      | `--max-line-length` | Maximum number of bytes that can be read for a single line (default `16000000`)              |   integer   |                       |
| `-o` | `--org`             | Organization name (mutually exclusive with `--org-id`)                                       |   string    | `INFLUX_ORG`          |
|      | `--org-id`          | Organization ID (mutually exclusive with `--org`)                                            |   string    | `INFLUX_ORG_ID`       |
| `-p` | `--precision`       | [Precision](/influxdb/version/write-data/#timestamp-precision) of the timestamps (default `ns`) |   string    | `INFLUX_PRECISION`    |
|      | `--rate-limit`      | Throttle write rate (examples: `5MB/5min` or `1MB/s`).                                   |   string    |                       |
|      | `--skip-verify`     | Skip TLS certificate verification                                                            |             | `INFLUX_SKIP_VERIFY`  |
|      | `--skipHeader`      | Skip first *n* rows of input data                                                            |   integer   |                       |
|      | `--skipRowOnError`  | Output CSV errors to stderr, but continue processing                                         |             |                       |
| `-t` | `--token`           | API token                                                                                    |   string    | `INFLUX_TOKEN`        |
| `-u` | `--url`             | URL to import data from                                                                      | stringArray |                       |

## Examples

{{< cli/influx-creds-note >}}

###### Write line protocol

- [via stdin](#write-line-protocol-via-stdin)
- [from a file](#write-line-protocol-from-a-file)
- [and skip header lines](#skip-header-lines-in-a-file)
- [from multiple files](#write-line-protocol-from-multiple-files)
- [from a URL](#write-line-protocol-from-a-url)
- [from multiple URLs](#write-line-protocol-from-multiple-urls)
- [from multiple sources](#write-line-protocol-from-multiple-sources)
- [from a compressed file](#write-line-protocol-from-a-compressed-file)

###### Write CSV data

- [annotated CSV via stdin](#write-annotated-csv-data-via-stdin)
- [extended annotated CSV via stdin](#write-extended-annotated-csv-data-via-stdin)
- [from a file](#write-annotated-csv-data-from-a-file)
- [from multiple files](#write-annotated-csv-data-from-multiple-files)
- [from a URL](#write-annotated-csv-data-from-a-url)
- [from multiple URLs](#write-annotated-csv-data-from-multiple-urls)
- [from multiple sources](#write-annotated-csv-data-from-multiple-sources)
- [and prepend annotation headers](#prepend-csv-data-with-annotation-headers)
- [from a compressed file](#write-annotated-csv-data-from-a-compressed-file)
- [using rate limiting](#write-annotated-csv-data-using-rate-limiting)

### Line protocol

##### Write line protocol via stdin
```sh
influx write --bucket example-bucket "
m,host=host1 field1=1.2,field2=5i 1640995200000000000
m,host=host2 field1=2.4,field2=3i 1640995200000000000
"
```

##### Write line protocol from a file
```sh
influx write \
  --bucket example-bucket \
  --file path/to/line-protocol.txt
```

##### Skip header lines in a file
```sh
influx write \
  --bucket example-bucket \
  --file path/to/line-protocol.txt
  --skipHeader 8
```

##### Write line protocol from multiple files
```sh
influx write \
  --bucket example-bucket \
  --file path/to/line-protocol-1.txt \
  --file path/to/line-protocol-2.txt
```

##### Write line protocol from a URL
```sh
influx write \
  --bucket example-bucket \
  --url https://example.com/line-protocol.txt
```

##### Write line protocol from multiple URLs
```sh
influx write \
  --bucket example-bucket \
  --url https://example.com/line-protocol-1.txt \
  --url https://example.com/line-protocol-2.txt
```

##### Write line protocol from multiple sources
```sh
influx write \
  --bucket example-bucket \
  --file path/to/line-protocol-1.txt \
  --url https://example.com/line-protocol-2.txt
```

##### Write line protocol from a compressed file
```sh
# The influx CLI assumes files with the .gz extension use gzip compression 
influx write \
  --bucket example-bucket \
  --file path/to/line-protocol.txt.gz

# Specify gzip compression for gzipped files without the .gz extension
influx write \
  --bucket example-bucket \
  --file path/to/line-protocol.txt.comp \
  --compression gzip
```

---

### CSV

##### Write annotated CSV data via stdin
```sh
influx write \
  --bucket example-bucket \
  --format csv \
  "#group,false,false,false,false,true,true
#datatype,string,long,dateTime:RFC3339,double,string,string
#default,_result,,,,,
,result,table,_time,_value,_field,_measurement
,,0,2020-12-18T18:16:11Z,72.7,temp,sensorData
,,0,2020-12-18T18:16:21Z,73.8,temp,sensorData
,,0,2020-12-18T18:16:31Z,72.7,temp,sensorData
,,0,2020-12-18T18:16:41Z,72.8,temp,sensorData
,,0,2020-12-18T18:16:51Z,73.1,temp,sensorData
"
```

##### Write extended annotated CSV data via stdin
```sh
influx write \
  --bucket example-bucket \
  --format csv \
  "#constant measurement,sensorData
#datatype dateTime:RFC3339,double
time,temperature
2020-12-18T18:16:11Z,72.7
2020-12-18T18:16:21Z,73.8
2020-12-18T18:16:31Z,72.7
2020-12-18T18:16:41Z,72.8
2020-12-18T18:16:51Z,73.1
"
```

##### Write annotated CSV data from a file
```sh
influx write \
  --bucket example-bucket \
  --file path/to/data.csv
```

##### Write annotated CSV data from multiple files
```sh
influx write \
  --bucket example-bucket \
  --file path/to/data-1.csv \
  --file path/to/data-2.csv
```

##### Write annotated CSV data from a URL
```sh
influx write \
  --bucket example-bucket \
  --url https://example.com/data.csv
```

##### Write annotated CSV data from multiple URLs
```sh
influx write \
  --bucket example-bucket \
  --url https://example.com/data-1.csv \
  --url https://example.com/data-2.csv
```

##### Write annotated CSV data from multiple sources
```sh
influx write \
  --bucket example-bucket \
  --file path/to/data-1.csv \
  --url https://example.com/data-2.csv
```

##### Prepend CSV data with annotation headers
```sh
influx write \
  --bucket example-bucket \
  --header "#constant measurement,birds" \
  --header "#datatype dateTime:2006-01-02,long,tag" \
  --file path/to/data.csv
```

##### Write annotated CSV data from a compressed file
```sh
# The influx CLI assumes files with the .gz extension use gzip compression 
influx write \
  --bucket example-bucket \
  --file path/to/data.csv.gz

# Specify gzip compression for gzipped files without the .gz extension
influx write \
  --bucket example-bucket \
  --file path/to/data.csv.comp \
  --compression gzip
```

##### Write annotated CSV data using rate limiting
```sh
influx write \
  --bucket example-bucket \
  --file path/to/data.csv \
  --rate-limit 5MB/5min
```
