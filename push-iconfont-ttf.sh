#!/bin/bash
set -ex
source "`dirname $0`/functions.sh"

NEW_FONT=
OLD_FONT=
BRANCH=
GIT_PATH=
FROM=
REVIEWERS=
DTALK_TOKEN_PATH=
JOB_NAME=

while getopts :f:d:n:o:j:b:p:r: OPTION
do
  case $OPTION in
    n)
      NEW_FONT="$OPTARG"
      ;;
    o)
      OLD_FONT="$OPTARG"
      ;;
    b)
      BRANCH="$OPTARG"
      ;;
    p)
      GIT_PATH="$OPTARG"
      ;;
    f)
      FROM="$OPTARG"
      ;;
    r)
      REVIEWERS="$OPTARG"
      ;;
    d)
      DTALK_TOKEN_PATH="$OPTARG"
      ;;
    j)
      JOB_NAME="$OPTARG"
      ;;
  esac
done

echo `basename $0`
check_arg "git path[-p]" "$GIT_PATH"
check_arg "branch[-b]" "$BRANCH"
check_arg "new iconfont[-n]" "$NEW_FONT"
check_arg "old iconfont[-o]" "$OLD_FONT"
check_arg "from[-f]" "$FROM"
check_arg "reviewers[-r]" "$REVIEWERS"
check_arg "job name[-j]" "$JOB_NAME"
echo "  🤝 let us go!"

TMP_BRANCH="tmp-iconfont"

ROOT="`pwd`"
cd "$GIT_PATH"
rm -rf ./*
git checkout .
git checkout -b $TMP_BRANCH
git branch -D $BRANCH
git checkout $BRANCH
git branch -D $TMP_BRANCH
git fetch
rm -rf ./*
git checkout .
git rebase origin/$BRANCH

cd $ROOT
mv "$NEW_FONT" "$OLD_FONT"
cd "$GIT_PATH"
git add */$NEW_FONT
git commit --allow-empty -m "${FROM} update iconfont.ttf"
git push origin HEAD:refs/for/$BRANCH%${REVIEWERS}

cd $ROOT

for line in `cat "${DTALK_TOKEN_PATH}"`; do
    curl "https://oapi.dingtalk.com/robot/send?access_token=${line}" \
        -H "Content-Type: application/json" \
        -d "{ \
            \"msgtype\": \"markdown\", \
            \"markdown\": { \
                \"title\":\"[${JOB_NAME}] 已更新iconfont.ttf\", \
                \"text\": \"### [${JOB_NAME}] 由${FROM}更新的iconfont.ttf已更新 \n> 已提交至XX仓库\n\n> 需要有`submit`的权限\" \
            } \
        }"
done
echo

DONE
