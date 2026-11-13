############################################################
# DEMO 8: AIKASARJAT JA KONEOPPIMISEN PERUSTEET
############################################################

# Demossa käsitellään kahta erilaista ennustamistilannetta:
#
# 1. SARIMA-malli ennustaa aikasarjan tulevia arvoja aikaisemman
#    kehityksen, trendin ja kausivaihtelun perusteella.
# 2. Random Forest estimoi myyntiä useiden selittävien muuttujien
#    perusteella. Vertailumallina käytetään lineaarista regressiota.

# Asenna tarvittavat paketit tarvittaessa vain kerran:
# install.packages(c("tidyverse", "readxl", "forecast", "randomForest"))

library(tidyverse)
library(readxl)
library(forecast)
library(randomForest)


############################################################
# 1. TUTUSTU AIKASARJA-AINEISTOON
############################################################

# AirPassengers on R:n valmis kuukausittainen aikasarja.
# Aineisto kuvaa kansainvälisten lentomatkustajien kuukausittaisia
# määriä vuosina 1949–1960. Arvot ilmoitetaan tuhansina matkustajina.

data("AirPassengers")

# Tarkastellaan aineiston rakennetta, ajanjaksoa ja havaintotiheyttä.
AirPassengers
class(AirPassengers)
start(AirPassengers)
end(AirPassengers)
frequency(AirPassengers)
summary(AirPassengers)

# Piirretään kuukausittaiset matkustajamäärät.
autoplot(AirPassengers) +
  labs(
    title = "Kansainvälisten lentomatkustajien määrä",
    x = "Aika",
    y = "Matkustajamäärä (tuhatta)"
  ) +
  theme_minimal()

# Pohdi:
# - Näkyykö aikasarjassa pitkän aikavälin trendiä?
# - Näkyykö aikasarjassa vuosittain toistuvaa kausivaihtelua?


############################################################
# 2. TARKASTELE AIKASARJAN RAKENNETTA
############################################################

# Kausikuvio näyttää kuukausittaisen vaihtelun eri vuosina.
ggseasonplot(
  AirPassengers,
  year.labels = TRUE,
  year.labels.left = TRUE
) +
  labs(
    title = "Matkustajamäärien kausivaihtelu",
    x = "Kuukausi",
    y = "Matkustajamäärä (tuhatta)"
  ) +
  theme_minimal()

# Alisarjakuvio näyttää kunkin kuukauden arvot eri vuosina.
ggsubseriesplot(AirPassengers) +
  labs(
    title = "Matkustajamäärät kuukausittain",
    x = "Kuukausi",
    y = "Matkustajamäärä (tuhatta)"
  ) +
  theme_minimal()

# Hajotetaan aikasarja trendiin, kausivaihteluun ja jäännökseen.
# Multiplikatiivinen hajotelma sopii tähän aineistoon, koska
# kausivaihtelun voimakkuus kasvaa sarjan tason kasvaessa.
hajotelma <- decompose(AirPassengers, type = "multiplicative")
plot(hajotelma)

# Lasketaan eri kuukausien keskimääräiset matkustajamäärät.
kuukaudet <- month.abb
kuukausidata <- tibble(
  Kuukausi = factor(
    kuukaudet[cycle(AirPassengers)],
    levels = kuukaudet
  ),
  Matkustajamaara = as.numeric(AirPassengers)
)

kuukausikeskiarvot <- kuukausidata |>
  group_by(Kuukausi) |>
  summarise(
    Keskiarvo = mean(Matkustajamaara),
    .groups = "drop"
  )

kuukausikeskiarvot

# Selvitetään suurimman ja pienimmän keskiarvon kuukaudet.
kuukausikeskiarvot |>
  slice_max(Keskiarvo, n = 1)

kuukausikeskiarvot |>
  slice_min(Keskiarvo, n = 1)


############################################################
# 3. MUODOSTA KAUSITTAINEN ARIMA-MALLI (SARIMA)
############################################################

# AirPassengers-aineistossa on nouseva trendi ja vuosittainen
# 12 kuukauden kausivaihtelu. Siksi käytetään kausittaista
# ARIMA-mallia eli SARIMA-mallia.
#
# auto.arima() valitsee aineistoon sopivan mallirakenteen
# automaattisesti. Mallimerkintä on muotoa:
# ARIMA(p,d,q)(P,D,Q)[12]
#
# Luku 12 tarkoittaa kuukausittaisen aineiston vuosittaista kautta.

