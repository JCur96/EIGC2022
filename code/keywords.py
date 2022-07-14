# generate keywords from twitter text data using tf idf
# imports
import re
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from nltk.corpus import stopwords 
import pandas as pd
import json

# defs 
def pre_process(text):
    text = text.lower()
    # remove tags
    text = re.sub("&lt;/?.*?&gt;", "&lt;&gt;", text)
    # remove special characters and digits
    text = re.sub("(\\d|\\W)+", " ", text)
    return text

def sort_coo(coo_matrix):
    tuples = zip(coo_matrix.col, coo_matrix.data)
    return sorted(tuples, key = lambda x: (x[1], x[0]), reverse = True)

def extract_topN_from_vector(feature_names, sorted_items, topN = 10):
    sorted_items = sorted_items[:topN]
    score_vals = []
    feature_vals = []
    for idx, score in sorted_items: 
        score_vals.append(round(score, 3))
        feature_vals.append(feature_names[idx])
    results = {}
    for idx in range(len(feature_vals)): 
        results[feature_vals[idx]] = score_vals[idx]
    return results

def extract_all_from_vector(feature_names, sorted_items):
    score_vals = []
    feature_vals = []
    for idx, score in sorted_items: 
        score_vals.append(round(score, 3))
        feature_vals.append(feature_names[idx])
    results = {}
    for idx in range(len(feature_vals)): 
        results[feature_vals[idx]] = score_vals[idx]
    return results

# load json of tweets / text
df_idf = pd.read_json("data/tweet_text.json", lines = True)

# process 
df_idf['text'] = df_idf['text'].apply(lambda x:pre_process(x))

# using imported common stopwords
# stops = set(stopwords.words("english")) # needs nltk download to work 
docs = df_idf['text'].tolist()
cv = CountVectorizer(max_df=0.85, stop_words='english')
word_count_vector=cv.fit_transform(docs)
tfidf_transformer = TfidfTransformer(smooth_idf = True, use_idf= True)
tfidf_transformer.fit(word_count_vector)
feature_names = cv.get_feature_names()
tf_idf_vector = tfidf_transformer.transform(cv.transform(docs))
sorted_items = sort_coo(tf_idf_vector.tocoo())
keywords = extract_topN_from_vector(feature_names, sorted_items, 10)

all_keywords = extract_all_from_vector(feature_names, sorted_items)
json_object = json.dumps(all_keywords)

with open("data/all_keywords.json", "w") as outfile:
    outfile.write(json_object)

df_idf.to_csv("../data/text_for_R.csv", index=False)

print("\n===Top 10 Keywords===")
for k in keywords:
    print(k, keywords[k])
