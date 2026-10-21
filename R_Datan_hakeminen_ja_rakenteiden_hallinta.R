#######################################################
# DEMO 2: DATAN HAKEMINEN JA RAKENTEEN TARKASTELU
#######################################################
# Demon jälkeen osaat:

#ladata CSV-muotoista dataa R:ään ja huomioida erotinmerkin, desimaalierottimen, 
#koodauksen ja ylimääräiset otsikkorivit
#ymmärtää data framen ja tibblen perusidean
#tarkastella aineiston rakennetta, sarakkeita ja tietotyyppejä
#valita ja poistaa aineistosta sarakkeita indeksoinnilla
#tunnistaa puuttuvia arvoja ja laskea niiden määrän
#käyttää loogisia ehtoja datan siivoamisessa
#yhdistää funktioita ja käyttää sapply()-funktiota useiden sarakkeiden käsittelyyn
#ymmärtää yksinkertaisen anonyymin funktion periaatteen
#muuntaa tarvittaessa tuloksen tibbleksi
#tallentaa käsitellyn aineiston CSV-tiedostoksi

#selvitä lisäksi itse miten Excel-tiedoston sisältämä data ladataan ja miten data tallennetaan xlsx-muotoon.

#######################################################
# 1. PAKETIN KÄYTTÖÖNOTTO
#######################################################
# Otetaan käyttöön readr-paketti. Pakettia käytetään
# CSV-tiedostojen lukemiseen ja kirjoittamiseen.
# Paketti tarvitsee asentaa vain kerran komennolla:
# install.packages("readr"). Asenna paketti tarvittaessa.

library(readr)

#######################################################
# 2. DATAN LUKEMINEN CSV-TIEDOSTOSTA
#######################################################
# Luetaan data.csv ensin read_csv2()-funktiolla ja
# tarkastellaan, onnistuuko tiedoston lukeminen halutulla tavalla.
# read_csv2() olettäa tyypillisesti puolipisteen kenttien erottimeksi
# ja pilkun desimaalierottimeksi.

#Huom! Tiedoston polku on Noppe-ympäristön mukainen. Mikäli et käytä Noppe-
#ympäristöä, lataa tiedosto Moodlen tiedostokansiosta ja vaihda polku. 

data <- read_csv2("~/shared/data.csv")
data

#######################################################
# 3. TIEDOSTON LUKEMINEN OIKEILLA ASETUKSILLA
#######################################################
# Edellinen lukeminen ei tuota haluttua lopputulosta.
# Tiedostossa erotinmerkki on puolipiste, desimaalierotin piste,
# merkistokoodaus UTF-8 ja kaksi ensimmäistä riviä ohitetaan.
# show_col_types = FALSE estaa sarakkeiden automaattisesti
# tunnistetuista tietotyypeista kertovan ilmoituksen tulostumisen.

data <- read_delim(
  "~/shared/data.csv",
  delim = ";",
  locale = locale(
    encoding = "UTF-8",
    decimal_mark = "."
  ),
  skip = 2,
  show_col_types = FALSE
)

data

#######################################################
# 4. TIBBLE JA AINEISTON RAKENTEEN TARKASTAMINEN
#######################################################
# readr-paketti lukee aineiston tibble-muotoon.
# Tibble on data.frame-rakenteen modernimpi versio ja osa
# tidyverse-kokonaisuutta. Tidyverse-paketit on suunniteltu
# toimimaan luontevasti yhdessa.
#
# Tällä kurssilla käytetään pääasiassa tibbleja, koska myöhemmin
# dataa käsitellään esimerkiksi dplyr- ja ggplot2-paketeilla.

# Aineiston rakenne
str(data)

# Sarakkeiden nimet
names(data)

# Yhteenveto aineistosta
summary(data)

# Selkeä yhteenveto datan rakenteesta.
# Merkintä paketti::funktio mahdollistaa funktion käytön ilman
# paketin lataamista library()-funktiolla. Paketin tulee olla asennettu.
dplyr::glimpse(data)

#######################################################
# 5. SARAKKEIDEN TIETOTYYPIT JA sapply()
#######################################################
# data[[1]] palauttaa ensimmäisen sarakkeen sisällön vektorina.
# data[1, ] puolestaan palauttaa ensimmäisen rivin.

class(data[[1]])

# sapply() käy läpi tietorakenteen osat ja suorittaa jokaiselle
# saman funktion. Tibblen tapauksessa sapply() käsittelee sarakkeita
# yksi kerrallaan. Tässä class() suoritetaan jokaiselle sarakkeelle.

