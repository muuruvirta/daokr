#######################################################
# DEMO 3: DATAN KÄSITTELY DPLYR-PAKETILLA
#######################################################
# Demon jälkeen osaat:
#
# ottaa käyttöön dplyr-paketin
# ymmärtää pipe-operaattorin |> toimintaperiaatteen
# valita ja poistaa sarakkeita select()-funktiolla
# suodattaa havaintoja filter()-funktiolla
# käyttää suodatuksessa vertailu- ja loogisia ehtoja
# käsitellä puuttuvia arvoja suodatuksen yhteydessä
# järjestää havaintoja arrange()-funktiolla
# muodostaa uusia muuttujia mutate()-funktiolla
# luokitella arvoja case_when()-funktiolla
# tehdä yksinkertaisen oman funktion
# käyttää omaa funktiota aineiston käsittelyssä
# yhdistää useita käsittelyvaiheita pipe-ketjuksi
# tallentaa käsittelyn tuloksen uutena CSV-tiedostona

#######################################################
# 1. PAKETTIEN KÄYTTÖÖNOTTO
#######################################################
# Otetaan käyttöön dplyr-paketti. Pakettia käytetään
# taulukkomuotoisen datan käsittelyyn.
# Paketti tarvitsee asentaa vain kerran komennolla:
# install.packages("dplyr"). Asenna paketti tarvittaessa.

# Pakettia ladatessa R huomauttaa samannimisistä funktioista. 
# Tästä ei tarvitse välittää. 

library(dplyr)

#######################################################
# 2. DATAN LUKEMINEN
#######################################################
# Luetaan data.Nyt tiedämme datan muodon, joten voimme käyttää
# funktiota read_csv().

data <- readr::read_csv(
  "~/shared/data3.csv",
  show_col_types = FALSE
)

# Tarkastellaan aineistoa.

data

# glimpse antaa nopean kuvan datasta

dplyr::glimpse(data)


#######################################################
# 3. PIPE-OPERAATTORI |>
#######################################################
# Pipe-operaattori |> välittää vasemmalla olevan tuloksen
# seuraavan funktion käsiteltäväksi.
#
# Seuraavat komennot tuottavat saman tuloksen:

glimpse(data)

data |>
  glimpse()

# Pipe helpottaa erityisesti useista peräkkäisistä vaiheista
# muodostuvaa datankäsittelyä.

# Saatat törmätä R-esimerkeissä myös %>%-merkintään. Se on erityisesti
# tidyverse-ympäristössä pitkään käytetty pipe-operaattori. 
# Uudemmissa R-versioissa on käytettävissä R:n oma |>-operaattori, jota 
# käytämme tällä kurssilla. Peruskäytössä niiden toimintaperiaate on sama: 
# vasemmalla oleva tulos välitetään seuraavalle funktiolle.


#######################################################
# 4. SARAKKAIDEN KÄSITTELY
#######################################################

#######################################################
# 4.1 SARAKKEIDEN VALITSEMINEN SELECT()-FUNKTIOLLA
#######################################################
# Valitaan aineistosta vain nimetyt sarakkeet.
# select() ei tässä muuta alkuperäistä data-oliota, koska
# käsittelyn tulosta ei tallenneta.

data |>
  select(Opiskelija, Koulutusala, Opintopisteet, Keskiarvo)

# Sarake voidaan jättää pois lisäämällä sen nimen eteen miinusmerkki.

data |>
  select(-Tunniste)

# select() mahdollistaa sarakkeiden valitsemisen nimien perusteella.
# Demo 2:ssa ensimmäinen sarake poistettiin indeksoinnilla näin:
# data[, -1]

#######################################################
# 4.2 SARAKKEEN NIMEÄMINEN UUDELLEEN
#######################################################

# rename()-funktiolla voidaan muuttaa sarakkeen nimeä.
# Muoto on: uusi_nimi = vanha_nimi

data |>
  rename(
    Opiskelijan_nimi = Opiskelija
  )

#######################################################
# 4.3 SARAKKEIDEN JÄRJESTYKSEN MUUTTAMINEN
#######################################################

# relocate()-funktiolla voidaan muuttaa sarakkeiden järjestystä.
# Siirretään Opintopisteet-sarake Keskiarvo-sarakkeen jälkeen.
# Voit kokeilla myös komentoa .before.
# Koska tulosta ei tallenneta, alkuperäinen data ei muutu.

data

