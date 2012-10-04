require 'spec_helper'

describe Authentication do

  before do
    Factory.create(:authentication) # Necessário para a validação de unicidade
  end

  it { should belong_to(:user) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:provider) }
  it { should validate_uniqueness_of(:uid).scoped_to(:provider) }

end
