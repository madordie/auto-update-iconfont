#!/usr/bin/python
#-*- coding: UTF-8 -*-
import sys
import re
import os

try:
    from fontTools.ttLib import TTFont, TTLibError, newTable
    from fontTools.ttLib.tables.otTables import *
except:
    try:
        sys.path.append('/Users/FDD/.jenkins/workspace/lib/fonttools/Lib')
        import fontTools
        from fontTools.ttLib import TTFont, TTLibError, newTable
        from fontTools.ttLib.tables.otTables import *
    except:
        print("Install https://github.com/behdad/fonttools/archive/master.zip \n OR `pip install fonttools`")
        sys.exit(1)

def getUnicodes(inPath):
    try:
        ttx = TTFont(inPath)
    except TTLibError:
        print("Cannot open %s" % inPath)
        sys.exit(1)

    unicodes = set()
    cmap = ttx['cmap'].buildReversed()
    for key in cmap.keys():
        values = cmap[key]
        for intUnicode in values:
            unicodes.add(intUnicode)
    return unicodes

def getFileUnicodes(filepath, regular):
    file = open(filepath, 'r')
    p = re.compile(regular)
    m = p.findall(file.read())
    file.close()
    return m
    
def formatUnicode(inputs):
    recompile = re.compile(r'([a-fA-F0-9]+)')
    end = set()
    for input in inputs:
        code = recompile.findall(input)
        if len(code) > 0:
            end.update(code)
    return end
    
def searchFile(path):
    if not os.path.isdir(path):
        return
    
    allUnicodes = set()
    
    rules = set([('.swift', r'\\[uU]{([0-9a-fA-F]+)}'),
            ('.mm', r'\\[uU]([a-fA-F0-9]+)'),
            ('.m', r'\\[uU]([a-fA-F0-9]+)'),
            ('.h', r'\\[uU]([a-fA-F0-9]+)'), 
            ('.xml', r'(&#x[a-fA-F0-9]+|\\[uU][a-fA-F0-9]+)'), 
            ('.java', r'\\[uU]([a-fA-F0-9]+)')])

    for root, dirs, list in os.walk(path):
        for i in list:
            dir = os.path.join(root, i)
            s = os.path.splitext(i)
            for r in rules:
                if s[1] == r[0]:
                    unicodes = getFileUnicodes(dir, r[1])
                    if len(unicodes) > 0:
                        unicodes = formatUnicode(unicodes)
                        print(unicodes, i)
                        allUnicodes.update([ int(v, 16) for v in unicodes ])
                        break
    return allUnicodes
    
def unicodes2Hex(unicodes):
    hexs = set()
    for intUnicode in unicodes:
        hexUnicode = '%X'.lstrip('0x') % intUnicode
        str = '0x' + '0' * (4 - len(hexUnicode)) + hexUnicode
        hexs.add(str)
    return hexs

def checkoutUnicode(iconfontPath, checkPath):
    print("开始校验ttf")
    iconfont = getUnicodes(iconfontPath)
    iconfontLen = len(iconfont)
    if iconfontLen == 0:
        print("无法识别ttf文件，请检查")
        sys.exit(2)
    print("ttf校验完毕, 共检索" + str(iconfontLen) + "个字符")
    
    print("正在提取代码中的iconfont")
    paths = [checkPath]
    unicodes = set()
    for p in paths:
        unicodes.update(searchFile(p))
    print("提取完毕～")

    print("开始比对...")
    error = unicodes - iconfont
    if len(error) > 0:
        print("这些icon貌似缺失咯：" + str(unicodes2Hex(error)))
        print("校验失败！")
#        sys.exit(3)
    redundancy = iconfont - unicodes
    if len(redundancy) > 0:
        print("这些icon貌似冗余请开发确认：" + str(unicodes2Hex(redundancy)))
    print("比对完毕～")


if __name__ == "__main__":
    args = sys.argv
    checkoutUnicode(args[1], args[2])