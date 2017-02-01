# -*- encoding : utf-8 -*-
class PackagePlan < Plan

  PLANS = {
    :free => {
      :name => "Professor Grátis",
      :price => 0,
      :yearly_price => 0,
      :video_storage_limit => 10.megabytes,
      :file_storage_limit => 5.megabytes,
      :members_limit => 30
    },
    :professor_lite => {
      :name => "Professor Lite",
      :price => 13.99,
      :yearly_price => 139.90,
      :membership_fee => 13.99,
      :video_storage_limit => 30.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 70
    },
    :professor_standard => {
      :name => "Professor Standard",
      :price => 56.99,
      :yearly_price => 569.90,
      :membership_fee => 56.99,
      :video_storage_limit => 90.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 100
    },
    :professor_plus => {
      :name => "Professor Plus",
      :price => 243.99,
      :yearly_price => 2439.90,
      :membership_fee => 245.99,
      :video_storage_limit => 150.megabytes,
      :file_storage_limit => 25.megabytes,
      :members_limit => 500
    },
    :instituicao_medio_tiny => {
      :name => "Instituição de Ensino Médio Tiny",
      :price => 600.00,
      :yearly_price => 5000.00,
      :membership_fee => 600.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 200
    },
    :instituicao_medio_lite => {
      :name => "Instituição de Ensino Médio Lite",
      :price => 870.00,
      :yearly_price => 7452.00,
      :membership_fee => 870.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 300
    },
    :instituicao_medio_standard => {
      :name => "Instituição de Ensino Médio Standard",
      :price => 1120.00,
      :yearly_price => 9888.00,
      :membership_fee => 1120.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 400
    },
    :instituicao_medio_plus => {
      :name => "Instituição de Ensino Médio Plus",
      :price => 1250.00,
      :yearly_price => 12000.00,
      :membership_fee => 1250.00,
      :video_storage_limit => 512.megabytes,
      :file_storage_limit => 512.megabytes,
      :members_limit => 500
    }
  }

  validates_presence_of :members_limit, :yearly_price
end
