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
new_iconfont=./../iconfont.ttf
# 最新iconfont所需要放置的位置(一般和自己项目有关系)
old_iconfont=Fangduoduo/Fangduoduo/Fonts/iconfont.ttf

user=$from
if [ -z "$user" ]; then 
    user=$BUILD_USER
fi

cd fdd-app-ios
git checkout master
git branch -D develop
git checkout develop
git fetch 
git rebase
mv $new_iconfont $old_iconfont
git add $old_iconfont
git commit -m "${user} update iconfont.ttf"
git push

# 钉钉群通知相关开发合并。（此处使用的是gerrit，所以必须手动合并。TOKEN为机器人TOKEN
info="{\"msgtype\":\"text\",\"text\":{\"content\":\"${user}向XX仓库提交了新的iconfont.ttf。传送门(需有合并权限):http://teamcode.fangdd.net/#/dashboard/self\"}}"
curl 'https://oapi.dingtalk.com/robot/send?access_token=TOKEN' -H 'Content-Type: application/json' -d $info

```

## [checkiconfont.py](https://github.com/madordie/auto-update-iconfont/blob/master/checkIconfont.py)

用作校验 提取iconfont中支持的unicode 以及 代码中支持的unicode 

配置在jenkins 中

```shell
# check iconfont.ttf
python /Users/FDD/.jenkins/workspace/lib/checkIconfont.py $TTF_PATH/iconfont.ttf  $CODE_PATH
```

记得过滤代码中一些特殊含义的unicode,正则可能误伤。。