data |>
  relocate(
    Opintopisteet,
    .after = Keskiarvo
  )

#######################################################
# 5. RIVIEN SUODATTAMINEN FILTER()-FUNKTIOLLA
#######################################################
# Valitaan havainnot, joiden keskiarvo on vähintään 4.

data |>
  filter(Keskiarvo >= 4)

#######################################################
# 5.1 USEIDEN EHTOJEN YHDISTÄMINEN
#######################################################
# Valitaan havainnot, joiden keskiarvo on vähintään 4 JA
# opintopisteiden määrä on vähintään 40.
#
# filter()-funktion sisällä pilkulla erotetut ehdot
# käsitellään JA-ehtoina. Molempien ehtojen täytyy toteutua.

data |>
  filter(
    Keskiarvo >= 4,
    Opintopisteet >= 40
  )

# Sama suodatus voidaan kirjoittaa &-operaattorin avulla.

data |>
  filter(Keskiarvo >= 4 & Opintopisteet >= 40)

#######################################################
# 5.2 VAIHTOEHTOISET EHDOT
#######################################################
# Valitaan havainnot, joissa koulutusala on Tekniikka TAI Liiketalous.
# |-operaattori tarkoittaa, että vähintään yhden ehdon täytyy toteutua.

data |>
  filter(
    Koulutusala == "Tekniikka" |
    Koulutusala == "Liiketalous"
  )

# Kun saman muuttujan arvoa verrataan useaan vaihtoehtoon,
# voidaan käyttää myös %in%-operaattoria.

data |>
  filter(Koulutusala %in% c("Tekniikka", "Liiketalous"))

#######################################################
# 5.3 YKSILÖLLISTEN ARVOJEN TARKASTELU
#######################################################

# distinct()-funktiolla voidaan tarkastella muuttujan
# yksilöllisiä arvoja.

data |>
  distinct(Koulutusala)


#######################################################
# 6. PUUTTUVIEN ARVOJEN HUOMIOIMINEN
#######################################################
# is.na() tunnistaa puuttuvat arvot.
# ! kääntää loogisen tuloksen, joten mukaan valitaan havainnot,
# joiden Keskiarvo-muuttujan arvo ei puutu.

data |>
  filter(!is.na(Keskiarvo))

# Valitaan puolestaan havainnot, joista keskiarvo puuttuu.

data |>
  filter(is.na(Keskiarvo))

#######################################################
# 7. HAVAINTOJEN JÄRJESTÄMINEN ARRANGE()-FUNKTIOLLA
#######################################################
# Järjestetään havainnot keskiarvon mukaan pienimmästä suurimpaan.

data |>
  arrange(Keskiarvo)

# desc() muuttaa järjestyksen laskevaksi.
# Järjestetään havainnot keskiarvon mukaan suurimmasta pienimpään.

data |>
  arrange(desc(Keskiarvo))

# Havaintoja voidaan järjestää usean muuttujan perusteella.
# Ensin järjestetään koulutusalan mukaan ja jokaisen koulutusalan
# sisällä keskiarvon mukaan suurimmasta pienimpään.

data |>
  arrange(Koulutusala, desc(Keskiarvo))

#######################################################
# 8. UUDEN MUUTTUJAN MUODOSTAMINEN MUTATE()-FUNKTIOLLA
#######################################################
# Muodostetaan Suoritusprosentti-muuttuja. Se kertoo suoritettujen
# opintopisteiden osuuden 60 opintopisteen tavoitteesta.
#
# Koska tulosta ei tallenneta, alkuperäinen data ei tässä muutu.
# Datassa oletetaan, että maksimiopintopisteet ovat 60. 

data |>
  mutate(
    Suoritusprosentti = Opintopisteet / 60 * 100
  )

# Tallennetaan uusi muuttuja data-olioon.

data <- data |>
  mutate(
    Suoritusprosentti = Opintopisteet / 60 * 100
  )

# Tarkistetaan lopputulos.

glimpse(data)

#######################################################
# 9. LOOGISEN MUUTTUJAN MUODOSTAMINEN
#######################################################
# Muodostetaan Hyvä_keskiarvo-muuttuja.
# Muuttujan arvo on TRUE, jos keskiarvo on vähintään 4,
# ja FALSE, jos ehto ei toteudu.
# Jos keskiarvo puuttuu, myös uuden muuttujan arvo on NA.

data <- data |>
  mutate(
    Hyvä_keskiarvo = Keskiarvo >= 4
  )

