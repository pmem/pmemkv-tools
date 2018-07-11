require '../../pmemkv-ruby/lib/pmemkv/kv_engine'

COUNT = 1000000
FILE = '/dev/shm/pmemkv'

def test_engine(engine, value)
  puts "\nTesting #{engine} engine for #{COUNT} keys, value size is #{value.length}..."
  File.delete(FILE) if File.exist?(FILE)
  kv = KVEngine.new(engine, FILE, 1024 * 1024 * 1024)

  puts "Put (sequential)"
  t1 = Time.now
  COUNT.times do |i|
    kv.put(i.to_s, value)
  end
  puts "   in #{Time.now - t1} sec"

  puts "Get (sequential)"
  failures = 0
  t1 = Time.now
  COUNT.times do |i|
    failures += 1 if kv.get(i.to_s).nil?
  end
  puts "   in #{Time.now - t1} sec, failures=#{failures}"

  puts "Exists (sequential)"
  failures = 0
  t1 = Time.now
  COUNT.times do |i|
    failures += 1 unless kv.exists(i.to_s)
  end
  puts "   in #{Time.now - t1} sec, failures=#{failures}"

  puts "Each (natural)"
  failures = COUNT
  t1 = Time.now
  kv.each {|k, v| failures -= 1}
  puts "   in #{Time.now - t1} sec, failures=#{failures}"

  kv.close
end

# test all engines for all keys & values
test_engine('blackhole', 'AAAAAAAAAAAAAAAA')
test_engine('kvtree2', 'AAAAAAAAAAAAAAAA')
test_engine('btree', 'AAAAAAAAAAAAAAAA')

puts "\nFinished!\n\n"
