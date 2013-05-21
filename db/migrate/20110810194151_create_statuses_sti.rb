# -*- encoding : utf-8 -*-
class CreateStatusesSti < ActiveRecord::Migration
  def self.up
    change_table(:statuses) do |t|
      # Atributos compartilhados entre todos
      t.remove :log
      t.remove :kind
      t.remove :logeable_name
      t.column :type, :string
      t.rename :log_action, :action
    end

    add_index :statuses, [:statusable_type, :statusable_id]
    add_index :statuses, [:in_response_to_id, :in_response_to_type],
      :name => :statuses_on_response_to_id_and_response_to_type_ix
    add_index :statuses, [:logeable_id, :logeable_type]
  end

  def self.down
    remove_index :statuses, [:statusable_type, :statusable_id]
    remove_index :statuses,
      :name => :statuses_on_response_to_id_and_response_to_type_ix
    remove_index :statuses, [:logeable_id, :logeable_type]

    change_table(:statuses) do |t|
      # Atributos compartilhados entre todos
      t.column :log, :boolean, :default => false
      t.column :kind, :integer
      t.remove :type
      t.rename :action, :log_action
    end
  end
end
