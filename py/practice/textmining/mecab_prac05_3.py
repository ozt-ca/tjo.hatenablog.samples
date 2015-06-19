# -*- coding: utf-8 -*-
"""
Created on Fri Nov 09 12:11:48 2012
"""

import sys
import MeCab
import operator

tagger=MeCab.Tagger("-Ochasen")
read_file = sys.argv[1] #コマンドラインから読み込むデータファイルを指定する
all_text = open(read_file).read() #指定したファイルを読み込む    node=tagger.parseToNode(str(text))
node=tagger.parseToNode(str(all_text))
words={}

while node:
    word=node.surface
    if node.feature.split(",")[0]==u"名詞":
        if not words.has_key(word):
            words[word]=0
        words[word]+=1
    node=node.next
    
word_items=words.items()
word_items.sort(key=operator.itemgetter(1),reverse=True)

min = sys.argv[2] #頻度下限
for word, count in word_items:
    if int(count) >= int(min):
        if len(word) >= 3:#設定した下限以上出現した単語だけを出力
            print word, count	#出力結果をリダイレクトで取得するなど