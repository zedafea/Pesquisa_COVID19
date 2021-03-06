library(readr)
library(readxl)
library(tidyverse)

#Importa��o dos dados de reelei��o e selecionando as colunas que nos interessam
dados_reeleicao = read.csv("consulta_cand_2020/consulta_cand_reeleicao_2020_SP.csv",
                           sep=';',encoding='latin1')
dados_reeleicao = dados_reeleicao %>%
  select("NM_UE","ST_REELEICAO")
#Importa��o dos c�digos dos munic�pios e jun��o com o dados_reeleicao
dados_codigo_mun = read_excel("R/GEPE/RELATORIO_DTB_BRASIL_MUNICIPIO.xls") %>%
  select("C�digo Munic�pio Completo","Nome_Munic�pio","Nome_UF") %>%
  filter(Nome_UF=="S�o Paulo")
dados_codigo_mun$Nome_Munic�pio = toupper(dados_codigo_mun$Nome_Munic�pio)
dados_reeleicao = inner_join(dados_reeleicao,dados_codigo_mun
                             ,by=c("NM_UE"="Nome_Munic�pio"))
dados_reeleicao = select(dados_reeleicao,c("C�digo Munic�pio Completo","ST_REELEICAO"))
#Importando dos dados de isolamento e limpeza
dados_isol = read_excel("R/GEPE/Dados.xlsx")
colnames(dados_isol) = dados_isol[1,]
dados_isol = dados_isol[-1,-266:-385]
#Constru��o da m�dia de isolamento pr� determina��o de lockdown (22/03)
dados_isol = dados_isol %>% 
  mutate_at(vars(-c(1,2,3,4)), ~as.numeric(as.character(.))) 
med = rowMeans(dados_isol[,5:27],na.rm=TRUE)
dim(med) <- c(140,1)
med <- as.vector(med)
dados_isol = mutate(dados_isol,media_isol_pre = med)
#Jun��o de dados_isol e dados_reeleicao
dados_isol = left_join(dados_isol,dados_reeleicao,
                       by=c("C�digo Munic�pio IBGE"="C�digo Munic�pio Completo"))
#Mudando o formato do df de "wide" para "long"
dados_isol <- gather(dados_isol,key='Dia',value='indice_isolamento',-c(1:4,266,267))
#Importando os dados de casos e mortos por COVID e limpeza
dados_casos = read.csv("R/GEPE/caso_sp.csv",encoding='latin1')
rownames(dados_casos) = dados_casos$X
dados_casos = dados_casos[,-1]
#Selecionando as colunas que nos interessam
dados_casos = dados_casos %>% select(city_ibge_code,date,last_available_confirmed_per_100k_inhabitants,
                       last_available_death_rate)
#Altera��es no formato dos dados para permitir o join
dados_casos$date = as.Date(dados_casos$date)
dados_isol$Dia = as.Date(dados_isol$Dia,format = "%d/%m/%y")
dados_isol$`C�digo Munic�pio IBGE` = as.numeric(dados_isol$`C�digo Munic�pio IBGE`)
#Testando diferentes tipos de join
df2=full_join(dados_isol,dados_casos,by=c("C�digo Munic�pio IBGE"="city_ibge_code",
                                           "Dia"="date"))

df3 = inner_join(dados_isol,dados_casos,by=c("C�digo Munic�pio IBGE"="city_ibge_code",
                                             "Dia"="date"))
#Manipula��o
colnames(df3)[3] <- 'pop'
df3$pop <- as.numeric(df3$pop)
#Testes
summary(lm(last_available_confirmed_per_100k_inhabitants~ST_REELEICAO,data=df3))
summary(lm(last_available_confirmed_per_100k_inhabitants~indice_isolamento,data=df3))
summary(lm(indice_isolamento~ST_REELEICAO+pop+media_isol_pre,data=df3))

ggplot(df3,aes(x=ST_REELEICAO,y=indice_isolamento)) + geom_point()
