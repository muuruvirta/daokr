#################################################
# DATA-ANALYTIIKAN OHJELMOINTIKIELET
# 1. R:n PÄÄTIETORAKENTEET
# Syntaksi, muuttujat, tietotyypit ja laskutoimitukset
#################################################

#Aja ohjelmakoodi rivi kerrallaan (Run tämä ikkunan yläoikealta tai CTRL+Enter,
#tulos näkyy konsolissa. Tehtävä kohdassa tee oma koodisi ja aja myös se. 

#################################################
# 1. VEKTORI
#################################################

# ESIMERKKI
# Vektori sisaltää saman tyyppisia arvoja.

pisteet <- c(72, 85, 61, 93, 78)

pisteet
pisteet[3]
mean(pisteet)

# Ehdon täyttavät arvot
pisteet[pisteet >= 80]


# TEHTÄVÄ 1
# Luo vektori, joka sisaltää kuusi lampotilaa.
# Tulosta:
# - koko vektori
# - toinen lampotila
# - lampotilojen keskiarvo
# - kaikki nollaa suuremmat lampotilat


#################################################
# 2. MATRIISI
#################################################

# ESIMERKKI
# Matriisi on kaksiulotteinen tietorakenne.
# Kaikki alkiot ovat samaa tyyppia.

pisteet_matriisi <- matrix(
  c(
    72, 85, 67, 91,
    65, 74, 81, 78,
    88, 92, 85, 90
  ),
  nrow = 3,
  byrow = TRUE
)

pisteet_matriisi

# Ensimmäinen rivi
pisteet_matriisi[1, ]

# Toinen sarake
pisteet_matriisi[, 2]

# Kolmannen rivin neljäs arvo
pisteet_matriisi[3, 4]


# TEHTÄVÄ 2
# Luo 3 x 3 -matriisi luvuista 1-9.
# Tulosta:
# - koko matriisi
# - toinen rivi
# - kolmas sarake
# - keskimmainen alkio


#################################################
# 3. ARRAY
#################################################

# ESIMERKKI
# Array voi sisältää enemmän kuin kaksi ulottuvuutta.

mittaukset <- array(
  1:24,
  dim = c(3, 4, 2)
)

mittaukset

# Ensimmäinen kaksiulotteinen taso
mittaukset[, , 1]


# TEHTÄVÄ 3
# Luo kolmiulotteinen array luvuista 1-12.
# Kayta mittoja 2 x 3 x 2.
# Tulosta koko array ja sen toinen taso.


#################################################
# 4. LISTA
#################################################

# ESIMERKKI
# Lista voi sisaltää erityyppisiä arvoja ja rakenteita.

opiskelija <- list(
  nimi = "Anna",
  ika = 23,
  pisteet = c(72, 85, 91),
  aktiivinen = TRUE
)

opiskelija
opiskelija$nimi
opiskelija$pisteet
mean(opiskelija$pisteet)

# Osalista
opiskelija["nimi"]

# Varsinainen alkio
opiskelija[["nimi"]]


# TEHTÄVÄ 5
# Luo tuotetta kuvaava lista, joka sisältää:
# - tuotteen nimen
# - hinnan
# - varastomaaran
# - kolme asiakasarviota
# Tulosta tuotteen nimi ja asiakasarvioiden keskiarvo.


#################################################
# 5. DATA FRAME
#################################################

# ESIMERKKI
# Data frame on taulukkomuotoinen tietorakenne.
# Eri sarakkeet voivat sisältää eri tyyppistä tietoa.

opiskelijat <- data.frame(
  nimi = c("Anna", "Matti", "Liisa", "Pekka"),
  ika = c(22, 25, 21, 27),
  pisteet = c(85, 72, 91, 48),
  hyvaksytty = c(TRUE, TRUE, TRUE, FALSE)
)

opiskelijat

# Rakenteen tutkiminen
str(opiskelijat)
dim(opiskelijat)
nrow(opiskelijat)
ncol(opiskelijat)
names(opiskelijat)

# Yksi sarake
opiskelijat$nimi

# Yksi rivi
opiskelijat[1, ]

# Valitut sarakkeet
opiskelijat[, c("nimi", "pisteet")]

# Ehdon tayttävät rivit
opiskelijat[opiskelijat$pisteet >= 80, ]


# TEHTÄVÄ 6
# Luo vähintään viiden tuotteen data frame, joka sisaltaa:
# - tuotteen nimen
# - hinnan
# - varastomäärän
# Tulosta:
# - koko data frame
# - pelkkä hintasarake
# - ensimmäisen tuotteen tiedot
# - tuotteet, joiden hinta on yli 50 euroa


#################################################
# 6. FACTOR
#################################################

# ESIMERKKI
# Factor soveltuu luokiteltuun tietoon.
# Luokille voidaan määritellä myos järjestys.

arvosanat <- factor(
  c(
    "Hyva",
    "Kiitettava",
    "Hyva",
    "Tyydyttava",
    "Kiitettava"
  ),
  levels = c(
    
    "Tyydyttava",
    "Hyva",
    "Kiitettava"
  ),
  ordered = TRUE
)

arvosanat
levels(arvosanat)

# Koska factor on jarjestetty, luokkia voidaan verrata.
arvosanat[1] < arvosanat[2]


# TEHTAVA
# Luo järjestetty factor seuraavista arvioista:
# "Heikko", "Hyva", "Erinomainen", "Hyva", "Heikko", "Erinomainen"
# Määritä järjestykseksi:
# Heikko < Hyva < Erinomainen
# Tulosta factor ja sen tasot.


#################################################
# 7. YHTEENVETO
#################################################

# Tarkeimmat tietorakenteet tassa demossa:
#
# Vektori    -> yksi ulottuvuus, sama tietotyyppi
# Matriisi   -> kaksi ulottuvuutta, sama tietotyyppi
# Array      -> useita ulottuvuuksia, sama tietotyyppi
# Lista      -> voi sisaltaa erityyppisia objekteja
# Data frame -> taulukko, sarakkeissa voi olla eri tietotyyppeja
# Factor     -> luokiteltu tieto, luokilla voi olla jarjestys
