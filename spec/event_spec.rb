require_relative 'rspec'

describe Event do

  time = 1000
  time_string = time.to_s
  event = Event.new(time: time)

  # Constructor
  describe '#new' do

    context 'with a manual integer time' do
      it 'should have an accurate time' do
        expect(event.time).to eql time
      end
    end

    context 'with a manual string time' do
      it 'should have an accurate time' do
        time_string_event = Event.new(time: time_string)
        expect(time_string_event.time).to eql 1000
      end
    end

    context 'with an invalid time' do
      it 'should raise TypeError' do
        expect{Event.new(time: 'abcd')}.to raise_error TypeError
      end
    end

    context 'when missing time' do
      it 'should raise an ArgumentError' do
        expect{event = Event.new}.to raise_error ArgumentError
      end
    end

  end


  # time
  describe '#time' do

    it 'should be an Integer' do
      expect(event.time).to be_a Integer
    end

  end


  # id
  describe '#id' do

    context 'when freshly created' do

      it 'should be nil' do
        expect(event.id).to eql nil
      end

    end

=begin
    context 'when saved' do

      it 'should be an integer' do
        expect().to be_a Numeric
      end

    end
=end

  end


end