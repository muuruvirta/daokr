# ============================================================
# Demo 5: Muuttujien välisten yhteyksien tutkiminen
# ============================================================
# Tavoite:
# - muodostaa frekvenssi- ja ristiintaulukoita
# - tarkastella kategoristen muuttujien välisiä yhteyksiä
# - tarkastella numeeristen muuttujien välisiä yhteyksiä
# - laskea ja tulkita korrelaatiota
# - muodostaa yksinkertainen lineaarinen regressiomalli
# - tulkita regressiosuoraa ja selitysastetta
#
# Demossa käytetään R:n valmista mtcars-aineistoa.
# ============================================================


# Ladataan tidyverse-pakettikokoelma.
# library() ottaa asennetun paketin käyttöön tässä R-istunnossa.
# tidyverse sisältää tässä demossa tarvittavat dplyr- ja
# ggplot2-paketit.

library(tidyverse)


################################
#  1. Aineistoon tutustuminen
################################

# as_tibble() muuttaa aineiston tibble-muotoon.
#
# rownames = "Auto" siirtää mtcars-aineiston alkuperäiset
# rivien nimet omaan Auto-sarakkeeseen.

data <- as_tibble(mtcars, rownames = "Auto")

# glimpse() näyttää aineiston rakenteen tiiviisti:
# rivien ja sarakkeiden määrän, sarakkeiden nimet,
# tietotyypit ja esimerkkiarvoja.

glimpse(data)

# head() näyttää aineiston ensimmäiset rivit.

head(data)

# Tässä demossa käytämme erityisesti seuraavia muuttujia:
#
# mpg = polttoainetaloudellisuus, mailia/gallona
# wt  = auton paino, 1000 paunaa
# hp  = moottorin teho hevosvoimina
# cyl = sylinterien määrä
# am  = vaihteisto, 0 = automaatti ja 1 = manuaali


###############################################
#  2. Kategoristen muuttujien muodostaminen
###############################################

# mutate() lisää aineistoon uusia muuttujia tai muokkaa
# olemassa olevia muuttujia.
#
# factor() muuttaa muuttujan kategoriseksi muuttujaksi
# eli faktoriksi.
#
# levels määrittää alkuperäiset arvot.
# labels antaa alkuperäisille arvoille selkeät nimet.

data <- data |>
  mutate(
    Sylinterit = factor(cyl),
    Vaihteisto = factor(
      am,
      levels = c(0, 1),
      labels = c("Automaatti", "Manuaali")
    )
  )

# Tarkistetaan aineiston rakenne ja uudet muuttujat.

glimpse(data)


###############################
#  3. Frekvenssitaulukko
###############################

# count() laskee muuttujan eri arvojen lukumäärät.
# Lukumäärää kutsutaan absoluuttiseksi frekvenssiksi.
#
# name-parametrilla määritetään frekvenssit sisältävän
# sarakkeen nimeksi Frekvenssi.

frekvenssit <- data |>
  count(Sylinterit, name = "Frekvenssi")

frekvenssit


#######################################
#  4. Suhteellinen frekvenssi
#######################################

# mutate() lisää frekvenssitaulukkoon uusia sarakkeita.
#
# sum(Frekvenssi) laskee havaintojen kokonaismäärän.
#
# Suhteellinen frekvenssi saadaan jakamalla ryhmän frekvenssi
# kaikkien havaintojen kokonaismäärällä.
#
# Prosenttiosuus saadaan kertomalla suhteellinen frekvenssi
# sadalla.

frekvenssit <- frekvenssit |>
  mutate(
    Suhteellinen_frekvenssi = Frekvenssi / sum(Frekvenssi),
    Prosenttia = Suhteellinen_frekvenssi * 100
  )

frekvenssit


#########################################
#  5. Kumulatiivinen frekvenssi
#########################################

# cumsum() laskee kumulatiivisen eli kertyvän summan.
#
# Kumulatiivinen frekvenssi kertoo, kuinka monta havaintoa
# on kertynyt kyseiseen luokkaan mennessä.
#
# Kumulatiivinen prosenttiosuus kertoo vastaavan tiedon
# prosentteina.