sarima_malli <- auto.arima(
  AirPassengers,
  seasonal = TRUE,
  stepwise = FALSE,
  approximation = FALSE
)

# Tulostetaan automaattisesti valittu malli.
sarima_malli
summary(sarima_malli)

# Tarkastellaan jäännöksiä.
# Hyvässä mallissa jäännöksiin ei pitäisi jäädä selvää rakennetta
# tai merkitsevää autokorrelaatiota.
checkresiduals(sarima_malli)

# checkresiduals()-tulosteen tulkinta:
#
# Yläkuva = jäännökset ajan suhteen
# - Arvojen pitäisi vaihdella melko satunnaisesti nollan ympärillä.
# - Selvä trendi tai toistuva kuvio olisi merkki siitä, että
#   malliin on jäänyt selittämätöntä rakennetta.
#
# Vasemman alakulman ACF-kuvio = jäännösten autokorrelaatio
# - Pylväiden pitäisi pysyä pääosin sinisten katkoviivojen sisällä.
# - Rajan ylittävät pylväät kertovat mahdollisesta jäljelle jääneestä
#   ajallisesta riippuvuudesta.
#
# Oikean alakulman histogrammi = jäännösten jakauma
# - Jäännösten olisi hyvä olla symmetrisiä ja keskittyä nollan ympärille sekä
#   olla likimain normaalisti jakautuneita
# - Hyvin epäsymmetrinen jakauma tai suuret poikkeamat voivat
#   kertoa mallin ongelmista.
#
# Ljung-Box-testi:
# - p > 0,05 = jäännöksissä ei havaita merkitsevää autokorrelaatiota.
# - p < 0,05 = jäännöksiin on jäänyt mallintamatonta rakennetta.


############################################################
# 4. ENNUSTA TULEVIA ARVOJA SARIMA-MALLILLA
############################################################

# Ennustetaan matkustajamäärät seuraavalle 12 kuukaudelle sekä 80 % että 
# 90 % ennustevälillä. 

sarima_ennuste <- forecast(
  sarima_malli,
  h = 12,
  level = c(80, 95)
)

sarima_ennuste

# Tulostetaan piste-estimaatit sekä 80 %:n ja 95 %:n ennustevälit.

tibble(
  Aika = time(sarima_ennuste$mean),
  Piste_estimaatti = as.numeric(sarima_ennuste$mean),
  Alaraja_80 = as.numeric(sarima_ennuste$lower[, "80%"]),
  Ylaraja_80 = as.numeric(sarima_ennuste$upper[, "80%"]),
  Alaraja_95 = as.numeric(sarima_ennuste$lower[, "95%"]),
  Ylaraja_95 = as.numeric(sarima_ennuste$upper[, "95%"])
)

# Piirretään alkuperäinen aikasarja ja seuraavan 12 kuukauden ennuste.
autoplot(sarima_ennuste) +
  labs(
    title = "Lentomatkustajien määrän SARIMA-ennuste",
    x = "Aika",
    y = "Matkustajamäärä (tuhatta)"
  ) +
  theme_minimal()

# Pohdi:
# - Miten ennustevälit muuttuvat ennustettaessa kauemmas tulevaisuuteen?
# - Miksi kauemmas tulevaisuuteen ennustamiseen liittyy enemmän epävarmuutta?


############################################################
# 5. TUTUSTU MYYNTIAINEISTOON
############################################################

# Käytetään samaa myyntiaineistoa kuin Python-demossa (jos olet myös
# Python-opintojaksolla.
# Tiedostossa on kolme välilehteä:
#
# Historia   = viikot 1–50, käytetään mallien opettamiseen
# Uusi_data  = viikot 51–70, käytetään mallien arviointiin
# Tuleva_data = viikot 71–90, myynti estimoidaan valitulla mallilla
#
# Muuta tiedoston nimeä tarvittaessa vastaamaan omalla koneellasi
# olevan Excel-tiedoston nimeä.

tiedosto <- "Demo8_myyntidata.xlsx"

