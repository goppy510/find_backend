# frozen_string_literal: true

class CategoryRepository
  class << self
    def fetch_all
      Category.select('name').all
    end
  end
end
