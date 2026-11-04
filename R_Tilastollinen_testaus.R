########################################################
# DEMO 6: TILASTOLLINEN TESTAUS
########################################################

# Tilastollisella testauksella tutkitaan, ovatko aineistossa
# havaitut erot tai yhteydet todennäköisesti todellisia vai
# voivatko ne johtua sattumasta.¨

# Aluksi tehdään aina hypoteesit:
#
# H0 = eroa tai yhteyttä ei ole.
# H1 = ero tai yhteys on olemassa.
#
# Tässä demossa käytetään yleisesti käytössä olevaa merkitsevyystasoa 0.05.
# Jos p < 0.05, tulosta pidetaan tilastollisesti merkitsevänä ja H0 voidaan hylätä.
# Jos p >= 0.05, aineiston perusteella ei ole riittävästi näyttöä 
# tilastollisesti merkitsevästa erosta tai yhteydestö ja H0:aa ei voida hylätä. 

# Mieti jokaisen testin yhteydessä seuraavaa:
#
# 1. Mitä testiä käytettiin ja miksi?
# 2. Oliko tulos tilastollisesti merkitsevä?
# 3. Mitä tulos tarkoittaa käytännössä?
#
# Muista:
# p < 0.05  -> tilastollisesti merkitsevä tulos
# p >= 0.05 -> ei riittävää näyttöä tilastollisesti merkitsevästa
#              erosta tai yhteydestä
#
# Oikeat vastaukset ovat Moodlessa.


library(tidyverse)
library(readxl)

# Lue Excel-aineisto.

data <- read_excel("shared/Tilastollinen_testaus.xlsx", sheet = "Aineisto")


########################################################
# 1. TUTUSTU AINEISTOON
########################################################

# Tarkastellaan aineiston rakennettä, muuttujia ja ensimmäisiä rivejä.

glimpse(data)
head(data)
summary(data)

# Tyytyväisyys on Likert-asteikollinen muuttuja:
# 1 = erittäin tyytymätön
# 5 = erittäin tyytyväinen


########################################################
# 2. KAHDEN RYHMÄN KESKIARVOJEN VERTAILU: T-TESTI
########################################################

# Ennen t-testiä tarkastellaan koepisteiden jakaumia.
# T-testin kannalta jakaumien olisi hyvä olla suunnilleen normaalisia
# eikä aineistossa saisi olla voimakkaita poikkeavia havaintoja.

# Histogrammit kevään ja syksyn toteutuksille.

ggplot(data, aes(x = Koepisteet, fill = Ryhmä)) +
  geom_histogram(binwidth = 5, color = "white") +
  facet_wrap(~ Ryhmä) +
  labs(
    title = "Koepisteiden jakaumat keväällä ja syksyllä",
    x = "Koepisteet",
    y = "Lukumäärä"
  ) +
  guides(fill = "none")

# Laatikkokaavio auttaa havaitsemaan mahdollisia poikkeavia havaintoja.

ggplot(data, aes(x = Ryhmä, y = Koepisteet, fill = Ryhmä)) +
  geom_boxplot() +
  labs(
    title = "Koepisteet keväällä ja syksyllä",
    x = "Toteutus",
    y = "Koepisteet"
  ) +
  guides(fill = "none")

# Ryhmät ovat riippumattomia, koska kevään ja syksyn toteutuksilla
# on eri opiskelijat.

# Lasketaan ryhmien koepisteiden keskiarvot.

data |>
  group_by(Ryhmä) |>
  summarise(
    n = n(),
    keskiarvo = mean(Koepisteet, na.rm = TRUE),
    keskihajonta = sd(Koepisteet, na.rm = TRUE)
  )

# Tehdään kahden riippumattoman otoksen t-testi.
# R:n t.test() käyttää oletuksena Welchin t-testiä,
# joten ryhmien varianssien ei tarvitse olla samansuuruisia.

t_testi <- t.test(Koepisteet ~ Ryhmä, data = data)

t_testi

# Tuloksesta tarkastellaan erityisesti:
# - p-arvoa
# - 95 %:n luottamusväliä
# - ryhmien keskiarvoja
#
# Jos p < 0.05, hylätään nollahypoteesi ja todetaan,
# että ryhmien koepisteissä on tilastollisesti merkitsevä ero.


########################################################
# 3. TYYTYVÄISYYDEN VERTAILU: MANN-WHITNEYN U-TESTI
########################################################

# Tyytyväisyys on Likert-asteikollinen muuttuja.
# Siksi kahden riippumattoman ryhmän vertailuun käytetään tässä
# Mann-Whitneyn U-testiä. R:ssa testi tehdään wilcox.test()-funktiolla.

# 3.1 Verkko-opiskelijat: kevät vs. syksy

verkko <- data |>
  filter(Opiskelumuoto == "Verkko")

# Tarkastellaan mediaaneja.