historia <- read_excel(tiedosto, sheet = "Historia")
uusi_data <- read_excel(tiedosto, sheet = "Uusi_data")
tuleva_data <- read_excel(tiedosto, sheet = "Tuleva_data")


# Tarkastellaan aineistojen rakennetta ja ensimmäisiä rivejä.
glimpse(historia)
glimpse(uusi_data)
glimpse(tuleva_data)

head(historia)
head(uusi_data)
head(tuleva_data)

summary(historia)

# Ennustettava muuttuja:
# Myynti_euroa
#
# Selittävät muuttujat:
# Mainonta_euroa
# Verkkosivukavijat
# Kampanja
# Keskihinta_euroa

# Tarkistetaan puuttuvat arvot.
colSums(is.na(historia))
colSums(is.na(uusi_data))
colSums(is.na(tuleva_data))

# Havainnollistetaan selittävien muuttujien yhteyksiä myyntiin.
ggplot(historia, aes(x = Mainonta_euroa, y = Myynti_euroa)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Mainonnan ja myynnin yhteys",
    x = "Mainonta (€)",
    y = "Myynti (€)"
  ) +
  theme_minimal()

ggplot(historia, aes(x = Verkkosivukavijat, y = Myynti_euroa)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Verkkosivukävijöiden ja myynnin yhteys",
    x = "Verkkosivukävijät",
    y = "Myynti (€)"
  ) +
  theme_minimal()

ggplot(historia, aes(x = Keskihinta_euroa, y = Myynti_euroa)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Keskihinnan ja myynnin yhteys",
    x = "Keskihinta (€)",
    y = "Myynti (€)"
  ) +
  theme_minimal()

ggplot(historia, aes(x = factor(Kampanja), y = Myynti_euroa)) +
  geom_boxplot() +
  labs(
    title = "Myynti kampanjan aikana ja ilman kampanjaa",
    x = "Kampanja",
    y = "Myynti (€)"
  ) +
  theme_minimal()


############################################################
# 6. MUODOSTA LINEAARINEN VERTAILUMALLI
############################################################

# Muodostetaan monimuuttujainen lineaarinen regressiomalli
# Historia-aineistolla.
regressiomalli <- lm(
  Myynti_euroa ~ Mainonta_euroa + Verkkosivukavijat +
    Kampanja + Keskihinta_euroa,
  data = historia
)

summary(regressiomalli)

# Tehdään piste-estimaatit Uusi_data-aineistolle.
uusi_data <- uusi_data |>
  mutate(
    Regressio_estimaatti = predict(
      regressiomalli,
      newdata = uusi_data
    )
  )

# Verrataan toteutunutta ja estimoitua myyntiä.
uusi_data |>
  select(Viikko, Myynti_euroa, Regressio_estimaatti)

# Lasketaan lineaariselle regressiolle arviointiaineiston MAE ja RMSE.
regressio_mae <- mean(
  abs(uusi_data$Myynti_euroa - uusi_data$Regressio_estimaatti)
)

regressio_rmse <- sqrt(
  mean((uusi_data$Myynti_euroa - uusi_data$Regressio_estimaatti)^2)
)

tibble(
  Malli = "Lineaarinen regressio",
  MAE = regressio_mae,
  RMSE = regressio_rmse
)


############################################################
# 7. MUODOSTA RANDOM FOREST -MALLI
############################################################

# Asetetaan siemenluku, jotta satunnaisuutta käyttävän
# Random Forest -mallin tulokset voidaan toistaa.
# Siemenluvuksi voidaan valita esimerkiksi mikä tahansa kokonaisluku.
set.seed(123)


# Muodostetaan Random Forest -malli samalla Historia-aineistolla
# ja samoilla selittävillä muuttujilla kuin regressiomalli.

# ntree määrittää Random Forest -malliin muodostettavien
# päätöspuiden määrän. Tässä muodostetaan 500 puuta.
# Mallin lopullinen estimaatti muodostetaan yhdistämällä
# yksittäisten puiden tuottamat estimaatit.


rf_malli <- randomForest(
  Myynti_euroa ~ Mainonta_euroa + Verkkosivukavijat +
    Kampanja + Keskihinta_euroa,
  data = historia,
  ntree = 500,
  importance = TRUE
)

rf_malli

