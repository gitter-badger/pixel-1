require_relative '../../rspec'

describe AdminStatusChangeEvent do

  device = 'gar-bdr-1'
  hw_type = 'CPU'
  index = '1'
  status = 'down'
  time = Time.now.to_i

  event = AdminStatusChangeEvent.new(
    device: device, hw_type: hw_type, index: index, status: status
  )

  # Constructor
  describe '#new' do

    context 'when properly formatted' do
      it 'should return a AdminStatusChangeEvent object' do
        expect(event).to be_a AdminStatusChangeEvent
      end
      it 'should have an accurate time' do
        expect(event.time).to eql time
      end
    end

    context 'when properly formatted with time' do
      custom_time = 1000
      time_event = AdminStatusChangeEvent.new(
        device: 'gar-bdr-1', hw_type: 'CPU', index: '1',
        status: 'test_status', time: custom_time
      )
      it 'should return a AdminStatusChangeEvent object' do
        expect(time_event).to be_a AdminStatusChangeEvent
      end
      it 'should have an accurate time' do
        expect(time_event.time).to eql custom_time
      end
    end

  end


  # device
  describe '#device' do

    it 'should be what was passed in' do
      expect(event.device).to eql device
    end

  end


  # hw_type
  describe '#hw_type' do

    it 'should be what was passed in' do
      expect(event.hw_type).to eql hw_type
    end

  end


  # index
  describe '#index' do

    it 'should be what was passed in' do
      expect(event.index).to eql index
    end

  end


  # subtype
  describe '#subtype' do

    it 'should be correct' do
      expect(event.subtype).to eql 'AdminStatusChangeEvent'
    end

  end


  # status
  describe '#status' do

    it 'should be correct' do
      expect(event.status).to eql status
    end

  end


  # functional tests
  context 'functional tests' do

    int = JSON.load(INTERFACE_1)
    int_data = JSON.parse(INTERFACE_1)["data"]
    int_data["admin_status"] = 2
    int_data["high_speed"] = int_data["speed"] / 1000000
    int_updated = int.dup.update(int_data, worker: 'test')
    func_event = int_updated.events.first

    it 'should not be present before a change' do
      expect(int.events).to be_empty
    end

    it 'should be present when event occurs' do
      expect(func_event).to be_a AdminStatusChangeEvent
    end

    it 'should have the correct status' do
      expect(func_event.status).to eql 'Down'
    end

    it 'should have the correct time' do
      expect(func_event.time).to eql int_updated.last_updated
    end

  end

  context 'saving' do

    before :each do
      JSON.load(DEVTEST_JSON).save(DB)
      int_save = JSON.load(INTERFACE_5)
      int_save_data = JSON.parse(INTERFACE_5)["data"]
      int_save_data["admin_status"] = 1
      int_save_data["high_speed"] = int_save_data["speed"] / 1000000
      int_save_updated = int_save.dup.update(int_save_data, worker: 'test')
      int_save_updated.save(DB)
    end

    after :each do
      DB[:device].where(device: 'test-v11u3-acc-y').delete
    end

    it 'should be saved' do
      saved_event = ComponentEvent.fetch(
        device: 'test-v11u3-acc-y', hw_type: 'interface',
        index: '10119', types: [ 'AdminStatusChangeEvent' ]
      ).first
      expect(saved_event).to be_a AdminStatusChangeEvent
      expect(saved_event.status).to eql 'Up'
    end

  end

end
