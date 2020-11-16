## auto-update-iconfont

让设计师自己更新iconfont。为的是多人开发的时候iconfont的更新会有冲突。。所以简单点。。（代码上传逻辑扔在了Jenkins上。此处只有触发）

## 主要逻辑

其实就一行：

```swift
struct Item {
    let name: String
    let file: String
    let jenkins: String

    func post(_ path: String) -> String {
        return "curl -u USERID:APITOKEN -X POST http://10.12.12.10:8080/job/\(jenkins)/build  --form file0=@\(path) --form json='{\"parameter\": [{\"name\":\"\(file)\", \"file\":\"file0\"},{\"name\":\"from\", \"value\":\"\(NSUserName())\"}]}'"
    }
}
```

需要注意的是`curl`后面的`USERID:APITOKEN`为`User ID`及`API Token`，可在`用户管理`相关界面取到。

## Jenkins配置

1. Jenkins 需要的插件：
  - 操作者用户名获取插件 [build user vars plugin](https://wiki.jenkins.io/display/JENKINS/Build+User+Vars+Plugin)

2. 参数构建配置
```
String Parameter:
  name: from
  default: ""
  desc: "默认使用登录用户～"

String Parameter:
  name: iconfont.ttf
  desc: "请上传iconfont.ttf字体库"
```

3. 构建执行脚本
事先已经将项目clone到了指定目录下。
剩下就是几个shell命令，自己看下就能看懂。
```shell
# 任务名字
JOB_NAME="iOS项目"
# path
GIT_PATH="ios-app"
# 原来的iconfont地址
OLD_FONT="Resources/Fonts"
# 提交分支
BRANCH="develop"
# 谁可以review
REVIEWERS="${IOS_REVIEWERS}"

# 钉钉机器人token 如需添加换行并列即可
cat << EOF > dtalk.tokens
41xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx96
EOF

#############################
#							#
#     从这里往下就别修改了	 #
#							#
#############################

# 标签
NEW_FONT="iconfont.ttf"
# 项目
JOB="$JOB_NAME($NODE_NAME)"

bash "${HOME}/cmd/push-iconfont-ttf.sh" \
	-j "$JOB_NAME" \
    -n "$NEW_FONT" \
    -o "$OLD_FONT" \
    -b "$BRANCH" \
    -p "$GIT_PATH" \
    -f "$from" \
    -r "$REVIEWERS" \
    -d dtalk.tokens
```

## [checkiconfont.py](https://github.com/madordie/auto-update-iconfont/blob/master/checkIconfont.py)

用作校验 提取iconfont中支持的unicode 以及 代码中支持的unicode 

配置在jenkins 中

```shell
# check iconfont.ttf
python /Users/User/.jenkins/workspace/lib/checkIconfont.py $TTF_PATH/iconfont.ttf  $CODE_PATH
```

记得过滤代码中一些特殊含义的unicode,正则可能误伤。。
