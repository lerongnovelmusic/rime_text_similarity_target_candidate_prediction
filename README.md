# rime_text_similarity_target_candidate_prediction

**通过上下文智能排序用户所需候选词插件**  
An approach, in Chinese keyboard, to predict and rank user's possible target candidate in candidate list in Rime, by using a BERT model.  
这是一个基于BERT模型，在中文输入法环境下预测并排序用户最可能想要的候选词的 Rime 输入法功能。

由本人和 [XYKK05](https://github.com/XYKK05) 共同开发。  
特别感谢：  
- [hchunhui/librime-cloud](https://github.com/hchunhui/librime-cloud)（提供 `json.lua` 文件）  
- [3q-u/rime-trans](https://github.com/3q-u/rime-trans)（提供 `simplehttp.dll` 文件）  

> ⚠️ 目前项目仍不完善，预测效果可能较差，且智能排序时会有卡顿感。我们会持续优化！

---

## 功能特点
用户输入拼音后，按下 `~` 键，候选词会根据用户**最近输入的50个文字**的上下文重新排序。目标是让用户需要的词优先显示，避免传统词频排序的困扰（例如：是/事/时、的/地/得、包子/豹子、生活/生火等）。  

📌 **注意**：  
1. 触发智能排序后，候选词栏将不再显示生僻字及含生僻字的词。  
2. 本功能基于 `reduce_english_filter.lua` 修改，原功能已被移除。如需保留原功能，请手动调整 `schema.yaml` 文件。  

---

## 文件说明
- `rime_recent_chars.txt`：记录用户最近输入的30个字符。  
- `candidates_weight.txt`：存储候选词的相似度数值。  
- `rime_personal_debug_log.txt`：预留调试日志文件（暂未使用）。  

---

## 安装方法
1. **复制文件**：  
   - 将以下文件放入 Rime 用户文件夹的 `lua` 目录（覆盖原有文件）：  
     ```
     reduce_english_filter.lua  
     select_character.lua  
     local_translation_server.py  
     json.lua
     ```
   - 将以下文件放入 Rime 用户文件夹根目录：  
     ```
     rime_recent_chars.txt  
     rime_personal_debug_log.txt  
     candidates_weight.txt
     ```
   - 将 `simplehttp.dll` 放入小狼毫程序文件夹。

2. **下载模型**：  
   从 [HuggingFace](https://huggingface.co/uer/chinese_roberta_L-12_H-512/tree/main) 下载 BERT 模型，解压为 `Chinese_roberta_L-12_H-512` 文件夹。

3. **配置路径**：  
   修改 `local_translation_server.py` 和 `select_character.lua` 中的路径注释（搜索 `改为这个文件在你电脑里的地址`）。

4. **运行服务**：  
   - 运行 `local_translation_server.py`，根据提示安装缺失的依赖库（建议使用清华/阿里等镜像加速）。  
   - 确保服务后台运行后，重新部署 Rime。  

---

## 致谢
- [3q-u/rime-trans](https://github.com/3q-u/rime-trans)  
- [hchunhui/librime-cloud](https://github.com/hchunhui/librime-cloud)  
- 共同开发者 [XYKK05](https://github.com/XYKK05)  

---

## 许可证
本项目遵循开源协议，欢迎贡献和改进！
