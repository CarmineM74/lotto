#!/usr/bin/ruby

require './framework.rb'

fname = ARGV[0]
@ruota = ARGV[1].downcase.to_sym

def load_search_set(fname)
  search_set = File.read(fname, :encoding => "BINARY").split("\n")
end

def compute_results(estrazioni, search_set)
  giocate = 0
  giocate_medie_tra_vincite = 0
  num_vincite = 0
  intervallo_max_tra_vincite = 0
  intervallo_min_tra_vincite = estrazioni.size
  keys = search_set.map { |s| s.delete("-").split(" ").map {|n| n.to_i} }
  stats = Hash[keys.zip([0]*keys.length)]
  estrazioni.each do |e|
    giocate += 1
    keys.each do |k|
      punti = 5-(e[:estratti] - k).size
      if punti >= 2
        stats[k] += 1
        intervallo_max_tra_vincite = giocate if giocate > intervallo_max_tra_vincite
        intervallo_min_tra_vincite = giocate if giocate < intervallo_min_tra_vincite
        giocate_medie_tra_vincite += giocate
        giocate = 0
        num_vincite += 1
        puts "#{e[:data]} Punti: #{punti} Lunghetta: #{k} Estratti: #{e[:estratti]}"
      end
    end
  end
  intervallo_max_tra_vincite = giocate if giocate > intervallo_max_tra_vincite
  giocate_trascorse_dall_ultima_vincita = giocate
  p stats
  puts "Giocate medie tra 2 vincite: #{giocate_medie_tra_vincite/num_vincite.to_f}"
  puts "Totale vincite: #{num_vincite}"
  puts "Giocate trascorse dall'ultima vincita: #{giocate_trascorse_dall_ultima_vincita}"
  puts "Max numero di giocate trascorse tra 2 vincite: #{intervallo_max_tra_vincite}"
  puts "Min numero di giocate trascorse tra 2 vincite: #{intervallo_min_tra_vincite}"
end

estrazioni = import_storico
search_set = load_search_set(fname)
compute_results(estrazioni,search_set)
