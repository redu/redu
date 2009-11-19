class InsertSkills < ActiveRecord::Migration
  def self.up
     mat = Skill.create(:name => 'Matemática')
     nat = Skill.create(:name => 'Ciências Naturais')
     hum = Skill.create(:name => 'Ciências Humanas')
     lin = Skill.create(:name => 'Linguagens')
     
     Skill.create(:name => 'Geometria', :parent => mat)
     Skill.create(:name => 'Trigonometria', :parent => mat)
     Skill.create(:name => 'Álgebra', :parent => mat)
     Skill.create(:name => 'Conjuntos', :parent => mat)
     
     fis = Skill.create(:name => 'Física', :parent => nat)
     Skill.create(:name => 'Química', :parent => nat)
     Skill.create(:name => 'Biologia', :parent => nat)
     
     Skill.create(:name => 'História', :parent => hum)
     Skill.create(:name => 'Geografia', :parent => hum)
     Skill.create(:name => 'Sociologia', :parent => hum)
     Skill.create(:name => 'Filosofia', :parent => hum)
     
     Skill.create(:name => 'Arte', :parent => lin)
     Skill.create(:name => 'Língua Portuguesa', :parent => lin)
     les = Skill.create(:name => 'Línguas Estrangeiras', :parent => lin)
     
     Skill.create(:name => 'Mecânica', :parent => fis)
     Skill.create(:name => 'Eletro-magnética', :parent => fis)
     Skill.create(:name => 'Termo-dinâmica', :parent => fis)
     
     Skill.create(:name => 'Inglês', :parent => les)
     Skill.create(:name => 'Espanhol', :parent => les)
     Skill.create(:name => 'Português', :parent => les)
     
  end

  def self.down
    Skill.delete_all
  end
end
