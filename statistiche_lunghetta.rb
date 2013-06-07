#!/usr/bin/ruby

fname = ARGV[0]
ruota = ARGV[1].downcase

def estratti_su_ruota(ruota,estrazione)
  ruote = [:bari,:cagliari,:firenze,:genova,:milano,:napoli,:palermo,:roma,:torino,:venezia]
  estratti = []
  begin
    estr_ruota = estrazione[ruote.index(ruota)]
    estratti = estr_ruota.split("-")
    estratti = estratti.map { |num| num.to_i }
  rescue
    puts "Ruota: #{ruota} Estrazione: #{estr_ruota}"
  end
  estratti
end

def import_storico()
  ruote = [:bari,:cagliari,:firenze,:genova,:milano,:napoli,:palermo,:roma,:torino,:venezia]
  estrazioni = []
  analisi_fr = ruote.inject({}) do |a,ruota|
    dati_iniziali = (1..90).inject({}) { |v,n| v[n] ||= 0; v } 
    a[ruota] = {freq: dati_iniziali, rit: dati_iniziali.dup}
    a
  end
  Dir.glob("estrazioni*.txt").each do |archivio|
    puts "Anno #{archivio.delete("estrazioni").split(".")[0]}"
    dati = File.read(archivio, :encoding => "BINARY").split("\n")
    dati = dati[4..-4]
    dati.each do |riga|
      data,*estr = riga.delete("|")[4..-1].split(" ")
      estrazioni << ruote.inject({}) do |e,r| 
        estratti = estratti_su_ruota(r,estr)
        estratti.each do |num|
          analisi_fr[r][:freq][num] += 1
          analisi_fr[r][:rit][num] = 0
        end
        ritardatari = ((1..90).map{|n| n})-estratti
        ritardatari.each { |num| analisi_fr[r][:rit][num] += 1}
        e[r] = estratti
        e
      end
    end
  end
  return estrazioni,analisi_fr
end

def load_search_set(fname)
  search_set = File.read(fname, :encoding => "BINARY").split("\n")
end

def compute_results(ruota,estrazioni, search_set)
  ruote = [:bari,:cagliari,:firenze,:genova,:milano,:napoli,:palermo,:roma,:torino,:venezia]
  giocate = 0
  giocate_medie_tra_vincite = 0
  num_vincite = 0
  intervallo_max_tra_vincite = 0
  intervallo_min_tra_vincite = estrazioni.size
  keys = search_set.map { |s| s.delete("-").split(" ").map {|n| n.to_i} }
  stats = Hash[keys.zip([0]*keys.length)]
  punteggi = { "2" => 0, "3" => 0, "4" => 0, "5" => 0 }
  estrazioni.each do |e|
    giocate += 1
    keys.each do |k|
      e = e[ruota.to_sym] 
      punti = 5-(e - k).size
      if punti >= 2
        punteggi[punti.to_s] += 1
        stats[k] += 1
        intervallo_max_tra_vincite = giocate if giocate > intervallo_max_tra_vincite
        intervallo_min_tra_vincite = giocate if giocate < intervallo_min_tra_vincite
        giocate_medie_tra_vincite += giocate
        giocate = 0
        num_vincite += 1
      end
    end
  end
  intervallo_max_tra_vincite = giocate if giocate > intervallo_max_tra_vincite
  giocate_trascorse_dall_ultima_vincita = giocate
  puts "Statistiche: #{stats}"
  puts "Punteggi: #{punteggi}"
  puts "Giocate medie tra 2 vincite: #{giocate_medie_tra_vincite/num_vincite.to_f}"
  puts "Totale vincite: #{num_vincite}"
  puts "Giocate trascorse dall'ultima vincita: #{giocate_trascorse_dall_ultima_vincita}"
  puts "Max numero di giocate trascorse tra 2 vincite: #{intervallo_max_tra_vincite}"
  puts "Min numero di giocate trascorse tra 2 vincite: #{intervallo_min_tra_vincite}"
end

estrazioni,analisi_fr = import_storico
search_set = load_search_set(fname)
compute_results(ruota, estrazioni,search_set)
