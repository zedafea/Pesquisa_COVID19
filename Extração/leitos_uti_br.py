#!/usr/bin/env python
# coding: utf-8

# In[1]:


import requests as req
import json


# In[2]:


import pandas as pd


# In[3]:


# 0 < leitos <= 1
url = "https://dadosgeociencias.ibge.gov.br/server/rest/services/Hosted/LeitosUTI2019/FeatureServer/8/query?where=leitos_uti_total%20%3E%3D%200%20AND%20leitos_uti_total%20%3C%3D%201&outFields=objectid,codigo_municipio,nome_municipio,nome_estado,gr,leitos_uti_total,leitos_uti_100mil_hab_ind,leitos_uti_sus_total,leitos_uti_sus_100mil_hab_ind,pop_total&outSR=4326&f=json"


# In[4]:


# 1 < leitos <= 10000000000 (máx)
url_1 = "https://dadosgeociencias.ibge.gov.br/server/rest/services/Hosted/LeitosUTI2019/FeatureServer/8/query?where=leitos_uti_total%20%3E%3D%201%20AND%20leitos_uti_total%20%3C%3D%20100000000000000&outFields=objectid,codigo_municipio,nome_municipio,nome_estado,gr,leitos_uti_total,leitos_uti_100mil_hab_ind,leitos_uti_sus_total,leitos_uti_sus_100mil_hab_ind,pop_total&outSR=4326&f=json"


# In[ ]:


urls = [url,url_1,url_2]


# In[12]:


bar = req.get(url_1).text


# In[13]:


baz = json.loads(bar)


# In[14]:


foo = []


# In[15]:


for i in baz['features']:
    foo.append(i['attributes'])


# In[9]:


df = pd.json_normalize(foo)


# In[10]:


df.head()


# In[11]:


df.shape


# In[28]:


df['leitos_uti_total'].value_counts()


# In[29]:


df_1['leitos_uti_total'].value_counts()


# In[30]:


df_1[df_1['leitos_uti_total'] == 1]


# In[16]:


df_1 = pd.json_normalize(foo)


# In[17]:


df_1.head()


# In[18]:


df_1.shape


# In[20]:


dfs = [df,df_1]
result = pd.concat(dfs)


# In[22]:


result.head()


# In[24]:


result_1 = result.drop_duplicates()


# In[25]:


result_1.shape


# In[27]:


result_1[result_1['nome_estado'] == 'São Paulo']


# In[33]:


result_1.to_csv(r'C:\Users\guilh\Documents\R\GEPE\leitos_uti.csv')

