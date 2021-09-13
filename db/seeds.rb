# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Season.create(name: "2021-22")
Location.create(name: "Marina Alabau", gmaps_url: "https://goo.gl/maps/GCHt21pgWYSbWZsw8", practice_court: false)
Location.create(name: "Marina Alabau-P.1", gmaps_url: "https://goo.gl/maps/GCHt21pgWYSbWZsw8", practice_court: true)
Location.create(name: "Marina Alabau-P.2", gmaps_url: "https://goo.gl/maps/GCHt21pgWYSbWZsw8", practice_court: true)
Location.create(name: "Marina Alabau-P-3", gmaps_url: "https://goo.gl/maps/GCHt21pgWYSbWZsw8", practice_court: true)
Location.create(name: "Marina Alabau-Ext", gmaps_url: "https://goo.gl/maps/GCHt21pgWYSbWZsw8", practice_court: true)
Location.create(name: "Centro Multiusos", gmaps_url: "https://goo.gl/maps/5dFaxD7yWn6jwa2t5", practice_court: true)
Location.create(name: "Francisco León-1", gmaps_url: "https://goo.gl/maps/GpErh2nmXaeuNKdB9", practice_court: true)
Location.create(name: "Francisco León-2", gmaps_url: "https://goo.gl/maps/GpErh2nmXaeuNKdB9", practice_court: true)
Location.create(name: "Francisco León-3", gmaps_url: "https://goo.gl/maps/GpErh2nmXaeuNKdB9", practice_court: true)
Location.create(name: "CD Polígono Sur", gmaps_url: "https://goo.gl/maps/qXE8EM8zNSBEtcjo9", practice_court: false)
Location.create(name: "CD Mar del Plata", gmaps_url: "https://goo.gl/maps/wYqn4tN4ymRziXRo8", practice_court: false)
Division.create(name: "JDM-Aljarafe")
Division.create(name: "IMD-Sevilla")
Division.create(name: "FAB-Sevilla")
Division.create(name: "FAB-Nacional")
Kind.create(name: "1x0")
Kind.create(name: "1x1")
Kind.create(name: "1x1+1")
Kind.create(name: "2x0")
Kind.create(name: "2x1")
Kind.create(name: "2x2")
Kind.create(name: "2x2+2")
Kind.create(name: "3x0")
Kind.create(name: "3x2")
Kind.create(name: "3x3")
Kind.create(name: "4x0")
Kind.create(name: "4x4")
Kind.create(name: "5x0")
Kind.create(name: "5x5")
Kind.create(name: "Físico")
Kind.create(name: "Descanso")
Kind.create(name: "Jugada")
Kind.create(name: "Defensa")
Kind.create(name: "Sistema")
Skill.create(name: "Velocidad")
Skill.create(name: "Salto")
Skill.create(name: "Resistencia")
Skill.create(name: "Fuerza")
Skill.create(name: "Bote")
Skill.create(name: "Pase")
Skill.create(name: "Tiro")
Skill.create(name: "Finalización")
Skill.create(name: "Defensa")
Skill.create(name: "Rebote")
Skill.create(name: "M-a-M")
Skill.create(name: "B.Ind.")
Skill.create(name: "B.Dir.")
Skill.create(name: "B.Ciego")
Skill.create(name: "Cambio Direc.")
Skill.create(name: "Cambio Ritmo")
Team.create(name: "Senior Fem. FAB", season_id: 1, category_id: 1, division_id: 3, homecourt_id: 1)
Team.create(name: "Senior Masc. FAB", season_id: 1, category_id: 2, division_id: 3, homecourt_id: 1)
Team.create(name: "Junior Masc. FAB", season_id: 1, category_id: 4, division_id: 3, homecourt_id: 1)
Team.create(name: "Cadete Fem. FAB", season_id: 1, category_id: 5, division_id: 3, homecourt_id: 1)
Team.create(name: "Cadete Masc. FAB", season_id: 1, category_id: 6, division_id: 3, homecourt_id: 1)
Team.create(name: "Infantil Fem. FAB", season_id: 1, category_id: 7, division_id: 3, homecourt_id: 1)
Team.create(name: "Infantil Masc. IMD", season_id: 1, category_id: 8, division_id: 2, homecourt_id: 11)
Team.create(name: "Alevín Masc. FAB", season_id: 1, category_id: 10, division_id: 3, homecourt_id: 1)
Team.create(name: "Junior Masc. IMD", season_id: 1, category_id: 4, division_id: 2, homecourt_id: 1)
Team.create(name: "Cadete Masc. IMD", season_id: 1, category_id: 6, division_id: 2, homecourt_id: 11)
Team.create(name: "Senior Masc. IMD", season_id: 1, category_id: 2, division_id: 2, homecourt_id: 11)
Team.create(name: "Alevín Iniciación", season_id: 1, category_id: 11, division_id: 1, homecourt_id: 1)
Team.create(name: "Benjamín Inciación", season_id: 1, category_id: 14, division_id: 1, homecourt_id: 1)
Team.create(name: "Baby Basket", season_id: 1, category_id: 15, division_id: 1, homecourt_id: 1)
