class PlansController < BaseController
  load_and_authorize_resource

  def confirm
    @order = @plan.create_order

    respond_to do |format|
      format.html
    end
  end

  def address
  end

  def pay
  end
end
