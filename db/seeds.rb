# ['elliott', 'hector', 'red', 'kachun'].each do |name|
#   u = User.create email: "#{name}@riothq.com", password: "testing"  
#   [1..5].each do |n|
#     site = u.sites.create :url => "#{name}-#{n}.getforge.io"
#   end
# end

# Site.all.each do |site|
#   start = 2.months.ago
#   today = Time.now
#   difference = today - start
  
#   bytes = rand * 100.megabytes
  
#   100.times do |usage|
#     date = start + rand * difference
#     site.add_usage bytes, date
#   end
# end