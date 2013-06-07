#!/usr/bin/ruby

fname_storico = ARGV[0]
storico = File.read(fname_storico).split("\r\n")
storico.delete_at(0)

frequenza = (1..20).inject({}) { |a,v| a[v.to_s] = 0; a }
frequenza_numerone = (1..20).inject({}) { |a,v| a[v.to_s] = 0; a }
frequenza_per_orario = (8..23).inject({}) { |a,v| a[v.to_s] = (1..20).inject({}) { |a,v| a[v.to_s] = 0; a }; a }
frequenza_numerone_per_orario = (8..23).inject({}) { |a,v| a[v.to_s] = (1..20).inject({}) { |a,v| a[v.to_s] = 0; a }; a }
ritardi = (1..20).inject({}) { |a,v| a[v.to_s] = 0; a }

storico.each do |estrazione|
  dati = estrazione.split("\t")
  estratti = dati[-11..-2]
  ora = dati[2]
  frequenza_numerone[dati[-1]] += 1
  frequenza_numerone_per_orario[ora][dati[-1]] += 1
  estratti.each do |estratto| 
    frequenza[estratto] += 1
    frequenza_per_orario[ora][estratto] += 1
    ritardi[estratto] = 0
  end
  ritardatari = ((1..20).map{|n| n.to_s})-estratti
  ritardatari.each { |r| ritardi[r] += 1}
end

puts "Ritardi:"
p ritardi

puts "Decina piu' frequente"
frequenza_ordinata = Hash[frequenza.sort_by {|num,freq| freq }]
decina_frequente = (frequenza_ordinata.keys.reverse[0..9].map { |num| "%d"%[num,frequenza_ordinata[num]]}).sort
puts decina_frequente.join(" - ")

puts "Confronto con storico estrazioni ..."

def calcolo_vincite(giocata, storico, stampa_solo_perc_utili)
  punteggi_utili = [0,1,2,3,7,8,9,10]
  frequenza_punteggi_utili = Hash[punteggi_utili.map { |p| [p,0]}]
  frequenza_punteggi_utili_per_ora = (8..23).inject({}) { |a,v| a[v.to_s] = Hash[punteggi_utili.map { |p| [p,0]}]; a}
  totale_punteggi_utili = 0

  storico.each do |estrazione|
    dati = estrazione.split("\t")
    estratti = dati[-11..-2]
    ora = dati[2]
    punti = 10-(estratti-giocata).size
    if punteggi_utili.include?(punti)
      #puts "Estrazione del #{dati[1]} ore #{ora} - Punti: #{punti} (#{estratti} / #{giocata})"
      totale_punteggi_utili += 1
      frequenza_punteggi_utili[punti] += 1
      frequenza_punteggi_utili_per_ora[ora][punti] += 1
    end
  end

  puts "Totale estrazione controllate: #{storico.size}" unless stampa_solo_perc_utili
  puts "Totale punteggi utili rilevati: #{totale_punteggi_utili}" unless stampa_solo_perc_utili
  puts "Rapporto punteggi utili / totale estrazioni: #{(totale_punteggi_utili.to_f/storico.size)*100} %"
  unless stampa_solo_perc_utili
    puts "Frequenza punteggi utili:" 
    frequenza_punteggi_utili.keys.sort.each do |punteggio|
      puts "Punti #{punteggio}: #{frequenza_punteggi_utili[punteggio]}"
    end
  end
end

calcolo_vincite(decina_frequente, storico, false)

puts "Analisi vincite per decine casuali ..."
(1..100).each do
  casuale = (1..20).to_a.shuffle[0..9].map(&:to_s)
  #puts casuale.join(" - ")
  calcolo_vincite(casuale,storico, true)
end


