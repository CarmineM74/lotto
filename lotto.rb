#!/usr/bin/ruby

class Integer
   def fact
     return 1 if self == 0
     (1..self).inject { |i,j| i*j }
   end
 end

puts "Sistema sofisticato per il Super Enalotto"
numeri = (1..90).to_a
colonne = (1..90).inject([]) do |a,v| a << numeri.delete_at(rand * numeri.size) end

puts "Colonne"
sistema = []
(1..15).each do |x|
  #puts "Colonna " + x.to_s
  colonna = (colonne[(x-1)*6..(((x-1)*6)+5)].map { |n| "%.2d"%(n) }.join(' '))
  puts colonna
  sistema << colonna
end

puts "\nSistema\n"
ctot = 36.fact/(6.fact * 30.fact)
rrt = 181.0
rapporto = ctot / rrt
puts "Combinazioni totali: #{ctot}"
puts "RRT (ridotto): (gr*(n-gr))+1: #{rrt}"
puts "Rapporto di riduzione: #{rapporto}"
puts "Nr colonne sistema ridotto: #{rapporto.ceil}" 
(1..6).each do |x|
  indice = (rand * sistema.size)
  puts sistema.delete_at(indice)
end

puts "\nNumeri di Vincenzo"
#numeri = [ '07', '10', '31', '33', '35', '37', '39', '42', '44', '48', '74', '76', '82', '17', '41', '67', '75', '81', '89', '26', '05', '15', '12', '01', '27', '49', '53', '65', '14', '38', '90', '83', '66', '51', '77', '84']
numeri = [ '01', '02', '05', '06', '07', '09', '10', '12', '15', '17', '26', '30', '33', '35', '37', '39', '42', '45', '44', '48', '49', '50', '62', '69', '70', '74', '76', '78', '82', '59', '81', '89', '18', '31', '77', '90', '25', '53', '55', '63']

(1..30).each do |c|
  riga = []
  numeri_work = numeri.dup
  numeri_work.shuffle!
  (1..6).each do |r|
    riga << numeri_work.delete_at(rand * numeri_work.size)
  end
  puts riga.join(' ')
end
