## CIP

查询IP地址详情

#### 使用例子

```shell
cip -n3 -i 8.8.8.8
```

```json
{
  "ip": "8.8.8.8",
  "city": "Mountain View",
  "region": "California",
  "region_code": "CA",
  "country": "US",
  "country_name": "United States",
  "continent_code": "NA",
  "in_eu": false,
  "postal": "94035",
  "latitude": 37.386,
  "longitude": -122.0838,
  "timezone": "America/Los_Angeles",
  "utc_offset": "-0700",
  "country_calling_code": "+1",
  "currency": "USD",
  "languages": "en-US,es-US,haw,fr",
  "asn": "AS15169",
  "org": "Google LLC"
}
```

```shell
cip                 #查询本机IP
cip -i 8.8.8.8      #查询指定IP信息
cip -n2 -i 8.8.8.8  #使用指定源查询指定IP信息
```
#### 可用源

```shell
cip -l
```

```shell
查询IP源列表：
  1    pconline
  2    ip-api
  3    cip
  4    ipapi
  5    ipsb

使用例子：
  cip -n1                         # 编号查询本机IP信息
  cip -t pconline -i 127.0.0.1    # 类型查询指定IP信息
```

#### 帮助

```shell
cip -h
```

```shell
使用：
  cip [args] [value]

参数：
  -h                    显示帮助
  -l                    显示列表
  -i   [ip]             指定查询IP
  -n   [num]            用编号选择源
  -t   [type]           用类型名称选择源

注：不使用IP参数显示本机IP
```