sapply(data, class)

#######################################################
# 6. TARPEETTOMAN SARAKKEEN POISTAMINEN
#######################################################
# Muistisääntö indeksointiin: data[rivit, sarakkeet]
# Pilkun vasemmalla puolella valitaan rivit ja oikealla sarakkeet.
# Tyhjä kohta tarkoittaa, että kaikki kyseisen ulottuvuuden arvot
# otetaan mukaan.
#
# data[, -1] = kaikki rivit, mutta ensimmäinen sarake pois.

data <- data[, -1]
data

#######################################################
# 7. PELKKIÄ PISTEITA SISÄLTÄVIEN SARAKKEIDEN TUNNISTAMINEN
#######################################################
# Joissakin sarakkeissa puuttuva tieto on merkitty pisteellä (.).
# Rakennetaan tarkistus vaiheittain.

#######################################################
# 7.1 VERTAILU
#######################################################
# data[[1]] palauttaa ensimmäisen sarakkeen vektorina.
# == "." vertaa jokaista sarakkeen arvoa pisteeseen ja palauttaa
# TRUE/FALSE-arvot.
# Vaihda tarvittaessa sarakenumero sellaiseksi, jossa on pisteitä.

data[[1]] == "."

#######################################################
# 7.2 all()-FUNKTIO
#######################################################
# all() palauttaa TRUE, jos kaikki sille annetut loogiset arvot
# ovat TRUE. Tässä tarkistetaan, ovatko sarakkeen kaikki arvot pisteitä.

all(data[[1]] == ".")

#######################################################
# 7.3 TARKISTUS KAIKILLE SARAKKEILLE
#######################################################
# sapply() suorittaa saman tarkistuksen jokaiselle sarakkeelle.
# function(col) ... on anonyymi funktio eli kertakäyttöinen funktio,
# jolle ei anneta omaa nimea. col tarkoittaa vuorollaan käsiteltävää
# sarakettä.

sapply(data, function(col) all(col == "."))

#######################################################
# 7.4 SARAKKEIDEN POISTAMINEN
#######################################################
# Ensin tunnistetaan sarakkeet, joiden kaikki arvot ovat pisteitä.
# ! kääntää TRUE/FALSE-valinnan, jolloin mukaan jäävät muut sarakkeet.

data <- data[, !sapply(data, function(col) all(col == "."))]
data

#######################################################
# 8. PUUTTUVIEN ARVOJEN TUTKIMINEN
#######################################################
# Tarkastellaan seuraavaksi R:n varsinaisia puuttuvia arvoja (NA).

# Onko aineistossa yhtäkään puuttuvaa arvoa?
anyNA(data)

# is.na() tarkistaa jokaisen arvon ja palauttaa TRUE, jos arvo on NA.
is.na(data)

# Puuttuvien arvojen kokonaismäärä.
# Tässä yhden funktion tulos annetaan seuraavalle funktiolle.
sum(is.na(data))

# Puuttuvien arvojen määrä sarakkeittain.
colSums(is.na(data))

# Puuttuvien arvojen määrä riveittain.
rowSums(is.na(data))

#######################################################
# 9. TULOKSEN MUUTTAMINEN TIBBLEKSI
#######################################################
# colSums() palauttaa nimetyn vektorin.
# enframe() muuttaa nimetyn vektorin tibbleksi, jolloin tulosta
# voidaan tarkastella taulukkomuodossa.

library(tibble)

sarakkeiden_puuttuvat_arvot <- enframe(
  colSums(is.na(data)),
  name = "Sarake",
  value = "Puuttuvia"
)

sarakkeiden_puuttuvat_arvot

#######################################################
# 10. LOPPUTULOKSEN TARKISTAMINEN
#######################################################
# Datan muokkaamisen jälkeen tarkistetaan, että lopputulos on odotettu.

dplyr::glimpse(data)
summary(data)
colSums(is.na(data))

#######################################################
# 11. KÄSITELLYN DATAN TALLENTAMINEN
#######################################################
# Tallennetaan käsitelty aineisto CSV-tiedostoksi jatkokäyttöä varten.

write_csv(
  data,
  "~/siivottudataR.csv"
)

# Vaihtoehtoisesti aineisto voidaan tallentaa Excel-muotoon.
# writexl-paketin tulee olla asennettuna:
# install.packages("writexl")

# writexl::write_xlsx(
#   data,
#   "~/siivottudataR.xlsx"
# )

