require 'rails_helper'
require 'database_cleaner/active_record'
require 'win32/process'

RSpec.describe "/quotes create", type: :request, database_cleaner_strategy: :truncation do
  self.use_transactional_tests = false
  self.use_transactional_tests = false

  before do
    DatabaseCleaner.strategy = :truncation

    instrument1 = FactoryBot.build(:instrument, Ticker: "abc1", CompanyName: "ABC")
    instrument2 = FactoryBot.build(:instrument, Ticker: "def1", CompanyName: "DEF")
    instrument3 = FactoryBot.build(:instrument, Ticker: "ghi1", CompanyName: "GHI")
    instrument1.save
    instrument2.save
    instrument3.save
  end

  after do
    DatabaseCleaner.clean
  end

  describe "create" do

    it "posts a quote" do
      # DatabaseCleaner.strategy = :truncation
      post '/quotes', params:
        {
          Ticker: "abc",
          Price: "100.2",
          Timestamp: "2022-07-28 18:18:29.294"
        }

      expect(Quote.count).to eq(1)
      expect(Quote.first.Price).to eq(100.2)
    end

    it "returns Error 422 due to bad parameters" do
      # DatabaseCleaner.strategy = :truncation
      post '/quotes', params:
        {
          Ticker: "abc",
          Price: "100.2",
          Timestamp: "abc"
        }
      expect(response.status).to eq(422)
    end

    it "does a thing and creates a new instrument along side it" do
      # DatabaseCleaner.strategy = :truncation
      post '/quotes', params:
        {
          Ticker: "dogma",
          Price: "100.2",
          Timestamp: "2022-07-28 18:18:29.294"
        }

      expect(Quote.count).to eq(1)
      expect(Quote.first.Price).to eq(100.2)
    end

    it "returns Error 422 due to missing parameters" do
      # DatabaseCleaner.strategy = :truncation
      post '/quotes', params:
        {
          Ticker: "abc",
          Price: "100.2",
        }

      expect(response.status).to eq(422)
    end

    # TODO I don't see why this expects a rollback. Tickers are unique, company names are not but they don't have to be
    #
    # it 'tests transaction' do
    #   # DatabaseCleaner.strategy = :truncation
    #   ActiveRecord::Base.transaction do
    #     instrument1 = FactoryBot.build(:instrument, Ticker: "abc", CompanyName: "DEF")
    #     instrument2 = FactoryBot.build(:instrument, Ticker: "b", CompanyName: "GHI")
    #     instrument1.save!
    #     instrument2.save!
    #
    #     throw 'expect rollback'
    #   end
    # end

    it "creates 2 quotes with the same non-existing ticker at the same time (transactions included)" do
      # DatabaseCleaner.strategy = :truncation
      # This shows how the code would work in case 2 requests with the same non-existing ticker would happen at the same time with the code wrapped in a transaction
      # This contains a replica of the quotes_controller code with some minor adjustments included in the 2 threads
      # We start the first thread and instantly add a blocker (blocker attribute)
      # We start the second thread which initiates a transaction and unblocks the first blocker afterwards
      # We continue the second thread and after adding a delay to make sure everything went through (sleep(2)), we check if the first thread has made any progress
      # thread_1_transaction_started is still false, so it didn't
      # We do some extra minor tests to make sure everything is in order
      # After the 2nd thread's transaction has ended, we wait for 2 seconds and check if the first transaction has made any progress
      # thread_1_transaction_started is now true
      # we double check that there are 2 quotes in the database and that they reference the same instrument

      blocker = Mutex.new
      thread_1_transaction_started = false
      ActiveRecord::Base.connection.disconnect!

      Process.fork do
        print "T2 starts \n"
        ActiveRecord::Base.connection_pool.with_connection do
          print "T2 con established \n"

          ActiveRecord::Base.transaction(isolation: :repeatable_read) do
            print "T2 starting trans \n"
            blocker.lock
            # can't change transaction to isolation: :serializable
            # cannot set transaction isolation in a nested transaction (ActiveRecord::TransactionIsolationError)
            ticker = "new"
            print "t2 find \n"
            instrument = Instrument.find_by_Ticker(ticker)
            print "t2 after find \n"
            thread_1_transaction_started = true
            if instrument.nil?
              instrument = Instrument.new(Ticker: ticker)
              instrument.save!
            end
            instrument.quotes.build(Timestamp: "2022-07-28 18:18:29.294", Price: "100.2").save
            print "tran2 finished \n"
          end
        end
        print "T2 finished \n"
      end

      Process.fork do
        blocker.lock
        print "T1 starts \n"
        ActiveRecord::Base.connection_pool.with_connection do
          ActiveRecord::Base.transaction(isolation: :repeatable_read) do
            # can't change transaction to isolation: :serializable
            # cannot set transaction isolation in a nested transaction (ActiveRecord::TransactionIsolationError)
            ticker = "new"
            print "T1 before find \n"
            instrument = Instrument.find_by_Ticker(ticker)
            blocker.unlock
            if instrument.nil?
              instrument = Instrument.new(Ticker: ticker)
              print "t1 before save\n"
              sleep(3)
              instrument.save!
              print "t1 after save\n"
              sleep(2)
              expect(thread_1_transaction_started).to eq(false)
            end
            expect(Instrument.find_by_Ticker(ticker)).not_to eq(nil)
            instrument.quotes.build(Timestamp: "2022-07-28 18:18:29.294", Price: "100.3").save
            expect(Quote.count).to eq(1)
            expect(thread_1_transaction_started).to eq(false)
            print "tran1 finished\n"
          end
        end
      end
      Process.waitall
      expect(thread_1_transaction_started).to eq(true)
      expect(Quote.count).to eq(2)
      expect(Quote.first.instrument_id).to eq(Quote.second.instrument_id)
      print "T1 finished \n"
    end

    it "creates 2 quotes with the same non-existing ticker at the same time (transactions excluded)" do
      # DatabaseCleaner.strategy = :truncation
      # This shows how the code would work in case 2 requests with the same non-existing ticker would happen at the same time without the transaction
      # Similar concept to the first scenario, except it shows that if both requests assert that there's no instrument with the given ticker and try to create one at the same time
      # then one of the two will be met with an error because the ticker's Unique constraint failed
      blocker1 = true
      blocker2 = true
      thread_1_started = false

      Thread.new {
        true while blocker1
        ticker = "new"
        instrument = Instrument.find_by_Ticker(ticker)
        thread_1_started = true
        if instrument.nil?
          true while blocker2
          instrument = Instrument.new(Ticker: ticker)
          expect { instrument.save! }.to raise_error
        end
      }

      Thread.new {
        ticker = "new"
        blocker1 = false
        instrument = Instrument.find_by_Ticker(ticker)
        if instrument.nil?
          instrument = Instrument.new(Ticker: ticker)
          instrument.save!
          blocker2 = false
          sleep(2)
          expect(thread_1_started).to eq(false)
        end
        expect(Instrument.find_by_Ticker(ticker)).not_to eq(nil)
        instrument.quotes.build(Timestamp: "2022-07-28 18:18:29.294", Price: "100.3").save
        expect(Quote.count).to eq(1)
      }
    end

    it "creates numerous quotes at once" do
      n = 9
      # DatabaseCleaner.strategy = :truncation
      ActiveRecord::Base.connection.disconnect!

      def build_quote(i)
        ticker = "oneto"
        instrument = Instrument.find_by_Ticker(ticker)
        if instrument.nil?
          instrument = Instrument.new(Ticker: ticker)
          instrument.save!
        end
        instrument.quotes.build(Timestamp: "2022-07-28 18:18:29.294", Price: i)
      end

      blocker = true
      (0...n).each { |i|
        Thread.new {
          puts "thread #{i} start"
          ActiveRecord::Base.establish_connection #TODO issue blocking half of the threads... why half?
          true while blocker
          ActiveRecord::Base.transaction(isolation: :repeatable_read) do
            quote = build_quote(i)

            puts quote.save
          end
          # ActiveRecord::Base.connection.disconnect!
          puts "thread #{i} done"
        }
      }
      blocker = false
      sleep(2)
      ActiveRecord::Base.establish_connection
      expect(Instrument.count).to eq(4)
      expect(Quote.count).to eq(n)
    end

    it "uses post to create numerous quotes at once" do
      # DatabaseCleaner.strategy = :truncation
      ActiveRecord::Base.connection.disconnect!
      blocker = true
      for i in 0...500 do
        Thread.new {
          ActiveRecord::Base.establish_connection
          true while blocker
          post '/quotes', params:
            {
              "Timestamp": "2022-07-28 18:18:29.294",
              "Price": "100.5",
              "Ticker": "dsfgs"
            }
        }
      end
      blocker = false
      sleep(5)
      ActiveRecord::Base.establish_connection
      expect(Instrument.count).to eq(4)
      expect(Quote.count).to eq(500)
    end

  end

  # after(:all) do
  #   #because each doesnt work
  #   DatabaseCleaner.clean_with(:truncation)
  # end
end
