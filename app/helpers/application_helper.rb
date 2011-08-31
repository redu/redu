module ApplicationHelper
  # Helpers usados pelo gem de navegação (simple-navigation)
  CREATE_ACTIONS = ['new', 'create']
  def create_action_matcher(controller, &additional_condition)
    action_matcher(controller, CREATE_ACTIONS, &additional_condition)
  end

  EDIT_ACTIONS = ['edit', 'update']
  def update_action_matcher(controller, &additional_condition)
    action_matcher(controller, EDIT_ACTIONS, &additional_condition)
  end

  def action_matcher(controller, action, &additional_condition)
    controllers = Array(controller)
    actions = Array(action)
    lambda do
      controllers.include?(controller_name) &&
        actions.include?(action_name) &&
        ( additional_condition.nil? ? true : additional_condition.call )
    end
  end
end
