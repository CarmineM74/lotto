#!/usr/bin/ruby
# encoding: utf-8

require './framework.rb'

@ruota = ARGV[0].downcase.to_sym

puts "Statistiche ambo per la ruota di #{@ruota.to_s.upcase}"
puts "Import storico in corso ..."
estrazioni = import_storico

puts "Totale estrazioni esaminate: #{@num_estrazioni}"

puts "Frequenza decrescente:"
f_ordinata = Hash[(@frequenza.sort_by { |n,f| f }).reverse]
puts dump_freq(f_ordinata)

puts "Numeri ritardatari:"
r_ordinata = Hash[(@ritardi.sort_by { |n,f| f }).reverse]
puts dump_freq(r_ordinata)

puts "Frequenza relativa numeri:"
prob = @frequenza.dup
prob.keys.each { |num| prob[num] /= @num_estrazioni}
prob_ordinata = Hash[(prob.sort_by { |n,f| f }).reverse]
puts dump_freq(prob_ordinata)

piu_freq = f_ordinata.keys.first
piu_rit = r_ordinata.keys.first
puts "(A) Numero piu' frequente: #{piu_freq}"
puts "(B) Maggiore ritardatario: #{piu_rit}"
print "Calcolo frequenza relativa di (A): "
f_a = calcola_freq_a_dato_b(estrazioni, piu_freq, piu_rit)
puts f_a
puts "Frequenza relativa combinata: #{f_a.to_f/f_ordinata[piu_rit]}"

# 38-45-76 Napoli

puts "Calcolo frequenze condizionate col piu' ritardatario ..."
dati = freq_combinate(estrazioni, piu_rit, f_ordinata)
dati.each_slice(4) do |s|
  puts s.join("\t")
end

puts "Calcolo frequenze condizionate col piu' frequente ..."
dati = freq_combinate(estrazioni, piu_freq, f_ordinata)
dati.each_slice(4) do |s|
  puts s.join("\t")
end


