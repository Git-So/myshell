## SURL

便捷的缩短网址命令

#### 使用例子

```shell
surl -u https://github.com/Git-So/myshell/tree/master/shell/src/cip
```

```json
http://t.cn/AiuHBmyU
```

```shell
surl -u http://baidu.com            # 转换为默认类型短网址
surl -n1     -u http://baidu.com    # 转换为t.cn类型短网址
surl -t t.cn -u http://baidu.com    # 转换为t.cn类型短网址
```

#### 可用源

```shell
surl -l
```

```shell
短网址源列表：
  1    t.cn
  2    t.im
  3    t.tl
  4    url.cn
  5    suo.im
  6    dwz.mn

使用例子：
  surl -u http://baidu.com    # 转换为t.cn类型短网址
  surl -n1     -u http://baidu.com    # 转换为t.cn类型短网址
  surl -t t.cn -u http://baidu.com    # 转换为t.cn类型短网址
```

#### 帮助

```shell
surl -h
```

```shell
使用：
  surl [args] [value]

参数：
  -h                    显示帮助
  -l                    显示列表
  -u   [url]            长网址
  -n   [id]             用ID选择源
  -t   [type]           用类型名称选择源
```
