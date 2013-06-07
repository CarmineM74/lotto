# encoding: utf-8
require 'time'

def dump_freq(freqs)
  count = 0
  f = freqs.keys.map do |num|
    count += 1
    "%.2d : %.2f #{((count%10)==0) ? "\n" : " - "}"%[num, freqs[num]]
  end
  f.join
end

@frequenza = (1..90).inject({}) { |a,v| a[v] = 0; a }
@ritardi = (1..90).inject({}) { |a,v| a[v] = 0; a }

@num_estrazioni = 0.0
def import_storico()
  ruote = [:bari,:cagliari,:firenze,:genova,:milano,:napoli,:palermo,:roma,:torino,:venezia]
  estrazioni = []
  riga_re =Regexp.new(/^(\d*?)\s\-\s(\d\d\/\d\d\/\d\d\d\d)\s\|\s(.*)/)
  Dir.glob("estrazioni*.txt").each do |archivio|
    puts "Anno #{archivio.delete("estrazioni").split(".")[0]}"
    dati = File.read(archivio, :encoding => "BINARY").split("\n")
    dati = dati[4..-4]
    dati.each do |riga|
      begin
        # 41 - 04/04/2013 | 60-58-23-27-30 | 32-81-13-16-84 | ... 
        m = riga_re.match(riga)
        unless m.nil?
          progressivo,data,estr = *m[1..2],m[3].delete('|').split(' ')
          estr_ruota = estr[ruote.index(@ruota)]
          estratti = estr_ruota.split("-")
          estratti = estratti.map { |num| num.to_i }
          estrazione = {progressivo: progressivo, data: Date.parse(data), estratti: estratti}
          estrazioni << estrazione
        end
        @num_estrazioni += 1.0
      rescue Exception => e
        puts riga
        puts e.message
      end
    end
    estrazioni = estrazioni.sort_by { |e| e[:data] }
    estrazioni.each do |e|
      estratti = e[:estratti]
      estratti.each { |num| @frequenza[num] += 1 }
      estratti.each { |num| @ritardi[num] = 0 }
      ritardatari = ((1..90).map{|n| n})-estratti
      ritardatari.each { |r| @ritardi[r] += 1}
    end
  end
  estrazioni
end

def calcola_freq_a_dato_b(estrazioni, a, b)
  f_a = 0
  estr_b = estrazioni.map { |estr| estr[:estratti] if estr[:estratti].include?(b) }
  estr_b.uniq!.compact!
  estr_b.each do |estr|
    f_a += 1 if estr.include?(a)
  end
  f_a
end

def freq_combinate(estrazioni, riferimento, f_ordinata)
  f_condizionate = {}
  (1..90).each do |num|
    unless num == riferimento
      f_n = calcola_freq_a_dato_b(estrazioni, num, riferimento)
      f_condizionate["#{riferimento} - #{num}"] = f_n.to_f / f_ordinata[riferimento]
    end
  end
  f_condizionate_ordinate = Hash[(f_condizionate.sort_by { |n,f| f }).reverse]
  dati = []
  f_condizionate_ordinate.keys.each do |ambo|
    dati << "#{ambo}: %.3f"%(f_condizionate_ordinate[ambo])
  end
  dati
end

def statistiche_ritardo(estrazioni,num)
  ritardi = (1..90).inject({}) { |a,v| a[v] = 0; a }
  eventi_ritardo = []
  estrazioni.each do |estr|
    estratti = estr[:estratti]
    ritardatari = (1..90).to_a-estratti
    unless ritardatari.include?(num)
      eventi_ritardo << ritardi[num] #unless ritardi[num] == 0
      ritardi[num] = 0
    else
      ritardi[num] += 1
    end
  end
  eventi_ritardo << ritardi[num] #unless ritardi[num] == 0
  ritardo_medio = eventi_ritardo.inject(0.0) { |a,v| a += v; a } / eventi_ritardo.length
  ritardo_minimo = eventi_ritardo.uniq.sort[1]
  ritardo_massimo = eventi_ritardo.sort.last
  sommatoria = eventi_ritardo.inject(0.0) { |a,v| a += (v*v)-(ritardo_medio**2); a}
  st_dev = Math.sqrt((1.0/eventi_ritardo.length)*(sommatoria))
  return eventi_ritardo, ritardo_minimo, ritardo_massimo, ritardo_medio, st_dev
end
