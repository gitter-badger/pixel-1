#
# Pixel is an open source network monitoring system
# Copyright (C) 2016 all Pixel contributors!
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# temperature.rb
#
require 'logger'
require 'json'
require_relative '../component'
require_relative '../core_ext/object'
$LOG ||= Logger.new(STDOUT)

class Temperature < Component


  def initialize(device:, index:)
    super(device: device, index: index, hw_type: 'Temperature')
  end


  def temp
    @temperature
  end


  def status_text
    @status_text
  end


  def populate(data)
    # If parent's #populate returns nil, return nil here also
    return nil unless super

    # Required in order to accept symbol and non-symbol keys
    data = data.symbolize

    @temperature = data[:temperature].to_i_if_numeric
    @status = data[:status].to_i_if_numeric
    @threshold = data[:threshold].to_i_if_numeric
    @vendor_status = data[:vendor_status].to_i_if_numeric
    @status_text = data[:status_text]

    return self
  end


  def update(data, worker:)
    # TODO: Data validation? See mac class for example

    super

    new_temperature = data['temperature'].to_i_if_numeric
    new_status = data['status'].to_i_if_numeric
    new_threshold = data['threshold'].to_i_if_numeric
    new_vendor_status = data['vendor_status'].to_i_if_numeric
    new_status_text = data['status_text']

    @temperature = new_temperature
    @status = new_status
    @threshold = new_threshold
    @vendor_status = new_vendor_status
    @status_text = new_status_text

    return self
  end


  def get_influxdb
    [{
      series: 'temperature',
      tags: { device: @device, index: @index, name: @description },
      values: { value: @temperature },
      timestamp: @last_updated
    }]
  end


  def save(db)
    begin
      super # Component#save

      data = { :component_id => @id }
      data[:temperature] = @temperature if @temperature
      data[:status] = @status if @status
      data[:threshold] = @threshold if @threshold
      data[:vendor_status] = @vendor_status if @vendor_status
      data[:status_text] = @status_text if @status_text

      existing = db[:temperature].where(:component_id => @id)
      if existing.update(data) != 1
        db[:temperature].insert(data)
      end
    rescue Sequel::NotNullConstraintViolation, Sequel::ForeignKeyConstraintViolation => e
      $LOG.error("PSU: Save failed. #{e.to_s.gsub(/\n/,'. ')}")
      return nil
    end

    return self
  end


  def to_json(*a)
    hash = {
      "json_class" => self.class.name,
      "data" => {}
    }

    hash['data']["temperature"] = @temperature if @temperature
    hash['data']["status"] = @status if @status
    hash['data']["threshold"] = @threshold if @threshold
    hash['data']["vendor_status"] = @vendor_status if @vendor_status
    hash['data']["status_text"] = @status_text if @status_text
    hash['data'].merge!( JSON.parse(super)['data'] )

    hash.to_json(*a)
  end


  def self.json_create(json)
    data = json["data"]
    Temperature.new(device: data['device'], index: data['index']).populate(data)
  end


end