# Tehdään piste-estimaatit Uusi_data-aineistolle.
uusi_data <- uusi_data |>
  mutate(
    Random_Forest_estimaatti = predict(
      rf_malli,
      newdata = uusi_data
    )
  )

# Arvioidaan seuraavaksi, kuinka tarkasti Random Forest
# estimoi Uusi_data-aineiston toteutunutta myyntiä.

# MAE = Mean Absolute Error eli keskimääräinen absoluuttinen virhe.
# Ensin lasketaan jokaiselle havainnolle toteutuneen ja estimoidun
# myynnin erotus. abs() muuttaa erotukset positiivisiksi ja
# mean() laskee niiden keskiarvon.
#
# Esimerkiksi MAE = 500 tarkoittaisi, että estimaatti poikkeaa
# toteutuneesta myynnistä keskimäärin noin 500 euroa.
# Mitä pienempi MAE, sitä tarkempia estimaatit ovat.

rf_mae <- mean(
  abs(uusi_data$Myynti_euroa - uusi_data$Random_Forest_estimaatti)
)


# RMSE = Root Mean Squared Error eli virheiden neliöiden
# keskiarvon neliöjuuri.
#
# Ensin lasketaan toteutuneen ja estimoidun myynnin erotukset.
# Virheet korotetaan toiseen potenssiin, jolloin suuret virheet
# saavat enemmän painoa. Lopuksi lasketaan keskiarvo ja neliöjuuri.
#
# RMSE on samassa yksikössä kuin myynti eli euroissa.
# Mitä pienempi RMSE, sitä tarkempia estimaatit ovat.
# Jos RMSE on selvästi MAE:ta suurempi, aineistossa voi olla
# yksittäisiä havaintoja, joissa mallin virhe on suuri.

rf_rmse <- sqrt(
  mean((uusi_data$Myynti_euroa - uusi_data$Random_Forest_estimaatti)^2)
)


# Tulostetaan virhemittarit samaan taulukkoon.
tibble(
  Malli = "Random Forest",
  MAE = rf_mae,
  RMSE = rf_rmse
)


# Tarkastellaan seuraavaksi muuttujien tärkeyttä.
#
# importance() kertoo, kuinka hyödyllisiä eri muuttujat olivat
# Random Forest -mallille myynnin estimoinnissa.
# Suurempi arvo tarkoittaa yleensä tärkeämpää muuttujaa.

importance(rf_malli)

# Muuttujien tärkeyden tulkinta:
#
# %IncMSE kertoo, kuinka tärkeä muuttuja on mallin estimointikyvylle.
# Mitä suurempi arvo, sitä tärkeämpi muuttuja.
#
# Tässä mallissa muuttujien tärkeysjärjestys on:
# 1. Kampanja
# 2. Keskihinta
# 3. Verkkosivukävijät
# 4. Mainonta
#
# IncNodePurity kertoo, kuinka paljon muuttuja on auttanut
# päätöspuiden muodostamisessa.Arvolla ei ole helposti tulkittavaa
# käytännön yksikköä. Tarkempi selitys sivuutetaan tällä opintojaksolla. 
#
# Muuttujan suuri tärkeys ei tarkoita syy-seuraussuhdetta.


# Piirretään muuttujien tärkeys graafisesti.
# Kuvion avulla voidaan vertailla, mitkä muuttujat vaikuttivat
# eniten Random Forest -mallin toimintaan.
#
# Muuttujan suuri tärkeys ei kuitenkaan tarkoita, että muuttuja
# aiheuttaisi myynnin muutoksen. Se kertoo muuttujan hyödyllisyydestä
# tämän mallin tekemissä estimaateissa.

varImpPlot(
  rf_malli,
  main = "Muuttujien tärkeys Random Forest -mallissa"
)

############################################################
# 8. VERTAA LINEAARISTA REGRESSIOTA JA RANDOM FORESTIA
############################################################

# Kootaan mallien virhemittarit samaan taulukkoon.
mallivertailu <- tibble(
  Malli = c("Lineaarinen regressio", "Random Forest"),
  MAE = c(regressio_mae, rf_mae),
  RMSE = c(regressio_rmse, rf_rmse)
)

mallivertailu

