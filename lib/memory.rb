# memory.rb
#
require 'logger'
require 'json'
require_relative 'api'
require_relative 'core_ext/object'
$LOG ||= Logger.new(STDOUT)

class Memory


  def initialize(device:, index:)

    # required
    @device = device
    @index = index

  end
  

  def populate(data=nil)

    # If we weren't passed data, look ourselves up
    data ||= API.get('core', "/v1/device/#{@device}/memory/#{@index}", 'Memory', 'memory data')
    # Return nil if we didn't find any data
    # TODO: Raise an exception instead?
    return nil if data.empty?

    @util = data['util'].to_i
    @description = data['description']
    @last_updated = data['last_updated'].to_i

    return self
  end


  def update(data)

    # TODO: Data validation? See mac class for example

    new_util = data['util'].to_i
    new_description = data['description'] || "Memory #{@index}"
    current_time = Time.now.to_i

    @util = new_util
    @description = new_description
    @last_updated = current_time

    return self
  end


  def to_json(*a)
    {
      "json_class" => self.class.name,
      "data" => {
        "device" => @device,
        "index" => @index,
        "util" => @util,
        "description" => @description,
        "last_updated" => @last_updated,
      }
    }.to_json(*a)
  end


end
