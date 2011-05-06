def create_privacies
  Privacy.create(:name => 'public')
  Privacy.create(:name => 'friends')
end
