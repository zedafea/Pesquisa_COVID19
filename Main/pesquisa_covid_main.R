library(readr)
library(readxl)
library(tidyverse)

#Importação dos dados de reeleição e selecionando as colunas que nos interessam
dados_reeleicao = read.csv("consulta_cand_2020/consulta_cand_reeleicao_2020_SP.csv",
                           sep=';',encoding='latin1')
dados_reeleicao = dados_reeleicao %>%
  select("NM_UE","ST_REELEICAO")
#Importação dos códigos dos municípios e junção com o dados_reeleicao
dados_codigo_mun = read_excel("R/GEPE/RELATORIO_DTB_BRASIL_MUNICIPIO.xls") %>%
  select("Código Município Completo","Nome_Município","Nome_UF") %>%
  filter(Nome_UF=="São Paulo")
dados_codigo_mun$Nome_Município = toupper(dados_codigo_mun$Nome_Município)
dados_reeleicao = inner_join(dados_reeleicao,dados_codigo_mun
                             ,by=c("NM_UE"="Nome_Município"))
dados_reeleicao = select(dados_reeleicao,c("Código Município Completo","ST_REELEICAO"))
#Importando dos dados de isolamento e limpeza
dados_isol = read_excel("R/GEPE/Dados.xlsx")
colnames(dados_isol) = dados_isol[1,]
dados_isol = dados_isol[-1,-266:-385]
#Construção da média de isolamento pré determinação de lockdown (22/03)
dados_isol = dados_isol %>% 
  mutate_at(vars(-c(1,2,3,4)), ~as.numeric(as.character(.))) 
med = rowMeans(dados_isol[,5:27],na.rm=TRUE)
dim(med) <- c(140,1)
med <- as.vector(med)
dados_isol = mutate(dados_isol,media_isol_pre = med)
#Junção de dados_isol e dados_reeleicao
dados_isol = left_join(dados_isol,dados_reeleicao,
                       by=c("Código Município IBGE"="Código Município Completo"))
#Mudando o formato do df de "wide" para "long"
dados_isol <- gather(dados_isol,key='Dia',value='indice_isolamento',-c(1:4,266,267))
#Importando os dados de casos e mortos por COVID e limpeza
dados_casos = read.csv("R/GEPE/caso_sp.csv",encoding='latin1')
rownames(dados_casos) = dados_casos$X
dados_casos = dados_casos[,-1]
#Selecionando as colunas que nos interessam
dados_casos = dados_casos %>% select(city_ibge_code,date,last_available_confirmed_per_100k_inhabitants,
                       last_available_death_rate)
#Alterações no formato dos dados para permitir o join
dados_casos$date = as.Date(dados_casos$date)
dados_isol$Dia = as.Date(dados_isol$Dia,format = "%d/%m/%y")
dados_isol$`Código Município IBGE` = as.numeric(dados_isol$`Código Município IBGE`)
#Testando diferentes tipos de join
df2=full_join(dados_isol,dados_casos,by=c("Código Município IBGE"="city_ibge_code",
                                           "Dia"="date"))

df3 = inner_join(dados_isol,dados_casos,by=c("Código Município IBGE"="city_ibge_code",
                                             "Dia"="date"))
#Manipulação
colnames(df3)[3] <- 'pop'
df3$pop <- as.numeric(df3$pop)
#Testes
summary(lm(last_available_confirmed_per_100k_inhabitants~ST_REELEICAO,data=df3))
summary(lm(last_available_confirmed_per_100k_inhabitants~indice_isolamento,data=df3))
summary(lm(indice_isolamento~ST_REELEICAO+pop+media_isol_pre,data=df3))

ggplot(df3,aes(x=ST_REELEICAO,y=indice_isolamento)) + geom_point()
