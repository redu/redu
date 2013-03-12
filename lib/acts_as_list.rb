module ActsAsList
  # Provê um comportamento de lista em relação a um determinado escopo.
  #
  # Uma implementação mínima pode ser:
  #
  # class Item
  #   include ActsAsList
  #   acts_as_list :scope => :todo_list_id
  # end

  extend ActiveSupport::Concern

  included do
    before_create :update_position
  end

  module ClassMethods
    # Adiciona métodos para consultar informações da lista na qual
    # o elemento está inserido.
    #
    # :scope => Atributo que define qual o escopo da lista
    #   na qual o elemento está inserido.
    def acts_as_list(opts={})
      cattr_accessor :acts_as_list_scope_id
      self.acts_as_list_scope_id = opts[:scope]

      extend ClassMethodsActsAsList
      include InstanceMethodsActsAsList
    end
  end

  module ClassMethodsActsAsList
    # Escopo que retorna a lista de itens ordenados pela posição
    def acts_as_list_scope(scope_id)
      self.where(
        "#{self.table_name}.#{self.acts_as_list_scope_id}" => scope_id).
        order("#{self.table_name}.position")
    end
  end

  module InstanceMethodsActsAsList
    # Retorna +true+ se o item em questão for o último da lista
    def last_item?
      self.acts_as_list_scope.last == self
    end

    # Retorna +true+ se o item em questão for o primeiro da lista
    def first_item?
      self.acts_as_list_scope.first == self
    end

    # Retorna o último item da lista
    def last_item
      self.acts_as_list_scope.last
    end

    # Retorna o primeiro item da lista
    def first_item
      self.acts_as_list_scope.first
    end

    # Retorna o próximo item da lista
    #
    # Retorna +nil+ se o item atual for o último da lista
    def next_item
      items = self.acts_as_list_scope
      index = items.index(self)
      items[index + 1]
    end

    # Retorna o item anterior da lista
    #
    # Retorna +nil+ se o item atual for o primeiro da lista
    def previous_item
      items = self.acts_as_list_scope
      index = items.index(self)
      index == 0 ? nil : items[index - 1]
    end

    # Retorna o item com a posição +offset+ em relação ao item atual
    #
    # Exemplo:
    #   @todo = Todo.create
    #   @todo_2 = Todo.create
    #   @todo.item_at_offset(1) # returns @todo_2
    #   @todo_2.item_at_offset(-1) # returns @todo
    #
    def item_at_offset(offset)
      items = self.acts_as_list_scope
      item_index = items.index(self)
      index = item_index + offset
      index < 0 ? nil : items[index]
    end

    protected

    # Atualiza a posição do item a ser criado
    def update_position
      items = self.acts_as_list_scope
      if items.length == 0
        self.position = 1
      else
        self.position = items.last.position + 1
      end
    end

    # Método auxiliar para invocar o escopo que retorna a lista
    def acts_as_list_scope
      scope_id = self.send(self.class.acts_as_list_scope_id)
      self.class.acts_as_list_scope(scope_id)
    end
  end
end
