#TODO: ensure tags are url friendly
class Tag
  include Mongoid::Document
  field :name
  # has_one :list
  embedded_in :list

  def self.grouped
    map = %Q{
      function () {
        emit(this.name, {count: 1});
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {count: 0};
        values.forEach(function(value) {
          result.count += value.count;
        });
        return result;
      }
    }
    self.all.
      map_reduce(map, reduce).out(inline: true)
  end
end
