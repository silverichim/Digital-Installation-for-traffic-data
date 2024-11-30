## Pacotes---------------------
install.packages("stringr")
library("tidyverse")
library("dplyr")
library("stringr")


## Importando arquivo------------
getwd()
setwd("D:/Google Drive/3.MESTRADO/DADOS/MIN_TRANSPORTES")
dados <- read.csv(file = "Acidentes_DadosAbertos_20230412.csv", sep = ";") #Fonte: Min dos Transportes

## variaveis---------------------
###população (Fonte:IBGE)
pop2022 <- c(203062512)
pop2021 <- c(213317639)
pop2020 <- c(211755692)
pop2019 <- c(210147125)
###frota de veiculos ativos (Fonte:Min Transportes)
frota2022 <- c(77902792)
frota2021 <- c(74238437)
frota2020 <- c(70747587)
frota2019 <- c(67601798)

## Analise-----------------------

str(dados) #verificar a estrutura dos dados
tibble(dados)

### Filtro macro
tipo_acid<- dados %>%
  select(tp_acidente, qtde_acidente, mes_acidente, ano_acidente, uf_acidente, chv_localidade) %>%
  filter(str_detect(tp_acidente, "PEDESTRE")) %>%
  group_by(uf_acidente)#dataframe com o tipo de acidente, quantidade, mes, ano e estado, com filtro para ocorrências com pedestres


str(dados)


#### Acidentes com pedestres a cada 100 mil habitantes 2022 (Nacional)
acid_2022 <- tipo_acid %>%
  ungroup()%>%
  select(qtde_acidente, ano_acidente, uf_acidente) %>%
  filter(ano_acidente == '2022')#filtro do respectivo ano

tibble(acid_2022)

soma_acid_2022 <- acid_2022 %>%
  select(qtde_acidente)%>%
  colSums(acid_2022$qtde_acidente)
  

tibble(soma_acid_2022)

media_2022 <-c((soma_acid_2022/pop2022)*1000000)
afv22 <- (soma_acid_2022/frota2022)*10000
  
#### Acidentes com pedestres a cada 100 mil habitantes 2021 (Nacional)
acid_2021 <- tipo_acid %>%
  select(qtde_acidente, ano_acidente) %>%
  filter(ano_acidente == '2021') #filtro do respectivo ano

tibble(acid_2021) #tabela de acidentes 2021

soma_acid_2021 <- acid_2021 %>%
  ungroup() %>%
  select(qtde_acidente)%>%
  colSums(acid_2021$qtde_acidente) #soma da coluna de acidentes

tibble(soma_acid_2021)

media_2021 <-(soma_acid_2021/pop2021)*100000 #quantidade de acidentes, dividido pela população, multiplicado por 100mil (hab.)
afv21 <- (soma_acid_2021/frota2021)*10000
  
#### Acidentes com pedestres a cada 100 mil habitantes 2020 (Nacional)
acid_2020 <- tipo_acid %>%
  select(qtde_acidente, ano_acidente) %>%
  filter(ano_acidente == '2020') #filtro do respectivo ano

tibble(acid_2020) #tabela de acidentes 2020

soma_acid_2020 <- acid_2020 %>%
  ungroup() %>%
  select(qtde_acidente)%>%
  colSums(acid_2020$qtde_acidente) #soma da coluna de acidentes
tibble(soma_acid_2020)

media_2020 <-(soma_acid_2020/pop2020)*100000 #quantidade de acidentes, dividido pela população, multiplicado por 100mil (hab.)
afv20 <- (soma_acid_2020/frota2020)*10000
tibble(media_2020)


#### Acidentes com pedestres a cada 100 mil habitantes 2019 (Nacional)
acid_2019 <- tipo_acid %>%
  select(qtde_acidente, ano_acidente, uf_acidente) %>%
  filter(ano_acidente == '2019') #filtro do respectivo ano

tibble(acid_2019) #tabela de acidentes 2019

soma_acid_2019 <- acid_2019 %>%
  ungroup() %>%
  select(qtde_acidente)%>%
  colSums(acid_2019$qtde_acidente) #soma da coluna de acidentes

tibble(soma_acid_2019)

media_2019 <- (soma_acid_2019/pop2019)*100000 #quantidade de acidentes, dividido pela população, multiplicado por 100mil (hab.)
afv19 <- (soma_acid_2019/frota2019)*10000

indice_acidentes <- c(media_2019, media_2020, media_2021, media_2022)

tibble(indice=indice_acidentes,
anos=c(2019,2020,2021,2022))


## quantidade de acidentes no ES por ano

acidentes_es <- tipo_acid %>%
  select(tp_acidente, uf_acidente, ano_acidente, qtde_acidente, chv_localidade) %>%
  filter(uf_acidente == 'ES') %>%
  group_by(ano_acidente)


#### ------------------ Vitoria

