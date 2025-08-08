import os
os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'

import math
import time
import jieba
import json
import sys
from flask import Flask, request, jsonify
import logging
import torch
from transformers import BertTokenizer, BertModel
from functools import lru_cache
import numpy as np

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class BERTSimilarityCalculator:
    def __init__(self, model_path="F:\For_tencent_Chinese_Embeddings\Chinese_roberta_L-12_H-512"): # 改为这个文件在你电脑里的地址,这个模型需要自己下，github README文件有下载地址注意地址的文件夹层级不要出现重名情况
        self.tokenizer = BertTokenizer.from_pretrained(model_path,num_threads=4)
        self.model = BertModel.from_pretrained(model_path)
        
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = self.model.to(self.device)
        self.model.eval()
    
    @lru_cache(maxsize=1000)  
    def _get_embedding(self, text):
        inputs = self.tokenizer(
            text,
            return_tensors="pt",
            max_length=64,         
            truncation=True,
            padding='max_length'  
        ).to(self.device)
        
        with torch.no_grad():
            outputs = self.model(**inputs)
        return outputs.last_hidden_state.mean(dim=1)  
    
    def calculate_similarities(self, input_text, candidate_words):
        # 批量编码候选词
        candidate_inputs = self.tokenizer(
            candidate_words,
            return_tensors="pt",
            padding=True,
            truncation=True,
            max_length=32  
        ).to(self.device)
        
        with torch.no_grad():
            candidate_embeds = self.model(**candidate_inputs).last_hidden_state.mean(dim=1)
        
        input_embed = self._get_embedding(input_text)
        
        sims = torch.cosine_similarity(
            input_embed, 
            candidate_embeds, 
            dim=1
        )
        
        return {word: sim.item() for word, sim in zip(candidate_words, sims)}

calculator = BERTSimilarityCalculator()

@app.route('/calculate_similarity', methods=['POST'])
def calculate_similarity():
    try:
        data = request.get_json()
        candidate_words = data.get('candidates', [])

        with open("D:\\For_Rime\\For_Rime_config\\rime_recent_chars.txt", 'r', encoding='utf-8') as file: #改为这个文件在你电脑里的地址
            input_text = file.read()
        
        similarities = calculator.calculate_similarities(input_text, candidate_words)

        with open("D:\\For_Rime\\For_Rime_config\\candidates_weight.txt", "w", encoding="utf-8") as f: #改为这个文件在你电脑里的地址
            for word, similarity in similarities.items():
                f.write(f"{word} {similarity:.4f}\n")

        serializable_similarities = {
            word: float(similarity) 
            for word, similarity in similarities.items()
        }

        return jsonify({
            "status": "success",
            "similarities": serializable_similarities
        })
    
    except Exception as e:
        logger.error(f"计算错误: {str(e)}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000, debug=False)