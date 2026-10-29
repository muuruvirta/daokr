# ============================================================
# Demo 4: Kuvaileva analyysi ja visualisointi
# ============================================================
# Tavoite:
# - laskea aineistosta kuvailevia tunnuslukuja
# - tehdä ryhmäkohtaisia yhteenvetoja
# - visualisoida aineistoa ggplot2-paketilla
# - tulkita tunnuslukuja ja kuvaajia
#
# Demossa käytetään R:n valmista iris-aineistoa.
# ============================================================

# Ladataan tidyverse-pakettikokoelma.
# library() ottaa asennetun paketin käyttöön tässä R-istunnossa.
# tidyverse sisältää tässä demossa tarvittavat dplyr- ja ggplot2-paketit.

library(tidyverse)


##########################
#  1. Aineistoon tutustuminen
##########################

# as_tibble() muuttaa aineiston tibble-muotoon.
# Tibble on tidyverse-pakettien käyttämä nykyaikainen taulukkomuotoinen rakenne.
#
# rename() vaihtaa sarakkeiden nimet. Uusi nimi kirjoitetaan ensin
# ja vanha nimi yhtäsuuruusmerkin jälkeen.
#
# |> on R:n pipe-operaattori. Se välittää edellisen vaiheen tuloksen
# seuraavalle funktiolle.

data <- as_tibble(iris) |>
  rename(
    Verholehden_pituus = Sepal.Length,
    Verholehden_leveys = Sepal.Width,
    Terälehden_pituus = Petal.Length,
    Terälehden_leveys = Petal.Width,
    Laji = Species
  )

# glimpse() näyttää aineiston rakenteen tiiviisti:
# rivien ja sarakkeiden määrän, sarakkeiden nimet, tietotyypit ja esimerkkiarvoja.
glimpse(data)

# head() näyttää aineiston ensimmäiset rivit.
head(data)

# summary() antaa nopeasti yleiskuvan aineiston muuttujista.
# Numeerisille muuttujille se näyttää mm. minimin, kvartiilit,
# mediaanin, keskiarvon ja maksimin.
summary(data)


##############################
#  2. Kuvailevat tunnusluvut
##############################

# mean() laskee aritmeettisen keskiarvon.
# na.rm = TRUE tarkoittaa, että mahdolliset puuttuvat arvot jätetään pois laskennasta.
mean(data$Verholehden_pituus, na.rm = TRUE)

# median() laskee mediaanin eli järjestetyn aineiston keskimmäisen arvon.
median(data$Verholehden_pituus, na.rm = TRUE)

# sd() laskee keskihajonnan. Se kuvaa arvojen vaihtelua keskiarvon ympärillä.
sd(data$Verholehden_pituus, na.rm = TRUE)

# min() etsii pienimmän arvon ja max() suurimman arvon.
min(data$Verholehden_pituus, na.rm = TRUE)
max(data$Verholehden_pituus, na.rm = TRUE)

# quantile() laskee aineiston kvantiileja.
# Oletuksena tuloksessa näkyvät mm. alakvartiili, mediaani ja yläkvartiili.
quantile(data$Verholehden_pituus, na.rm = TRUE)


########################################
#  3. Yhteenveto summarise()-funktiolla
#######################################

# summarise() tiivistää aineiston yhteen tai useampaan tunnuslukuun.
# Tässä useita tunnuslukuja lasketaan samalla komennolla.
data |>
  summarise(
    Keskiarvo = mean(Verholehden_pituus, na.rm = TRUE),
    Mediaani = median(Verholehden_pituus, na.rm = TRUE),
    Keskihajonta = sd(Verholehden_pituus, na.rm = TRUE),
    Minimi = min(Verholehden_pituus, na.rm = TRUE),
    Maksimi = max(Verholehden_pituus, na.rm = TRUE)
  )


#######################################
#  4. Ryhmittely group_by()-funktiolla
#######################################

