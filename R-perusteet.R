#################################################
# DATA-ANALYTIIKAN OHJELMOINTIKIELET
# 0. R:N PERUSTEET
# Syntaksi, muuttujat, tietotyypit ja laskutoimitukset
#################################################

#Aja ohjelmakoodi rivi kerrallaan (Run tämä ikkunan yläoikealta tai CTRL+Enter,
#tulos näkyy konsolissa. Tehtävä kohdassa tee oma koodisi ja aja myös se. 

#################################################
# 1. MUUTTUJAT
#################################################

# ESIMERKKI

nimi <- "Matti"
ika <- 25

nimi


# TEHTÄVÄ
# Luo muuttujat etunimi ja opiskeluvuosi.
# Anna niille sopivat arvot ja tulosta ne.

#################################################
# 2. NUMEROT (NUMERIC)
#################################################

# ESIMERKKI

a <- 10
b <- 2.5

a
b

# TEHTÄVÄ
# Luo muuttujat luku1 ja luku2.
# Anna niille haluamasi numeeriset arvot ja tulosta ne.




#################################################
# 3. TEKSTI (CHARACTER)
#################################################

# ESIMERKKI

kaupunki <- "Kuopio"

kaupunki

# TEHTÄVÄ
# Luo muuttuja harrastus.
# Anna sille arvoksi jokin harrastuksesi ja tulosta arvo.



#################################################
# 4. LOOGISET ARVOT (LOGICAL)
#################################################

# ESIMERKKI

kurssi_suoritettu <- TRUE

kurssi_suoritettu

# TEHTÄVÄ
# Luo muuttuja osallistunut_luennolle.
# Anna sille arvoksi FALSE.
# Tulosta muuttujan arvo.



#################################################
# 5. YHTEENLASKU
#################################################

# ESIMERKKI

a <- 5
b <- 3

tulos <- a + b

tulos

# TEHTÄVÄ
# Luo muuttujat x ja y.
# Anna niille arvot 12 ja 7.
# Laske summa muuttujaan summa.
# Tulosta summa.





#################################################
# 6. VÄHENNYSLASKU
#################################################

# ESIMERKKI

a <- 20
b <- 4

a - b

# TEHTÄVÄ
# Luo muuttujat x ja y.
# Anna niille arvot 30 ja 12.
# Laske erotus ja tulosta tulos.



#################################################
# 7. KERTOLASKU
#################################################

# ESIMERKKI

a <- 6
b <- 7

a * b

# TEHTÄVÄ
# Laske lukujen 8 ja 9 tulo.



#################################################
# 8. JAKOLASKU
#################################################

# ESIMERKKI

a <- 15
b <- 3

a / b

# TEHTÄVÄ
# Laske lukujen 40 ja 5 osamäärä.



#################################################
# 9. POTENSSI
#################################################

# ESIMERKKI

4^2

# TEHTÄVÄ
# Laske 5^3.




#################################################
# 10. VERTAILUOPERAATTORIT
#################################################

# ESIMERKKI

10 > 5

# TEHTÄVÄ
# Suorita seuraavat vertailut ja tarkastele tuloksia.

8 > 12

15 == 15

7 != 3



#################################################
# 11. TIETOTYYPIN TARKASTAMINEN
#################################################

# ESIMERKKI

nimi <- "Matti"

class(nimi)

# TEHTÄVÄ
# Luo seuraavat muuttujat.

a <- 100
b <- "Savonia"
c <- TRUE

# Selvitä muuttujien tietotyypit käyttäen
# class()-funktiota.

#################################################
# 12. YHDISTELMÄTEHTÄVÄ
#################################################

# ESIMERKKI

hinta <- 120
alennus <- 15

alennettu_hinta <- hinta * (1 - alennus/100)

alennettu_hinta

# TEHTÄVÄ
# Tuotteen hinta on 250 €.
# Alennus on 20 %.
# Laske tuotteen alennettu hinta ja tulosta tulos.

#################################################
# 13. EHTOLAUSE IF
#################################################

# ESIMERKKI

ika <- 20

if (ika >= 18) {
  print("Täysi-ikäinen")
}

# TEHTÄVÄ
# Luo muuttuja ika ja anna sille arvoksi 16.
# Tulosta teksti "Täysi-ikäinen", jos ikä on vähintään 18.





#################################################
# 14. IF ELSE
#################################################

# ESIMERKKI

lampotila <- 15

if (lampotila >= 20) {
  print("Lämmin päivä")
} else {
  print("Viileä päivä")
}

# TEHTÄVÄ
# Luo muuttuja lampotila ja anna sille arvoksi 25.
# Tulosta:
# "Lämmin päivä", jos lämpötila on vähintään 20.
# Muuten tulosta "Viileä päivä".





#################################################
# 15. PISTEIDEN ARVIOINTI
#################################################

# ESIMERKKI

pisteet <- 85

if (pisteet >= 50) {
  print("Hyväksytty")
} else {
  print("Hylätty")
}

# TEHTÄVÄ
# Luo muuttuja pisteet ja anna sille arvoksi 40.
# Tulosta:
# "Hyväksytty", jos pisteitä on vähintään 50.
# Muuten tulosta "Hylätty".





#################################################
# 16. IF ELSE IF ELSE
#################################################

# ESIMERKKI

arvosana <- 4

if (arvosana == 5) {
  print("Erinomainen")
} else if (arvosana >= 3) {
  print("Hyvä")
} else {
  print("Tarvitsee harjoittelua")
}

# TEHTÄVÄ
# Luo muuttuja arvosana ja anna sille arvoksi 2.
# Käytä samaa logiikkaa kuin esimerkissä.
# Mitä ohjelma tulostaa?





#################################################
# 17. VERTAILU MERKKIJONOLLA
#################################################

# ESIMERKKI

vari <- "sininen"

if (vari == "sininen") {
  print("Oikea väri")
} else {
  print("Väärä väri")
}

# TEHTÄVÄ
# Luo muuttuja vari ja anna sille arvoksi "punainen".
# Käytä samaa logiikkaa kuin esimerkissä.





#################################################
# 18. LOOGISET OPERAATTORIT
#################################################

# ESIMERKKI

ika <- 25
ajokortti <- TRUE

if (ika >= 18 & ajokortti == TRUE) {
  print("Saa ajaa autoa")
}

# TEHTÄVÄ
# Luo muuttujat:
# ika <- 17
# ajokortti <- TRUE
#
# Käytä samaa ehtoa kuin esimerkissä.
# Tulostuuko teksti?





#################################################
# 19. IF JA LASKUTOIMITUS
#################################################

# ESIMERKKI

ostos <- 120

if (ostos >= 100) {
  alennettu_hinta <- ostos * 0.90
  print(alennettu_hinta)
}

# TEHTÄVÄ
# Tuotteen hinta on 80 €.
# Jos hinta on vähintään 100 €, myönnetään 10 % alennus.
# Toteuta ohjelma ja tarkastele tulosta.





#################################################
# 20. YHDISTELMÄTEHTÄVÄ
#################################################

# ESIMERKKI

saldo <- 250

if (saldo >= 100) {
  print("Tilillä on riittävästi rahaa")
} else {
  print("Tilillä ei ole riittävästi rahaa")
}

# TEHTÄVÄ
# Luo muuttuja saldo ja anna sille arvoksi 50.
# Tulosta:
# "Tilillä on riittävästi rahaa", jos saldo on vähintään 100.
# Muuten tulosta:
# "Tilillä ei ole riittävästi rahaa".

