############################################################
# DEMO 7: TILASTOLLINEN ENNUSTAMINEN
############################################################

# Tilastollisessa ennustamisessa muodostetaan ensin havaintojen
# perusteella tilastollinen malli. Vasta tämän jälkeen mallia
# käytetään uuden havainnon arvon ennustamiseen.
#
# Tässä demossa erotetaan toisistaan:
# 1. aineiston yhteyksien tarkastelu
# 2. regressiomallin muodostaminen
# 3. uusien havaintojen ennustaminen muodostetulla mallilla

library(tidyverse)


############################################################
# 1. TUTUSTU AINEISTOON
############################################################

# airquality on R:n valmis aineisto New Yorkin ilmanlaadusta.
# Aineisto sisältää päivittäisiä havaintoja touko-syyskuulta 1973.
#
# Muuttujat:
# Ozone   = otsonipitoisuus (ppb)
# Solar.R = auringon säteily (langley)
# Wind    = tuulen nopeus (mph)
# Temp    = lämpötila (°F)
# Month   = kuukausi
# Day     = kuukauden päivä

data(airquality)
data <- airquality

glimpse(data)
head(data)
summary(data)

# Tarkistetaan puuttuvat arvot.
colSums(is.na(data))

# Mallinnuksessa tarvitaan muuttujia Ozone, Temp, Wind ja Solar.R.
# Poistetaan vain näiden muuttujien puuttuvia arvoja sisältävät rivit.
data_malli <- data |>
  select(Ozone, Temp, Wind, Solar.R) |>
  drop_na()

nrow(data_malli)
glimpse(data_malli)


############################################################
# 2. TUTKI MUUTTUJIEN VÄLISIÄ YHTEYKSIÄ
############################################################

# Tarkastellaan ensin ennustettavan muuttujan jakaumaa.
ggplot(data_malli, aes(x = Ozone)) +
  geom_histogram(binwidth = 10, color = "white", fill = "steelblue") +
  labs(
    title = "Otsonipitoisuuden jakauma",
    x = "Otsonipitoisuus (ppb)",
    y = "Havaintojen määrä"
  ) +
  theme_minimal()

# Tarkastellaan lämpötilan ja otsonipitoisuuden välistä yhteyttä.
# Tässä ei vielä ennusteta uutta havaintoa. Regressiosuora
# havainnollistaa havaintojen perusteella laskettua lineaarista yhteyttä.
# Harmaa alue kuvaa regressiosuoran 95 %:n luottamusväliä eli
# epävarmuutta keskimääräisessä otsonipitoisuudessa.
# Harmaa alue ei ole yksittäisen uuden havainnon ennusteväli.
ggplot(data_malli, aes(x = Temp, y = Ozone)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Lämpötilan ja otsonipitoisuuden lineaarinen yhteys",
    x = "Lämpötila (°F)",
    y = "Otsonipitoisuus (ppb)"
  ) +
  theme_minimal()

# Tarkastellaan myös tuulen nopeuden ja auringon säteilyn yhteyksiä.
ggplot(data_malli, aes(x = Wind, y = Ozone)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Tuulen nopeuden ja otsonipitoisuuden lineaarinen yhteys",
    x = "Tuulen nopeus (mph)",
    y = "Otsonipitoisuus (ppb)"
  ) +
  theme_minimal()

ggplot(data_malli, aes(x = Solar.R, y = Ozone)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Auringon säteilyn ja otsonipitoisuuden lineaarinen yhteys",
    x = "Auringon säteily (langley)",
    y = "Otsonipitoisuus (ppb)"
  ) +
  theme_minimal()

# Lasketaan muuttujien Pearsonin korrelaatiot.
cor(data_malli)

# Pohdi:
# - Minkä suuntainen yhteys lämpötilalla on otsonipitoisuuteen?
# - Minkä suuntainen yhteys tuulella on otsonipitoisuuteen?
# - Mikä muuttuja näyttää olevan voimakkaimmin yhteydessä Ozone-muuttujaan?


############################################################
# 3. LINEAARISEN REGRESSIOMALLIN MUODOSTAMINEN
############################################################

# Muodostetaan havaintojen perusteella regressiomalli, jossa
# otsonipitoisuutta selitetään lämpötilalla.
#
# lm() ei tässä vielä ennusta uutta havaintoa. Se muodostaa mallin:
#
# Ozone = vakiotermi + regressiokerroin * Temp
#
# Tämä on sama lineaarinen regressiomalli, jonka regressiosuora
# piirrettiin kohdassa 2. Nyt malli tallennetaan, jotta sen tuloksia
# voidaan tarkastella ja sitä voidaan käyttää uusien havaintojen
# ennustamiseen.

malli_yksi <- lm(Ozone ~ Temp, data = data_malli)

# Tarkastellaan mallin tuloksia.
summary(malli_yksi)