# group_by() jakaa aineiston ryhmiin valitun muuttujan perusteella.
# Kun sen jälkeen käytetään summarise()-funktiota, tunnusluvut
# lasketaan erikseen jokaiselle ryhmälle.

# Lasketaan verholehden pituuden keskiarvo erikseen jokaiselle lajille.
data |>
  group_by(Laji) |>
  summarise(
    Keskiarvo = mean(Verholehden_pituus, na.rm = TRUE)
  )

# n() palauttaa ryhmän havaintojen lukumäärän.
# Tehdään laajempi yhteenveto lajeittain.

data |>
  group_by(Laji) |>
  summarise(
    Lukumaara = n(),
    Keskiarvo = mean(Verholehden_pituus, na.rm = TRUE),
    Mediaani = median(Verholehden_pituus, na.rm = TRUE),
    Keskihajonta = sd(Verholehden_pituus, na.rm = TRUE)
  )


#############################################
#  5. Havaintojen määrät count()-funktiolla
#############################################

# count() laskee, kuinka monta havaintoa kussakin ryhmässä on.
# Tässä lasketaan havaintojen määrä lajeittain.
data |>
  count(Laji)

# sort = TRUE järjestää ryhmät havaintomäärän mukaan suurimmasta pienimpään.
# Iris-aineistossa kaikissa lajeissa on yhtä paljon havaintoja,
# mutta muissa aineistoissa järjestäminen voi olla hyödyllistä.
data |>
  count(Laji, sort = TRUE)


####################################
#  6. ggplot2-kuvaajan perusrakenne
####################################

# ggplot() aloittaa kuvaajan rakentamisen.
# Ensimmäiseksi sille annetaan käytettävä aineisto.
#
# aes() määrittää, mitkä aineiston muuttujat liitetään kuvaajan
# ominaisuuksiin, kuten x-akseliin, y-akseliin tai väriin.
#
# geom_...()-funktio määrittää varsinaisen kuvaajatyypin.
# Esimerkiksi geom_point() tekee pisteitä ja geom_bar() pylväitä.
#
# ggplot2-kuvaaja rakennetaan kerroksittain, jotka yhdistetään +-merkillä.


###################
#  7. Histogrammi
###################

# geom_histogram() tekee histogrammin numeerisen muuttujan jakaumasta.
# bins määrittää, kuinka moneen luokkaan arvot jaetaan.

ggplot(data, aes(x = Verholehden_pituus)) +
  geom_histogram(bins = 10)

# Luokkien määrä vaikuttaa siihen, miltä jakauma näyttää.
# Verrataan esimerkiksi 5 ja 20 luokan histogrammeja.
ggplot(data, aes(x = Verholehden_pituus)) +
  geom_histogram(bins = 5)

ggplot(data, aes(x = Verholehden_pituus)) +
  geom_histogram(bins = 20)


##########################
#  8. Pylväsdiagrammi
##########################

# geom_bar() tekee pylväsdiagrammin ja laskee automaattisesti,
# kuinka monta havaintoa kussakin kategoriassa on.
ggplot(data, aes(x = Laji)) +
  geom_bar()


##########################
#  9. Laatikkokaavio
##########################

# geom_boxplot() tekee laatikkokaavion (boxplot).
# Laatikkokaavion avulla voidaan vertailla numeerisen muuttujan
# jakaumaa eri ryhmien välillä.
#
# Laatikon keskellä oleva viiva kuvaa mediaania.
# Laatikko kuvaa aineiston keskimmäistä 50 prosenttia.
# Kuviossa voi näkyä myös mahdollisia poikkeavia havaintoja.
ggplot(data, aes(x = Laji, y = Verholehden_pituus)) +
  geom_boxplot()


##########################
#  10. Hajontakuvio
##########################

# geom_point() tekee hajontakuvion.
# Hajontakuviolla tarkastellaan kahden numeerisen muuttujan
# välistä mahdollista yhteyttä.
ggplot(data, aes(x = Terälehden_pituus, y = Terälehden_leveys)) +
  geom_point()