# Muutetaan aineisto pitkään muotoon kuvion piirtämistä varten.
mallivertailu_pitka <- uusi_data |>
  select(
    Viikko,
    Toteutunut = Myynti_euroa,
    Regressio = Regressio_estimaatti,
    Random_Forest = Random_Forest_estimaatti
  ) |>
  pivot_longer(
    cols = c(Toteutunut, Regressio, Random_Forest),
    names_to = "Sarja",
    values_to = "Myynti"
  )

# Piirretään toteutunut myynti ja molempien mallien estimaatit.
ggplot(
  mallivertailu_pitka,
  aes(x = Viikko, y = Myynti, color = Sarja)
) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "Toteutunut ja estimoitu myynti viikoilla 51–70",
    x = "Viikko",
    y = "Myynti (€)",
    color = "Sarja"
  ) +
  theme_minimal()

# Lasketaan havaintokohtaiset virheet.
uusi_data <- uusi_data |>
  mutate(
    Regressio_virhe = Myynti_euroa - Regressio_estimaatti,
    Random_Forest_virhe = Myynti_euroa - Random_Forest_estimaatti,
    Mallien_eron_itseisarvo = abs(
      Regressio_estimaatti - Random_Forest_estimaatti
    )
  )

# Tarkastellaan viikkoja, joilla mallien estimaatit eroavat eniten.
uusi_data |>
  arrange(desc(Mallien_eron_itseisarvo)) |>
  select(
    Viikko,
    Myynti_euroa,
    Regressio_estimaatti,
    Random_Forest_estimaatti,
    Mallien_eron_itseisarvo
  ) |>
  slice_head(n = 5)


############################################################
# 9. ESTIMOI TULEVAA MYYNTIÄ
############################################################

# Valitaan mallivertailun perusteella pienemmän RMSE-arvon saanut malli.
parempi_malli <- mallivertailu |>
  slice_min(RMSE, n = 1, with_ties = FALSE) |>
  pull(Malli)

parempi_malli

# Tehdään Tuleva_data-aineistolle estimaatit paremmaksi valitulla mallilla.
if (parempi_malli == "Random Forest") {
  tuleva_data <- tuleva_data |>
    mutate(
      Myynti_estimaatti = predict(
        rf_malli,
        newdata = tuleva_data
      )
    )
} else {
  tuleva_data <- tuleva_data |>
    mutate(
      Myynti_estimaatti = predict(
        regressiomalli,
        newdata = tuleva_data
      )
    )
}

# Tulostetaan viikkojen 71–90 myyntiestimaatit.
tuleva_data |>
  select(Viikko, Myynti_estimaatti)

# Piirretään tulevien viikkojen myyntiestimaatit.
ggplot(tuleva_data, aes(x = Viikko, y = Myynti_estimaatti)) +
  geom_line(linewidth = 1, color = "steelblue") +
  geom_point(color = "steelblue") +
  labs(
    title = paste("Myyntiestimaatit mallilla:", parempi_malli),
    x = "Viikko",
    y = "Estimoitu myynti (€)"
  ) +
  theme_minimal()


############################################################
# 10. POHDINTA
############################################################

# Pohdi lopuksi:
#
# 1. Miten trendi ja kausivaihtelu näkyivät AirPassengers-aineistossa?
# 2. Miten ennustevälit muuttuivat, kun SARIMA-mallilla ennustettiin
#    kauemmas tulevaisuuteen?
# 3. Kumpi arvioi Uusi_data-aineiston myyntiä tarkemmin:
#    lineaarinen regressio vai Random Forest?
# 4. Kuinka suuri ero mallien MAE- ja RMSE-arvoissa oli?
# 5. Mitkä muuttujat olivat Random Forest -mallissa tärkeimpiä?
# 6. Missä tilanteissa Random Forestista oli hyötyä lineaariseen
#    regressioon verrattuna?
# 7. Miksi Uusi_data-aineisto sopii mallien arviointiin paremmin
#    kuin Historia-aineisto?
# 8. Miksi Tuleva_data kannattaa ottaa käyttöön vasta mallien
#    arvioinnin jälkeen?
# 9. Mitä eroa on SARIMA-mallilla tehdyllä aikasarjaennustamisella
#    ja Random Forestilla tehdyllä estimoinnilla?