# Tuloksesta tarkastellaan erityisesti:
# - Intercept: mallin vakiotermi
# - Temp: lämpötilan regressiokerroin
# - p-arvo: onko lämpötilan yhteys tilastollisesti merkitsevä?
# - Multiple R-squared: kuinka suuren osuuden Ozone-muuttujan
#   vaihtelusta malli selittää?

coef(malli_yksi)

# Pohdi:
# - Mitä lämpötilan regressiokerroin tarkoittaa käytännössä?
# - Kuinka suuren osan otsonipitoisuuden vaihtelusta malli selittää?
# - Kuinka hyvin kohdassa 2 piirretty suora kuvaa havaintopisteitä?


############################################################
# 4. UUDEN HAVAINNON ENNUSTAMINEN REGRESSIOMALLILLA
############################################################

# Nyt käytetään kohdassa 3 muodostettua mallia uuden havainnon
# ennustamiseen.
#
# Kysymys on esimerkiksi:
# Mikä otsonipitoisuus mallin perusteella ennustetaan, jos
# lämpötila on 85 °F?

uusi_havainto <- data.frame(Temp = 85)

predict(malli_yksi, newdata = uusi_havainto)

# Ennustetaan seuraavaksi useita uusia lämpötiloja.
uudet_lampotilat <- data.frame(
  Temp = c(70, 80, 85, 90)
)

piste_estimaatit <- predict(
  malli_yksi,
  newdata = uudet_lampotilat
)

# Tulostetaan uudet lämpötilat ja niitä vastaavat piste-estimaatit.
data.frame(
  Temp = uudet_lampotilat$Temp,
  Piste_estimaatti = piste_estimaatit
)

# Piste-estimaatti antaa yhden arvon. Yksittäisen uuden havainnon
# todelliseen arvoon liittyy kuitenkin epävarmuutta. Tämän vuoksi
# lasketaan myös 95 %:n ennusteväli. Ennusteväli kuvaa yksittäisen
# uuden havainnon mahdollisten arvojen vaihtelualuetta.
ennustevali <- predict(
  malli_yksi,
  newdata = uudet_lampotilat,
  interval = "prediction",
  level = 0.95
)

cbind(uudet_lampotilat, ennustevali)

# fit = mallin piste-estimaatti
# lwr = 95 %:n ennustevälin alaraja
# upr = 95 %:n ennustevälin yläraja
#
# Pohdi:
# - Mikä ero on regressiosuoralla ja varsinaisella ennusteella?
# - Miksi ennuste ei ole yksi täysin varma arvo?
# - Miksi ennusteväli kannattaa ilmoittaa piste-estimaatin rinnalla?
# - Miksi ennustevälin alaraja voi olla negatiivinen,
#   vaikka otsonipitoisuus ei voi olla negatiivinen?


############################################################
# 5. USEAN MUUTTUJAN REGRESSIOMALLIN MUODOSTAMINEN
############################################################

# Muodostetaan havaintojen perusteella toinen regressiomalli.
# Nyt otsonipitoisuutta selitetään lämpötilan lisäksi tuulen
# nopeudella ja auringon säteilyllä.

malli_usea <- lm(
  Ozone ~ Temp + Wind + Solar.R,
  data = data_malli
)

summary(malli_usea)

# Tarkastellaan:
# - regressiokertoimia
# - kertoimien p-arvoja
# - Multiple R-squared -arvoa
# - Adjusted R-squared -arvoa

# Verrataan yhden ja usean muuttujan mallien selitysasteita.
data.frame(
  Malli = c("Yhden muuttujan regressio", "Usean muuttujan regressio"),
  R2 = c(
    summary(malli_yksi)$r.squared,
    summary(malli_usea)$r.squared
  ),
  Korjattu_R2 = c(
    summary(malli_yksi)$adj.r.squared,
    summary(malli_usea)$adj.r.squared
  )
)

# Pohdi:
# - Mitkä muuttujat ovat tilastollisesti merkitseviä?
# - Miten kertoimet tulkitaan, kun muut mallin muuttujat pidetään vakioina?
# - Paransiko uusien muuttujien lisääminen mallin selitysastetta?
# - Miksi korjattu R² on hyödyllinen usean muuttujan mallissa?


############################################################
# 6. UUDEN HAVAINNON ENNUSTAMINEN USEAN MUUTTUJAN MALLILLA
############################################################

# Nyt käytetään kohdassa 5 muodostettua mallia uuden havainnon
# ennustamiseen. Uudesta tilanteesta täytyy antaa kaikki mallin
# tarvitsemat selittävät muuttujat.

uusi_saatilanne <- data.frame(
  Temp = 85,
  Wind = 8,
  Solar.R = 200
)

predict(malli_usea, newdata = uusi_saatilanne)

# Lasketaan myös 95 %:n ennusteväli.
predict(
  malli_usea,
  newdata = uusi_saatilanne,
  interval = "prediction",
  level = 0.95
)

# Verrataan yhden ja usean muuttujan mallien piste-estimaatteja.
# Mallit käyttävät eri määrän tietoa samasta säätilanteesta.
# Yhden muuttujan malli käyttää vain lämpötilaa. Usean muuttujan
# malli käyttää lämpötilan lisäksi tuulen nopeutta ja auringon säteilyä.