##########################
#  11. Trendisuora
##########################

# geom_smooth() lisää kuvaajaan tasoituksen tai trendin.
# method = "lm" käyttää lineaarista mallia ja piirtää suoran.
#
# Trendisuora auttaa hahmottamaan, näyttääkö kahden numeerisen
# muuttujan välillä olevan lineaarista yhteyttä.
# Tässä vaiheessa yhteyttä tarkastellaan vain visuaalisesti.
# Lineaariseen regressioon ja suoran yhtälöön palataan myöhemmin kurssilla.

ggplot(data, aes(x = Terälehden_pituus, y = Terälehden_leveys)) +
  geom_point() +
  geom_smooth(method = "lm")


#################################
#  12. Otsikot ja akselien nimet
#################################

# labs() lisää kuvaajaan esimerkiksi otsikon, akselien nimet
# ja selitteen otsikon.
ggplot(data, aes(x = Terälehden_pituus, y = Terälehden_leveys)) +
  geom_point() +
  labs(
    title = "Terälehden pituuden ja leveyden välinen yhteys",
    x = "Terälehden pituus (cm)",
    y = "Terälehden leveys (cm)"
  )


############################
#  13. Värit ryhmän mukaan
############################

# Kun color määritellään aes()-funktion sisällä,
# väri määräytyy aineiston muuttujan perusteella.
# Tässä eri lajit saavat automaattisesti eri värit.
ggplot(
  data,
  aes(
    x = Terälehden_pituus,
    y = Terälehden_leveys,
    color = Laji
  )
) +
  geom_point()

# Jos color annetaan aes()-funktion ulkopuolella,
# kaikille pisteille annetaan sama väri.
# Voit käyttää myös heksa ja rgb-värejä: color=#0078D4 tai 
# color=rgb(0,120,212,maxColorValue=255). Oletuksena R käyttää rgb-arvoja välillä 0-1.

ggplot(data, aes(x = Terälehden_pituus, y = Terälehden_leveys)) +
  geom_point(color = "blue")


##########################
#  14. Kuvaajan teema
##########################

# theme_minimal() vaihtaa kuvaajan ulkoasun pelkistettyyn teemaan.
# Teeman muuttaminen ei muuta aineistoa eikä kuvaajan sisältämää tietoa.
# Kokeile myös muita teemoja: _gray(), _bw, _light(), _dark(),
# _classic(), _void(),

ggplot(
  data,
  aes(
    x = Terälehden_pituus,
    y = Terälehden_leveys,
    color = Laji
  )
) +
  geom_point() +
  labs(
    title = "Iris-lajien terälehtien koko",
    x = "Terälehden pituus (cm)",
    y = "Terälehden leveys (cm)",
    color = "Laji"
  ) +
  theme_minimal()


##########################
#  15. Kokoava esimerkki
##########################

# Muodostetaan ensin lajeittainen yhteenvetotaulukko.
# arrange() järjestää aineiston rivejä.
# desc() vaihtaa järjestyksen laskevaksi eli suurimmasta pienimpään.

yhteenveto <- data |>
  group_by(Laji) |>
  summarise(
    Lukumaara = n(),
    Keskiarvo = mean(Verholehden_pituus, na.rm = TRUE),
    Mediaani = median(Verholehden_pituus, na.rm = TRUE),
    Keskihajonta = sd(Verholehden_pituus, na.rm = TRUE)
  ) |>
  arrange(desc(Keskiarvo))

yhteenveto

# fill määrittää kuvion täyttövärin.
# Kun fill = Laji on aes()-funktion sisällä,
# jokainen laji saa oman täyttövärinsä.

ggplot(data, aes(x = Laji, y = Verholehden_pituus, fill = Laji)) +
  geom_boxplot() +
  labs(
    title = "Verholehden pituus lajeittain",
    x = "Laji",
    y = "Verholehden pituus (cm)",
    fill = "Laji"
  ) +
  theme_minimal()

