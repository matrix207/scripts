###What it is
**ds2img**.py (**D**ata**S**tructure **T**o **I**mage) 

A python script transfer c header file which contains lots of data structures 
to a dot script, and then use dot to convert to a image file

###How to run

	Usage: ds2imgpy -i INPUT_FILE -f png|svg -o OUTPUT_FILE [-d DOT_FILE]

	-i  input file which have structures"
	-f  image fomat, only support png and svg"
	-o  output file, image file"
	-d  dot script file, default is tmp.dot"

	e.g:

		python ds2img.py -i t.h -f png -o t.png 

###TODO
Waiting for your advices

###Reference
* [★★★使用graphviz画数据结构](http://emacser.com/emacs_graphviz_ds.htm)
* [graphviz for Data Structures](http://www.graphviz.org/content/datastruct)
* [使用graphviz dot来画图表](http://gashero.iteye.com/blog/1748795)
* [Python正则表达式指南](http://www.cnblogs.com/huxi/archive/2010/07/04/1771073.html)
* [★★python文件操作字符串操作总结](http://blog.csdn.net/wangyezi19930928/article/details/25652295)
* [用python如何匹配注释](http://zhidao.baidu.com/link?url=lwqlXGEAznkWAc26v929RcbA-TuG_McqeQ2BgRWWXaiNS2KQPfU4LR-QdmJkn3eWb5Bfn6qA_7wAboaFThjUkSznQi432soyDnXbd3vPxWO)
* [Python文件去除注释](http://blog.csdn.net/xmnathan/article/details/4192821)
* [★★★遍历python字典几种方法](http://5iqiong.blog.51cto.com/2999926/806230)
* [python循环遍历字典元素](http://www.cnblogs.com/skyhacker/archive/2012/01/27/2330177.html)
* [Python的字典操作](http://blog.csdn.net/nrs12345/article/details/4869272)
* [★★★python解析ini文件](http://blog.csdn.net/feixin620/article/details/4209783)
* [python_getopt解析命令行输入参数的使用](http://blog.csdn.net/xiaocaiju/article/details/7590106)
