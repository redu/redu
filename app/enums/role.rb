# -*- encoding : utf-8 -*-
class Role < ClassyEnum::Base
end

class Role::Admin < Role
end

class Role::Member < Role
end

class Role::EnvironmentAdmin < Role
end

class Role::Teacher < Role
end

class Role::Tutor < Role
end
