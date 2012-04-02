require "benchmark"

ActiveRecord::Base.logger = Logger.new STDOUT

subject = Subject.find(977)
user = User.find_by_login('guiocavalcanti')

Benchmark.bm do |x|
  x.report("criando 3 lectures num space com 60 users") do
    3.times do
      subject.lectures << Factory(:lecture, :owner => user, :subject => subject)
    end
  end
end