acidentes_vix <-acidentes_es %>%
  select(tp_acidente, uf_acidente, ano_acidente, qtde_acidente, chv_localidade) %>%
  filter(str_detect(chv_localidade, "ES3205309")) %>%
  group_by(ano_acidente) ## filtrar o município

soma_vix20 <- acidentes_vix %>% ##mudar o ano no filtro para obter os números do respectivo ano
  ungroup()%>%
  select(ano_acidente, qtde_acidente)%>%
  filter(ano_acidente == '2020')%>%
  colSums(acidentes_vix$qtde_acidente)

print(soma_vix20) ## exibir a quantidade de acidentes para o ano inserido no filtro
result.vix <-data.frame(
  ano=c(2019, 2020, 2021, 2022),
  qtd_acid= c(188, 107, 218, 115)) #data frame com a quantidade de acidentes para o respectivo ano

as_tibble(result.vix) ## visualizar a tabela
colSums(result.vix) ## somar a coluna de acidentes



#### ------------------ Vila Velha

acidentes_v.velha <-acidentes_es %>%
  select(tp_acidente, uf_acidente, ano_acidente, qtde_acidente, chv_localidade) %>%
  filter(str_detect(chv_localidade, "ES3205200")) %>%
  group_by(ano_acidente) ## filtrar o município

soma_vv <- acidentes_v.velha %>% ##mudar o ano no filtro para obter os números do respectivo ano
  ungroup()%>%
  select(ano_acidente, qtde_acidente)%>%
  filter(ano_acidente == '2022')%>%
  colSums(acidentes_v.velha$qtde_acidente)

print(soma_vv) ## exibir a quantidade de acidentes para o ano inserido no filtro
result.vv <-data.frame(
  ano=c(2019, 2020, 2021, 2022),
  qtd_acid= c(157, 106, 225, 140)) #data frame com a quantidade de acidentes para o respectivo ano

as_tibble(result.vv) ## visualizar a tabela
colSums(result.vv) ## somar a coluna de acidentes


#### ------------------ Serra

acidentes_serra <-acidentes_es %>%
  select(tp_acidente, uf_acidente, ano_acidente, qtde_acidente, chv_localidade) %>%
  filter(str_detect(chv_localidade, "3205002")) %>%
  group_by(ano_acidente) ## filtrar o município

soma_serra <- acidentes_serra %>% ##mudar o ano no filtro para obter os números do respectivo ano
  ungroup()%>%
  select(ano_acidente, qtde_acidente)%>%
  filter(ano_acidente == '2019')%>%
  colSums(acidentes_serra$qtde_acidente)

print(soma_serra) ## exibir a quantidade de acidentes para o ano inserido no filtro
result.serra <-data.frame(
  ano=c(2019, 2020, 2021, 2022),
  qtd_acid= c(142, 90, 208, 128)) #data frame com a quantidade de acidentes para o respectivo ano

as_tibble(result.serra) ## visualizar a tabela
colSums(result.serra) ## somar a coluna de acidentes


#### ------------------ Cariacica

acidentes_cariacica <-acidentes_es %>%
  select(tp_acidente, uf_acidente, ano_acidente, qtde_acidente, chv_localidade) %>%
  filter(str_detect(chv_localidade, "3201308")) %>%
  group_by(ano_acidente) ## filtrar o município

soma_cariacica <- acidentes_cariacica %>% ##mudar o ano no filtro para obter os números do respectivo ano
  ungroup()%>%
  select(ano_acidente, qtde_acidente)%>%
  filter(ano_acidente == '2020')%>%
  colSums(acidentes_cariacica$qtde_acidente)

print(soma_cariacica) ## exibir a quantidade de acidentes para o ano inserido no filtro

result.cariacica <-data.frame(
  ano=c(2019, 2020, 2021, 2022),
  qtd_acid= c(108, 67, 160, 95)) #data frame com a quantidade de acidentes para o respectivo ano

as_tibble(result.cariacica) ## visualizar a tabela
colSums(result.cariacica) ## Somar a coluna de acidentes


### total_GV

GrandeVix <- bind_rows(result.vix, result.vv, result.cariacica, result.serra)
as_tibble(GrandeVix)

somaGv <- GrandeVix%>%
  ungroup()%>%
  select(ano, qtd_acid) %>%
  filter(ano == '2020')%>%
  colSums(GrandeVix$qtd_acid) #total acidentes na Grande vitória no respectivo ano

print(somaGv)

result_gv <- data.frame(
  ano = c(2019, 2020, 2021, 2022),
  qtd = c(595, 370, 811, 478)
  )
colSums(result_gv)

#### Media estadual (rever código)
soma_es <- acidentes_es %>%
  ungroup() %>%
  select(ano_acidente, qtde_acidente) %>%
  filter(ano_acidente == '2022') %>%
  colSums(acidentes_es$qtde_acidente)

print(soma_es)

result_es <- data.frame(
  ano = c(2019, 2020, 2021, 2022),
  qtd = c(1236, 767, 1918, 1025)
)