frekvenssit <- frekvenssit |>
  mutate(
    Kumulatiivinen_frekvenssi = cumsum(Frekvenssi),
    Kumulatiivinen_prosentti = cumsum(Prosenttia)
  )

frekvenssit

# Kumulatiivinen frekvenssi on mielekäs silloin, kun luokilla
# on luonnollinen järjestys.
#
# Sylinterien määrällä tällainen järjestys on olemassa.
# Sen sijaan esimerkiksi auton värille kumulatiivista
# frekvenssiä ei yleensä olisi mielekästä laskea.


################################
#  6. Ristiintaulukointi
################################

# table() muodostaa frekvenssitaulukon yhdestä tai useammasta
# kategorisesta muuttujasta.
#
# Kun table()-funktiolle annetaan kaksi muuttujaa,
# tuloksena saadaan ristiintaulukko.
#
# Muuttujat nimetään table()-funktion sisällä.
# Näin myös taulukon riveille ja sarakkeille saadaan
# selkeät otsikot.

ristiintaulukko <- table(
  Sylinterit = data$Sylinterit,
  Vaihteisto = data$Vaihteisto
)

# Tulostetaan ristiintaulukko.

cat("\nRistiintaulukko:\n")

ristiintaulukko

# Taulukosta voidaan tarkastella, kuinka monta automaatti- ja
# manuaalivaihteista autoa eri sylinteriluokissa on.
#
# Rivit 4, 6 ja 8 tarkoittavat sylinterien lukumäärää.


#########################################
#  7. Summat ristiintaulukkoon
#########################################

# addmargins() lisää ristiintaulukkoon rivi- ja sarakesummat.
#
# cat() tulostaa konsoliin otsikon.
# Se ei muuta taulukkoa eikä vaikuta laskentaan.

cat("\nRistiintaulukko rivi- ja sarakesummilla:\n")

addmargins(ristiintaulukko)


#####################################
#  8. Suhteelliset osuudet
#####################################

# prop.table() muuttaa frekvenssit suhteellisiksi osuuksiksi.
#
# Ilman margin-parametria osuudet lasketaan suhteessa
# koko aineiston havaintomäärään.

cat("\nSuhteelliset osuudet koko aineistosta:\n")

prop.table(ristiintaulukko)

# Suhteelliset osuudet voidaan muuttaa prosenteiksi
# kertomalla ne sadalla.

cat("\nProsenttiosuudet koko aineistosta:\n")

prop.table(ristiintaulukko) * 100


#######################################
#  9. Rivi- ja sarakeprosentit
#######################################

# margin = 1 laskee prosenttiosuudet riveittäin.
#
# Jokaisen rivin summa on 100 prosenttia.
#
# Tässä tarkastellaan, miten automaatti- ja
# manuaalivaihteiset autot jakautuvat kunkin
# sylinterimäärän sisällä.

cat("\nRiviprosentit:\n")

prop.table(ristiintaulukko, margin = 1) * 100

# margin = 2 laskee prosenttiosuudet sarakkeittain.
#
# Jokaisen sarakkeen summa on 100 prosenttia.
#
# Tässä tarkastellaan, miten eri sylinterimäärät
# jakautuvat automaatti- ja manuaalivaihteisten
# autojen sisällä.

cat("\nSarakeprosentit:\n")

prop.table(ristiintaulukko, margin = 2) * 100


###############################################
#  10. Ristiintaulukon visualisointi
###############################################

# geom_bar() tekee pylväsdiagrammin ja laskee automaattisesti
# kategorioiden havaintomäärät.
#
# fill = Vaihteisto jakaa pylväät vaihteiston mukaan.
#
# position = "dodge" sijoittaa automaatti- ja
# manuaalivaihteisten autojen pylväät vierekkäin.
#
# labs() lisää kuvaajaan otsikon, akselien nimet
# ja selitteen otsikon.

ggplot(data, aes(x = Sylinterit, fill = Vaihteisto)) +
  geom_bar(position = "dodge") +
  labs(
    title = "Vaihteistot sylinterimäärän mukaan",
    x = "Sylinterien määrä",
    y = "Autojen määrä",
    fill = "Vaihteisto"
  ) +
  theme_minimal()


################################################
#  11. Kahden numeerisen muuttujan yhteys
################################################

