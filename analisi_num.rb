#!/Users/carminemoleti/.rvm/rubies/ruby-1.9.3-p194/bin/ruby
require './framework.rb'

@ruota = ARGV[0].downcase.to_sym
@num = ARGV[1].to_i

puts "Import storico in corso ..."
estrazioni = import_storico
puts "Totale estrazioni esaminate: #{@num_estrazioni}"
puts "Calcolo frequenze e ritardi ..."
f_ordinata = Hash[(@frequenza.sort_by { |n,f| f }).reverse]
r_ordinata = Hash[(@ritardi.sort_by { |n,f| f }).reverse]
puts "Calcolo probabilita' combinata ..."
prob = @frequenza.dup
prob.keys.each { |num| prob[num] /= @num_estrazioni}
prob_ordinata = Hash[(prob.sort_by { |n,f| f }).reverse]
piu_freq = f_ordinata.keys.first
piu_rit = r_ordinata.keys.first

puts "Analisi per il numero #{@num} sulla ruota di #{@ruota} ..."

analisi = { freq_decina: { } }
(0..9).each { |x| analisi[:freq_decina][x.to_s] ||= 0 }
estrazioni.each do |e|
  if e[:estratti].include?(@num)
    ns = e[:estratti] - [@num]
    ns.each { |n| analisi[:freq_decina][(n/10).to_i.to_s] += 1 }
  end
end

puts "Frequenza per decina ..."
analisi[:freq_decina] = analisi[:freq_decina].sort_by { |k,v| v }.reverse
analisi[:freq_decina].each do |d,freq|
  puts "Decina: #{d} - Freq: #{freq}"
end

(1..3).each do |dec|
  decina = analisi[:freq_decina].shift.first.to_i
  decina = ((decina*10)..((decina*10)+9))
  offsets = (1..3).map { |x| decina.min + Random.rand(9) }
  puts "Decine abbinabili #{dec}: #{decina}"
  puts "#{@num} - #{offsets.join(',')}"
  offsets.each do |o|
    eventi,rmin,rmax,rm,std_dev = statistiche_ritardo(estrazioni,o)
    puts "Statistiche ritardo #{o}:"
    puts "\tmin: #{rmin}\t max: #{rmax}\t med: #{rm}\t st_dev: #{std_dev}"
  end
end



