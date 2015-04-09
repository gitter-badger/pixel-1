require_relative 'rspec'

describe Fan do

  json_keys = [ 'device', 'index', 'description', 'last_updated',
                'status', 'vendor_status', 'status_text', 'worker' ]

  data1_base = {"device" => "gar-b11u1-dist", "index" => "4.1.1.1", "description" => "FAN 0 @ 0/0/0", "last_updated" => 1427164532, "status" => 1, "vendor_status" => 2, "status_text" => "OK"}
  data2_base = {"device" => "gar-b11u17-acc-g", "index" => "1004", "description" => "Switch#1,  Fan#1", "last_updated" => 1427164623, "status" => 1, "vendor_status" => 1, "status_text" => "OK"}
  data3_base = {"device" => "iad1-trn-1", "index" => "1.1", "description" => "PSU 1.1", "last_updated" => 1427164801, "status" => 1, "vendor_status" => 1, "status_text" => "OK"}

  data1_update_ok = {
    "device" => "gar-b11u1-dist",
    "index" => "4.1.1.1",
    "description" => "FAN 0 @ 0/0/0",
    "last_updated" => 1427164532,
    "status" => 1,
    "vendor_status" => 2,
    "status_text" => "OK" }
  data2_update_ok = {
    "device" => "gar-b11u17-acc-g",
    "index" => "1004",
    "description" => "Switch#1,  Fan#1",
    "last_updated" => 1427164623,
    "status" => 1,
    "vendor_status" => 1,
    "status_text" => "OK" }
  data3_update_ok = {
    "device" => "iad1-trn-1",
    "index" => "1.1",
    "description" => "PSU 1.1",
    "last_updated" => 1427164901,
    "status" => 1,
    "vendor_status" => 1,
    "status_text" => "OK" }

  # Constructor
  describe '#new' do

    context 'with good data' do
      it 'should return a Fan object' do
        fan = Fan.new(device: 'gar-test-1', index: 103)
        expect(fan).to be_a Fan
      end
    end

  end


  # populate
  describe '#populate' do

    before :each do
      @bad_fan = Fan.new(device: 'gar-test-1', index: 'test')
      @good_fan = Fan.new(device: 'iad1-bdr-1', index: '4.1.4.0')
    end


    it 'should return nil if the object does not exist' do
      expect(@bad_fan.populate).to eql nil
    end

    it 'should return an object if the object exists' do
      expect(@good_fan.populate).to be_a Fan
    end

    it 'should fill up the object' do
      expect(JSON.parse(@good_fan.populate(data1_base).to_json)['data'].keys).to eql json_keys
    end


  end


  # update
  describe '#update' do

    context 'when freshly created' do

      before(:each) do
        @fan = Fan.new(device: 'gar-test-1', index: '103')
      end


      it 'should return a Fan object' do
        expect(@fan.update(data1_update_ok, worker: 'test')).to be_a Fan
      end

    end


    context 'when populated' do

      before(:each) do
        @fan = Fan.new(device: 'gar-b11u1-dist', index: '7.1.0.0').populate(data1_base)
        @fan2 = Fan.new(device: 'gar-k11u1-dist', index: '1').populate(data2_base)
        @fan3 = Fan.new(device: 'gar-k11u1-dist', index: '1').populate(data3_base)
      end


      it 'should return a Fan object' do
        expect(@fan.update(data1_update_ok, worker: 'test')).to be_a Fan
        expect(@fan2.update(data2_update_ok, worker: 'test')).to be_a Fan
        expect(@fan3.update(data3_update_ok, worker: 'test')).to be_a Fan
      end

    end

  end

  # to_json
  describe '#to_json and #json_create' do

    context 'when freshly created' do

      before(:each) do
        @fan = Fan.new(device: 'gar-test-1', index: '103')
      end


      it 'should return a string' do
        expect(@fan.to_json).to be_a String
      end

      it 'should serialize and deserialize' do
        json = @fan.to_json
        expect(JSON.load(json)).to be_a Fan
        expect(JSON.load(json).to_json).to eql json
      end

    end


    context 'when populated' do

      before(:each) do
        @fan1 = Fan.new(device: 'gar-b11u1-dist', index: '4.1.1.1').populate
        @fan2 = Fan.new(device: 'iad1-bdr-1', index: '4.1.4.0').populate
        @fan3 = Fan.new(device: 'gar-k11u1-dist', index: '1').populate
        @fan4 = Fan.new(device: 'iad1-trn-1', index: '2.1').populate
      end


      it 'should serialize and deserialize properly' do
        json1 = @fan1.to_json
        json2 = @fan2.to_json
        json3 = @fan3.to_json
        json4 = @fan4.to_json
        expect(JSON.load(json1).to_json).to eql json1
        expect(JSON.load(json2).to_json).to eql json2
        expect(JSON.load(json3).to_json).to eql json3
        expect(JSON.load(json4).to_json).to eql json4
      end

    end

  end


end