# Hajontakuviolla voidaan tarkastella kahden numeerisen
# muuttujan välistä mahdollista yhteyttä.
#
# geom_point() tekee hajontakuvion, jossa jokainen piste
# vastaa yhtä aineiston autoa.
#
# Tarkastellaan auton painon ja polttoainetaloudellisuuden
# välistä yhteyttä.

ggplot(data, aes(x = wt, y = mpg)) +
  geom_point() +
  labs(
    title = "Auton paino ja polttoainetaloudellisuus",
    x = "Paino (1000 paunaa)",
    y = "Mailia/gallona"
  ) +
  theme_minimal()

# Tarkastele kuviota:
#
# - Näyttääkö muuttujien välillä olevan yhteyttä?
# - Onko mahdollinen yhteys positiivinen vai negatiivinen?
# - Kuinka voimakkaalta yhteys näyttää?
# - Näkyykö aineistossa mahdollisia poikkeavia havaintoja?


#########################
#  12. Korrelaatio
#########################

# cor() laskee kahden numeerisen muuttujan välisen
# korrelaatiokertoimen.
#
# Oletuksena cor() laskee Pearsonin korrelaatiokertoimen.
#
# Korrelaatiokerroin saa arvoja väliltä -1 ja +1.
#
# Arvo lähellä +1 tarkoittaa voimakasta positiivista
# lineaarista yhteyttä.
#
# Arvo lähellä -1 tarkoittaa voimakasta negatiivista
# lineaarista yhteyttä.
#
# Arvo lähellä nollaa tarkoittaa, että lineaarinen
# yhteys on heikko.

cor(data$wt, data$mpg)

# use = "complete.obs" jättää laskennasta pois rivit,
# joilla on puuttuvia arvoja jommassakummassa muuttujassa.

cor(
  data$wt,
  data$mpg,
  use = "complete.obs"
)

# Korrelaatio kertoo muuttujien välisestä lineaarisesta
# yhteydestä, mutta se ei osoita syy-seuraussuhdetta.


#####################################
#  13. Lineaarinen regressio
#####################################

# Lineaarisessa regressiossa aineiston havaintopisteisiin
# sovitetaan suora.
#
# R etsii sellaisen suoran, joka kuvaa havaintopisteitä
# mahdollisimman hyvin.
#
# Suoran avulla voidaan kuvata, miten yhden muuttujan
# muuttuminen liittyy toisen muuttujan muuttumiseen.
#
# Mallissa on kaksi muuttujaa:
#
# - selitettävä muuttuja, jonka arvoa halutaan selittää
#   tai ennustaa
#
# - selittävä muuttuja, jonka avulla selitettävän muuttujan
#   vaihtelua pyritään selittämään
#
# Tässä auton painolla yritetään selittää
# polttoainetaloudellisuutta.
#
# mpg on selitettävä muuttuja.
# wt on selittävä muuttuja.
#
# Ajatus on:
#
# auton paino -> regressiomalli -> arvio polttoainetaloudellisuudesta
#
# lm() muodostaa lineaarisen regressiomallin.
#
# Malli kirjoitetaan muodossa:
#
# selitettävä muuttuja ~ selittävä muuttuja
#
# Merkki ~ voidaan lukea tässä:
#
# "selitetään muuttujalla"
#
# Siten mpg ~ wt tarkoittaa:
#
# "mpg:tä selitetään wt:llä"

malli <- lm(mpg ~ wt, data = data)

# Muodostettu regressiomalli tallennetaan muuttujaan malli.
#
# Kun muuttujan nimi kirjoitetaan konsoliin,
# R näyttää mallin tärkeimmät kertoimet.

malli


###########################################
#  14. Regressiosuoran yhtälö
###########################################

# Lineaarisen regressiomallin yleinen muoto on:
#
# y = a + bx
#
# jossa:
#
# y = selitettävän muuttujan ennustettu arvo
# a = vakiotermi
# b = kulmakerroin
# x = selittävän muuttujan arvo
#
# coef() palauttaa regressiomallin kertoimet.
#
# Ensimmäinen kerroin on vakiotermi.
# Toinen kerroin on kulmakerroin.

coef(malli)

# Tallennetaan kertoimet omiin muuttujiinsa.

a <- coef(malli)[1]
b <- coef(malli)[2]