en_yksi <- predict(
  malli_yksi,
  newdata = data.frame(Temp = 85)
)

en_usea <- predict(
  malli_usea,
  newdata = uusi_saatilanne
)

data.frame(
  Malli = c("Yhden muuttujan regressio", "Usean muuttujan regressio"),
  Piste_estimaatti = c(en_yksi, en_usea)
)

# Pohdi:
# - Miten lisätiedot tuulesta ja auringon säteilystä muuttivat
#   saman säätilanteen piste-estimaattia?
# - Kumpi malli käyttää enemmän tilanteesta saatavaa tietoa?
# - Tarkoittaako monimutkaisempi malli automaattisesti parempaa ennustetta?


############################################################
# 7. MALLIN SOPIVUUDEN JA JÄÄNNÖSTEN TARKASTELU
############################################################

# Mallin sovite on mallin alkuperäiselle havainnolle laskema arvo.
# Se ei ole sama asia kuin täysin uuden havainnon ennustaminen.
# Jäännös on todellisen ja mallin sovittaman arvon erotus.

data_arviointi <- data_malli |>
  mutate(
    Sovite_yksi = fitted(malli_yksi),
    Jäännös_yksi = residuals(malli_yksi),
    Sovite_usea = fitted(malli_usea),
    Jäännös_usea = residuals(malli_usea)
  )

# Verrataan todellisia ja usean muuttujan mallin sovittamia arvoja.
ggplot(data_arviointi, aes(x = Ozone, y = Sovite_usea)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = "Todelliset ja mallin sovittamat otsonipitoisuudet",
    x = "Todellinen otsonipitoisuus (ppb)",
    y = "Mallin sovittama otsonipitoisuus (ppb)"
  ) +
  theme_minimal()

# Tarkastellaan usean muuttujan mallin jäännöksiä.
ggplot(data_arviointi, aes(x = Sovite_usea, y = Jäännös_usea)) +
  geom_point() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(
    title = "Usean muuttujan mallin jäännökset",
    x = "Mallin sovittama otsonipitoisuus (ppb)",
    y = "Jäännös (ppb)"
  ) +
  theme_minimal()

# Lasketaan MAE ja RMSE mallinnusaineistolle.
# Näitä ei tässä kutsuta uuden aineiston ennustevirheeksi, koska
# samat havainnot ovat olleet mukana mallin muodostamisessa.

mallien_sopivuus <- data.frame(
  Malli = c("Yhden muuttujan regressio", "Usean muuttujan regressio"),
  MAE = c(
    mean(abs(data_arviointi$Jäännös_yksi)),
    mean(abs(data_arviointi$Jäännös_usea))
  ),
  RMSE = c(
    sqrt(mean(data_arviointi$Jäännös_yksi^2)),
    sqrt(mean(data_arviointi$Jäännös_usea^2))
  )
)

mallien_sopivuus

# MAE kertoo virheen keskimääräisen itseisarvon.
# RMSE painottaa suuria virheitä MAE:ta voimakkaammin.
# Tässä ne kuvaavat mallien sopivuutta käytettyyn aineistoon.
# Mallin pienempi MAE ja RMSE osoittavat tässä paremman sopivuuden
# mallinnusaineistoon. Ne eivät vielä osoita parempaa ennustekykyä
# aineiston ulkopuolisille uusille havainnoille.

# R:n valmiit regressiomallin diagnostiikkakuviot.
par(mfrow = c(2, 2))
plot(malli_usea)
par(mfrow = c(1, 1))

# Pohdi:
# - Kumpi malli sopii käytettyyn aineistoon paremmin?
# - Näkyykö jäännöksissä järjestelmällistä rakennetta?
# - Onko havaintoja, joissa mallin virhe on erityisen suuri?
# - Miksi samalla aineistolla laskettu RMSE ei vielä todista,
#   että malli ennustaa hyvin täysin uusia havaintoja?


############################################################
# 8. POHDINTAA
############################################################

# Pohdi lopuksi:
#
# 1. Mikä ero on regressiomallin muodostamisella ja ennustamisella?
# 2. Kuinka hyvin lämpötila yksin selitti otsonipitoisuutta?
# 3. Paransivatko Wind ja Solar.R mallia?
# 4. Tarkoittaako korkea R² automaattisesti hyvää ennustetta?
# 5. Miksi ennusteväli kannattaa ilmoittaa piste-estimaatin rinnalla?
# 6. Mitä ongelmia syntyy, jos ennustetaan alkuperäisen aineiston
#    havaintoalueen ulkopuolelle?
# 7. Voidaanko regressiomallin perusteella päätellä syy-seuraussuhteita?
# 8. Mitä tapahtuu, jos muuttujien väliset yhteydet eivät ole lineaarisia?
# 9. Miten trendit, kausivaihtelu tai toimintaympäristön muutokset
#    voivat heikentää ennusteita?
#