verkko |>
  group_by(Ryhmä) |>
  summarise(
    n = n(),
    mediaani = median(Tyytyväisyys, na.rm = TRUE)
  )

# Tarkastellaan vastausten jakaumia.

verkko |>
  count(Ryhmä, Tyytyväisyys)

# Mann-Whitneyn U-testi verkko-opiskelijoille.

mann_verkkok <- wilcox.test(
  Tyytyväisyys ~ Ryhmä,
  data = verkko,
  exact = FALSE
)

mann_verkkok

# 3.2 Lähiopiskelijat: kevät vs. syksy

lähi <- data |>
  filter(Opiskelumuoto == "Lähi")

lähi |>
  group_by(Ryhmä) |>
  summarise(
    n = n(),
    mediaani = median(Tyytyväisyys, na.rm = TRUE)
  )

lähi |>
  count(Ryhmä, Tyytyväisyys)

mann_lähi <- wilcox.test(
  Tyytyväisyys ~ Ryhmä,
  data = lähi,
  exact = FALSE
)

mann_lähi

# 3.3 Koko vuosi: verkko vs. lähi
# Nyt kevättä ja syksyä ei erotella, vaan verrataan kaikkia
# verkko-opiskelijoita kaikkiin lähiopiskelijoihin.

data |>
  group_by(Opiskelumuoto) |>
  summarise(
    n = n(),
    mediaani = median(Tyytyväisyys, na.rm = TRUE)
  )

data |>
  count(Opiskelumuoto, Tyytyväisyys)

mann_vuosi <- wilcox.test(
  Tyytyväisyys ~ Opiskelumuoto,
  data = data,
  exact = FALSE
)

mann_vuosi

# Jokaisesta vertailusta tarkastellaan p-arvoa.
# Jos p < 0.05, ryhmien välillä on tilastollisesti merkitsevä ero.
# Jos p >= 0.05, aineisto ei anna riittävää näyttöä ryhmien erosta.


########################################################
# 4. OPISKELUMUODON JA LÄPÄISYN YHTEYS: CHI2-TESTI
########################################################

# Muodostetaan ensin ristiintaulukko opiskelumuodosta ja läpäisystä.

ristiintaulukko <- table(data$Opiskelumuoto, data$Läpäissyt)

cat("\nRistiintaulukko:\n")
ristiintaulukko

# Riviprosentit kertovat, kuinka suuri osuus kunkin opiskelumuodon
# opiskelijoista on läpäissyt tai ei ole läpäissyt kurssia.

cat("\nRiviprosentit (%):\n")

prop.table(ristiintaulukko, margin = 1) * 100

# χ²-testillä tutkitaan, ovatko opiskelumuoto ja läpäisy
# yhteydessä toisiinsa.

chi2_testi <- chisq.test(ristiintaulukko)

chi2_testi

# Tuloksesta tarkastellaan p-arvoa.
# Jos p < 0.05, opiskelumuodon ja läpäisyn välillä on
# tilastollisesti merkitsevä yhteys.
# Testi kertoo yhteydestä, ei siitä, että opiskelumuoto aiheuttaisi läpäisyn.


########################################################
# 5. OPISKELUTUNTIEN JA KOEPISTEIDEN YHTEYS:
#    PEARSONIN KORRELAATIOTESTI
########################################################

# Piirretään ensin hajontakuvio.
# X-akselilla ovat opiskelutunnit ja y-akselilla koepisteet.

ggplot(data, aes(x = Opiskelutunnit, y = Koepisteet)) +
  geom_point() +
  labs(
    title = "Opiskelutuntien ja koepisteiden yhteys",
    x = "Opiskelutunnit viikossa",
    y = "Koepisteet"
  )

# Hajontakuviosta arvioidaan:
# - yhteyden suuntaa
# - yhteyden voimakkuutta
# - näyttääkö yhteys suunnilleen lineaariselta
# - onko aineistossa selvästi poikkeavia havaintoja.

# Lasketaan Pearsonin korrelaatiokerroin.

korrelaatio <- cor(
  data$Opiskelutunnit,
  data$Koepisteet,
  use = "complete.obs",
  method = "pearson"
)

korrelaatio

# Pearsonin korrelaatiotestillä tutkitaan,
# onko havaittu lineaarinen yhteys tilastollisesti merkitsevä.

pearson_testi <- cor.test(
  data$Opiskelutunnit,
  data$Koepisteet,
  method = "pearson"
)

pearson_testi

# Tuloksesta tarkastellaan:
# - korrelaatiokerrointa r
# - p-arvoa
# - 95 %:n luottamusväliä.
#
# Positiivinen r tarkoittaa, että muuttujat kasvavat keskimäärin samaan suuntaan.
# Negatiivinen r tarkoittaa, että toisen kasvaessa toinen pienenee.
# Pearsonin korrelaatio kertoo lineaarisesta yhteydestä,
# mutta korrelaatio ei tarkoita syy-seuraussuhdettä.



