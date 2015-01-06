module BSON
  class ObjectId
    def as_json(*)
      to_s
    end
  end
end
