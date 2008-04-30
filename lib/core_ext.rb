class Array
  def sum
    inject(0) do |sum, each|
      block_given? ? sum + yield(each) : sum + each
    end
  end
end
