class ResponderWithPutContent < ActionController::Responder
  def api_behavior(*args, &block)
    if put?
      display resource, status: :ok
    else
      super
    end
  end
end
