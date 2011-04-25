def create_privacies
  # Necessário devido o act_as_enumeration
  Privacy.enumeration_model_updates_permitted = true
  Privacy.create(:name => 'public')
  Privacy.create(:name => 'friends')
  Privacy.enumeration_model_updates_permitted = false
end
