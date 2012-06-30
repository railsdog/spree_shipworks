require 'spec_helper'

module SpreeShipworks
  describe Orders do
    context '#since' do
      let(:date)  { DateTime.now }
      let(:order_scope)       { mock('order_scope') }
      let(:where_date_scope)  { mock('where_date_scope') }
      let(:where_state_scope) { mock('where_state_scope') }

      before(:each) do
        Spree::Order.should_receive(:where).
          with(:state => SpreeShipworks::Orders::VALID_STATES).
          and_return(where_state_scope)

        where_state_scope.should_receive(:order).
          with('updated_at asc').
          and_return(order_scope)
      end

      context 'without a date argument' do
        it 'should return the correct scope' do
          Orders.since.should == order_scope
        end
      end

      context 'with an invalid date argument' do
        it 'should raise an ArgumentError' do
          lambda { Orders.since('blargh') }.should raise_error(ArgumentError)
        end
      end

      context 'with a date argument' do
        it 'should return the correct scope' do
          order_scope.should_receive(:where).
            with('updated_at > ?', DateTime.parse(date.to_s)).
            and_return(where_date_scope)

          Orders.since(date).should == where_date_scope
        end
      end
    end

    context '#since_in_batches' do
      let(:date_string) { '2012-01-01T00:00:00' }
      let(:maxcount_string) { '2' }

      it 'should raise an error if a block is not provided' do
        lambda { Orders.since_in_batches(date_string, maxcount_string) }.should raise_error(ArgumentError, /block/)
      end

      it 'should raise an error if the date can not be parsed' do
        lambda { Orders.since_in_batches(nil, maxcount_string) { |orders| break } }.should raise_error(ArgumentError, /start/)
      end

      it 'should raise an error if the maxcount is not an integer' do
        lambda { Orders.since_in_batches(date_string, nil) { |orders| break } }.should raise_error(ArgumentError, /maxcount/)
      end

      context 'with valid arguments' do
        def order(date_time)
          parsed_date_time = DateTime.parse(date_time)
          result = mock("order created at #{DateTime.now} updated at #{parsed_date_time}")
          result.stub(:updated_at).and_return(parsed_date_time)
          result
        end

        let(:date)              { DateTime.parse(date_string) }
        let(:maxcount)          { maxcount_string.to_i }
        let(:relation_scope)    { mock('relation_scope') }
        let(:limit_scope)       { mock('limit_scope') }
        let(:offset_scope)      { mock('offset_scope') }
        let(:orders) {[
          order(date.to_s),
          order(date.to_s),
          order(date.next_day.to_s),
          order(date.next_day.to_s),
          order(date.next_day.next_day.to_s),
          order(date.next_day.next_day.to_s)
        ]}

        before(:each) do
          Orders.should_receive(:since).
            with(date).and_return(relation_scope)

          relation_scope.should_receive(:limit).
            with(maxcount).
            and_return(limit_scope)

          limit_scope.should_receive(:offset).
            with(0).
            and_return(offset_scope)
        end

        context 'when there are fewer orders than requested' do
          it 'should return all the orders' do
            offset_scope.should_receive(:all).
              and_return(orders[0..0])

            counter = 0
            Orders.since_in_batches(date_string, maxcount_string) do |order|
              counter += 1
            end
            counter.should == 1
          end
        end

        context 'when there are exactly the requested number of orders available' do
          it 'should return all the orders' do
            offset_scope.should_receive(:all).
              and_return(orders[0..1])

            limit_scope.should_receive(:offset).
              with(maxcount).
              and_return(offset_scope)

            offset_scope.should_receive(:all).
              and_return(orders[2..3])

            counter = 0
            Orders.since_in_batches(date_string, maxcount_string) do |order|
              counter += 1
            end
            counter.should == maxcount
          end
        end

        context 'when there are no orders for the requested time' do
          it 'should not return any orders' do
            offset_scope.should_receive(:all).
              and_return([])

            counter = 0
            Orders.since_in_batches(date_string, maxcount_string) do |order|
              counter += 1
            end
            counter.should == 0
          end
        end

        context 'when requested orders have dates that cross the limit boundry' do
          let(:maxcount_string) { '3' }

          it 'should return the correct amount of orders' do
            offset_scope.should_receive(:all).
              and_return(orders[0..2])

            limit_scope.should_receive(:offset).
              with(maxcount).
              and_return(offset_scope)

            offset_scope.should_receive(:all).
              and_return(orders[3..5])

            counter = 0
            Orders.since_in_batches(date_string, maxcount_string) do |order|
              counter += 1
            end
            counter.should == 4
          end
        end
      end
    end
  end
end
