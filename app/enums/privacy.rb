class Privacy < ClassyEnum::Base
end

class Privacy::Public < Privacy
end

class Privacy::Friends < Privacy
end