# Tarkastellaan uusia muuttujia.

data |>
  select(Opiskelija, Keskiarvo, Suoritusprosentti, Hyvä_keskiarvo)

#######################################################
# 10. ARVOJEN LUOKITTELEMINEN CASE_WHEN()-FUNKTIOLLA
#######################################################
# Muodostetaan keskiarvon perusteella uusi Menestys-muuttuja:
#
# vähintään 4          -> Hyvä
# vähintään 3, alle 4  -> Kohtalainen
# alle 3               -> Heikko
# puuttuva keskiarvo   -> puuttuva arvo
#
# case_when()-funktiossa luokittelu kirjoitetaan muodossa:
# ehto ~ tulos
#
# Ehdot tarkistetaan ylhäältä alaspäin. Ensimmäinen toteutuva ehto
# määrittää havainnolle annettavan arvon.

data <- data |>
  mutate(
    Menestys = case_when(
      is.na(Keskiarvo) ~ NA_character_,
      Keskiarvo >= 4 ~ "Hyvä",
      Keskiarvo >= 3 ~ "Kohtalainen",
      TRUE ~ "Heikko"
    )
  )

# Tarkastellaan muodostettua luokitusta.

data |>
  select(Opiskelija, Keskiarvo, Menestys)

#######################################################
# 11. OMAN FUNKTION KÄYTTÄMINEN DATAN KÄSITTELYSSÄ
#######################################################

#######################################################
# 11.1 OMAN FUNKTION MÄÄRITTELY JA TESTAAMINEN
#######################################################

# Tehdään funktio, joka luokittelee opintojen etenemisen
# suoritettujen opintopisteiden perusteella.

luokittele_eteneminen <- function(op) {
  case_when(
    is.na(op) ~ NA_character_,
    op >= 45 ~ "Hyvin edennyt",
    op >= 30 ~ "Edistynyt",
    TRUE ~ "Alkuvaiheessa"
  )
}

# Testataan funktiota yksittäisillä arvoilla.

luokittele_eteneminen(50)
luokittele_eteneminen(35)
luokittele_eteneminen(20)

# Funktio toimii myös vektorille.

luokittele_eteneminen(c(50, 35, 20))


#######################################################
# 11.2 OMAN FUNKTION KÄYTTÄMINEN DATAAN
#######################################################

# Käytetään omaa funktiota mutate()-funktion sisällä.
# Tuloksesta muodostetaan uusi Eteneminen-muuttuja.

data <- data |>
  mutate(
    Eteneminen = luokittele_eteneminen(Opintopisteet)
  )

# Tarkastellaan tulosta.

data |>
  select(Opiskelija, Opintopisteet, Eteneminen)

#######################################################
# 12. USEIDEN KÄSITTELYVAIHEIDEN YHDISTÄMINEN
#######################################################
# Muodostetaan alkuperäisestä aineistosta uusi analyysidata:
#
# 1. Poistetaan havainnot, joista keskiarvo puuttuu.
# 2. Valitaan analyysissä tarvittavat muuttujat.
# 3. Muodostetaan suoritusprosentti.
# 4. Luokitellaan opintojen eteneminen oman funktion avulla.
# 5. Järjestetään havainnot keskiarvon mukaan laskevaan järjestykseen.
#
# Käsittelyketjua luetaan ylhäältä alaspäin.

analyysidata <- data |>
  filter(!is.na(Keskiarvo)) |>
  select(
    Opiskelija,
    Koulutusala,
    Opintopisteet,
    Keskiarvo
  ) |>
  mutate(
    Suoritusprosentti = Opintopisteet / 60 * 100,
    Eteneminen = luokittele_eteneminen(Opintopisteet)
  ) |>
  arrange(desc(Keskiarvo))

# Tulostetaan muodostettu aineisto.

analyysidata

#######################################################
# 13. LOPPUTULOKSEN TARKISTAMINEN
#######################################################
# Tarkistetaan analyysiaineiston rakenne, ensimmäiset rivit
# ja muuttujien yhteenvetotiedot.

glimpse(analyysidata)
head(analyysidata)
summary(analyysidata)

#######################################################
# 14. ANALYYSIAINEISTON TALLENTAMINEN
#######################################################
# Tallennetaan käsitelty analyysiaineisto CSV-tiedostoksi.

readr::write_csv(
  analyysidata,
  "~/analyysidata.csv"
)

