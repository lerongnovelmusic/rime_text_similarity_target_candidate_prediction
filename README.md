# rime_text_similarity_target_candidate_prediction
**通过上下文智能排序用户所需候选词插件**
An approach, in Chinese keyboard, to predict and rank user's possible target candidate in candidate list in rime, by using a BERT model. / 这是一个基于BERT模型，在中文输入法环境下预测并排序用户最可能想要的候选词的一个rime输入法功能。

由本人和XYKK05(github用户名)共同开发。同时感谢hchunhui处拿来的json.lua文件(这个文件是开源的，项目地址https://github.com/hchunhui/librime-cloud)，以及感谢3q-u大佬处拿来的simplehttp.dll文件(项目地址：https://github.com/3q-u/rime-trans)。
目前还很不完善，预测效果可以说很糟糕，而且智能排序时会有卡顿感(这里说一句抱歉！)，会继续优化~

**功能特点:**
用户敲下拼音后，按下键盘上的"~"键，候选词们会被按照用户历史输入的50个文字的上下文，对现在拼音所对应的候选词进行重新排序。目的是让用户需要的词排在最前面，而不受传统的词频权重排序的困扰(比如是时事式，的地得，包子豹子，生活生火……)。注意现阶段触发智能排序后，候选词栏将不会显示生僻字和含有生僻字的词。

(注意: 本功能在rime的reduce_english_filter.lua文件上直接修改得来，这个lua文件原本的功能已经被移除。所以如果客官需要保留原reduce_english_filter.lua地功能，可能需要自己调整schema.yaml文件来适配，万分抱歉QWQ。)

rime_recent_chars.txt: 储存着用户的历史输入，仅动态保留最近输入的30个字。
candidates_weight.txt: 放着用户触发智能排序后，候选词栏中的候选词们的相似度数值。
rime_personal_debug_log.txt: 可以储存一些调试信息，但是目前没有使用。

**安装方法:**
1,把这个项目里的"reduce_english_filter.lua", "select_character.lua"以及"local_translation_server.py", "json.lua”放到你的rime用户文件夹里的lua文件夹里(会提示"reduce_english_filter.lua"和"select_character.lua"已存在，选择替换即可)

2,把这个项目里的“rime_recent_chars.txt”, "rime_personal_debug_log.txt", "candidates_weight.txt"放到你的rime用户文件夹里

3,把simplehttp.dll放到小狼毫程序文件夹里

5,从https://huggingface.co/uer/chinese_roberta_L-12_H-512/tree/main处下载BERT模型文件，解压后会是叫“Chinese_roberta_L-12_H-512”的文件夹。

4,打开local_translation_server.py, select_character.lua, 搜索注释“改为这个文件在你电脑里的地址”，然后在对应的行里修改它们使用的模型文件夹和txt文件的路径。

5,运行local_translation_server.py，应该会提示缺少一些库，安装库即可，推荐多用不同的镜像，清华啊，阿里啊都试试。local_translation_server.py要运行成功

6,重新部署即可。

以后，如果想要开启智能排序功能，只要确保local_translation_server.py在电脑后台运行着就OK啦。


**致谢:**
感谢3q-u大佬的项目https://github.com/3q-u/rime-trans，我的simplehttp.dll是从这里拿来的
感谢hchunhui大佬的项目https://github.com/hchunhui/librime-cloud，我的json.lua文件是从这里拿来的
感谢XYKK05，这是本项目的另一个作者。

**许可证:**
本项目遵循开源协议，欢迎贡献和改进。

