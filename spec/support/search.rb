# -*- encoding : utf-8 -*-
module SearchSpecHelper
  def mock_search_perform(collection, klass)
    # Necessário para a chamada da paginação na view
    collection.stub!(:total_count).and_return(1)
    collection.stub!(:current_page).and_return(1)
    collection.stub!(:num_pages).and_return(1)
    collection.stub!(:limit_value).and_return(1)
    collection.stub!(:total_pages).and_return(1)

    # Stub para resultado da busca com o sunspot
    klass.stub_chain(:perform, :results).and_return(collection)
  end
end