a
b

# Tässä mallissa:
#
# x tarkoittaa auton painoa
# y tarkoittaa auton arvioitua polttoainetaloudellisuutta
#
# Muodostetaan yhtälö tekstiksi ja pyöristetään
# kertoimet kahden desimaalin tarkkuuteen.

yhtalo <- paste(
  "y =",
  round(a, 2),
  "+",
  round(b, 2),
  "x"
)

yhtalo


###########################################
#  15. Kulmakertoimen tulkinta
###########################################

# Kulmakerroin kertoo, kuinka paljon selitettävän muuttujan
# ennustettu arvo muuttuu, kun selittävä muuttuja kasvaa
# yhden yksikön.
#
# Jos kulmakerroin on negatiivinen, y pienenee x:n kasvaessa.
#
# Jos kulmakerroin on positiivinen, y kasvaa x:n kasvaessa.
#
# Tässä aineistossa wt-muuttujan yksi yksikkö vastaa
# 1000 paunaa.
#
# Negatiivinen kulmakerroin tarkoittaa, että auton painon
# kasvaessa arvioitu polttoainetaloudellisuus pienenee.

b


################################################
#  16. Regressiosuoran visualisointi
################################################

# geom_smooth(method = "lm") lisää hajontakuvioon
# lineaarisen regressiosuoran.
#
# Kuvaajan pisteet ovat aineiston todellisia havaintoja.
#
# Suora on mallin sovittama regressiosuora, joka kuvaa
# pistejoukon yleistä suuntaa.
#
# Kaikkien pisteiden ei tarvitse olla suoralla.
#
# se = FALSE poistaa suoran ympäriltä luottamusvälin.
# Luottamusväleihin palataan myöhemmin kurssilla.

ggplot(data, aes(x = wt, y = mpg)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Auton painon ja polttoainetaloudellisuuden yhteys",
    x = "Paino (1000 paunaa)",
    y = "Mailia/gallona"
  ) +
  theme_minimal()


##################################
#  17. Mallin yhteenveto
##################################

# summary() näyttää regressiomallista tarkempia tietoja.
#
# Tuloksessa näkyvät esimerkiksi:
#
# - regressiokertoimet
# - mallin selitysaste R²
# - jäännösten tunnuslukuja
# - tilastolliseen merkitsevyyteen liittyviä tunnuslukuja
#
# Tässä demossa keskitymme regressiokertoimiin
# ja selitysasteeseen.
#
# P-arvoja ja tilastollista merkitsevyyttä
# käsitellään myöhemmin kurssilla.

summary(malli)


#################################
#  18. Selitysaste R²
#################################

# Multiple R-squared eli R² kertoo mallin selitysasteen.
#
# R² saa arvoja väliltä 0 ja 1.
#
# Mitä suurempi arvo on, sitä suuremman osan selitettävän
# muuttujan vaihtelusta malli pystyy kuvaamaan.
#
# R² voidaan hakea mallin yhteenvedosta suoraan
# r.squared-tiedon avulla.

summary(malli)$r.squared

# Muutetaan selitysaste prosentiksi.

summary(malli)$r.squared * 100


#####################################
#  19. Tulosten tulkinta
#####################################

# Tarkastele lopuksi tekemiäsi analyysejä ja pohdi:
#
# - Mitä frekvenssitaulukko kertoo aineistosta?
#
# - Mitä suhteelliset ja kumulatiiviset frekvenssit kertovat?
#
# - Mitä ristiintaulukko kertoo sylinterimäärän ja
#   vaihteistotyypin suhteesta?
#
# - Miten rivi- ja sarakeprosenttien tulkinnat eroavat
#   toisistaan?
#
# - Mitä hajontakuvio kertoo auton painon ja
#   polttoainetaloudellisuuden välisestä yhteydestä?
#
# - Onko korrelaatio positiivinen vai negatiivinen?
#
# - Kuinka voimakkaalta yhteys vaikuttaa?
#
# - Mitä regressiosuoran kulmakerroin tarkoittaa?
#
# - Kuinka suuren osan polttoainetaloudellisuuden vaihtelusta
#   regressiomalli selittää?
#
# Muista, että muuttujien välinen yhteys ei yksin osoita
# syy-seuraussuhdetta.